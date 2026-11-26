# stORCA Nature Communications Figure Plan: 5 Main Figures, Panel Blueprint, and Required Additions (2026-11-23)

**Working Title:** *Calibrated detection and decomposition of differential spatial gene expression across replicate tissue sections with stORCA*

This note defines the revised figure plan for the stORCA manuscript targeting Nature Communications, starting from `0-Paper-Draft/0-paper-outline-natcomm.md` and the findings of `0-Paper-Draft/0-audit-natcomm-nov23.md`. It follows one line: (1) evaluate the one-Results-section-per-Figure structure and three structural adjustments; (2) specify panel-by-panel layouts and required additions for Main Figures 1 to 5; (3) define Supplementary Figures S1 to S5; (4) state the execution order. Paths are relative to the project root.

**Core structure verdict.** Mapping one Results section to one Main Figure and one primary claim is the cleanest structure for a Nature Communications methods paper. Three structural edits are needed relative to the 2026-11-20 outline:

1. **Adopt a 5 Main Figures structure (remove Claim 5 / Figure 6 from the main text).** The ARTISTA time-course analysis has 2 to 3x sequencing-depth variation across days, up to 41 false-label calls at 15 DPI, and non-monotonic $\Delta$ outside amplitude changes (Fix 4). Keeping Main Figures 1 to 5 (Problem/Method, Benchmark, False Positive 1 Replicates, False Positive 2 Unmatched Tissue, Typing/Biology) gives a tighter, harder-to-attack manuscript.
2. **Trim each Main Figure to 5 to 6 panels.** Current Figures 2 to 5 carry 7 to 8 panels each and mix strong evidence with broken or weak panels (`2d`, `3d Colitis D0 vs D3`, `4g`). Moving weak or auxiliary items to Supplementary keeps every main figure crisp and legible within the 18-inch landscape width cap.
3. **Relocate or drop specific panels:**
   - Move `Fig 2e` (synthetic ground-truth $\rho\kappa$ type validation) to **`Fig 5a`** so Claim 4 opens with ground-truth typing accuracy before real-data interpretation.
   - Remove `Fig 2d` (`3-BM-DSE-Scores`, where ROS v4 lost 3/20 vs 20/20), move `Fig 2f2` (`HPOA swap`) to Supplementary, and move `Fig 4g` (synthetic rearrangement `08 to 12`, where competitors are fixed at rank 30.5 even at `strength = 0`) to Supplementary.

## 0. Summary

| Figure (= Results Section) | Primary Claim | Panels | Core Data | Blocking Additions |
|---|---|---|---|---|
| Figure 1 (Results 1) | Spatial changes can be real or apparent (replicate variation, unmatched tissue), and stORCA separates them | `1a` to `1e` (5) | Toy + HPOA/Colitis/Cortex thumbnails + schematic | Finalize scoring formula ($\mathrm{ROS}_\lambda^{\text{sym}}$) then draw unified `1a` to `1e` |
| Figure 2 (Results 2) | stORCA detects pattern, amplitude, and local spatial changes while ignoring global shifts; competitors have blind spots | `2a` to `2e` (5) | Synthetic v2 (`02 to 07`), LIBD 3 vs 3 semi-synthetic (+ decoys), Runtime | Fix Synthetic v2 1,000x scale + `01F to 01K` bins; apply Fix 1 & symmetric ROS; fair gated LIBD + SpaceExpress `FDR=0` fix + STcompare `spatialSimilarity`; add competitors to `8-BM-Runtime` |
| Figure 3 (Results 3) | Single-pair tests call replicate variation as change; stORCA's replicate design calibrates false positives | `3a` to `3f` (6) | Real (LIBD, HPOA, NRDR, ARTISTA) + LIBD implant scaling | Apply symmetric ROS (resolve HPOA 1/30 fwd/rev); resolve LIBD 3 vs 3 donor-pairing confound; remove invalid STcompare $H_0: r=0$ inversion; correct ARTISTA STcompare = 40 calls |
| Figure 4 (Results 4) | Tissue without a counterpart fills registration and domain top lists, whereas partial OT + thinning avoids it | `4a` to `4f` (6) | Real (Cortex 3 dpi, Colitis D0 vs D9, HPOA) | Rescore CODA using saved `common_cells` on `colitisq1`/`cortexor`; add Balanced vs Partial OT ablation; draw `4e`, `4f` |
| Figure 5 (Results 5) | stORCA accurately types changes, localizes residuals, and discovers biological spatial changes missed by DE and domain tests | `5a` to `5f` (6) | Fixed Synthetic v2 (`5a`) + Real (ARTISTA, NRDR, HPOA) | Fix `interpret.py` `rho > 1` bug; run ground-truth typing (`5a`); compute Q3xQ5 split (`5c`) & quantitative localization (`5d`); verify NRDR L2/3-L4 shift & Xie et al. Dataset S1 (`5e`, `5f`) |

---

## 1. Main Figure Panel Blueprint

Status tags: `[Keep]` = ready as is; `[Update/Rerun]` = revise existing analysis or recompute under finalized scoring; `[Add]` = new analysis or figure panel required for Nature Communications.

### Figure 1 (Results 1): Problem Definition and stORCA Overview

- **Claim:** Condition-to-condition spatial expression differences can be real or apparent (replicate variation, unmatched tissue), and stORCA separates them.

| Panel | Content | Data / Source | Status |
|---|---|---|---|
| `1a` | Three toy genes: global shift ($\mathrm{ROS} = 0$), amplitude change, pattern change | Toy | `[Add]` |
| `1b` | Two apparent-change thumbnails: (left) replicate hotspot in one condition (HPOA `Oxt`); (right) unmatched tissue (lost Colitis D0 epithelium or Cortex lesion) | Real thumbnails | `[Add]` |
| `1c` | stORCA pipeline schematic: SysVI embedding, niche+cell cost and density-ratio partial OT, symmetric stabilized spatial concordance ($\mathrm{ROS}_\lambda^{\text{sym}}$ removes 50 random matchings and multi-stage `z_den` filters), thinned within vs between replicate `limma` | Schematic (`01-storca-figure1-nov19.py`) | `[Update/Rerun]` |
| `1d` | Single-gene outputs: effect size $\Delta$ and call, $(\rho, \kappa)$ decomposition plane, spatial residual map | Schematic | `[Keep]` / `[Update/Rerun]` |
| `1e` | Feature comparison grid vs CODA, STcompare, DESpace2, River, SpaceExpress (accurately noting STcompare `spatialSimilarity` and actual 1-vs-1 vs replicate usage) | Method table | `[Add]` |

### Figure 2 (Results 2): Controlled Benchmarks (Synthetic, Semi-Synthetic, Runtime)

- **Claim:** stORCA detects pattern, amplitude, and local spatial changes while ignoring global shifts, whereas registration, domain, and classifier methods each have blind spots.
- **Removed from main text:** `2d` (`3-BM-DSE-Scores`, drop), `2f2` (`HPOA swap`, Supplementary), `2e` (type validation, moved to `Fig 5a`).

| Panel | Content | Data / Source | Status |
|---|---|---|---|
| `2a` | Schematic of 6 designed change types (`domain-de`, `domain-ct-de`, `within-shift`, `boundary-band`, `amplitude/svg-increase`, `ring-domain`) with animal effects | Synthetic v2 (`3-BM-DSE-Scenario-v2`) | `[Keep]` / `[Update/Rerun]` |
| `2b` | Blind-spot heatmap: AUROC across methods x 6 change types (3 vs 3, `strength = 1`), including both STcompare `correlation` and `spatialSimilarity` | Repaired Synthetic v2 | `[Update/Rerun]` |
| `2c` | Null calibration at `strength = 0`: fraction of genes called at FDR 0.05 across methods | Repaired Synthetic v2 | `[Update/Rerun]` |
| `2d` | Real-tissue semi-synthetic benchmark (`LIBD DLPFC 3 vs 3` implants, **fair shared gene universe**): (left) AUROC across 5 types (`domain_de`, `within_shift`, `amplitude`, `relocation`, `pure_shift`); (right) global-shift decoy separation (showing River fails decoys while stORCA separates them) | `1-BM-DSE-Semi-LIBD` (re-evaluated) | `[Update/Rerun]` |
| `2e` | Wall-clock runtime and peak RAM/GPU scaling across 2.5k to 20k cells per section for **stORCA and all competitors** | `8-BM-Runtime` | `[Add]` |

**Required additions for Figure 2:** (1) Repair Synthetic v2 generator (matched background/focal count scale + `01F to 01K` Moran bins) and rerun with Fix 1 / $\mathrm{ROS}_\lambda^{\text{sym}}$; (2) re-evaluate LIBD on a fair shared gene universe with fixed SpaceExpress `FDR = 0` sentinel, STcompare `spatialSimilarity`, and `same_donor` handling; (3) add competitor runtime and memory bars to `8-BM-Runtime`.

### Figure 3 (Results 3): Apparent Change 1, Replicate Variation

- **Claim:** Single-pair tests report replicate variation as condition change, whereas stORCA's replicate design calibrates false positives.
- **Moved to Supplementary:** Colitis D0 vs D3 (`29` true vs `26` false calls, presented in Supplementary as a subgroup-heterogeneity diagnostic case).

| Panel | Content | Data / Source | Status |
|---|---|---|---|
| `3a` | Single-pair test false-positive call fraction on within-condition replicate pairs across real datasets (remove invalid STcompare $H_0: r=0$ failure-to-reject inversion) | Real (5 to 6 datasets, Q2) | `[Update/Rerun]` |
| `3b` | Single-pair ranking contamination: overlap of top-20 between-pair and within-pair genes (evaluated on stORCA's shared gene universe) | Real (Q2) | `[Update/Rerun]` |
| `3c` | Replicate design true-label vs all false-label (label-swap) calls: LIBD null (donor-adjusted), HPOA, NRDR (pos/ant), ARTISTA | Real (symmetric ROS) | `[Update/Rerun]` |
| `3d` | 2 x 2 ablation (single-pair vs replicate design; score vs test) across competitors (honestly reporting ARTISTA STcompare = 40 calls alongside River = 46) | Real (`q2-four-comparisons.csv`) | `[Update/Rerun]` |
| `3e` | Cause and scaling: (left) replicate-to-matching variance ratio (26 to 155x across 5 datasets); (right) LIBD implant empirical FDR and power across replicate counts (2 vs 2, 3 vs 3) | Real + LIBD implant | `[Keep]` / `[Update/Rerun]` |
| `3f` | Named HPOA examples: competitor false positives (`Blank_2`, `Oxt`) vs stORCA true positive (`Cpne5`, stable under symmetric ROS; remove River `Sema4d`, fix `Gbx2` text) | Real (HPOA) | `[Update/Rerun]` |

**Required additions for Figure 3:** (1) Rerun HPOA, NRDR, ARTISTA, and LIBD with symmetric ROS ($\mathrm{ROS}_\lambda^{\text{sym}}$) to eliminate the HPOA 1/30 forward/reverse asymmetry; (2) fix LIBD 3 vs 3 donor-pairing confound (`same_donor` covariate or non-paired null) so nominal $p$-values are centered; (3) fix STcompare `3a` and `3d` reporting.

### Figure 4 (Results 4): Apparent Change 2, Tissue Without a Counterpart

- **Claim:** Tissue without a counterpart fills the top lists of registration and domain methods, whereas stORCA's partial OT and symmetric within-pair thinning avoid it.
- **Moved to Supplementary:** `4g` (synthetic rearrangement `08 to 12`, after resolving `10-domain-expansion` Fix 2 with $\mathrm{ROS}_\lambda^{\text{sym}}$ + `limma::treat`).

| Panel | Content | Data / Source | Status |
|---|---|---|---|
| `4a` | Spatial retained-mass maps: Cortex 3 dpi lesion (`r14`) and Colitis D0 lost epithelium appear dark | Real (Cortex, Colitis, Q1) | `[Keep]` |
| `4b` | Per-cluster retained mass vs condition specificity (`AUROC 0.89` Cortex, `0.94` Colitis D0; within-pairs `0.99`) | Real (Q1) | `[Keep]` |
| `4c` | Share of unmatched-tissue markers in top 20 (and top $k$) across methods: stORCA vs **CODA (including `common_cells` enabled)**, STcompare, DESpace2, pseudobulk DE, River | Real (Q1) | `[Add]` |
| `4d` | Named Colitis examples: `Ptger3` (lost D0 epithelium, top 3 in competitors, rank 212 in stORCA) vs `Flnc`, `Grem2` (muscularis changes present at both days) | Real (Colitis) | `[Keep]` |
| `4e` | Two-part ablation: (left) Partial OT vs Balanced OT (forced matching); (right) no thinning vs control-only vs symmetric thinning across Cortex, Colitis, and HPOA | Real (Q1) | `[Add]` |
| `4f` | Mechanism of registration failure: Colitis D0 vs D9 (9 pairs) showing CODA/STcompare overlaying lost epithelium onto mismatched D9 tissue to create negative correlation on `Ptger3` | Real (Colitis, Q1 7c) | `[Update/Rerun]` (draw) |

**Required additions for Figure 4:** (1) Rescore CODA on `colitisq1` and `cortexor` using its already saved `common_cells` in `*-align.pkl`; (2) add the Balanced OT vs Partial OT ablation alongside the thinning ablation; (3) draw panels `4e` and `4f`.

### Figure 5 (Results 5): Change Typing and Biological Discoveries Beyond DE

- **Claim:** stORCA accurately types each change into pattern, amplitude, or mixed, localizes where changes occur, and finds biological spatial changes missed by pseudobulk DE and domain tests.

| Panel | Content | Data / Source | Status |
|---|---|---|---|
| `5a` | Ground-truth typing validation (moved from Fig 2e): pattern vs amplitude designed genes in the $(\rho, \kappa)$ plane + confusion matrix (after fixing `interpret.py` `rho > 1` bug) | Repaired Synthetic v2 | `[Add]` |
| `5b` | Real-data $(\rho, \kappa)$ plane and type shares across ARTISTA, NRDR, and HPOA (after `rho > 1` fix and symmetric ROS) | Real (Q5) | `[Update/Rerun]` |
| `5c` | Overlap with DESpace2 and global/domain pseudobulk DE (ARTISTA 29 missed by both; NRDR layer 19) + pattern/amplitude type breakdown of non-DE calls (Q3 x Q5 join) | Real (ARTISTA, NRDR) | `[Add]` |
| `5d` | Typed examples with residual maps (`CDKN1B` amplitude, `FABP7` pattern in ARTISTA) + **quantitative localization ("where") metric** (domain/niche residual enrichment and cross-pair consistency) | Real (ARTISTA) | `[Add]` |
| `5e` | Visually verifiable non-DE spatial reorganization example: NRDR 4 vs 4 shifted L2/3-L4 boundary gene or a visually clear non-DE pattern gene in ARTISTA/HPOA (do not overclaim `Prkca`/`Trpc3` as DE-invisible since they are layer DE at 4 vs 4) | Real (NRDR / ARTISTA) | `[Add]` |
| `5f` | External biological validation: NRDR dark-reared V1 activity genes (`7/7` $\ell > 0$, `11/11` sign match with pseudobulk) + cross-check against Xie et al. 2025 Dataset S1 (`L2/3B/C`) | Real (NRDR) | `[Add]` |

**Required additions for Figure 5:** (1) Fix `storca/interpret.py:66-70` (`rho > 1` and `one_side_constant` bugs); (2) run ground-truth typing validation (`5a`); (3) compute Q3 x Q5 join (`5c`) and quantitative localization metric (`5d`); (4) validate NRDR L2/3-L4 boundary shift and Xie et al. Dataset S1 (`5e`, `5f`).

---

## 2. Supplementary Figures Blueprint

| Supp Fig | Content | Current Status |
|---|---|---|
| **S1** | Sensitivity and stability: `9-BM-Sensitivity` (HPOA 12 parameter variants), 5-seed SysVI stability (`Q-E5`), SysVI loss convergence curves, forward vs reverse symmetry validation (`Q-S7`) | 12-variant sensitivity done; add 5-seed, loss curves, symmetry |
| **S2** | Robustness controls: gene-holdout embedding circularity test (`Q-E6` on HPOA/NRDR and `04-within-domain-shift`) + blind per-labeling thinning check (`Q-I4` on HPOA/LIBD) | `[Add]` |
| **S3** | Synthetic rearrangement `08 to 12` (including `10-domain-expansion` Fix 2 resolved by $\mathrm{ROS}_\lambda^{\text{sym}}$ + `limma::treat`) + subgroup-heterogeneity diagnostic cases (LIBD 6 vs 6, Colitis D0 vs D3) | `[Update/Rerun]` |
| **S4** | Exploratory 1-vs-1 mode (gene-bulk / split-half ranking), `limma` calibration simulations, and Python vs R `limma` numerical agreement | Mostly done |
| **S5** | *(Optional)* ARTISTA regeneration time course (former Fig 6, only if paired with depth-matched downsampling) + NRDR 4 vs 4 replication | Optional; needs depth downsampling |

---

## 3. Recommended Execution Order

1. **Freeze scoring and fix core code bugs first:** Validate $\mathrm{ROS}_\lambda^{\text{sym}}$ (`lam = 0.03, 0.05`) + balanced 3-column `limma::treat` across HPOA, NRDR, LIBD, ARTISTA, and Colitis Q1, and fix the 6 `storca/` bugs (including `interpret.py` `rho > 1`). This unblocks Figures 1 to 5 simultaneously.
2. **Repair benchmarks and fair competitor runs:** Fix Synthetic v2 (`2a to c`, `5a`, `S3`), re-evaluate LIBD fairly (`2d`, `3c`, `3e`), rescore CODA with `common_cells` (`4c`), and add competitors to `8-BM-Runtime` (`2e`).
3. **Complete Claim 4 biology and Supplementary controls:** Q3 x Q5 join, quantitative localization, NRDR L2/3-L4 / Xie et al. Dataset S1 (`5c to f`), plus `Q-E5`, `Q-E6`, `Q-I4` (`S1`, `S2`).
4. **Draw unified final figures and package `storca/`:** Draw `1a to e`, `4e`, `4f`, and sync `0-paper-outline-natcomm.md`, `0-method-v1.md`, and Q1 to Q5 reports to the final frozen numbers.
