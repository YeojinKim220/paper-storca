#!/usr/bin/env bash
set -euo pipefail

# Single-command workflow to commit/push changes, conditionally deploy Paper Studio,
# and upload the latest PaperGraph snapshot + assets to Paper Studio.

MANUSCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STUDIO_DIR="${PAPER_STUDIO_DIR:-$(cd "$MANUSCRIPT_DIR/../paper-studio" && pwd)}"
URL="${PAPER_STUDIO_URL:-https://paper-studio.our-departure.workers.dev}"
SLUG="${PAPER_STUDIO_SLUG:-storca}"

SECRETS_FILE="${PAPER_STUDIO_SECRETS_FILE:-$HOME/.paper-studio-secrets}"
if [[ -f "$SECRETS_FILE" && ( -z "${CLOUDFLARE_API_TOKEN:-}" || -z "${PAPER_SYNC_TOKEN:-}" ) ]]; then
  _prev_cf="${CLOUDFLARE_API_TOKEN:-}"
  _prev_sync="${PAPER_SYNC_TOKEN:-}"
  # shellcheck disable=SC1090
  source "$SECRETS_FILE"
  [[ -n "$_prev_cf" ]] && export CLOUDFLARE_API_TOKEN="$_prev_cf"
  [[ -n "$_prev_sync" ]] && export PAPER_SYNC_TOKEN="$_prev_sync"
  unset _prev_cf _prev_sync
fi

COMMIT_MSG=""
DEPLOY_APP=0
RUN_SNAPSHOT=1
RUN_TESTS=1
DRY_RUN=0

usage() {
  cat <<'EOF'
Usage: ./update-paper-studio.sh [options] ["commit message"]

Options:
  --deploy-app    Force build and Cloudflare Workers deploy for paper-studio
  --no-snapshot   Skip direct paper-sync snapshot upload (rely on GitHub Actions)
  --skip-tests    Skip typecheck and vitest run when paper-studio has changes
  --dry-run       Show planned actions without modifying git, Cloudflare, or R2
  -h, --help      Show this help message

Environment variables used (already exported or auto-loaded from ~/.paper-studio-secrets):
  CLOUDFLARE_API_TOKEN      Required only when paper-studio is deployed
  PAPER_SYNC_TOKEN          Required for immediate snapshot + asset upload
  PAPER_STUDIO_SECRETS_FILE Override secrets file path (default: ~/.paper-studio-secrets)
  PAPER_STUDIO_URL          Override Worker URL (default: https://paper-studio.our-departure.workers.dev)
  PAPER_STUDIO_SLUG         Override project slug (default: storca)
  PAPER_STUDIO_DIR          Override path to paper-studio checkout
EOF
}

while (($# > 0)); do
  case "$1" in
    --deploy-app)
      DEPLOY_APP=1
      shift
      ;;
    --no-snapshot)
      RUN_SNAPSHOT=0
      shift
      ;;
    --skip-tests)
      RUN_TESTS=0
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "Error: Unknown option '$1'. Run '$0 --help' for usage." >&2
      exit 1
      ;;
    *)
      if [[ -n "$COMMIT_MSG" ]]; then
        echo "Error: Unexpected extra positional argument '$1'." >&2
        exit 1
      fi
      COMMIT_MSG="$1"
      shift
      ;;
  esac
done

if [[ -z "$COMMIT_MSG" ]]; then
  COMMIT_MSG="Update manuscript and Paper Studio ($(date '+%Y-%m-%d %H:%M'))"
fi

if [[ ! -d "$STUDIO_DIR" ]]; then
  echo "Error: paper-studio directory not found at '$STUDIO_DIR'." >&2
  exit 1
fi

if [[ ! -f "$MANUSCRIPT_DIR/paper.json" ]]; then
  echo "Error: paper.json not found in '$MANUSCRIPT_DIR'." >&2
  exit 1
fi

git_dirty_count() {
  git -C "$1" status --porcelain | wc -l | tr -d '[:space:]'
}

git_ahead_count() {
  git -C "$1" rev-list --count '@{u}..HEAD' 2>/dev/null | tr -d '[:space:]' || echo "0"
}

git_has_upstream() {
  git -C "$1" rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1
}

# 1. Inspect and publish paper-studio (only when changed, ahead, or --deploy-app)
studio_dirty="$(git_dirty_count "$STUDIO_DIR")"
studio_ahead="$(git_ahead_count "$STUDIO_DIR")"
studio_needs_publish=0
if ((studio_dirty > 0 || studio_ahead > 0 || DEPLOY_APP == 1)); then
  studio_needs_publish=1
fi

echo "=== [1/3] paper-studio ($STUDIO_DIR) ==="
if ((studio_needs_publish == 1)); then
  echo "  Pending work: dirty=${studio_dirty}, unpushed=${studio_ahead}, force_deploy=${DEPLOY_APP}"
  if ((DRY_RUN == 1)); then
    cf_state="unset"
    [[ -n "${CLOUDFLARE_API_TOKEN:-}" ]] && cf_state="set"
    echo "  [dry-run] CLOUDFLARE_API_TOKEN is ${cf_state}"
    if ((studio_dirty > 0)); then
      ((RUN_TESTS == 1)) && echo "  [dry-run] Would run: npm run typecheck && npm test"
      echo "  [dry-run] Would run: git add -A && git commit -m \"$COMMIT_MSG\" && git push"
    elif ((studio_ahead > 0)); then
      echo "  [dry-run] Would run: git push"
    fi
    echo "  [dry-run] Would run: npm run build && npx wrangler deploy --config apps/api/wrangler.toml"
  else
    if [[ -z "${CLOUDFLARE_API_TOKEN:-}" ]]; then
      echo "Error: CLOUDFLARE_API_TOKEN is required to deploy paper-studio changes." >&2
      exit 1
    fi
    pushd "$STUDIO_DIR" >/dev/null
    if ((studio_dirty > 0)); then
      if ((RUN_TESTS == 1)); then
        npm run typecheck
        npm test
      fi
      git add -A
      if ! git diff --cached --quiet; then
        git commit -m "$COMMIT_MSG"
      fi
      git push
    elif ((studio_ahead > 0)); then
      git push
    fi
    npm run build
    npx wrangler deploy --config apps/api/wrangler.toml
    popd >/dev/null
  fi
else
  echo "  Clean and up-to-date; skipping app build and deploy."
fi

# 2. Pull any web edits, commit, and push paper-storca
storca_dirty="$(git_dirty_count "$MANUSCRIPT_DIR")"
storca_ahead="$(git_ahead_count "$MANUSCRIPT_DIR")"
echo "=== [2/3] paper-storca ($MANUSCRIPT_DIR) ==="
echo "  Pending work: dirty=${storca_dirty}, unpushed=${storca_ahead}"
if ((DRY_RUN == 1)); then
  if git_has_upstream "$MANUSCRIPT_DIR"; then
    echo "  [dry-run] Would run: git pull --rebase --autostash"
  fi
  if ((storca_dirty > 0)); then
    echo "  [dry-run] Would run: git add -A && git commit -m \"$COMMIT_MSG\" && git push"
  elif ((storca_ahead > 0)); then
    echo "  [dry-run] Would run: git push"
  else
    echo "  [dry-run] No manuscript git changes to commit or push."
  fi
else
  pushd "$MANUSCRIPT_DIR" >/dev/null
  if git_has_upstream "$MANUSCRIPT_DIR"; then
    git pull --rebase --autostash
  fi
  storca_dirty="$(git_dirty_count "$MANUSCRIPT_DIR")"
  storca_ahead="$(git_ahead_count "$MANUSCRIPT_DIR")"
  if ((storca_dirty > 0)); then
    git add -A
    if ! git diff --cached --quiet; then
      git commit -m "$COMMIT_MSG"
    fi
    git push
  elif ((storca_ahead > 0)); then
    git push
  else
    echo "  No manuscript git changes to commit or push."
  fi
  popd >/dev/null
fi

# 3. Upload immediate PaperGraph snapshot + figure assets
echo "=== [3/3] Paper Studio snapshot ($URL, slug=$SLUG) ==="
if ((RUN_SNAPSHOT == 0)); then
  echo "  Skipped snapshot upload (--no-snapshot); pushed commits rely on GitHub Actions."
elif ((DRY_RUN == 1)); then
  sync_state="unset"
  [[ -n "${PAPER_SYNC_TOKEN:-}" ]] && sync_state="set"
  echo "  [dry-run] PAPER_SYNC_TOKEN is ${sync_state}"
  echo "  [dry-run] Would run: npm run paper-sync -- snapshot --url \"$URL\" --slug \"$SLUG\" --paper \"$MANUSCRIPT_DIR/paper.json\" --work-dir \"$MANUSCRIPT_DIR/.paper-sync\""
elif [[ -z "${PAPER_SYNC_TOKEN:-}" ]]; then
  echo "  Warning: PAPER_SYNC_TOKEN is unset; skipped direct R2 snapshot upload (relying on GitHub Actions)."
else
  pushd "$STUDIO_DIR" >/dev/null
  npm run paper-sync -- snapshot \
    --url "$URL" \
    --slug "$SLUG" \
    --paper "$MANUSCRIPT_DIR/paper.json" \
    --work-dir "$MANUSCRIPT_DIR/.paper-sync"
  popd >/dev/null
fi

echo "Done."
