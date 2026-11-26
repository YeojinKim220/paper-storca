# Q2 replicate calibration: what single-pair rankings pick up, how the replicate contrast behaves on false labels, why a single-pair null is too narrow, and which examples hold

This note explains the notebook [12-q2-replicate-calibration.ipynb](12-q2-replicate-calibration.ipynb) section by section. It follows one line: (1) the problem, that the top "condition" genes of single-pair methods are also top genes when two replicates are compared, and that single-pair tests call most genes on replicate pairs; (2) the check that stORCA's replicate contrast gives no calls on false labels, that the replicate design repairs the ranking of any score, and that only ROS turns it into calls; (3) the cause, that the variation inside one pair is far smaller than the variation between replicates; (4) the example genes, and whether each one survives a look at the maps; (5) what can be claimed and what must be fixed first.

The line supports claim 3 of the outline, replicate calibration (Figure 3 of [0-paper-outline-natcomm.md](../0-Paper-Draft/0-paper-outline-natcomm.md)). Figure 3b of the outline is now section 1b, section 1c tests whether a single pair can be calibrated from its own genes, and colitis is included since the rerun on 2026-11-16. One point still drifts and is stated here: the overlap result of section 1 holds for every method only in HPOA; CODA looks clean in most datasets, but that is mostly an artifact of the gene universe (section 1).

All figures are copied unchanged from the notebook (PDF in `5-Case-Study-Comparison/fig/`, PNG copies in `5-Case-Study-Comparison/fig/12-q2-replicate-calibration/`). Paths are relative to the project root unless they are links. Numbers marked "computed for this report" were derived from the saved result files and are not in the notebook.

**Data.** Six multi-replicate case studies. A within pair compares two sections of the same condition, so any difference in it is replicate variation by construction. A between pair compares a control section with a treated section.

| Case | Design | Between pairs | Within pairs | False labelings | Genes tested by stORCA |
|---|---|---|---|---|---|
| LIBD DLPFC (no condition, a null dataset) | 3 vs 3 | 9 | 6 | 9 | 664 of 3000 |
| HPOA (naive vs aggression) | 3 vs 3 | 9 | 6 | 9 | 149 of 160 |
| NRDR V1 posterior (normal vs dark reared) | 2 vs 2 | 4 | 2 | 2 | 377 of 500 |
| NRDR V1 anterior | 2 vs 2 | 4 | 2 | 2 | 363 of 500 |
| ARTISTA (2 DPI vs 20 DPI) | 3 vs 3 | 9 | 6 | 9 | 782 of 3000 |
| Colitis (D0 vs D3) | 3 vs 4 | 12 | 9 | 34 | 490 of 989 |

Colitis here is `5-Case-Study-Colitis-Replicate`: slice 1 of one section per mouse, D0 mice `m3a`, `m6`, `m7` against D3 mice `m1` to `m4` (biological replicates). It is not the slice set chosen on 2026-11-16 (D0 `0629-m3a-r2` slices 1 to 3, D3 `0924-m1-r1` or `0924-m3-r1` slices 1 to 3), which takes three slices of one mouse per condition. For calibration the mouse-level design is the right one, because slices of one mouse underestimate the replicate variation (in Q1 such a design calls 425 of 502 genes).

**Score.** For gene $g$ and pair $p$, with $x$ the source expression, $y$ the matched target expression and $Q(v)=\tilde v^\top W\tilde v$ the centered spatial quadratic form,

$$
\mathrm{ROS}_{g,p}=\frac{Q(x-y)}{Q(x)+Q(y)},\qquad
\Delta_g=\overline{\mathrm{ROS}}_{g,\text{between}}-\overline{\mathrm{ROS}}_{g,\text{within}} .
$$

ROS is near 0 when the two sections share the spatial structure of the gene and near 1 when they share none. $\Delta_g$ is the excess of the between pairs over the within pairs. The call is a one-sided unweighted limma test of $\Delta_g>0$ on the pair scores, BH $<0.05$.

**Rules of the v3 pipeline.**

1. Gene gate: a whole gene is dropped when its Moran's I is $\le 0.03$ in every section of the study.
2. Evaluability: a whole gene is dropped when it can be scored in fewer than 60% of the pairs.
3. Kept genes use the ROS of all pairs. Blank probes are never tested.

## 0. Summary

| Step | Finding |
|---|---|
| 1. Problem | In HPOA, 0.50 to 0.80 of each method's top 20 between genes are also in its top 20 within genes (chance 0.13). Outside HPOA the picture is mixed: River 0.15 to 0.63, SpaceExpress 0.94 in ARTISTA, CODA 0.00 to 0.14. CODA's low values come from ranking over all panel genes; on the 782 genes stORCA tested in ARTISTA, CODA rises from 0.14 to 0.55 |
| 1b. Single-pair tests | stORCA's former single-pair test, SpaceExpress and STcompare call 34% to 94% of the genes on within pairs (median per dataset), against 5% expected; between pairs are only 0.00 to 0.18 higher |
| 1c. Gene-bulk null | Judging each gene against the 50 genes of the same pair with the closest structure strength brings within-pair calls down from 34% to 94% to 2% to 8% (BH) and recovers 18% to 77% of the replicate-design calls on between pairs (p < 0.05), against 0% to 14% on within pairs. Better, but still not a usable single-pair test: within pairs stay above the nominal level, between pairs are called as often as within pairs in total, and at BH it recovers 0% to 55% of the replicate-design calls |
| 2. Replicate contrast | LIBD: 0 calls of 664 genes on the true labels and on all 9 false labelings. HPOA: 11 calls, 0 on false labels. NRDR: 32 and 11 calls, 0 on false labels, but only 2 false labelings exist. ARTISTA: 115 calls, and 1 of 9 false labelings gives 18. Colitis: 27 calls, and 1 of 34 false labelings gives 26 |
| 2b. Replicate design, scores | Read through the replicate design, the true labeling has the largest top effect in 15 of 19 method and dataset combinations outside LIBD, for every method; in LIBD it is 4th of 10 |
| 2c. Four comparisons | 1 vs 1 fails in both readings for every method; the replicate design repairs the ranking for every method; only ROS turns the design into calls (competitors 0 to 3 calls, except River in ARTISTA) |
| 3. Cause | The replicate variance of ROS is 26 to 155 times the matching variance inside one pair (median over genes). A null built inside one pair cannot contain replicate differences |
| 4. False-positive examples | `Blank_2`, `Mki67` and `Oxt` hold. `Gbx2` holds as an example but the notebook text about it is wrong. `Sema4d` does not hold: it is a pseudobulk DE gene (global FDR 0.005), not replicate variation |
| 5. True-positive example | `Cpne5` holds (within ROS 0.23, between 0.55, BH 0.008), but River and SpaceExpress also rank it high and it is a global DE gene |
| 6. Fix or defend | Four fixes: drop the River example, correct the `Gbx2` sentence, look at the colitis false labeling with 26 calls, rank all methods on the same genes in the section 1 figure. Every other issue is recorded with its defence in section 6 |

## 1. Single-pair methods: do the top between genes also top the within pairs? (notebook section 1)

**Question.** If a method ranks genes from one pair of sections, are its top "condition" genes different from the genes it ranks top when both sections come from the same condition?

**In plain words.** Take a method, compare a naive section with an aggression section, and write down the 20 most "changed" genes. Now compare two naive sections, where nothing changed, and write down the 20 most "changed" genes again. If the two lists are nearly the same, the first list cannot be read as the effect of aggression. The method is finding genes that always differ between two sections.

**Why it matters.** CODA, River, STcompare and SpaceExpress compare one pair and have no test at the replicate level. This check asks whether their output can be read as a condition effect at all. It is the motivation for the replicate design, which none of them has.

**Implementation** (`5-Case-Study-Comparison/02-compare-methods.py`, read by the notebook from `res/Comparison/<case>-method-summary.csv`, column `top_between_in_top_within`).

1. For each method, every pair gets the native score, oriented so that larger means more differential (CODA: minus CCI; River: minus rank; STcompare: minus correlation; SpaceExpress: minus score; "stORCA single pair": ROS).
2. Per gene, average the score over the between pairs and, separately, over the within pairs.
3. Take the top $N$ genes of each average, with $N=\max(20,\ \text{number of stORCA calls})$. So $N=20$ in LIBD, HPOA and NRDR anterior, 32 in NRDR posterior, 115 in ARTISTA.
4. Report the overlap

$$
\text{overlap}=\frac{|\text{top}_N(\text{between})\cap\text{top}_N(\text{within})|}{N} .
$$

A method needs a result for every pair of the case, otherwise it is skipped. That is why STcompare appears only in HPOA, SpaceExpress only in HPOA and ARTISTA, and River not in LIBD.

![Overlap of top between genes with top within genes](fig/12-q2-replicate-calibration/q2-top-between-in-top-within.png)

*One group of bars per dataset, one bar per method (legend: `fig/12-q2-replicate-calibration/q2-method-legend.png`). Height: fraction of the top $N$ between genes that are also in the top $N$ within genes. Takeaway: in HPOA every method is at 0.50 or above. Source: [12-q2-replicate-calibration.ipynb](12-q2-replicate-calibration.ipynb) section 1.*

**Result.** Notebook values, with the chance level $N/n$ for two random lists of $N$ genes out of $n$ (computed for this report):

| Case | $N$ | stORCA single pair | CODA | River | STcompare | SpaceExpress | Chance, stORCA-tested genes | Chance, all panel genes |
|---|---|---|---|---|---|---|---|---|
| LIBD | 20 | 0.70 | 0.00 | not run | not run | not run | 0.03 | 0.007 |
| HPOA | 20 | 0.80 | 0.75 | 0.60 | 0.55 | 0.50 | 0.13 | 0.13 |
| NRDR posterior | 32 | 0.47 | 0.09 | 0.53 | not run | not run | 0.08 | 0.06 |
| NRDR anterior | 20 | 0.35 | 0.00 | 0.15 | not run | not run | 0.06 | 0.04 |
| ARTISTA | 115 | 0.64 | 0.14 | 0.63 | not run | 0.94 | 0.15 | 0.04 |
| Colitis | 27 | 0.63 | 0.07 | 0.81 | not run | not run | 0.06 | 0.03 |

**The stORCA single-pair score has the same problem (0.35 to 0.80).** So the score alone does not solve it. The replicate design does.

**Is the comparison fair across methods?** Not yet. The stORCA row ranks only the genes stORCA tested (782 in ARTISTA), while the other rows rank all panel genes (3000). CODA's top list is filled with genes that have almost no spatial structure: only 4 of CODA's top 115 between genes in ARTISTA are among the 782 tested genes. On the same 782 genes (computed for this report from `res/Comparison/<case>-gene-table.csv`):

| Case | CODA, all genes | CODA, stORCA-tested genes | River, all genes | River, stORCA-tested genes |
|---|---|---|---|---|
| LIBD | 0.00 | 0.10 | not run | not run |
| HPOA | 0.75 | 0.70 | 0.60 | 0.60 |
| NRDR posterior | 0.09 | 0.09 | 0.53 | 0.53 |
| NRDR anterior | 0.00 | 0.00 | 0.15 | 0.15 |
| ARTISTA | 0.14 | 0.55 | 0.63 | 0.66 |
| Colitis | 0.07 | 0.11 | 0.81 | 0.81 |

**Verdict: partial.** The statement "top condition genes of single-pair methods are largely top replicate genes" is supported in HPOA for all five scores, and for River, SpaceExpress and stORCA single-pair ROS in most datasets. It is not supported for CODA in NRDR and LIBD, where the overlap is at chance. The outline asks to "show the cases where a competitor is well calibrated", so CODA in NRDR belongs in the figure, with the note that a low overlap there says CODA's top list is unstable, not that it is correct.

Result files: `5-Case-Study-Comparison/res/Comparison/<case>-method-summary.csv` (column `top_between_in_top_within`), `<case>-gene-table.csv` (columns `<method>_between`, `<method>_within`).

## 1b. Single-pair tests: genes called on replicate pairs (notebook section 1b)

**Question.** When a single-pair test compares two sections of the same condition, how many genes does it call?

**In plain words.** Section 1 looked at rankings. Some methods also give a p-value per gene for one pair. Apply such a test to two naive sections: nothing changed, so every call is a false positive, and at FDR 0.05 a calibrated test should call about 5% of the genes. If it calls half of them, its p-values measure "these two sections are not identical", which is true of any two sections, not "the condition changed this gene". This is panel 3b of the outline.

**Implementation** (notebook section 1b; per-pair result files of each method).

1. Methods with a p-value for every gene in one pair:
   - **stORCA single pair**: our former single-pair test, a sign-flip test of the matched residual (9999 flips), BH over the genes tested in that pair (`res/SysVI/<pair prefix>-ratio-capgene-scores.csv`, column `pvalue_adj_bh`). The outline asks to show it as one of the failing methods.
   - **SpaceExpress**: its native per-gene FDR (column `fdr`), call at FDR $<0.05$.
   - **STcompare**: permutation p-value of the spatial correlation (larger of `pValuePermuteX` and `pValuePermuteY`), BH per pair. STcompare tests for similarity, so a gene counts as differential when it is not significantly and positively correlated.
2. For every pair: number of genes called divided by the number the method tested in that pair. Blank probes are excluded.
3. Within pairs and between pairs are shown separately. CODA and River give no p-value and stay in section 1.

![Single-pair tests on within and between pairs](fig/12-q2-replicate-calibration/q2-single-pair-test-call-fraction.png)

*One panel per method, datasets on the horizontal axis. Grey points: within pairs (same condition). Coloured points: between pairs. Black ticks: medians. Dotted line: 0.05 (legend: `fig/12-q2-replicate-calibration/q2-single-pair-test-legend.png`). Takeaway: within pairs sit between 0.34 and 0.94, never near 0.05. Source: [12-q2-replicate-calibration.ipynb](12-q2-replicate-calibration.ipynb) section 1b.*

**Result.**

| Case | Method | Genes tested per pair | Within pairs, median (range) | Between pairs, median |
|---|---|---|---|---|
| LIBD | stORCA single pair | 1081 | 0.52 (0.42 to 0.62) | 0.40 |
| HPOA | stORCA single pair | 151 | 0.94 (0.93 to 0.98) | 0.97 |
| HPOA | SpaceExpress | 155 | 0.34 (0.25 to 0.39) | 0.37 |
| HPOA | STcompare | 160 | 0.73 (0.38 to 0.95) | 0.89 |
| NRDR posterior | stORCA single pair | 392 | 0.77 (0.65 to 0.88) | 0.95 |
| NRDR anterior | stORCA single pair | 397 | 0.84 (0.82 to 0.86) | 0.84 |
| ARTISTA | stORCA single pair | 957 | 0.59 (0.51 to 0.65) | 0.63 |
| ARTISTA | SpaceExpress | 3000 | 0.61 (0.55 to 0.71) | 0.63 |
| ARTISTA | STcompare | 3000 | 0.90 (0.87 to 0.93) | 0.94 |
| Colitis | stORCA single pair | 516 | 0.87 (0.70 to 0.92) | 0.89 |

**Every single-pair test calls 34% to 94% of the genes on replicate pairs, 7 to 19 times the 5% level.** Between pairs are only 0.00 to 0.18 higher, and in LIBD, where there is no condition, the within pairs are higher than the between pairs (0.52 against 0.40). A single-pair p-value therefore does not tell a condition effect from replicate variation. Section 3 gives the reason: the null of a single-pair test only knows the variation inside one pair.

**Verdict: works.** This is the direct evidence for outline panel 3b and it holds for all three methods with a test.

Result files: `res/Comparison/q2-four-comparisons.csv` (column `1v1 test, within`); per-pair files listed above.

## 1c. A single-pair null from the other genes: the gene-bulk empirical null (notebook section 1c)

**Question.** Can a single pair be calibrated without replicates, by using the other genes of the same pair as the null?

**In plain words.** Section 1b shows that a single-pair test calls most genes because its null only knows the matching noise. The gene-bulk null of `99-Notes/03-one-vs-one-analysis-history.md` (section 3.4) grades each gene on a curve against its classmates: the 50 other genes of the same pair whose structure strength is closest to its own. Structure strength matters because weakly structured genes get a high ROS even with no change. A gene is called when its ROS is far above the typical ROS of its classmates. No other section is used. The cost is an assumption: most genes do not change, so the classmates show what "no change" looks like.

**Implementation** (notebook section 1c; v3 ROS of the genes stORCA kept, from `storca-v3-rep1-<case>-limma-pair-scores.csv`).

1. Structure strength $\ell_g=\log\,\mathrm{median}_s z_{\mathrm{den},s}$ (column `z_den_median`, genes with a positive value).
2. For gene $g$ in pair $p$, take the set $N_g$ of the 50 other genes of the same pair with $\ell$ closest to $\ell_g$:

$$
z_g=\frac{\mathrm{ROS}_g-\mathrm{median}_{h\in N_g}\mathrm{ROS}_h}{1.4826\cdot\mathrm{MAD}_{h\in N_g}\mathrm{ROS}_h},\qquad p_g=1-\Phi(z_g),
$$

   BH over the genes of the pair.
3. Two checks per dataset: the fraction of genes called on within pairs (false positives), and the fraction of the replicate-design calls of section 2 (true labels) that are called on a single pair, on between pairs against within pairs.

![Gene-bulk null](fig/12-q2-replicate-calibration/q2-gene-bulk-null.png)

*Left: the sign-flip test of section 1b (FDR < 0.05). Middle: the gene-bulk null (FDR < 0.05). Right: share of the replicate-design calls that the gene-bulk null calls on a single pair (p < 0.05). Grey: within pairs. Red: between pairs. Black ticks: medians. Dotted line: 0.05. Takeaway: the false calls drop to near the nominal level, and on between pairs the replicate-design genes are found far more often than on within pairs. Source: [12-q2-replicate-calibration.ipynb](12-q2-replicate-calibration.ipynb) section 1c.*

**Result** (medians over pairs; "recall" is the share of the replicate-design calls that are called on one pair).

| Case | Pairs | Sign flip, called (BH) | Gene bulk, called (p < 0.05) | Gene bulk, called (BH) | Recall of replicate calls (p < 0.05) | Recall (BH) |
|---|---|---|---|---|---|---|
| LIBD | within | 0.52 | 0.12 | 0.05 | no calls | no calls |
| LIBD | between | 0.40 | 0.10 | 0.04 | no calls | no calls |
| HPOA | within | 0.94 | 0.14 | 0.08 | 0.00 | 0.00 |
| HPOA | between | 0.97 | 0.11 | 0.02 | 0.18 | 0.00 |
| NRDR posterior | within | 0.77 | 0.10 | 0.02 | 0.14 | 0.03 |
| NRDR posterior | between | 0.95 | 0.14 | 0.05 | 0.53 | 0.31 |
| NRDR anterior | within | 0.84 | 0.07 | 0.02 | 0.09 | 0.05 |
| NRDR anterior | between | 0.84 | 0.11 | 0.03 | 0.77 | 0.55 |
| ARTISTA | within | 0.59 | 0.10 | 0.03 | 0.07 | 0.03 |
| ARTISTA | between | 0.63 | 0.12 | 0.04 | 0.34 | 0.13 |
| Colitis | within | 0.87 | 0.12 | 0.04 | 0.04 | 0.00 |
| Colitis | between | 0.89 | 0.12 | 0.02 | 0.28 | 0.04 |

**The gene-bulk null removes most of the over-calling, and on between pairs it points at the right genes.** Within pairs drop from 0.52 to 0.94 to 0.02 to 0.08 at BH. On between pairs it finds 18% to 77% of the replicate-design calls at $p<0.05$, against 0% to 14% on within pairs.

**It does not make a single pair usable for calls.**
- Within pairs are still above the nominal level: 7% to 14% at $p<0.05$ and 2% to 8% at BH, where an exact null would give about 5% and about 0.
- The total call fraction is the same on within and between pairs (0.10 to 0.14 at $p<0.05$). A call on one pair does not tell whether that pair holds a condition effect.
- At BH it recovers 0% (HPOA) to 55% (NRDR anterior) of the replicate-design calls.
- It answers "is this gene's ROS high for its structure, within this pair?", which assumes that most genes do not change. When much of the transcriptome changes, the classmates move up as well (colitis D3 to D9 in note 03: 8 calls against 35 with the replicate null).

**Verdict: improves calibration, but the conclusion stands that a single pair is not calibrated.** The gene-bulk null is the best single-pair option measured so far and can be offered for ranking when no replicate exists. The replicate design is still needed for calls.

Result files: `res/Comparison/q2-gene-bulk-null-pairs.csv` (one row per pair).

## 2. stORCA: true labels against false labels (notebook section 2)

**Question.** When the sections are assigned to two groups in a way that does not follow the condition, does stORCA still call genes?

**In plain words.** With 3 naive and 3 aggression sections, the true labeling puts the 3 naive sections in one group. A false labeling puts, for example, 2 naive and 1 aggression section in one group. Under a false labeling the "between" pairs are a mixture of real between pairs and replicate pairs, so a calibrated test should call nothing or almost nothing. LIBD is stricter still: it has no condition at all, so even the true labeling must give 0 calls.

**Implementation** (`storca/replicate_case_studies.py`, limma stage; notebook reads `<case folder>/res/stORCA/storca-v3-rep1-<case>-limma-splits.csv`, rows with `weighting == "unweighted"`, column `limma_bh_one`).

1. Unit of analysis: the pair score. With 3 vs 3 there are 15 scores per gene (9 between, 6 within); with 2 vs 2 there are 6 (4 between, 2 within).
2. Model per gene: $\mathrm{ROS}_{g,p}=\alpha_g+\Delta_g\,b_p+\varepsilon_{g,p}$, where $b_p=1$ for a between pair and 0 for a within pair. The null is $\Delta_g=0$, the alternative $\Delta_g>0$. The moderated $t$ of limma (eBayes with a trend on structure strength) is used, one-sided, then BH over the tested genes.
3. The same fit is repeated for every other way of splitting the sections into two groups of the same sizes. A 3 vs 3 design has 9 such false labelings, a 2 vs 2 design has 2.
4. The notebook reports the calls on the true labeling and the maximum over the false labelings.

**Statistical consequence of the design.** The 15 pair scores come from only 6 sections, so they are not independent, and the limma p-value treats them as if they were. The false labelings are the check on that. With 2 vs 2 the check is weak: only 2 false labelings exist, so "0 calls on false labels" in NRDR is 0 of 2.

**Worked example (HPOA, from `res/Comparison/hpoa-gene-table.csv`).**

| Gene | Mean ROS, within | Mean ROS, between | $\Delta$ | $t$ | BH | Call |
|---|---|---|---|---|---|---|
| `Cpne5` | 0.231 | 0.545 | 0.314 | 4.93 | 0.008 | yes |
| `Oxt` | 0.676 | 0.868 | 0.192 | not listed | 0.173 | no |

`Oxt` has the higher between ROS (0.868), so a single-pair ranking puts it at the top. But its replicates already disagree (0.676), so the excess is small against the spread. `Cpne5` has a lower between ROS, but its replicates agree (0.231), so the excess is clear.

![True labels against false labels](fig/12-q2-replicate-calibration/q2-storca-true-vs-null-calls.png)

*Red: calls on the true labels. Grey: largest number of calls over the false labelings. Takeaway: LIBD has 0 and 0. Source: [12-q2-replicate-calibration.ipynb](12-q2-replicate-calibration.ipynb) section 2.*

**Result.**

| Case | Genes tested | Calls, true labels | False labelings with any call | Largest count on a false labeling |
|---|---|---|---|---|
| LIBD | 664 | 0 | 0 of 9 | 0 |
| HPOA | 149 | 11 | 0 of 9 | 0 |
| NRDR posterior | 377 | 32 | 0 of 2 | 0 |
| NRDR anterior | 363 | 11 | 0 of 2 | 0 |
| ARTISTA | 782 | 115 | 1 of 9 | 18 |
| Colitis, 3 vs 4 | 490 | 27 | 7 of 34 | 26 |

**Is a call on a false labeling a false positive?** Not always. In a dataset with a real effect, a false labeling still carries part of the true contrast. Two cases need a look (computed for this report from the `limma-splits.csv` files):

- ARTISTA: the one labeling with 18 calls groups `dpi2-r1, dpi2-r2, dpi20-r1` against `dpi2-r3, dpi20-r2, dpi20-r3`. The same labeling gives 10 calls in the time-course run of 2 vs 20 DPI. This points at specific sections (`dpi2-r3` or `dpi20-r1`), not at a general loss of calibration.
- Colitis: one labeling (`D0-m3a, D0-m6, D3-m2` against the rest) gives 26 calls, almost as many as the true labels (27). Another (`D3-m1, D3-m2, D3-m3` against the rest) gives 10, but that one differs from the truth by a single section, so calls are expected there.

**Verdict: works on the null dataset (LIBD) and on HPOA; needs a check of the sections in ARTISTA and colitis.** "Calibrated" should be written as "0 calls on LIBD and on all false labelings in HPOA", not as a general statement.

The same replicate contrast applied to the competitors' pair scores is now part of the notebook, in section 2c.

Result files: `<case folder>/res/stORCA/storca-v3-rep1-<case>-limma-splits.csv` (columns `labeling`, `group_a`, `limma_bh_one`).

## 2b. Replicate design read by scores: top effect under true and false labels (notebook section 2b)

**Question.** With the replicate design but without a test, does each method's score ranking point at the condition?

**In plain words.** Section 2 counted calls. Here the same design is read by scores only. For each gene, take the mean score over the between pairs minus the mean over the within pairs. Take the 20 genes with the largest difference (more when stORCA calls more) and average their difference: that is the "top effect" of the labeling. Do the same for every false labeling. If the score plus the design separates the condition from replicate variation, the true labeling should give the largest top effect. In LIBD, which has no condition, the true labeling should not stand out.

**Implementation** (notebook section 2b).

1. Pair scores of each method as in section 1, oriented so that larger means more differential, on the genes stORCA tested (the same gene universe for every method).
2. For each labeling $L$ (the true one and every false one of section 2):

$$
\Delta_g^{L}=\overline{s}_{g,\text{between}(L)}-\overline{s}_{g,\text{within}(L)},\qquad
T^{L}=\operatorname{mean}\{\Delta_g^{L}: g\in\text{top}_N(\Delta^{L})\},
$$

   where $s$ is the method's score and $N$ is as in section 1.
3. Report the rank of the true labeling among all labelings by $T$ (1 = largest), and $T^{\text{true}}$ divided by the median $T$ over the false labelings so that methods with different score units share one axis.

![Top effect under true and false labels](fig/12-q2-replicate-calibration/q2-replicate-score-true-vs-null.png)

*One panel per method, datasets on the horizontal axis, log scale. Diamond: true labeling. Grey points: false labelings. Dashed line: the median of the false labelings (legend: `fig/12-q2-replicate-calibration/q2-replicate-score-legend.png`). Takeaway: the diamond is above every grey point in most datasets and methods, but not in LIBD. Source: [12-q2-replicate-calibration.ipynb](12-q2-replicate-calibration.ipynb) section 2b.*

**Result.** Rank of the true labeling by top effect (1 = largest).

| Case | Labelings | stORCA ROS | CODA | River | STcompare | SpaceExpress |
|---|---|---|---|---|---|---|
| LIBD (no condition) | 10 | 4 | 4 | not run | not run | not run |
| HPOA | 10 | 1 | 1 | 1 | 1 | 6 |
| NRDR posterior | 3 | 1 | 3 | 1 | not run | not run |
| NRDR anterior | 3 | 1 | 1 | 1 | not run | not run |
| ARTISTA | 10 | 1 | 1 | 1 | 1 | 1 |
| Colitis | 35 | 3 | 18 | 1 | not run | not run |

For stORCA ROS the top effect under the true labels is 2.8, 4.2, 1.6, 2.4 and 1.5 times the median of the false labelings in HPOA, NRDR posterior, NRDR anterior, ARTISTA and colitis, and 1.1 times in LIBD.

**Reading:**

- **The replicate design fixes the ranking for almost every score.** Outside LIBD the true labeling ranks first in 15 of 19 method and dataset combinations. The exceptions are CODA in NRDR posterior and colitis, SpaceExpress in HPOA, and stORCA in colitis.
- **LIBD behaves as a null should.** For both methods run there the true labeling is 4th of 10.
- **Colitis needs a look.** For stORCA, two false labelings give a larger top effect than the true one. This is the same signal as the false labeling with 26 calls in section 2.

So the problem of section 1 lies in the single-pair design, not in the score: any score read through the replicate design ranks the condition. What the design alone does not provide is a call with a known error rate, which section 2c shows.

**Verdict: works; colitis is the one case to check.**

Result files: computed in the notebook from the pair scores (`02-compare-methods.py`, function `pair_scores`); summary in `res/Comparison/q2-four-comparisons.csv` (column `rep score, true rank`).

## 2c. The four comparisons side by side (notebook section 2c)

**Question.** Across the 2 x 2 grid (one pair or replicate design, score or test), where does each method stand?

**Implementation** (notebook section 2c, saved as `res/Comparison/q2-four-comparisons.csv`). The 1 vs 1 score column is the overlap of section 1 recomputed on the genes stORCA tested. The rep test column uses stORCA's own limma fit for stORCA, and for the other methods the same replicate contrast (plain limma, one-sided, BH) applied to their pair scores by `02-compare-methods.py` (columns `contrast_limma_bh`, `contrast_null_max`).

**Result.**

| Case | Method | 1v1 score: top between in top within | 1v1 test: called per within pair | rep score: true rank | rep test: calls (largest on false labels) |
|---|---|---|---|---|---|
| LIBD | stORCA | 0.70 | 0.52 | 4 of 10 | 0 (0) |
| LIBD | CODA | 0.10 | no test | 4 of 10 | 0 (1) |
| HPOA | stORCA | 0.80 | 0.94 | 1 of 10 | 11 (0) |
| HPOA | CODA | 0.70 | no test | 1 of 10 | 0 (0) |
| HPOA | River | 0.60 | no test | 1 of 10 | 3 (2) |
| HPOA | STcompare | 0.55 | 0.73 | 1 of 10 | 1 (0) |
| HPOA | SpaceExpress | 0.50 | 0.34 | 6 of 10 | 1 (1) |
| NRDR posterior | stORCA | 0.47 | 0.77 | 1 of 3 | 32 (0) |
| NRDR posterior | CODA | 0.09 | no test | 3 of 3 | 0 (0) |
| NRDR posterior | River | 0.53 | no test | 1 of 3 | 0 (0) |
| NRDR anterior | stORCA | 0.35 | 0.84 | 1 of 3 | 11 (0) |
| NRDR anterior | CODA | 0.00 | no test | 1 of 3 | 0 (0) |
| NRDR anterior | River | 0.15 | no test | 1 of 3 | 0 (0) |
| ARTISTA | stORCA | 0.64 | 0.59 | 1 of 10 | 115 (18) |
| ARTISTA | CODA | 0.55 | no test | 1 of 10 | 1 (0) |
| ARTISTA | River | 0.66 | no test | 1 of 10 | 46 (1) |
| ARTISTA | SpaceExpress | 0.90 | 0.60 | 1 of 10 | 3 (0) |
| Colitis | stORCA | 0.63 | 0.87 | 3 of 35 | 27 (26) |
| Colitis | CODA | 0.11 | no test | 18 of 35 | 0 (1) |
| Colitis | River | 0.81 | no test | 1 of 35 | 1 (7) |

**Reading, one column at a time:**

1. **1 vs 1 fails in both readings.** Rankings repeat between replicates (section 1) and tests call a third to almost all genes on replicate pairs (section 1b). This holds for every method that can be measured, stORCA's own single-pair test included.
2. **The replicate design repairs the ranking for every method** (section 2b).
3. **Only ROS turns the design into calls.** stORCA calls genes in every dataset with a condition and none in LIBD. The same contrast on the competitors' scores gives 0 to 3 calls, with one exception (River in ARTISTA, 46). The fit is not what makes the difference: plain limma on ROS, as used for the competitors, gives 10, 104 and 23 calls in HPOA, ARTISTA and NRDR posterior, with at most 0, 11 and 0 on false labels (`<case>-method-summary.csv`, row `stORCA single pair`).

**So claim 3 holds in its two parts: the replicate design is necessary, and a score on a common scale is what makes the replicate test usable.**

**Verdict: works.** The one cell against the claim is colitis (27 calls against 26 on one false labeling), which is a Fix item in section 6.

## 3. Why a single-pair test is overconfident (notebook section 3)

**Question.** How large is the variation of ROS that can be seen inside one pair, compared with the variation between replicate pairs?

**In plain words.** A single-pair test must build its null from the one pair it has, for example by redrawing the cell matching. That tells how stable the score is if the same two sections are matched again. It does not tell how much the score would move if a different animal had been used. If the second is 100 times larger than the first, the single-pair test is asking "is this difference larger than my matching noise?" and nearly every gene passes.

Two quantities that sound alike are kept apart here:

- **Matching SD**: SD of ROS over bootstrap redraws of the matching inside one pair (column `boot_sd`).
- **Replicate SD**: SD of ROS across the within pairs of a case.

**Implementation** (notebook section 3, from `storca-v3-rep1-<case>-limma-pair-scores.csv`, kept genes, pairs whose name starts with `rep-`).

1. Per gene, matching variance $=\operatorname{mean}_p(\texttt{boot\_sd}_{g,p}^2)$ over the within pairs.
2. Per gene, replicate variance $=\operatorname{Var}_p(\mathrm{ROS}_{g,p})$ over the same within pairs.
3. Ratio per gene, then the median over genes.

![Replicate variance over matching variance](fig/12-q2-replicate-calibration/q2-replicate-vs-matching-variance.png)

*Bars: median over genes of replicate variance divided by matching variance, log scale. Dashed line: ratio 1. Takeaway: every dataset is above 26. Source: [12-q2-replicate-calibration.ipynb](12-q2-replicate-calibration.ipynb) section 3.*

**Result.**

| Case | Median matching SD | Median replicate SD | Median variance ratio |
|---|---|---|---|
| LIBD | 0.028 | 0.171 | 42 |
| HPOA | 0.010 | 0.113 | 155 |
| NRDR posterior | 0.012 | 0.056 | 26 |
| NRDR anterior | 0.012 | 0.147 | 143 |
| ARTISTA | 0.023 | 0.140 | 31 |

**So a null built inside one pair is 5 to 12 times too narrow in SD.** This agrees with the numbers in the outline (about 0.006 against 0.15 in colitis).

Caveats. In NRDR the replicate variance is the variance of 2 values per gene, so those two rows are rough. The replicate SD pools the within pairs of both conditions. Neither caveat can bring a ratio of 26 to 155 down to 1.

**Does this explain the competitors?** The ratio is measured on ROS and stORCA's own matching bootstrap. For the competitors with a test the outcome is measured directly in section 1b: SpaceExpress and STcompare call 34% to 90% of the genes on replicate pairs, as a null that only knows one pair predicts.

**Verdict: works.**

Result files: `<case folder>/res/stORCA/storca-v3-rep1-<case>-limma-pair-scores.csv` (columns `gene`, `pair`, `ROS`, `boot_sd`).

## 4. Examples of competitor false positives in HPOA (notebook section 4)

**Question.** Can we point at a gene that a competitor ranks at the top and that is visibly not a condition effect?

**Selection rule.** For each competitor: genes in the top 20 of the between average and in the top 20 of the within average, not called by stORCA, sorted by between rank. HPOA is used because all five methods ran there. The notebook then shows, per gene, the rank in every pair for every method and the expression map of all six sections.

**Result, checked on the maps for this report.**

| Gene | Picked for | Between rank / within rank (of 160) | stORCA | Largest Moran's I over sections | Pseudobulk DE | What the map shows | Holds as an example? |
|---|---|---|---|---|---|---|---|
| `Blank_2` | CODA, STcompare | CODA 3 / 2, STcompare 9 / 5 | not tested (blank) | not applicable | not applicable | negative control probe, no signal | yes |
| `Mki67` | STcompare | 5 / 4 | dropped by the gene gate | 0.026 | no (global FDR 0.59) | no structure | yes |
| `Gbx2` | CODA, STcompare | CODA 2 / 9, STcompare 1 / 8 | passed the gate, dropped by the 60% rule | 0.109 (`naive-a6`) | domain FDR 0.049 | one hotspot in the top right of `naive-a6` only | yes, with corrected text |
| `Oxt` | SpaceExpress | 1 / 18 | tested, BH 0.173 | 0.391 | no (global FDR 0.71) | very sparse; a hotspot in `naive-a6` only | yes |
| `Sema4d` | River | 1 / 8 | tested, BH 0.157 | 0.141 | yes (global FDR 0.005) | naive sections brighter overall than aggression sections | no |

![Blank_2 ranks per pair](fig/12-q2-replicate-calibration/q2-example-fp-blank-2-ranks.png)

*One panel per method. Grey: rank of the gene in each within pair. Red: rank in each between pair. Rank 1 is the most differential. Takeaway: CODA puts a negative control probe between rank 2 and 30 in every pair, within and between alike; River puts it near the bottom (rank 87 to 160). Source: [12-q2-replicate-calibration.ipynb](12-q2-replicate-calibration.ipynb) section 4a.*

![Oxt maps](fig/12-q2-replicate-calibration/q2-example-fp-oxt-maps.png)

*Top row: naive sections. Bottom row: aggression sections. Shared colour scale (log1p counts). Takeaway: the strong spot is in `naive-a6` only, so the between pairs that involve `naive-a6` differ for a reason that is not the condition. Source: [12-q2-replicate-calibration.ipynb](12-q2-replicate-calibration.ipynb) section 4b.*

**Two corrections to the notebook summary.**

- **`Gbx2` is not "Moran's I at most 0.03 in every section".** Its Moran's I is 0.109 in `naive-a6` and 0.036 in `aggr-a34` (`5-Case-Study-HPOA-MERFISH/res/stORCA/storca-v3-rep1-hpoa-gene-gate.csv`). It passed rule 1 and was dropped by rule 2. The right reading is the same as for `Oxt`: one section has a hotspot. The sentence is true for `Mki67` only.
- **`Sema4d` is not a replicate-variation false positive.** River ranks it between 1 and 8 in all 9 between pairs and between 4 and 52 in the within pairs, and the pseudobulk test agrees that the level differs (global FDR 0.005, domain FDR 0.003). River is reporting a real change of level. stORCA does not call it because a change of level without a change of spatial structure is not DSE by the definition of the outline. That is a point for Q3 (what kind of change), not for Q2. The other River candidates have the same property: `Pak3`, `Cspg5`, `Mlc1`, `Cbln2` all have global FDR between 0.005 and 0.023.

**So HPOA gives no clean River false positive.** For River the honest statement is "River's top genes are DE genes, and it ranks them high in within pairs too (`Pak3`: between rank 2, within rank 1)".

**Is the blank example fair to the competitors?** Partly. stORCA never scores blank probes, so this is not a head-to-head result. It shows only where CODA and STcompare put a probe with no biology.

**Verdict: works for CODA, STcompare and SpaceExpress (`Blank_2`, `Mki67`, `Gbx2`, `Oxt`); fails for River (`Sema4d`).**

Result files: `5-Case-Study-Comparison/res/Comparison/hpoa-gene-table.csv`; figures `fig/12-q2-replicate-calibration/q2-example-fp-<gene>-ranks.png` and `-maps.png`.

## 5. Example of a stORCA call in HPOA (notebook section 5)

**Question.** Is there a called gene whose maps show the same change in every replicate?

**Selection rule.** The stORCA call with the largest $t$.

**Result.** `Cpne5`: mean ROS 0.231 within, 0.545 between, $t=4.93$, BH 0.008.

| Method | Between rank | Within rank | Out of |
|---|---|---|---|
| stORCA ROS | 31 | 109 | 149 |
| SpaceExpress | 2 | 93 | 155 |
| River | 14 | 61 | 160 |
| STcompare | 96 | 125 | 160 |
| CODA | 113 | 125 | 160 |

![Cpne5 maps](fig/12-q2-replicate-calibration/q2-example-tp-cpne5-maps.png)

*Top row: naive. Bottom row: aggression. Takeaway: bright bands at the upper and lower edges in the naive sections (clear in `naive-a5` and `naive-a6`, weaker in `naive-a7`), weak in all three aggression sections. Source: [12-q2-replicate-calibration.ipynb](12-q2-replicate-calibration.ipynb) section 5.*

**What this example shows and what it does not.** It shows the within against between separation that the replicate contrast uses. It does not show an advantage over the competitors: SpaceExpress and River also rank `Cpne5` high, and it is a pseudobulk DE gene (global FDR 0.001). Note also that its single-pair ROS rank is only 31 of 149; it becomes the top call because its within pairs are low, which is the point of section 2.

**Verdict: works as an illustration of the contrast; no evidence yet of a call that only stORCA gets right in Q2.**

## 6. Where this leaves Q2

| Claim | Supported? | Basis |
|---|---|---|
| Top between genes of single-pair scores are largely top within genes | Partial: all methods in HPOA; River, SpaceExpress and single-pair ROS in most datasets; CODA only after fixing the gene universe | 1 |
| The replicate contrast gives no calls without a condition | Yes on LIBD (0 of 664) and on false labels in HPOA | 2 |
| The replicate contrast is calibrated in every dataset | Not shown: 2 false labelings in NRDR; calls on single false labelings in ARTISTA (18) and colitis (26) | 2 |
| A single-pair test does not separate condition from replicate variation | Yes: 34% to 94% of genes called per within pair, for every method with a test | 1b |
| The replicate design makes any score rank the condition | Yes: true labeling first in 15 of 19 combinations outside LIBD; not in LIBD | 2b |
| ROS, not the replicate design alone, makes the replicate test work | Yes: competitors give 0 to 3 calls under the same contrast, except River in ARTISTA | 2c |
| A null from the other genes of the pair calibrates a single pair | Partly: false calls drop to 2% to 8% (BH) and between pairs are enriched for the replicate-design genes, but within pairs stay above nominal and between pairs are called as often as within pairs | 1c |
| A single-pair null is too narrow | Yes for ROS (variance ratio 26 to 155) | 3 |
| Competitors with p-values call most genes on replicate pairs | Yes (section 1b) | 1b, 3 |
| Competitors rank negative controls and one-section hotspots at the top | Yes for CODA, STcompare, SpaceExpress | 4 |
| River's top genes are replicate variation | No. They are DE genes | 4 |

**Status: sufficient after the fixes below.** With sections 1b, 1c, 2b and 2c every cell of the 2 x 2 grid is measured, and all of them point the same way as claim 3. The gene-bulk null (1c) improves single-pair calibration a lot but does not change the conclusion that one pair cannot give calls. One item could still turn out major: colitis, where one false labeling gives 26 calls against 27 and ranks above the true labeling in section 2b (Fix 3). Issues are split by the rule in `CLAUDE.md` ("Level of Rigor: Fix or Defend"): fix what goes against the claim or is wrong as written, record a defence for the rest.

**Fix.**

1. Drop the River example. `Sema4d` is a DE gene, so it shows the opposite of "replicate variation". Simplest: remove the River panel from the false-positive figure and keep `Blank_2`, `Mki67`, `Gbx2` and `Oxt`.
2. Correct the `Gbx2` sentence in the notebook summary to "a hotspot in one section (`naive-a6`)".
3. Look at the colitis false labeling that gives 26 calls against 27 on the true labels (the rerun now includes colitis). It is the only result in Q2 that speaks against "calls exceed replicate variation", and section 2b shows the same signal (true labeling 3rd of 35). The likely cause is one atypical section (`D0-m7` or `D3-m2`, see [16-colitis-sample-review.ipynb](16-colitis-sample-review.ipynb)).
4. Section 1 figure: draw the overlap on the genes stORCA tested, as section 2c already does. This removes the CODA artifact (0.14 to 0.55 in ARTISTA).

**Defend.**

| A reviewer can say | Answer |
|---|---|
| NRDR has only 2 false labelings | A 2 vs 2 design allows no more. Calibration rests on LIBD (0 of 664) and HPOA (0 calls on 9 false labelings); NRDR contributes calls only |
| One of 9 false labelings in ARTISTA gives 18 calls | 8 of 9 give 0 and 18 is far below 115. In a dataset with a real effect a false labeling keeps part of the true contrast |
| Pair scores share sections, so they are not independent | The false labelings check exactly this, and they give 0 calls where there is no effect |
| CODA has a chance-level overlap in NRDR and LIBD | Its top list there is unstable between pairs, not correct: it is filled with genes without spatial structure, and blank probes rank 2 to 30 |
| The variance ratio is measured on ROS, not on each competitor's own null | The ratio is a property of the data: replicates differ far more than a rematching of one pair. It applies to any null built from one pair |
| Not every competitor ran on every dataset | All five methods ran on HPOA and at least two on every dataset. More runs add panels, they do not change the conclusion |
| STcompare tests for similarity, not for difference | That is how its output is read when looking for changes. Even so, 73% to 90% of the genes are "not similar" between replicates, so the label carries no information about the condition |
| The failing single-pair test includes stORCA's own | It is our former test and is shown as one of the failing methods, as the outline plans. The paper's test is the replicate contrast |
| Section 2b shows that the replicate design works with any score, so ROS is not needed | For ranking, yes, and the paper says so. For calls, plain limma on ROS gives 10, 104 and 23 calls in HPOA, ARTISTA and NRDR posterior, while the same fit on CODA, STcompare and SpaceExpress scores gives 0 to 3 |
| The gene-bulk null of section 1c calibrates a single pair, so replicates are not needed | It removes most false calls, but within pairs stay at 2% to 8% at BH, the total call rate is the same on within and between pairs, and it recovers 0% to 55% of the replicate-design calls. It also assumes that most genes do not change. It is offered for ranking when no replicate exists, not as a test |
| With 3 labelings in NRDR, rank 1 of 3 is weak | It is reported as such. The rank evidence rests on the 3 vs 3 datasets (10 labelings) |
| stORCA does not score blank probes | The example shows where competitors put a negative control. It is not presented as a head-to-head result |
| `Cpne5` is also a DE gene, and River and SpaceExpress rank it high | The example illustrates the within against between contrast. A call may also be DE |

**Decisions for you.**

1. Drop the River panel, or search another dataset for a River example. Recommended: drop it.
2. Whether the colitis false labeling with 26 calls leads to removing a section. Recommended: decide after looking at notebook 16; removing a section is your call.
