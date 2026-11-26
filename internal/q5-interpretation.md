# Q5 interpretation: how each call is typed as pattern or amplitude, what the types look like per dataset, whether the NRDR activity genes and the ARTISTA examples agree with the maps, and what is still unvalidated

This note explains the notebook [15-q5-interpretation.ipynb](15-q5-interpretation.ipynb) section by section. It follows one line: (1) the decomposition of ROS into a pattern part and an amplitude part, and the type given to each call; (2) the share of each type per dataset; (3) a biological check on activity genes in NRDR, where the type and direction can be predicted; (4) two ARTISTA examples, checked on maps; (5) what can be claimed and what must be fixed first.

The line supports claim 4 of the outline, interpretation: "what kind of change (pattern or amplitude) and where" (Figures 2b, 5c, 5d and 6e of [0-paper-outline-natcomm.md](../0-Paper-Draft/0-paper-outline-natcomm.md)). Three points drift from the outline and are stated here. First, the symbols differ: the notebook's `kappa` is the outline's $C(\kappa)$, and the outline's $\kappa$ equals $e^{-\ell}$ (now stated in the notebook header). Second, the type describes the whole between-pair score, not the excess over replicates; section 1 measures how much this matters (most types stay; the ones that move go from mixed to amplitude). Third, the "where" half of the claim is shown as a residual map of one pair for two genes, with no number. The NRDR direction problem of the earlier version is resolved by the source study (section 3).

All figures are copied unchanged from the notebook (PDF in `5-Case-Study-Comparison/fig/`, PNG copies in `5-Case-Study-Comparison/fig/15-q5-interpretation/`). Paths are relative to the project root unless they are links. Numbers marked "computed for this report" come from the saved result files and are not in the notebook.

**Data.** stORCA v3 calls (one-sided unweighted limma, BH $<0.05$) in three datasets: ARTISTA 2 DPI vs 20 DPI (115 calls of 782 tested, 9 between pairs), NRDR V1 posterior, normal reared vs dark reared (32 of 377, 4 between pairs), HPOA naive vs aggression (11 of 149, 9 between pairs).

**Score.** For one pair, let $Q_x$, $Q_y$ and $Q_r$ be the spatial quadratic forms of the source expression, the matched target expression and their difference, summed over the sampled matchings. Then $\mathrm{ROS}=Q_r/(Q_x+Q_y)$ and (`storca/interpret.py`, function `pair_decomposition`)

$$
1-\mathrm{ROS}=\rho\cdot\kappa,\qquad
\kappa=\frac{2\sqrt{Q_xQ_y}}{Q_x+Q_y},\qquad
\rho=\frac{Q_x+Q_y-Q_r}{2\sqrt{Q_xQ_y}} .
$$

$\kappa$ is 1 when the two sections have the same strength of spatial structure and falls towards 0 as the strengths differ. $\rho$ is 1 when the structure has the same shape and falls as the shapes differ. Taking logs makes the loss additive, $-\log(1-\mathrm{ROS})=-\log\rho-\log\kappa$, which gives the amplitude share and the direction:

$$
s=\frac{-\log\kappa}{-\log\kappa-\log\rho},\qquad
\ell=\tfrac12\log\frac{Q_y}{Q_x} .
$$

$\ell>0$ means the treated section has the stronger structure. Between pairs always run from a control section to a treated section (`storca/replicate_case_studies.py`), so the sign of $\ell$ has the same meaning in every between pair.

**Rules for the type of one pair.**

1. On/off: one side is constant.
2. Undefined: $Q_x\le0$ or $Q_y\le0$.
3. Pattern: $\rho\le0$, or $s<1/3$.
4. Amplitude: $s>2/3$. Everything else is mixed.

Per gene, the notebook takes the median of $\kappa$, $\rho$, $s$ and $\ell$ over the between pairs, and the type that occurs most often among the between pairs.

## 0. Summary

| Step | Finding |
|---|---|
| 1. Types | ARTISTA, 115 calls: 63 pattern, 42 mixed, 10 amplitude. NRDR posterior, 32 calls: 14, 14, 4. HPOA, 11 calls: 2, 3, 6 |
| 2. Shares | Pattern share 0.55 in ARTISTA, 0.44 in NRDR, 0.18 in HPOA. HPOA rests on 11 calls |
| 3. NRDR check | 7 of 11 activity genes are called. The source study (Xie, Jain, Xu et al. 2025, PNAS) reports immediate early genes up in dark-reared V1, by a similar amount in every L2/3 sublayer. Predicted: $\ell>0$ and a change mostly of strength. Observed: $\ell>0$ in 7 of 7 calls (0.63 to 1.38), same sign as pseudobulk in 11 of 11 genes. Type: 5 mixed and 2 pattern on the between pairs; 3 amplitude, 3 mixed and 1 pattern on the excess over replicates |
| 4. Examples | `CDKN1B` (amplitude, $s$ 0.82) and `FABP7` (pattern, $s$ 0.12) both agree with the maps. Both are also global DE genes, and River ranks both in its top 40 |
| 5. Excess over replicates | Typing the excess of the between pairs over the within pairs keeps the type of 87 of 115 calls (ARTISTA), 21 of 32 (NRDR) and 8 of 11 (HPOA). The moves are mostly mixed to amplitude (17 and 6); only 2 calls switch between pattern and amplitude. Still not validated: no agreement measure across pairs, no ground truth, no number for location |
| 6. Fix or defend | The two fixes are done on 2026-11-17 (NRDR hypothesis from the source study; symbol sentence in the notebook header), and the residual panel now shows one sampled matching. The check came out "most types stay", so the simple definition is kept and the number is the defence. Every other issue is recorded in section 5 |

## 1. Typing each call (notebook section 1)

**Question.** For a called gene, is the loss of spatial concordance due to a change of shape or to a change of strength?

**In plain words.** Two toy genes. Gene A has the same map in both conditions but at half strength, $y=0.5\,x$. Then $Q_y=0.25\,Q_x$, so $\kappa=2(0.5)/(1+0.25)=0.8$, $\rho=1$, $\mathrm{ROS}=1-0.8=0.2$ and $s=1$: all of the loss is amplitude. Gene B keeps its strength but moves to another place: $\kappa=1$, $\rho<1$, $s=0$: all of the loss is pattern. Real genes are in between, and $s$ says where.

**"Amplitude" is the strength of spatial structure, not the mean level.** $Q$ is a spatially weighted variance. A gene that rises by the same amount everywhere on the log scale keeps the same $Q$, so $\kappa$ stays 1. This is why a gene can be typed "pattern" with $\kappa=0.96$ and still be a pseudobulk DE gene (`FABP7`, section 4).

**Why it matters.** CODA and STcompare score with a correlation, which by construction ignores a change of strength. River and DESpace2 give one number per gene. A type per call is something none of them outputs.

**Implementation** (notebook section 1; `interpret.case_decomposition`, which reads the per-matching tables `<plan prefix>-issue-matching.csv`, columns `q_x`, `q_y`, `q_r`, so the numbers agree with the ROS that limma used).

1. Decompose every pair of the case by the formulas above.
2. Keep the between pairs. Per gene: median $\kappa$, $\rho$, $s$, $\ell$; most frequent type.
3. Join with the limma table and keep the calls.

**Worked example with real numbers (ARTISTA, gene medians).**

| Gene | $\kappa$ | $\rho$ | $-\log\kappa$ | $-\log\rho$ | $s$ | $\ell$ | Type |
|---|---|---|---|---|---|---|---|
| `CDKN1B` | 0.239 | 0.736 | 1.431 | 0.307 | $1.431/1.738=0.82$ | 2.11 | amplitude |
| `FABP7` | 0.961 | 0.746 | 0.040 | 0.293 | $0.040/0.333=0.12$ | 0.28 | pattern |

For `CDKN1B`, $\ell=2.11$ means $Q_y/Q_x=e^{4.22}\approx68$: the structure is 68 times stronger at 20 DPI. Both genes have nearly the same $\rho$; they differ in $\kappa$.

**Result.**

| Dataset | Calls | Pattern | Mixed | Amplitude |
|---|---|---|---|---|
| ARTISTA | 115 | 63 | 42 | 10 |
| NRDR posterior | 32 | 14 | 14 | 4 |
| HPOA | 11 | 2 | 3 | 6 |

**Does the type describe the condition effect?** Not exactly. The call is made on the excess $\Delta$ of between pairs over within pairs, but the type is computed from the between pairs alone. A called gene with a within ROS of 0.35 and a between ROS of 0.57 (`B2M` in ARTISTA) gets a type for the whole 0.57, of which 0.35 is already there between replicates. The log form gives a direct fix, because the two losses add:

$$
\text{excess amplitude loss}=\overline{-\log\kappa}_{\text{between}}-\overline{-\log\kappa}_{\text{within}},\qquad
\text{excess pattern loss}=\overline{-\log\rho}_{\text{between}}-\overline{-\log\rho}_{\text{within}} .
$$

The share computed from these two excesses types the part of the change that the call is about.

**Check run** (notebook section 5, 2026-11-17; `res/Comparison/q5-excess-type-check.csv`). Rules:

1. Per gene, the median of $-\log\kappa$ and of $-\log\rho$ over the between pairs and over the within pairs. Pairs with an undefined decomposition (one side constant, $Q\le0$ or $\rho\le0$) are left out of the medians.
2. Excess = between median minus within median, floored at 0.
3. Excess share = amplitude excess / (amplitude excess + pattern excess), typed with the same cut points (1/3, 2/3).

The between-pair types of sections 1 to 4 are kept as they are; the check only counts how many calls keep their type.

| Dataset | Calls | Same type | Pattern (between, excess) | Mixed (between, excess) | Amplitude (between, excess) |
|---|---|---|---|---|---|
| ARTISTA | 115 | 87 (0.76) | 63, 56 | 42, 30 | 10, 29 |
| NRDR posterior | 32 | 21 (0.66) | 14, 13 | 14, 9 | 4, 10 |
| HPOA | 11 | 8 (0.73) | 2, 0 | 3, 4 | 6, 7 |

**Reading:**

- **Most calls keep their type, and almost none flips between the two ends.** In ARTISTA 2 pattern calls become amplitude and no amplitude call becomes pattern; in NRDR and HPOA none flips.
- **The moves go one way: mixed to amplitude** (17 of 42 in ARTISTA, 6 of 14 in NRDR). So the disagreement between replicates is mostly of shape, and typing the between pairs alone adds that shape loss to every call.
- **The examples keep their type.** `CDKN1B`: share 0.82 on the between pairs, 0.87 on the excess. `FABP7`: 0.12 and 0.07.

**Is this a reason to change the definition?** Not by the rule set before the check (change only if many calls switch). A reader who wants the condition effect itself can use the excess share; the paper can report both shares per call, at no extra cost.

**Where it still goes wrong.**

- The type is the most frequent of 9 pair types (4 in NRDR). How many pairs agree is not reported, so a 4 to 3 to 2 vote looks the same as 9 to 0.
- Pairs with $\rho\le0$ are typed "pattern" by rule 3. $\rho\le0$ means $\mathrm{ROS}\ge1$, which includes the out-of-range scores described in [14-q4-effect-size.md](14-q4-effect-size.md) section 6. In these three datasets 3.1% of the pair scores of tested genes are out of range in ARTISTA (8 of 115 calls involved), 0.9% in NRDR posterior (1 of 32) and 0.2% in HPOA (0 of 11) (computed for this report from the `limma-pair-scores.csv` files).
- The cut points 1/3 and 2/3 are a convention. Nothing in the notebook shows how the counts move with other cut points.

**Verdict: works as a description of the between pairs, and the excess check shows it agrees with the type of the condition effect for 66% to 76% of calls; the rest lean towards amplitude.**

Result files: per-pair tables under each case folder (`<plan prefix>-issue-gene.csv`, `-issue-matching.csv`); no per-gene type table is saved by the notebook.

## 2. The rho-kappa plane and the share of types (notebook section 2)

**Question.** Do the datasets differ in what kind of change dominates?

**Implementation** (notebook section 2). Every tested gene is placed at its median $(\kappa,\rho)$; calls are coloured by type. Dashed curves are lines of equal ROS, $\rho\,\kappa=1-\mathrm{ROS}$, for ROS of 0.2, 0.4, 0.6 and 0.8.

![rho-kappa plane](fig/15-q5-interpretation/q5-rho-kappa-plane.png)

*One panel per dataset. Horizontal: $\kappa$, agreement of strength. Vertical: $\rho$, agreement of shape. Light grey: tested genes that are not called. Blue: amplitude calls. Red: pattern calls. Dark grey: mixed calls (legend: `fig/15-q5-interpretation/q5-change-type-legend.png`). Takeaway: ARTISTA calls spread down the right edge ($\kappa$ near 1, $\rho$ low), HPOA calls sit to the left at high $\rho$. Source: [15-q5-interpretation.ipynb](15-q5-interpretation.ipynb) section 2.*

**Result.**

| Dataset | Pattern | Mixed | Amplitude |
|---|---|---|---|
| ARTISTA | 0.55 (63 of 115) | 0.37 (42) | 0.09 (10) |
| NRDR posterior | 0.44 (14 of 32) | 0.44 (14) | 0.12 (4) |
| HPOA | 0.18 (2 of 11) | 0.27 (3) | 0.55 (6) |

The notebook reads ARTISTA as "regeneration relocates patterns" and HPOA as "same structure, different strength". Both readings are plausible and neither is tested. HPOA has 11 calls, so its shares move by 0.09 per gene. The outline expects "most colitis calls are amplitude changes"; colitis is not in this notebook, so that sentence has no support here.

**Verdict: partial; the shares are measured, the biological reading of them is not.**

Result files: figures `fig/15-q5-interpretation/q5-rho-kappa-plane.png`, `q5-change-type-share.png`.

## 3. Biological check: activity genes in NRDR (notebook section 3)

**Question.** For genes whose response is known in advance, does the type come out as expected?

**Hypothesis, from the source study.** Xie, Jain, Xu et al. 2025 (PNAS 122:e2421022122; `0-Data/Mouse-NRDR-2024/pnas.202421022.pdf`) dark-reared the mice from P21 to P28 and harvested them under red light; normally reared mice were harvested 6 to 8 h into the dark phase. In V1 they report 13 genes up in dark-reared mice (fold change above 2, FDR below 0.05), all canonical immediate early genes, with the rise visible throughout cortical depth and similar in all L2/3 sublayers (their Fig. 3). So activity genes should be **higher** in dark-reared cortex, $\ell>0$, and since the rise is similar in every layer the layer shape should be kept: a change mostly of strength (amplitude or mixed type, $\rho$ near 1). The earlier version of the notebook predicted the opposite direction from the general idea that darkness lowers activity; the source study shows that this does not hold for these samples.

**Implementation** (notebook section 3). The per-gene summary of section 1 for 11 activity genes in NRDR posterior (2 vs 2, 4 between pairs).

**Result** (notebook table, plus the pseudobulk columns computed for this report from `res/Comparison/nrdr-pos-gene-table.csv`).

| Gene | Call (BH) | Type | $s$ | $\kappa$ | $\rho$ | $\ell$ | Pseudobulk $\log_2$ fold change, dark vs normal (FDR) |
|---|---|---|---|---|---|---|---|
| `Arc` | yes (0.025) | mixed | 0.35 | 0.83 | 0.71 | 0.63 | 2.40 (0.001) |
| `Egr4` | yes (0.025) | mixed | 0.55 | 0.69 | 0.70 | 0.93 | 2.36 (0.001) |
| `Fos` | yes (0.038) | mixed | 0.58 | 0.47 | 0.56 | 1.38 | 3.08 (0.001) |
| `Fosb` | yes (0.039) | mixed | 0.60 | 0.51 | 0.66 | 1.30 | 3.11 (0.001) |
| `Junb` | yes (0.030) | mixed | 0.57 | 0.62 | 0.68 | 1.06 | 2.71 (0.001) |
| `Nr4a2` | yes (0.020) | pattern | 0.14 | 0.83 | 0.37 | 0.64 | 2.69 (0.001) |
| `Npas4` | yes (0.030) | pattern | 0.28 | 0.74 | 0.52 | 0.81 | 1.57 (0.048) |
| `Egr2` | no (0.082) | amplitude | 0.73 | 0.51 | 0.76 | 1.32 | 3.02 (0.008) |
| `Nr4a3` | no (0.067) | pattern | 0.21 | 0.87 | 0.61 | 0.53 | 2.31 (0.008) |
| `Nr4a1` | no (0.108) | pattern | 0.30 | 0.92 | 0.83 | 0.41 | 1.99 (0.003) |
| `Bdnf` | no (0.325) | pattern | 0.31 | 0.91 | 0.84 | -0.43 | -0.31 (0.72) |

**Reading:**

- **Detection is as expected.** 7 of 11 activity genes are called and 3 more have BH below 0.11. `Bdnf`, the one gene with no pseudobulk change (FDR 0.72), is not called.
- **The direction is as predicted.** $\ell>0$ for all 7 calls, and the sign of $\ell$ equals the sign of the pseudobulk change in 11 of 11 genes. The pseudobulk level is 3 to 9 times higher in the dark-reared sections, the same direction and size as the study's fold change above 2.
- **The type is partly as predicted.** On the between pairs: 5 mixed, 2 pattern, no amplitude. On the excess over replicates (section 1): `Fos`, `Fosb` and `Junb` become amplitude, `Arc`, `Egr4` and `Npas4` are mixed, and `Nr4a2` stays pattern (share 0.12). So most of the loss beyond replicate variation is a change of strength, as the study's "similar in all sublayers" predicts.

**Why some pattern loss remains.** Immediate early genes are expressed in a sparse subset of cells, so the matched partner of an active cell is often an inactive cell even when the layer profile is the same. That lowers $\rho$ without a change of layer shape. This is a property of sparse genes, not of the decomposition; it is the reason the type is read with $s$, not as a strict label.

**Verdict: works as a direction check (7 of 7 calls, 11 of 11 genes), partial as a type check (amplitude or mixed for 6 of 7 calls on the excess, none on the between pairs alone).** Gap type: Defend (see section 5).

Result files: `5-Case-Study-Comparison/res/Comparison/nrdr-pos-gene-table.csv` (columns `de_global_logfc`, `de_global_fdr`).

## 4. Examples in ARTISTA: one amplitude call and one pattern call (notebook section 4)

**Question.** Do the maps of a call typed amplitude and of a call typed pattern look like what the type says?

**Selection rule.** Per type, the call with the largest stORCA $t$. For each: maps of the six sections, and for one between pair (`dpi2-r1` against `dpi20-r1`) the source expression, the target expression under one sampled hard matching (matching 0 of the scoring matchings: each retained source cell gets exactly one target cell) and the smoothed residual of that matching. Before 2026-11-17 the middle panel showed the average over all matchings, which is close to a barycentric projection and is smoother than any real matching.

**Result, checked on maps for this report.**

| Gene | Type | $t$ | $s$ | $\kappa$ | $\rho$ | $\ell$ | What the maps show | Holds? |
|---|---|---|---|---|---|---|---|---|
| `CDKN1B` (`XICL`) | amplitude | 17.1 | 0.82 | 0.24 | 0.74 | 2.11 | almost absent at 2 DPI; a strong band lining the ventricle in all three 20 DPI sections | yes |
| `FABP7` | pattern | 10.1 | 0.12 | 0.96 | 0.75 | 0.28 | 2 DPI: band along the ventricle in both hemispheres; 20 DPI: concentrated in the ventral part of the injured hemisphere in all three sections | yes |

The same genes in the other methods (rank of the between average among 3000 genes, and pseudobulk; the pseudobulk columns were computed for this report):

| Gene | CODA rank | River rank | SpaceExpress rank | DESpace2 FDR | Pseudobulk $\log_2$ fold change (FDR) |
|---|---|---|---|---|---|
| `CDKN1B` | 2799 | 37 | 1298 | 0.65 | 3.30 (below 0.001) |
| `FABP7` | 2961 | 7 | 1312 | below 0.001 | 1.86 (below 0.001) |

![CDKN1B maps](fig/15-q5-interpretation/q5-artista-amplitude-xiclnr-cdkn1bhs-maps.png)

*Top row: 2 DPI. Bottom row: 20 DPI. Shared colour scale. Takeaway: the band at the ventricle is in the same place where a few cells are positive at 2 DPI, and far stronger at 20 DPI. Source: [15-q5-interpretation.ipynb](15-q5-interpretation.ipynb) section 4.*

![FABP7 maps](fig/15-q5-interpretation/q5-artista-pattern-fabp7nr-maps.png)

*Top row: 2 DPI. Bottom row: 20 DPI. Takeaway: at 20 DPI the bright area sits in the lower part of the right (injured) hemisphere in every section, a place where it is not at 2 DPI. Source: [15-q5-interpretation.ipynb](15-q5-interpretation.ipynb) section 4.*

![FABP7 residual](fig/15-q5-interpretation/q5-artista-pattern-fabp7nr-residual.png)

*Left: `dpi2-r1`. Middle: the `dpi20-r1` cell matched to each source cell in one sampled matching, drawn at the source position. Right: smoothed difference of that matching; blue means higher at 20 DPI. Takeaway: the blue area is the ventral injured hemisphere, the same place the maps show. Source: [15-q5-interpretation.ipynb](15-q5-interpretation.ipynb) section 4.*

**Reading:**

- **The two types agree with the maps.** `CDKN1B` keeps its place and gains strength; `FABP7` gains a new place.
- **`CDKN1B` is close to an on/off gene.** With almost no signal at 2 DPI, "amplitude" here means appearance. The outline treats on/off as the limit $\kappa\to0$, which is consistent, but the text should say "appears at the ventricle", not "same pattern, stronger".
- **Neither example shows a failure of a competitor that the type explains.** River ranks both in its top 40. CODA ranks both near the bottom, as it does for every structured gene (see [13-q3-beyond-de.md](13-q3-beyond-de.md) section 2), so its rank does not separate amplitude from pattern. The notebook says the same and points to the designed-gene experiment of outline Figure 2a.
- **A cross-check with Q4 that needs a look.** `DDIT4` is second on the pattern list ($\rho$ 0.24, $\kappa$ 0.70), while its maps in [14-q4-effect-size.md](14-q4-effect-size.md) show a rise over the whole section. A broad rise in level being typed "pattern" should be understood before the types are reported.

**Is the location claim shown?** Only by eye, for two genes and one pair each. There is no number for "where": no enrichment of the residual by domain or cell type, and no check that the location repeats in the other eight between pairs.

**Verdict: works for the type of these two genes; no evidence yet for a quantified location.**

Result files: figures `fig/15-q5-interpretation/q5-artista-amplitude-xiclnr-cdkn1bhs-maps.png`, `-residual.png`, `q5-artista-pattern-fabp7nr-maps.png`, `-residual.png`.

## 5. Where this leaves Q5

| Claim | Supported? | Basis |
|---|---|---|
| Every call gets a pattern and an amplitude component | Yes, as a computation | 1 |
| The type describes the condition effect | Mostly: the excess over replicates gives the same type for 66% to 76% of calls; the rest move from mixed to amplitude | 1 |
| The type is stable across pairs | No evidence yet | 1 |
| Datasets differ in the share of types | Measured (pattern 0.55, 0.44, 0.18); HPOA has 11 calls | 2 |
| The type is biologically correct | Partly: NRDR direction as in the source study (7 of 7); type amplitude or mixed for 6 of 7 calls on the excess | 3 |
| The direction $\ell$ agrees with the data | Yes: same sign as pseudobulk in 11 of 11 NRDR activity genes | 3 |
| Named examples match their type on maps | Yes: `CDKN1B`, `FABP7` | 4 |
| Competitors miss amplitude changes | No evidence in real data; needs designed genes | 4 |
| Each call is localized | By eye only, two genes, one pair each | 4 |
| The type is validated against ground truth | No evidence yet (outline Figure 4d not run) | 5 |

**Status: sufficient for what this notebook shows** (a type per call, with examples that match the maps, and a direction check that agrees with the source study). The fixes listed in the earlier version are done (below). Claim 4 as a whole also needs the designed-gene validation of outline Figure 4d, which is a separate experiment. Issues are split by the rule in `CLAUDE.md` ("Level of Rigor: Fix or Defend").

**Fix.** None open. Done on 2026-11-17:

1. The NRDR hypothesis is rewritten from the source study (dark-reared mice have higher immediate early gene levels, similar in all L2/3 sublayers); the data now agree with it in direction (section 3).
2. The notebook header states that its `kappa` is the outline's $C(\kappa)$ and that the outline's $\kappa$ equals $e^{-\ell}$.
3. The residual panel shows one sampled hard matching instead of the average over matchings (section 4).

**The check that decided between fix and defend** (section 1): typing the excess over replicates keeps the type of 66% to 76% of calls, and almost no call switches between pattern and amplitude. By the rule set before the check, the simple definition is kept, and this number is the defence.

**Defend.**

| A reviewer can say | Answer |
|---|---|
| The type is the most frequent of the pair types | The medians of $\kappa$, $\rho$ and $s$ are reported next to it, and every call is shown on the plane, so the reader sees the continuous values |
| The cut points 1/3 and 2/3 are a convention | $s$ is reported; the labels are a reading aid |
| HPOA has 11 calls | Shares are shown with counts |
| "Amplitude" is not the mean level (`FABP7` is pattern type and DE) | Defined in Methods as strength of spatial structure. A uniform shift on the log scale leaves it unchanged |
| `CDKN1B` is close to an on/off gene | On/off is the limit $\kappa\to0$ in the outline. The text says "appears at the ventricle" |
| River ranks both examples high, and CODA's rank does not separate them | The claim is about the output, a type per call, not about detection. Blindness to amplitude is shown with designed genes (outline Figure 2a) |
| Location is shown by eye; there is no ground truth for the type | These are the planned panels Figure 5d and Figure 4d, not the task of this notebook |
| Pairs with $\rho\le0$ are typed pattern, including out-of-range scores | They are excluded from the excess check, which gives the same types for most calls; the clip of [14-q4-effect-size.md](14-q4-effect-size.md) bounds them once it is moved into the pipeline |
| The type is computed on the between pairs, which include replicate disagreement | The excess over replicates gives the same type for 87 of 115, 21 of 32 and 8 of 11 calls; both shares can be reported per call (section 1) |
| NRDR activity genes are mixed, not amplitude, on the between pairs | On the excess over replicates 6 of 7 are amplitude or mixed; the remaining pattern loss comes from sparse, cell-level expression, not a change of layer shape (section 3) |
| The sampled-matching panel shows one of many matchings | It is the first of the matchings the score uses, so it shows what a real matching looks like. The smoothed residual puts the change where the six-section maps show it (section 4) |
| Cosmetic: the middle panel title touches its colour bar | One line when the figure is redrawn |
| Colitis is not in the notebook | Added once the colitis replicate run is final |
| `DDIT4` is typed pattern while its level rises over the whole section | No claim rests on it |

**Decisions for you.**

1. The name of the amplitude component in the text. Recommended: keep "amplitude" and define it once as strength of spatial structure.
2. Whether NRDR stays as the biological check. Recommended: yes, as a direction check with the source study cited, and the type read on the excess.
3. Whether the paper reports the excess share next to the between-pair share for each call. Recommended: yes, as one extra column; it costs nothing and answers the replicate objection in advance.
