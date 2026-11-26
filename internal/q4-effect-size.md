# Q4 effect size: whether Delta ROS can be compared across comparisons, what the ARTISTA time course shows, which example genes hold, and how clipping out-of-range ROS keeps the scale common

This note explains the notebook [14-q4-effect-size.ipynb](14-q4-effect-size.ipynb) section by section. It follows one line: (1) the four comparisons of the ARTISTA time course and their false-label check; (2) the size of the change, $\Delta$, put on one axis across time points; (3) the trajectory of each gene; (4) two example genes, checked on maps and per-section counts; (5) why a rank inside one pair cannot do the same job; (6) the pair scores that fall outside the valid range of ROS; (7) the AD age comparison; (8) what can be claimed and what must be fixed first.

The line supports the second half of outline claim 3 ("ROS is an effect size on a common scale") and the trajectory panels Figure 5g and Figure 6d of [0-paper-outline-natcomm.md](../0-Paper-Draft/0-paper-outline-natcomm.md). Three points drift from the outline and are stated here. First, the outline plans the trajectory on the colitis severity series; the notebook uses the ARTISTA time course. Second, the "common scale" is assumed, not tested: sequencing depth differs by a factor of 2 to 3 between time points and peaks where $\Delta$ peaks. Third, about 3% of the pair scores are outside the range ROS can take, and $\Delta$ is a mean, so it is sensitive to them. Since 2026-11-17 every pair ROS is clipped to 0 to 2 before limma (`19-q4-clip-refit.py`); the calls and the time-course picture barely change (section 6). The clip is applied here only; other notebooks still read the unclipped v3 tables.

All figures are copied unchanged from the notebook (PDF in `5-Case-Study-Comparison/fig/`, PNG copies in `5-Case-Study-Comparison/fig/14-q4-effect-size/`). Paths are relative to the project root unless they are links. Numbers marked "computed for this report" come from the saved result files or the prepared sections and are not in the notebook.

**Data.**

- ARTISTA time course (`5-Case-Study-ARTISTA-Timecourse`): 16 sections on one gene panel. Each comparison is 2 DPI against one later time point, so the same three 2 DPI sections are the reference in all four comparisons.

| Comparison | Sections | Between pairs | Within pairs | False labelings | Median counts per cell, later time point |
|---|---|---|---|---|---|
| 2 vs 5 DPI | 3 vs 3 | 9 | 6 | 9 | 541 to 672 |
| 2 vs 10 DPI | 3 vs 3 | 9 | 6 | 9 | 461 to 561 |
| 2 vs 15 DPI | 3 vs 4 | 12 | 9 | 34 | 798 to 1486 |
| 2 vs 20 DPI | 3 vs 3 | 9 | 6 | 9 | 548 to 707 |

The 2 DPI sections have 556 to 776 median counts per cell (computed for this report from `data/prepared/artistatc-*-prepared.h5ad`).

- STARmap PLUS AD: 8 months (control 2 vs AD 2) and 13 months (2 vs 2).

**Score.** The effect size of gene $g$ in one comparison is

$$
\Delta_g=\overline{\mathrm{ROS}}_{g,\text{between}}-\overline{\mathrm{ROS}}_{g,\text{within}},
$$

the limma coefficient `coef_unweighted`. ROS is 0 when two sections share all the spatial structure of the gene and 1 when they share none; values above 1 mean opposite patterns, and the valid range is 0 to 2. The call is one-sided unweighted limma, BH $<0.05$, on v3 tables as in [12-q2-replicate-calibration.md](12-q2-replicate-calibration.md), refitted with every pair ROS clipped to $[0,2]$ (files `limma-genes-clip.csv`, `limma-splits-clip.csv`).

## 0. Summary

| Step | Finding |
|---|---|
| 1. Calls | 117, 249, 331 and 155 calls at 5, 10, 15 and 20 DPI (clipped ROS). False labels: largest 0, 0, 43 (15 DPI, 34 labelings) and 12. The call counts are not comparable across time points because 15 DPI has four sections |
| 2. Size on one axis | Median $\Delta$ over the 684 genes tested at every time point: 0.047, 0.094, 0.099, 0.058. Largest at 10 to 15 DPI. Not yet separated from depth: 10 DPI has the lowest and 15 DPI the highest counts per cell |
| 3. Trajectories | Of 426 genes called at least once, $\Delta$ peaks at 5, 10, 15, 20 DPI for 38, 132, 168, 88 genes. No uncertainty on the peak |
| 4. Examples | `DDIT4` holds as an increase that is clear at 20 DPI ($\Delta$ 0.50); it is a change of level (global $\log_2$ fold change 2.17). `ZIC1` replaces `NPTXR` as the transient example ($\Delta$ 0.03, 0.16, 0.47, 0.05; BH 0.002 at 15 DPI): in all four 15 DPI sections it forms one band across the dorsal midline, and the two dorsolateral patches return at 20 DPI. `NPTXR` was removed because its mean count is about 40 times lower in all three 10 DPI sections |
| 5. Ranks | The rank of the same gene's ROS varies widely between pairs (46 to 1059 for `ZIC1` at 15 DPI). This is shown for stORCA's own ROS, not for River or CODA |
| 6. Out of range and clip | 360 to 373 pair scores per comparison (2.0 to 3.3%) are below 0 or above 2, from -37 to 60. Clipping every pair ROS to 0 to 2 changes the calls from 111, 250, 325, 151 to 117, 249, 331, 155 and loses 0, 3, 1, 4 calls; the medians of $\Delta$ move by 0.003 at most. The time-course result does not depend on these scores |
| 7. AD ages | No consistent increase of $\Delta$ from 8 to 13 months. Not usable |
| 8. Fix or defend | The clip is done. Both fixes are done: `NPTXR` is replaced by `ZIC1` (2026-11-19) and the plaque ratio in the notebook text is corrected (1.75). Depth and every other issue are recorded with their defence in section 8 |

## 1. ARTISTA: calls and false-label check per comparison (notebook section 1)

**Question.** Is each of the four comparisons a valid replicate analysis before their sizes are compared?

**In plain words.** Before asking "at which time point is the change largest", each comparison must pass the check of Q2: when the sections are grouped in a way that does not follow the time point, the calls should mostly disappear.

**Implementation** (notebook section 1; `5-Case-Study-ARTISTA-Timecourse/res/stORCA/storca-v3-rep1-artistatc<day>-limma-genes.csv` and `-limma-splits.csv`, rows `weighting == "unweighted"`).

1. Calls: genes with `adj_p_one_unweighted` $<0.05$.
2. False labelings: every other split of the sections into groups of the same sizes. The notebook reports the largest count.
3. Median ROS of the between pairs and of the within pairs over the tested genes.

![Calls per comparison](fig/14-q4-effect-size/q4-artista-timecourse-calls.png)

*Coloured bars: calls on the true labels. Grey bars: largest count over the false labelings. Takeaway: grey is 0 at 5 and 10 DPI. Source: [14-q4-effect-size.ipynb](14-q4-effect-size.ipynb) section 1.*

**Result.**

| Comparison | Genes tested | Calls | False labelings with any call | Largest count | Median ROS, within | Median ROS, between |
|---|---|---|---|---|---|---|
| 2 vs 5 DPI | 753 | 117 | 0 of 9 | 0 | 0.245 | 0.306 |
| 2 vs 10 DPI | 782 | 249 | 0 of 9 | 0 | 0.255 | 0.373 |
| 2 vs 15 DPI | 878 | 331 | 3 of 34 | 43 | 0.298 | 0.419 |
| 2 vs 20 DPI | 774 | 155 | 1 of 9 | 12 | 0.289 | 0.374 |

Numbers are after the clip of section 6; before the clip they were 111, 250, 325, 151 calls and largest false counts 0, 0, 40, 10.

**Are the 43 calls at 15 DPI false positives?** Mostly not (computed for this report from the `limma-splits-clip.csv` file). In a 3 vs 4 design some "false" labelings are one section away from the truth. The labeling with 43 calls puts `dpi15-r2, dpi15-r3, dpi15-r4` in one group and the three 2 DPI sections plus `dpi15-r1` in the other. The labeling with 11 calls is the same with a different 15 DPI section moved. Calls are expected there. The 12 calls at 20 DPI come from the labeling `dpi2-r1, dpi2-r2, dpi20-r1` against the rest, the same one that gives 18 calls in Q2; it needs a look at the sections.

**Statistical consequence of the design.** The number of calls is not a measure of the size of the change. 15 DPI has 21 pairs instead of 15 and more genes tested, so it has more power. That is the reason the rest of the notebook uses $\Delta$ and not the call count.

**Verdict: works for 5 and 10 DPI; works for 15 DPI once near-true labelings are separated; 20 DPI needs the section check.**

## 2. ARTISTA: the size of the change on one axis (notebook section 2)

**Question.** Is the change relative to 2 DPI larger at some time points than at others?

**In plain words.** A rank says "this gene is the 30th most changed in this pair". A p-value says "this change is unlikely to be chance, given this many sections". Neither is a size. $\Delta$ is a size: $\Delta=0.10$ means that the between pairs fail to share 10 percentage points more of the gene's spatial structure than replicates do. Because that unit does not depend on which other genes were measured or on how many sections there were, a $\Delta$ at 5 DPI can be put next to a $\Delta$ at 15 DPI. This is what River and CODA (ranks inside a pair) and DESpace2 and SpaceExpress (p-values) do not give.

**Implementation** (notebook section 2).

1. Keep the 684 genes tested in all four comparisons.
2. Compare the distribution of $\Delta_g$ (`coef_unweighted`) across the four comparisons.

![Distribution of Delta per time point](fig/14-q4-effect-size/q4-artista-delta-distribution.png)

*One violin per comparison with the median marked. Dashed line: $\Delta=0$. Takeaway: the medians at 10 and 15 DPI are about twice those at 5 and 20 DPI. Source: [14-q4-effect-size.ipynb](14-q4-effect-size.ipynb) section 2.*

**Result** (684 genes).

| | 5 DPI | 10 DPI | 15 DPI | 20 DPI |
|---|---|---|---|---|
| Median $\Delta$ | 0.047 | 0.094 | 0.099 | 0.058 |
| Mean $\Delta$ | 0.077 | 0.120 | 0.113 | 0.094 |
| 25% to 75% | 0.008 to 0.127 | 0.042 to 0.179 | 0.035 to 0.174 | 0.017 to 0.146 |
| Smallest, largest | -0.26, 0.59 | -0.20, 0.77 | -0.30, 0.59 | -0.27, 0.67 |

After the clip of section 6. Before the clip the smallest and largest were -3.01 and 6.61 and the medians 0.049, 0.096, 0.102, 0.058.

**Is the scale really common?** Three things besides biology can move $\Delta$. The first two can be defended; the third is removed by the clip (section 6):

- **Depth.** The 10 DPI sections have the lowest counts per cell (461 to 561) and the 15 DPI sections the highest (798 to 1486). The two time points with the largest median $\Delta$ are the two that differ most from 2 DPI in depth, in opposite directions. ROS removes a global shift on the log scale, but a depth change is not a pure shift after `log1p` and the cap. The notebook has no control for this.
- **The within baseline.** $\Delta$ subtracts the within pairs of both groups, so the baseline changes with the later time point (median within ROS 0.238 to 0.294).
- **Out-of-range scores.** Before the clip a $\Delta$ of -3.01 or 6.61 appeared, which cannot come from scores in the range 0 to 2. After the clip $\Delta$ lies in -0.30 to 0.77 and the medians move by 0.003 at most (section 6).

**Verdict: works as a description of the time course.** The medians follow a rise and fall. Depth is a caveat that can be defended (section 8), and the depth-matched downsampling already listed in the outline Supplementary answers it if a reviewer asks.

## 3. ARTISTA: trajectory of each gene (notebook section 3)

**Question.** For each gene, at which time point is the change relative to 2 DPI largest?

**Implementation** (notebook section 3).

1. Keep the 426 of 684 genes called in at least one comparison.
2. Peak time point: the comparison with the largest $\Delta_g$.
3. Heat map of $\Delta_g$ over the four time points, genes sorted by peak.

![Trajectories](fig/14-q4-effect-size/q4-artista-delta-trajectories.png)

*Rows: 426 genes sorted by peak time point. Columns: 5, 10, 15, 20 DPI. Colour: $\Delta$, red positive. Takeaway: most genes peak at 10 or 15 DPI. Source: [14-q4-effect-size.ipynb](14-q4-effect-size.ipynb) section 3.*

**Result.** Peak at 5, 10, 15, 20 DPI: 38, 132, 168, 88 genes (clipped ROS).

Caveats. The peak is the largest of four noisy numbers with no interval, so a gene with $\Delta$ of 0.20 and 0.21 at two time points is assigned to one of them by chance. "Called at least once" favours 15 DPI, which has the most power. And 132 genes peaking at 10 DPI inherit the depth question of section 2.

**Verdict: partial; descriptive only until the peak has an uncertainty.**

## 4. ARTISTA: example genes (notebook section 4)

**Question.** Can we show one gene whose change grows over time and one whose change comes and goes, with maps that agree?

**Selection rules in the notebook.**

1. Increasing: $\Delta$ rises from 5 to 10 to 15 DPI, stays at 80% or more of the 15 DPI value at 20 DPI, and the gene is called at 20 DPI. Take the largest $\Delta$ at 20 DPI.
2. Transient: called at 10 or 15 DPI, the peak is at 10 or 15 DPI, and $\Delta$ at 5 and at 20 DPI is at most half the peak. Take the largest peak.
3. Both: mean log1p expression above 0.3 in the sections of the relevant time points, so the maps can be read.

**Result, checked for this report.**

| Gene | $\Delta$ at 5, 10, 15, 20 DPI | BH at 5, 10, 15, 20 DPI | What the sections show | Holds? |
|---|---|---|---|---|
| `DDIT4` | 0.035, 0.091, 0.149, 0.502 | 0.52, 0.15, 0.016, below 0.001 | mean count 0.30 to 0.47 at 2 DPI, 1.43 to 1.79 at 20 DPI; brighter over the whole section at 20 DPI | yes, for 20 DPI |
| `ZIC1` | 0.034, 0.156, 0.471, 0.054 | 0.25, 0.15, 0.002, 0.10 | dorsal pallium: two dorsolateral patches at 2, 5, 10 and 20 DPI; at 15 DPI one strong band across the dorsal midline in all four sections | yes |
| `NPTXR` (removed) | 0.025, 0.772, 0.285, 0.014 (v3) | 0.23, below 0.001, 0.021, 0.34 (v3) | mean count 0.17 to 0.23 in all three 10 DPI sections, 5.6 to 15.6 in the other 13 sections | no |

![DDIT4 ROS per pair](fig/14-q4-effect-size/q4-artista-increasing-ddit4-pair-ros.png)

*One column per comparison. Grey: within pairs. Colour: between pairs. Takeaway: only at 20 DPI are the between pairs (0.65 to 0.88) clear of the within pairs (0.12 to 0.49); at 5, 10 and 15 DPI the two overlap. Source: [14-q4-effect-size.ipynb](14-q4-effect-size.ipynb) section 4.*

**`DDIT4`: an increase, but of level.** The pair plot supports "larger at 20 DPI than at any earlier time point". It does not support a steady rise: the first three values are inside the replicate spread. `DDIT4` is also a global DE gene at 20 DPI ($\log_2$ fold change 2.17), so this example shows that $\Delta$ tracks a change that pseudobulk also sees.

![ZIC1 ROS per pair](fig/14-q4-effect-size/q4-artista-transient-zic1-pair-ros.png)

*One column per comparison. Grey: within pairs. Colour: between pairs. Takeaway: only at 15 DPI are the between pairs (0.16 to 1.12) clear of the within pairs (0.06 to 0.20); at 5 and 20 DPI the two overlap again. Source: [14-q4-effect-size.ipynb](14-q4-effect-size.ipynb) section 4.*

![ZIC1 maps](fig/14-q4-effect-size/q4-artista-transient-zic1-maps.png)

*One section per time point (replicate 1), shared colour scale. Source: [14-q4-effect-size.ipynb](14-q4-effect-size.ipynb) section 4.*

![ZIC1 all sections](fig/14-q4-effect-size/q4-artista-transient-zic1-all-sections.png)

*All 16 sections, kNN-15 smoothed log1p, shared colour scale. Takeaway: the band across the dorsal midline is present in all four 15 DPI sections and in none of the other twelve. Source: [14-q4-effect-size.ipynb](14-q4-effect-size.ipynb) section 4b.*

**`ZIC1`: a transient change of pattern, with a level change on top.** Checks (notebook section 4b, v4 pair scores):

- In every section of 2, 5, 10 and 20 DPI the gene sits in two dorsolateral patches, one per hemisphere. In all four 15 DPI sections it forms one strong band across the dorsal midline, and the class with the highest mean moves to `ntng1IN` (3 of 4 sections) or `scgnIN`. At 20 DPI the two patches return.
- It is not only depth. 15 DPI has the highest counts per cell, but the share of `ZIC1` in the total counts is also higher there: 9.7 to 12.8 per 10k against 5.6 to 8.3 at 2, 5 and 20 DPI (10 DPI 8.1 to 10.8). So a level change of about 1.5 to 2-fold rides on the pattern change; the text says "transient change", not "pattern only".
- It does not rest on two pairs. At 15 DPI 11 of 12 between pairs lie above the largest within pair (0.20). The between pairs split into a high group (0.72 to 1.12) and a low group (0.16 to 0.36); `dpi15-r4` is in the high group with all three 2 DPI sections. Without the three `dpi15-r4` pairs, $\Delta$ is still 0.38.
- Selection rule added to the notebook: genes whose mean count at one time point is more than 10-fold off the other sections in every replicate are skipped (`abrupt_level_shift`). This rule removes `NPTXR`, and `ZIC1` is the next candidate.

**Why `NPTXR` was removed** (former transient example, checked on 2026-11-17):

![NPTXR maps](fig/14-q4-effect-size/q4-artista-transient-nptxr-maps.png)

*One section per time point (replicate 1), shared colour scale. Takeaway: the gene is nearly absent from the whole 10 DPI section and strong in the same regions at every other time point. The 10 DPI panel is drawn small because of a few stray cells far from the tissue. Source: [14-q4-effect-size.ipynb](14-q4-effect-size.ipynb) section 4.*


- Its mean count is about 40 times lower in every 10 DPI section than in every other section, including 5 and 15 DPI on either side.
- Among 640 genes with more than 200 CPM outside 10 DPI, it is the only one that is more than 4-fold lower at 10 DPI. A gene that switches off in all cells at one time point and returns, alone, points at a probe, annotation or gene-ID problem in the 10 DPI data before it points at regeneration.
- Its 15 DPI value rests on two pairs. Worked through the formula with the 15 DPI pair scores:

| Pairs | ROS values | Mean |
|---|---|---|
| Within (9) | 0.08, 0.10, 0.04, 0.06, 0.06, 0.10, 0.04, 0.11, 0.07 | 0.073 |
| Between (12) | 0.19, 0.33, 0.31, 0.26, 1.20, 0.15, 0.88, 0.14, 0.12, 0.35, 0.15, 0.21 | 0.358 |

$\Delta = 0.358 - 0.073 = 0.285$. The two large values, 1.20 and 0.88, are `dpi2-r2` against `dpi15-r1` and against `dpi15-r3`. Without them the between mean is 0.221 and $\Delta$ is 0.148.

The next candidates by the same rule were `ZIC1`, `TAC1`, `CCK` and `PENK`. `ZIC1` has a mean count of 1.09 to 1.59 in the four 15 DPI sections against 0.37 to 0.56 in the other 12, which is consistent across replicates; it should be checked on maps first. `TAC1` and `CCK` vary 10-fold between replicates of one time point (0.03 to 0.31 at 2 DPI) and are poor candidates.

**Verdict: `DDIT4` works for 20 DPI; `ZIC1` works as the transient example at 15 DPI. `NPTXR` is removed.**

Result files: `5-Case-Study-ARTISTA-Timecourse/res/stORCA/storca-v3-rep1-artistatc<day>-limma-pair-scores.csv` (columns `gene`, `pair`, `ROS`, `usable`, `blank`).

## 5. A rank inside one pair cannot be compared across comparisons (notebook section 5)

**Question.** Could the rank of a gene inside each pair do the job of $\Delta$?

**In plain words.** A rank depends on the other genes. If many genes change at 15 DPI, a gene whose own change stayed the same falls in rank. So a rank cannot say whether the change of one gene grew.

**Implementation** (notebook section 5). For the two example genes and each comparison: the rank of the gene's ROS among all genes, in every between pair; the smallest and largest rank are reported next to $\Delta$.

**Result.**

| Gene | Day | $\Delta$ | Best rank | Worst rank | Genes ranked |
|---|---|---|---|---|---|
| `DDIT4` | 5 | 0.035 | 367 | 896 | 947 |
| `DDIT4` | 10 | 0.091 | 326 | 684 | 981 |
| `DDIT4` | 15 | 0.149 | 425 | 915 | 1155 |
| `DDIT4` | 20 | 0.502 | 140 | 255 | 949 |
| `ZIC1` | 5 | 0.034 | 639 | 826 | 947 |
| `ZIC1` | 10 | 0.156 | 61 | 907 | 981 |
| `ZIC1` | 15 | 0.471 | 46 | 1059 | 1155 |
| `ZIC1` | 20 | 0.054 | 705 | 893 | 949 |

**Is this a result about the competitors?** No. The ranks are of stORCA's own ROS. The table shows that one pair is noisy and that averaging over pairs is needed, which is the Q2 point. For the claim against River and CODA, their ranks on the time-course pairs are needed, and they have not been run on this dataset. Note also that with a strong change (`DDIT4` at 20 DPI) the rank range is narrow, so ranks do carry the large effects; `ZIC1` at 15 DPI, with a larger $\Delta$, still ranks from 46 to 1059 because its pairs split into a high and a low group.

**Verdict: partial; the argument is correct in principle, the evidence for the named competitors is missing.**

## 6. Caution: ROS outside its range (notebook section 5b)

**Question.** How many pair scores are outside the range that ROS can take, and do they reach the calls?

**In plain words.** ROS is a ratio. Its denominator, $Q(x)+Q(y)$, measures how much spatial structure the gene has in the two sections. For a gene with almost no structure in a pair the denominator is near 0, and because the spatial weight matrix is not positive semidefinite it can even be negative. Dividing by a number near 0 gives values such as -37 or 60. Rule 3 of v3 ("kept genes use all pairs") lets these values into limma.

**Why it matters here.** $\Delta$ is a difference of means, and limma's variance is a mean of squares. One value of 60 among 15 pairs changes both. So this is not cosmetic for a notebook whose subject is the size of $\Delta$.

**Result** (notebook section 5b; tested genes, blank probes excluded).

| Day | Pair scores | Outside 0 to 2 | Of these, flagged not evaluable | Genes affected | Calls | Calls with such a pair | Smallest ROS | Largest ROS |
|---|---|---|---|---|---|---|---|---|
| 5 | 11295 | 373 | 114 | 193 | 111 | 16 | -26.17 | 4.03 |
| 10 | 11730 | 360 | 137 | 186 | 250 | 42 | -37.22 | 14.05 |
| 15 | 18438 | 370 | 139 | 187 | 325 | 52 | -5.08 | 6.41 |
| 20 | 11610 | 373 | 158 | 197 | 151 | 27 | -28.81 | 60.39 |

About two thirds of the out-of-range scores are in pairs the pipeline itself flags as evaluable, so dropping the non-evaluable pairs alone does not remove them.

**What each fix would mean.**

| | Current (v3) | Clip ROS to 0 to 2 | Use only matchings with a positive denominator |
|---|---|---|---|
| What enters limma | every pair score, any value | every pair, bounded | only well-defined ratios |
| Meaning of an extreme value | arbitrary | "no shared structure" or "opposite" | not produced |
| Pairs per gene | all | all | all, fewer matchings in some |
| Cost | $\Delta$ and variance distorted for about 190 genes | hides the cause | changes the score definition; needs a rerun |

**Tried first: a positive-denominator gene filter** (`21-positive-denominator-filter.py`, 2026-11-17). Rule A keeps a gene only if $\sum_s[Q_s(x)+Q_s(y)]>0$ in every pair; rule B asks $\sum_s Q_s(x)>0$ and $\sum_s Q_s(y)>0$ in every pair.

| Case | Tested | Calls | Kept by A (genes, calls) | Kept by B (genes, calls) |
|---|---|---|---|---|
| 2 vs 5 DPI | 753 | 111 | 750, 110 | 712, 105 |
| 2 vs 10 DPI | 782 | 250 | 775, 250 | 741, 244 |
| 2 vs 15 DPI | 878 | 325 | 874, 324 | 812, 307 |
| 2 vs 20 DPI | 774 | 151 | 764, 151 | 733, 143 |
| ARTISTA 2 vs 20 | 782 | 115 | 771, 115 | 735, 112 |
| Colitis | 490 | 27 | 489, 27 | 473, 26 |
| HPOA, NRDR, LIBD, Allen | 149 to 664 | 0 to 32 | all but 0 to 2 genes, all calls | all but 0 to 32 genes, all calls |

**Rule A is cheap but does not remove the problem.** Of the out-of-range scores, 371 of 373, 346 of 360, 362 of 370 and 358 of 373 belong to genes that pass rule A, and almost all of them (370, 346, 359, 356) have $Q_r<0$: the numerator is negative, not the denominator. So a filter on the denominator cannot fix the range, and the clip is the simplest change that does.

**Clip applied** (`19-q4-clip-refit.py`, 2026-11-17). Every pair ROS is clipped to $[0,2]$ in the stored pair-score table, and the same v3 limma fit is rerun with all labelings. No matching or scoring is rerun. The notebook now reads the clipped tables; section 5b shows both.

| Day | Pair scores clipped (all genes) | Calls before | Calls after | Kept | Lost | Gained | Largest false-label count after (before) |
|---|---|---|---|---|---|---|---|
| 5 | 815 | 111 | 117 | 111 | 0 | 6 | 0 (0) |
| 10 | 790 | 250 | 249 | 247 | 3 | 2 | 0 (0) |
| 15 | 1060 | 325 | 331 | 324 | 1 | 7 | 43 (40) |
| 20 | 806 | 151 | 155 | 147 | 4 | 8 | 12 (10) |

The clipped count is larger than the out-of-range count of the first table because it covers every gene in the pair-score file, not only the genes kept by limma. Median $\Delta$ becomes 0.047, 0.094, 0.099, 0.058 (before 0.049, 0.096, 0.102, 0.058), and the peak counts become 38, 132, 168, 88 (before 38, 133, 165, 88).

**Reading:**

- **The out-of-range scores did not drive the result.** 829 of 837 calls are kept, and the shape of the time course is the same.
- **The clip keeps every pair and has a direct meaning**: a score at 2 means "opposite patterns", the most a pair can disagree.

**Verdict: works; the clip removes the conflict with "common scale" without changing the conclusion.** Result files: `5-Case-Study-Comparison/res/Comparison/q4-clip-refit-summary.csv`, `5-Case-Study-ARTISTA-Timecourse/res/stORCA/storca-v3-rep1-artistatc<day>-limma-genes-clip.csv`.

## 7. STARmap PLUS AD: 8 against 13 months (notebook section 6)

**Question.** Is $\Delta$ larger at 13 months, when there are more plaques?

**Implementation** (notebook section 6; `5-Case-Study-AD-STARmap/res/stORCA/storca-v3-rep1-ad-limma-genes-m8.csv` and `-m13.csv`). The limma design is fitted per age with 2 vs 2 sections (4 between pairs, 2 within pairs). Plaques are counted per disease section. There are no calls at 2 vs 2, so only $\Delta$ is compared, for the 10 genes with the largest $t$ in the pooled analysis.

![AD by age](fig/14-q4-effect-size/q4-ad-age-delta.png)

*Left: plaques per disease section. Right: $\Delta$ at 13 months against $\Delta$ at 8 months, one point per gene, top 10 genes in red, dashed diagonal. Takeaway: the red points are on both sides of the diagonal. Source: [14-q4-effect-size.ipynb](14-q4-effect-size.ipynb) section 6.*

**Result.** Plaques: 88 and 99 at 8 months, 192 and 136 at 13 months, 1.75 times as many (the notebook summary now says 1.75; it said about 1.6 before 2026-11-17). $\Delta$ rises for `C1qa` (0.153 to 0.248), `Nefh` (0.123 to 0.228) and `Slc32a1` (0.097 to 0.313), and falls for `Gfap` (0.162 to 0.124), `Clstn1` (0.228 to 0.098), `Nnat` (0.111 to 0.050), `Slc17a7` (0.097 to -0.005) and `Slco1a4` (0.123 to 0.037).

**Why it fails.** With 2 within pairs per age, $\Delta$ of one gene has almost no replication, and the pooled AD analysis itself is not calibrated (1 call, up to 10 on false labels, see [13-q3-beyond-de.md](13-q3-beyond-de.md) section 4).

**Verdict: fail. Correctly excluded by the notebook.**

## 8. Where this leaves Q4

| Claim | Supported? | Basis |
|---|---|---|
| Each time-course comparison passes the false-label check | Yes at 5 and 10 DPI; 15 DPI after separating near-true labelings; 20 DPI open | 1 |
| $\Delta$ is on a common scale across comparisons | Assumed, not tested (depth, baseline) | 2 |
| The change relative to 2 DPI is largest at 10 to 15 DPI | Medians say so; depth not excluded | 2 |
| Genes have distinct peak times | Descriptive; no uncertainty | 3 |
| A named gene shows a growing change | Yes at 20 DPI: `DDIT4`, a change of level | 4 |
| A named gene shows a transient change | Yes at 15 DPI: `ZIC1`, a dorsal midline band in all four 15 DPI sections, with a level change on top | 4 |
| Ranks of River and CODA cannot be compared across comparisons | Not shown; only stORCA's own ranks | 5 |
| All pair scores entering $\Delta$ are valid | Yes after the clip; the clip keeps 829 of 837 calls | 6 |
| $\Delta$ follows AD progression | No | 7 |

**Status: sufficient after the fixes below.** The clip is applied and leaves the time-course picture unchanged (section 6). The transient example is now `ZIC1`, which holds on all sections (section 4). Issues are split by the rule in `CLAUDE.md` ("Level of Rigor: Fix or Defend").

**Fix.**

None open. Done on 2026-11-19: `NPTXR` is replaced by `ZIC1` after a look at all 16 sections (notebook section 4b), and the 10-fold level-shift rule is in the selection.

**Defend.**

| A reviewer can say | Answer |
|---|---|
| Depth differs between time points | ROS is a ratio of spatial structure, and the within pairs of each time point are subtracted. $\Delta$ is high both at the lowest depth (10 DPI) and at the highest (15 DPI). Depth-matched downsampling is already planned in the outline Supplementary |
| Call counts differ in power (15 DPI has four sections) | This is the reason $\Delta$, not the count, is compared |
| A false labeling at 15 DPI gives 43 calls | That labeling differs from the truth by one section, so calls are expected |
| One of 9 false labelings at 20 DPI gives 12 calls | 8 of 9 give 0, and 12 is far below 155 |
| The peak time has no interval | The trajectories are descriptive and labelled so, as in outline Figure 5g |
| `DDIT4` is a change of level, clear only at 20 DPI | $\Delta$ may follow a DE gene; the point is its size over time. The text says "largest at 20 DPI", not "steady rise" |
| The rank table uses stORCA's own single-pair ranks | The argument holds for any rank inside a pair. The text says "single-pair rank", not River or CODA |
| The clip changes the score, so it is a method change | It keeps every pair and only bounds values to the range the score can take; 829 of 837 calls are kept (section 6). The clip must be applied in every notebook before the paper, not only here |
| AD by age shows no trend | The notebook already excludes it |
| Cosmetic: stray cells in `dpi10-r1` and `dpi20-r2`, old `pgam1` and `faslg` figure files | One line each when the figures are redrawn |

**Decisions for you.**

1. Move the clip into the pipeline (`storca/replicate_case_studies.py`, before `fit_design`) so that every dataset uses it. Recommended: yes; it is now tested on four comparisons, where it loses 8 and adds 23 calls out of 837.
2. Whether the effect-size trajectory stays on ARTISTA or moves to the colitis severity series named in the outline. Recommended: ARTISTA, since it has replicates at every time point; note it in the outline.
