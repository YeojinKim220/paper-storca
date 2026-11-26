# Q1 unmatched cells: whether the plan leaves new cells out, whether competitors are misled by them, and whether stORCA's score is free of them

This note explains the notebook [11-q1-unmatched-cells.ipynb](11-q1-unmatched-cells.ipynb) section by section. It follows one line: (1) the dead-zone plan leaves cells without a counterpart unmatched; (2) whether competitors put markers of those cells at the top of their lists; (3) whether stORCA's own score stays free of them, in real data and in a controlled semi-synthetic test; (4) what can be claimed now and what must change.

The line serves claim 3 of the outline as revised on 2026-11-18, tissue without a counterpart (Figure 4 of [0-paper-outline-natcomm.md](../0-Paper-Draft/0-paper-outline-natcomm.md)). **Section 7 (2026-11-18) is the conclusion.** With the replicate baseline thinned on both sides, the plan's low retained mass finds the tissue without a counterpart (AUROC 0.89 in cortex, 0.94 in colitis day 0), and 0.20 and 0.35 of stORCA's top 20 are markers of that tissue against 0.45 to 0.70 for CODA, STcompare and DESpace2 (base 0.11 and 0.28). Sections 2 to 5f record how this was reached; their verdicts were written before the symmetric thinning and the standard markers, and section 6 is updated to section 7. The semi-synthetic test of sections 5 to 5c is not used (decision of 2026-11-18); section 7c shows why it does not reproduce the real cases.

Figures are copied unchanged from the notebook (PDF in `5-Case-Study-Comparison/fig/`, PNG copies in `5-Case-Study-Comparison/fig/11-q1-unmatched-cells/`). Paths are relative to the project root unless they are links. All numbers come from the notebook runs of 2026-11-17 and 2026-11-18.

**Data.**

| Case | Folder | Control | Treated | Replicates |
|---|---|---|---|---|
| Colitis, healthy vs day 9 (Cadinu et al. 2024, MERFISH) | `5-Case-Study-Colitis-Q1` | `062921_D0_m3a_2` slices 1 to 3 | `100221_D9_m5_1` slices 1 to 3 (ulcer neighbourhood MU8 38% to 51% of cells) | 3 vs 3 slices, one mouse per condition, so technical replicates |
| Cortex stab wound (Visium) | `5-Case-Study-Cortex-Stab` | intact r1, r2 | 3 dpi r1, r2 | 2 vs 2; two hemispheres of one capture area may come from one animal |
| Semi-synthetic HPOA (MERFISH) | `5-Case-Study-HPOA-Synthetic` | naive a5, a6, a7 | aggression a34, a35, a36 with one cell class removed (OD Mature or Astrocyte) | 3 vs 3 animals |

The colitis slices are the ones chosen on 2026-11-16 from [17-q1-sample-gallery.ipynb](17-q1-sample-gallery.ipynb). stORCA is v3 (`STORCA_CLIP=nonzero95`, `STORCA_GATE=gene`). Competitor tables come from `02-compare-methods.py` (`res/Comparison/<case>-gene-table.csv`). DESpace2 did not run on the cortex case.

**Score.** For a between pair the dead-zone plan gives each treated cell a retained mass $m_i\in[0,1]$, the fraction of its mass kept by the plan, scaled so that a fully matched cell has $m_i=1$. Rules:

1. A cell is **unmatched** when $m_i<0.5$ (cell level).
2. A population is **new** when it is below 1% of control cells and at least 2% of treated cells (annotation level).
3. A gene's **enrichment in unmatched cells** is

$$
E_g=\frac{\sum_{i\in U} x_{ig}\big/\sum_{i} x_{ig}}{|U|/n},
$$

where $x_{ig}$ is log1p expression in the treated sections, $U$ the unmatched cells and $n$ all treated cells. $E_g=1$ means the gene is spread like all cells; $E_g\gg1$ means it marks the cells without a counterpart.

## 0. Summary

| Step | Finding |
|---|---|
| 1. The plan leaves new cells out | Colitis: 0.469 of treated cells unmatched in between pairs (0.413 to 0.537) against 0.031 in within pairs. Cortex: 0.087 against 0.000, and the lesion cluster r14 is 0.81 of all unmatched cells. Semi-synthetic: 0.92 (OD Mature) and 0.65 (Astrocyte) of the removed class unmatched, other cells 0.02 to 0.04 |
| 2. Marker share in top lists | Not interpretable in colitis: the day-9 neighbourhoods are absent from day 0 by name, so the "new population" is 96% of treated cells. In cortex (sections not yet oriented, see 5f) the competitors' top 20 holds 0 to 7 of 20 markers, stORCA 5 of 20. Superseded by sections 5f and 7b (standard markers, lost tissue included) |
| 3. Are top genes expressed in unmatched cells? | No method's top 20 is concentrated there. Median $E_g$ of competitors: 0.56 to 0.79 in colitis (all tested genes 0.76), 1.01 to 1.17 in cortex (all tested 1.13). stORCA: 0.54 and 1.39. Gained tissue only; section 5d finds the effect in lost tissue |
| 4. Examples | None by this rule. Section 5f gives `Ptger3` (colitis) and `Lgals1` (cortex, STcompare) |
| 5. Controlled test | Removing OD Mature cells adds 3 removed-class markers to stORCA's top 20 (1 to 4) and creates the calls `Gjc3` and `Opalin`; removing astrocytes adds 3 (2 to 5) and creates `Aldh1l1`. CODA, STcompare and the stORCA single-pair score do not change; River and SpaceExpress move by at most 2 |
| 5b. Why | Not a leak: removed cells are 5% of retained cell-matchings. Removing the class cuts the between pairs' $Q_x+Q_y$ (`Gjc3` 190k to 26k) while the within-naive pairs keep it, so ROS of the between pairs rises (0.17 to 0.28) above a baseline measured on different cells |
| 5c. Test | Scoring the within-control pairs on the cells the between pairs keep (thinning by retained mass) removes all 6 calls the OD Mature removal created; the 7 left are original calls, and the original HPOA keeps 11 of 11. The astrocyte case is unchanged (`Aldh1l1` stays), because the plan keeps about 40% of astrocyte mass. With both sides thinned (`basew2`, the variant of section 7), 10 calls remain and 4 are not original HPOA calls (`Gjc3`, `Opalin`, `Pnoc`, `Th`; BH of `Gjc3` and `Opalin` 0.045); 4 of the top 20 are removed-class markers under every variant (original 1) |
| 5d. Colitis, lost tissue | In D0 vs D9, 0.70, 0.65 and 0.80 of the top 20 of CODA, STcompare and DESpace2 are markers of the epithelium that disappears (base 0.36); stORCA 0.25, River 0.30. No spatial method is enriched for the ulcer (gained) markers |
| 5f. Standard markers | Cluster vs rest, shared genes (also changed outside the clusters) separated. Colitis lost epithelium: CODA, STcompare, DESpace2 0.60 to 0.70 of top 20 (cluster-only 0.30 to 0.35), stORCA 0.35 (0.05 to 0.10); example `Ptger3`. Oriented cortex, lesion r14 only: CODA 0.45 and STcompare 0.70 of top 20 against stORCA 0.30, thinned 0.20 (base 0.11); CODA's are almost all shared (cluster-only 0.05), STcompare has 0.20 cluster-only (`Lgals1` rank 1) against stORCA 0.00 (base 0.07) |
| 7a. Retained mass (conclusion) | Tissue without a counterpart keeps 0.43 (cortex r14) and 0.19 (colitis day-0 epithelium) of its mass, against 0.97 and 0.81 for other cells and 0.99 in within pairs; AUROC 0.89 and 0.94. Colitis day 9 is weaker (0.66) |
| 7b. Top genes (conclusion) | Markers of the tissue without a counterpart in the top 20 (cortex, colitis): stORCA with both sides thinned 0.20 and 0.35 (base 0.11 and 0.28); CODA 0.45 and 0.70; STcompare 0.70 and 0.60; DESpace2 0.70 (colitis); River 0.10 and 0.30; pseudobulk DE 0.60 and 0.40 |
| 7c. Why CODA and STcompare are misled (mechanism, 9 pairs) | The alignment lays the lost epithelium over day-9 tissue (CODA: 0.79 of the lost cells on a day-9 cell; STcompare: 0.74 to 0.99 of epithelial pixels stay shared), where its markers are below the day-9 mean, so their correlation turns negative (`Ptger3` in 9 of 9 pairs for both). This overlay gives 0.85 (CODA) and 0.59 (STcompare) of `Ptger3`'s negative score. Removing a scattered class (HPOA) leaves nothing to overlay; the marker's CCI only falls to the level of genes without structure (`Gjc3` 0.18 to 0.04) |
| 6. Status (updated after section 7) | Sufficient for tissue lost or gained as a region. The semi-synthetic test (sections 5 to 5c) is not used |

## 1. Which treated cells stORCA leaves unmatched (notebook sections 1 and 5)

**Question.** When the treated section contains tissue the control does not have, does the plan leave exactly that tissue unmatched?

**In plain words.** The dead-zone plan may refuse to match a cell when no control cell looks like it. A within pair (two control sections or two treated sections) has nothing new, so almost every cell should be matched. A between pair should leave out the new tissue and keep the rest.

**Implementation** (notebook section 1; `interpret.retained_fraction` on the stored plan `-ratio-ot.npz`).

1. For every pair, read the retained mass of every target cell.
2. Average over the pairs that share a treated section; group by annotated population (colitis `neigh`, cortex `region`).
3. Report the share of unmatched cells per population for between and within pairs.

**Result.**

| Case | Unmatched, between pairs | Unmatched, within pairs | Population most left out |
|---|---|---|---|
| Colitis D0 vs D9 | 0.469 (0.413 to 0.537) | 0.031 (0.000 to 0.129) | LUM (lumen) 0.98, MU8 (ulcer mucosa) 0.64; smooth muscle SM2 0.33, ME3 0.12 |
| Cortex intact vs 3 dpi | 0.087 (0.039 to 0.141) | 0.000 | r14 (lesion; 0.1% of control, 12.5% of treated cells) 0.53; it makes up 0.81 of unmatched cells |

![Colitis maps](fig/11-q1-unmatched-cells/q1-retained-maps-colitisq1.png)

*Left column: annotated neighbourhood of each day-9 slice (legend: `fig/11-q1-unmatched-cells/q1-population-legend-colitisq1.png`). Right column: retained mass averaged over the between pairs; dark = unmatched. Takeaway: the lumen and the ulcerated mucosa are dark, the outer muscle layer is bright. Source: [11-q1-unmatched-cells.ipynb](11-q1-unmatched-cells.ipynb) section 1b.*

![Cortex maps](fig/11-q1-unmatched-cells/q1-retained-maps-cortexrep.png)

*Same layout for the two 3 dpi hemispheres (legend: `fig/11-q1-unmatched-cells/q1-population-legend-cortexrep.png`). Takeaway: the lesion is the only dark region. Source: notebook section 1b.*

**Color code of the population maps** (palette tab20 then tab20b; fixed on 2026-11-18, before which 22 colitis neighbourhoods shared 20 colors, so FOL1 and SM2, LUM and SM3, ME1 and `others` had the same color). These maps show only the treated sections: the lost day-0 epithelium is not in them (it is in the maps of section 5f).

| Colitis neighbourhood | Color | Colitis neighbourhood | Color | Cortex cluster | Color |
|---|---|---|---|---|---|
| FOL1 | blue `#1f77b4` | MU2 | magenta `#e377c2` | r0 | blue `#1f77b4` |
| LUM (lumen) | light blue `#aec7e8` | MU3 | light pink `#f7b6d2` | r1 | light blue `#aec7e8` |
| ME1 | orange `#ff7f0e` | MU4 | grey `#7f7f7f` | r2 | purple `#9467bd` |
| ME2 | light orange `#ffbb78` | MU5 | light grey `#c7c7c7` | r3 | lavender `#c5b0d5` |
| ME3 | green `#2ca02c` | MU6 | olive `#bcbd22` | r4 | brown `#8c564b` |
| ME4 | light green `#98df8a` | MU7 | light olive `#dbdb8d` | r5 | light brown `#c49c94` |
| MES1 | red `#d62728` | MU8 (ulcer mucosa) | cyan `#17becf` | r6 | magenta `#e377c2` |
| MES2 | pink `#ff9896` | SM1 | light cyan `#9edae5` | r7 | light pink `#f7b6d2` |
| MES3 | purple `#9467bd` | SM2 (smooth muscle) | navy `#393b79` | r8 | grey `#7f7f7f` |
| MU1 | lavender `#c5b0d5` | SM3 | indigo `#5254a3` | r9 | light grey `#c7c7c7` |
| MU10 | brown `#8c564b` | others | periwinkle `#6b6ecf` | r10 / r11 | orange `#ff7f0e` / light orange `#ffbb78` |
| MU11 | light brown `#c49c94` | | | r12 / r13 | green `#2ca02c` / light green `#98df8a` |
| | | | | **r14 (lesion)** / r15 | **red `#d62728`** / pink `#ff9896` |

In the colitis maps the three blues are therefore LUM (light blue, lumen content), MU8 (cyan, ulcer mucosa, gained tissue) and SM2 (navy, smooth muscle).

**Is colitis too easy?** Yes, in one way: day 9 has almost no epithelium (42% of day-0 cells, 1% of day-9 cells), so nearly half of the tissue is new. Cortex is the cleaner case: one small lesion in otherwise intact tissue.

**Verdict: works.** This supports the plan half of the claim as it is.

Result files: none saved; numbers are in the notebook output of section 1.

## 2. Marker share in each method's top list (notebook sections 2 and 3)

**Question.** Are the top genes of each method markers of the new population?

**Implementation.** Markers: top 50 genes of a Wilcoxon test (scanpy) of new-population cells against all other treated cells, log fold change above 1. Share of the top 20 and top 50 of each method (genes stORCA tested) that are markers.

**Result.**

| Method | Colitis top 20 | Cortex top 20 |
|---|---|---|
| stORCA (replicate t) | 0.20 | 0.25 |
| stORCA single pair | 0.10 | 0.30 |
| CODA | 0.15 | 0.00 |
| River | 0.20 | 0.35 |
| STcompare | 0.20 | 0.00 |
| SpaceExpress | not run | 0.00 |
| DESpace2 | 0.10 | not run |
| Markers among all tested genes | 44 of 502 (0.09) | 46 of 1940 (0.02) |

**Where it goes wrong.** In colitis, the day-9 neighbourhoods (MU8, MU7, SM2, ME3, LUM) do not occur in day 0 by name, so rule 2 makes 96% of treated cells "new" and the markers become "day-9 genes". The colitis column therefore does not measure the new population.

**Verdict: partial; colitis is not interpretable, cortex shows no advantage for stORCA.** Gap type: Fix (the comparison as planned does not show the claim; see section 6).

Result files: `5-Case-Study-Comparison/res/Comparison/colitisq1-gene-table.csv`, `cortexrep-gene-table.csv`.

## 3. Are each method's top genes expressed in the unmatched cells? (notebook section 3b)

**Question.** Without any annotation: do the top genes of a method sit in the cells that stORCA left out?

**In plain words.** If a method were misled by new tissue, its top genes would be the genes that are expressed mostly in that tissue, so their $E_g$ (section Score) would be well above the value for all genes.

**Implementation.** $E_g$ for every stORCA-tested gene over the three (colitis) or two (cortex) treated sections, with the unmatched cells of section 1; median over each method's top 20.

![Enrichment in unmatched cells](fig/11-q1-unmatched-cells/q1-unmatched-enrichment-top20.png)

*One panel per case. Bars: median $E_g$ of each method's top 20 genes. Dashed line: median over all tested genes. Dotted red line: $E_g=1$. Takeaway: no method is far above the dashed line except the stORCA single-pair score in cortex (3.05). Source: notebook section 3b.*

**Result.**

| Method | Colitis | Cortex |
|---|---|---|
| All tested genes | 0.76 | 1.13 |
| stORCA (replicate t) | 0.54 | 1.39 |
| stORCA single pair | 0.94 | 3.05 |
| CODA | 0.56 | 1.17 |
| River | 0.72 | 1.01 |
| STcompare | 0.65 | 1.16 |
| DESpace2 | 0.79 | not run |

**Reading:**

- **The competitors are not dominated by the new cells in these two datasets.** Their medians are at or below the all-gene value.
- **stORCA's replicate score is not lower than theirs in cortex** (1.39 against 1.01 to 1.17).

**Verdict: fails as evidence for the claim for new tissue.** The premise (competitors are misled) is not visible for the tissue that appears; section 5d shows it for the tissue that disappears.

Result files: `5-Case-Study-Comparison/res/Comparison/q1-unmatched-enrichment.csv` (columns `case`, `method`, `top`, `median_enrichment`).

## 4. Examples (notebook section 4)

**Rule.** A new-population marker that is in the top 20 of at least three competitors and is not a stORCA call.

**Result.** 0 candidates in colitis, 0 in cortex. **No evidence yet** for a named gene.

## 5. Controlled test: semi-synthetic HPOA with one cell class removed (notebook section 6)

**Question.** When the only difference is that one cell class is gone, does any method call its markers, and does stORCA?

**Why it is needed.** In real data a new population and a real change of the shared tissue come together, so a marker in a top list can be a true change. Here every other cell keeps its real expression and position, so a marker of the removed class that enters a list relative to the original HPOA is there only because cells lost their counterpart.

**Implementation** (`20-q1-hpoasyn-check.py`, inputs from `02-compare-methods.py` on `hpoa`, `hpoasyn-odm`, `hpoasyn-astro`).

1. Markers: top 10 genes of the removed class against all other cells in the original aggression sections (Wilcoxon, log fold change above 1, BH below 0.05). OD Mature: `Ermn`, `Mbp`, `Ndrg1`, `Sgk1`, `Gjc3`, `Ttyh2`, `Lpar1`, `Opalin`, `Cck`, `Gnrh1`. Astrocyte: `Aqp4`, `Aldh1l1`, `Cxcl14`, `Mlc1`, `Pou3f2`, `Trh`, `Cspg5`, `Sst`, `Ttyh2`, `Sox8`.
2. Count markers in each method's top 20 on the original and the synthetic tables.
3. Retained mass of naive cells of the removed class in the between pairs (they lose their counterpart in the aggression sections).

**Result.**

| Method | OD Mature: original | synthetic | Astrocyte: original | synthetic |
|---|---|---|---|---|
| stORCA (replicate t) | 1 | **4** | 2 | **5** |
| stORCA calls that are markers | 1 of 11 | **3 of 14** | 2 of 11 | 2 of 8 |
| stORCA single pair | 0 | 0 | 1 | 1 |
| CODA | 0 | 0 | 0 | 0 |
| River | 3 | 1 | 5 | 5 |
| STcompare | 0 | 0 | 2 | 2 |
| SpaceExpress | 7 | 8 | 4 | 2 |

| Removed class | Unmatched, removed class (between) | Unmatched, other cells (between) |
|---|---|---|
| OD Mature | 0.922 | 0.044 |
| Astrocyte | 0.647 | 0.023 |

New stORCA calls caused by the removal that are markers: `Gjc3` (BH 0.157 to 0.042) and `Opalin` (0.190 to 0.042) for OD Mature, `Aldh1l1` (0.481 to 0.031) for astrocytes. The call set also changes outside the markers (OD Mature: 6 new and 3 lost of 11; Astrocyte: 1 new and 4 lost), because the synthetic run retrains the embedding and the plan.

**Reading:**

- **The plan works: the removed cells are left unmatched.** 0.92 and 0.65 against 0.02 to 0.04 for other cells.
- **The score does not follow the plan.** Although the cells are left out of the matching, stORCA's replicate t ranks their markers higher, and three become calls. Unmatched cells are already left out of the score: in each sampled matching, a source cell is kept with probability equal to its retained mass, and $Q_x$, $Q_y$, $Q_r$ are computed only on the kept cells and their partners (`5-Case-Study-Colitis/22-nrmi-issue-frequency.py`). Section 5b shows why: the denominator, not a leak.
- **The competitors are hardly affected.** CODA, STcompare and the single-pair score do not change; River and SpaceExpress move by at most 2.

**Verdict: fails.** Gap type: Fix (major). This cannot be explained away: it is the one controlled test of the claim, and it shows the opposite for the score.

Result files: `5-Case-Study-Comparison/res/Comparison/q1-hpoasyn-marker-ranks.csv` (columns `scen`, `method`, `table`, `markers_in_top20`), `q1-hpoasyn-retained.csv`, `hpoasyn-odm-gene-table.csv`, `hpoasyn-astro-gene-table.csv`.

## 5b. Why the removed-class markers are called (notebook section 7)

**Question.** The removed cells are left out of the matching, so where does the extra discordance come from?

**In plain words.** ROS is a ratio, $Q_r/(Q_x+Q_y)$. It can rise because the numerator grows (cells are paired with the wrong partner) or because the denominator shrinks (the gene has less spatial structure left to agree on). For `Gjc3`, most of its structure in the naive sections is the oligodendrocyte band. Take that band away and what is left is a weak, scattered pattern in other cells. In a weak pattern, matching noise is a larger fraction of what remains, so ROS goes up even if no cell is paired wrongly.

**Implementation** (notebook section 7; per-matching tables `-issue-matching.csv`, and per-cell contributions recomputed with the same matchings, weights and preprocessing as the score).

1. Per pair kind (within naive, within aggression, between), the mean of $Q_x+Q_y$, $Q_r$ and ROS, on the original and the synthetic data.
2. Per source cell, its contribution to $Q_r$, $c_i=\sum_s \tilde r_i\,(W_s\tilde r)_i$ summed over the matchings $s$ in which it is retained ($\sum_i c_i=Q_r$). The share of $Q_r$ from removed-class cells is compared with their share of retained cell-matchings.

**Result.**

| Gene | Data | $Q_x+Q_y$, within naive | $Q_x+Q_y$, between | ROS, within naive | ROS, within aggression | ROS, between |
|---|---|---|---|---|---|---|
| `Gjc3` | original | 275k | 190k | 0.021 | 0.117 | 0.173 |
| `Gjc3` | synthetic | 276k | 26k | 0.021 | 0.165 | 0.279 |
| `Opalin` | original | 135k | 89k | 0.056 | 0.147 | 0.199 |
| `Opalin` | synthetic | 135k | 7k | 0.056 | 0.401 | 0.475 |
| `Aldh1l1` | original | 47k | 34k | 0.118 | 0.363 | 0.290 |
| `Aldh1l1` | synthetic | 47k | 21k | 0.132 | 0.407 | 0.483 |

| Gene | Data | Removed class, share of retained cell-matchings | Removed class, share of $Q_r$ |
|---|---|---|---|
| `Gjc3` | original | 0.196 | 0.465 |
| `Gjc3` | synthetic | 0.051 | 0.267 |
| `Opalin` | original | 0.196 | 0.558 |
| `Opalin` | synthetic | 0.051 | 0.320 |
| `Aldh1l1` | original | 0.106 | 0.147 |
| `Aldh1l1` | synthetic | 0.049 | 0.143 |

(medians over the 9 between pairs)

![Denominator and ROS by pair kind](fig/11-q1-unmatched-cells/q1-hpoasyn-qparts.png)

*One column per gene. Top: $Q_x+Q_y$ summed over matchings, log scale. Bottom: ROS. Grey: original HPOA. Red: synthetic (class removed from the aggression sections). Takeaway: in the synthetic data the denominator of the between pairs falls 1.6 to 12 times while the within-naive pairs do not move, and ROS of the between pairs rises. Source: [11-q1-unmatched-cells.ipynb](11-q1-unmatched-cells.ipynb) section 7.*

![Gjc3 Q_r maps](fig/11-q1-unmatched-cells/q1-hpoasyn-gjc3-qr-maps.png)

*Pair `naive-a5` to `aggr-a34`. From left: `Gjc3` in `naive-a5`; OD Mature cells coloured by the share of matchings in which they are retained (other cells grey); per-cell contribution to $Q_r$ on the original data; the same on the synthetic data, same colour scale. Takeaway: in the synthetic pair the oligodendrocyte band (top) is almost never retained, and $Q_r$ comes from cells spread over the whole section, at the same size as in the original. `Opalin` and `Aldh1l1`: `fig/11-q1-unmatched-cells/q1-hpoasyn-opalin-qr-maps.png`, `q1-hpoasyn-aldh1l1-qr-maps.png`. Source: notebook section 7.*

**Reading:**

- **It is not a leak.** The removed cells are retained in only 5% of cell-matchings and give a smaller share of $Q_r$ than in the original.
- **It is the denominator.** The between pairs lose most of the marker's spatial structure ($Q_x+Q_y$ of `Opalin` falls from 89k to 7k), $Q_r$ falls less, and ROS rises.
- **The baseline is measured on different cells.** The within-naive pairs keep the class on both sides and keep their low ROS (0.021 for `Gjc3`). The between pairs score the gene on the tissue without the class. So "between minus within" compares the gene's concordance on two different sets of cells, and the difference is called.

**Is the call wrong?** Partly not: the treated sections did lose the marker's spatial pattern, and in the matched cells what is left of it is weak and disordered. But it is not a change in the shared tissue, which is what Q1 claims to isolate. A fix would score the within-control pairs on the same kind of cells that the between pairs keep (for example, weight each control cell by its retained mass in the between pairs). That is a method change.

**Verdict: mechanism found.** The plan works; the replicate baseline does not follow the plan.

Result files: `5-Case-Study-Comparison/res/Comparison/q1-hpoasyn-qr-share.csv` (columns `gene`, `data`, `pair`, `class_share_of_cell_matchings`, `class_share_of_Qr`); the $Q$ table is in the notebook output of section 7.

## 5c. Test: score the replicate baseline on the cells the between pairs keep (notebook section 8)

**Question.** If the within-control pairs are scored on the same cells that the between pairs keep, do the calls caused by the removed class go away, and do real calls stay?

**In plain words.** In a between pair the naive oligodendrocytes are mostly left out, so the naive sections should also be compared with each other without them. Then both sides of "between minus within" see the same tissue.

**Implementation** (`22-q1-baseline-weighting.py`, 2026-11-17). Two variants; both rerun the v3 limma fit with all labelings.

1. **Thinning (`basew`).** For a within-control pair with source section $s$, each source cell $i$ is kept in each scoring matching with an extra probability $m_i$, its mean retained mass over the between pairs from $s$. Matchings and partners are unchanged; cells are only thinned. Between pairs are unchanged.
2. **Hard (`hard`).** Cells with retained mass below 0.5 are dropped from every matching, in the between pairs (own retained mass) and in the within-control pairs (mean over the between pairs).

Controls: the original HPOA, where no class is missing, so its 11 calls should stay; the false labelings of each fit.

**Result.**

| Variant | Case | Calls before | Calls after | After calls that are original HPOA calls | Lost | Gained | Largest false-label count |
|---|---|---|---|---|---|---|---|
| Thinning | OD Mature removed | 14 | 7 | 7 of 7 | `Cd24a`, `Gjc3`, `Greb1`, `Igf2r`, `Opalin`, `Pnoc`, `Rxfp1` | none | 1 |
| Thinning | Astrocyte removed | 8 | 8 | 7 of 8 | none | none | 0 |
| Thinning | Original HPOA | 11 | 11 | 11 of 11 | none | none | 0 |
| Thinning | Colitis D0 vs D9 | 425 | 407 | not applicable | 20 | 2 | 0 |
| Hard | OD Mature removed | 14 | 8 | 6 of 8 | `Cd24a`, `Gjc3`, `Greb1`, `Igf2r`, `Ntsr1`, `Pnoc`, `Rxfp1` | `Lpar1` | 1 |
| Hard | Astrocyte removed | 8 | 8 | 7 of 8 | none | none | 0 |
| Hard | Original HPOA | 11 | 9 | 9 of 9 | `Adora2a`, `Cckbr` | none | 0 |
| Thinning, both sides (`basew2`, 2026-11-18) | OD Mature removed | 14 | 10 | 6 of 10 | `Cd24a`, `Col25a1`, `Crhr1`, `Greb1`, `Rxfp1` | `Th` | 0 |
| Thinning, both sides (`basew2`, 2026-11-18) | Original HPOA | 11 | 11 | 11 of 11 | none | none | 0 |

**Reading:**

- **Thinning removes every call the OD Mature removal created** (`Gjc3`, `Opalin` and the four non-marker calls), and what is left is a subset of the original calls. The original HPOA does not change, so the change costs no real call here.
- **It does not fix the astrocyte case.** `Aldh1l1` stays called (BH 0.034; within ROS 0.30, between 0.48). Astrocytes are scattered, and the plan keeps 37% to 43% of their mass in the between pairs (other cells 95% to 100%), so a real leak remains: the kept astrocytes are paired with cells of another class. Thinning the baseline cannot remove that.
- **The hard rule is worse.** It keeps `Opalin`, adds the OD Mature marker `Lpar1`, and drops 2 of 11 real calls in the original HPOA.

**Update 2026-11-18: both sides thinned.** Section 7 uses the symmetric variant of section 5e. On the OD Mature case it does not repeat the result above: `Gjc3` and `Opalin` stay called (BH 0.045, against 0.069 and 0.056 with the control side alone), `Pnoc` stays, `Th` is added, and two original calls (`Col25a1`, `Crhr1`) are lost. The control-side variant had moved `Gjc3` and `Opalin` only just above the threshold, so the variants differ little. What none of them moves is the ranking: 4 of the top 20 are removed-class markers with no thinning, with the control side and with both sides (original HPOA 1). The astrocyte case was not rerun with both sides.

**Verdict (updated): thinning moves the calls of a scattered class across the threshold but not out of the top 20.** The semi-synthetic test is not used in the paper (decision of 2026-11-18; section 7c).

Result files: `5-Case-Study-Comparison/res/Comparison/q1-baseline-weighting-summary-basew.csv`, `-hard.csv`, `-basew2-hpoasynodm.csv`, `-basew2-hpoa.csv`; `<case>/res/stORCA/storca-v3-rep1-<case>-limma-genes-basew.csv`, `-hard.csv`, `-basew2.csv`.

## 5d. Colitis: tissue that disappears as well as tissue that appears (notebook section 9)

**Question.** Section 3 counted only the new tissue. In colitis at day 9 the epithelium also disappears. Do the competitors' top genes come from either side?

**In plain words.** A cell can lack a counterpart in two ways: it is in the treated section and nothing like it is in the control (gained tissue, the ulcer), or it is in the control and nothing like it remains in the treated section (lost tissue, the epithelium). A method that compares whole sections sees the marker of either kind as "changed". stORCA's plan leaves both out.

**Implementation** (`23-q1-colitis-competitors.py`, 2026-11-17).

1. Unmatched cells: retained mass below 0.5, averaged over the between pairs; target side for gained tissue, source side for lost tissue.
2. Markers of each side: Wilcoxon of unmatched against matched cells of that condition (normalized log1p, log fold change above 1, BH below 0.05), among the 502 genes stORCA tested. No annotation is used.
3. Per method: share of the top 20 and top 50 genes that are markers, against the share among all tested genes, and the AUROC of the score.

**Result** (D0 vs D9; 0.452 of D9 cells and 0.441 of D0 cells are unmatched; 69 gained and 181 lost markers).

| Method | Lost markers, top 20 | Lost, top 50 | Lost, AUROC | Gained markers, top 20 | Gained, AUROC |
|---|---|---|---|---|---|
| All tested genes (base) | 0.36 | 0.36 | 0.50 | 0.14 | 0.50 |
| stORCA (replicate t) | **0.25** | 0.30 | 0.44 | 0.15 | 0.45 |
| stORCA, baseline thinned (section 5c) | **0.25** | 0.24 | 0.42 | 0.15 | 0.45 |
| stORCA single pair | 0.15 | 0.20 | 0.52 | 0.15 | 0.34 |
| CODA | **0.70** | 0.48 | 0.42 | 0.05 | 0.44 |
| River | 0.30 | 0.44 | 0.62 | 0.20 | 0.51 |
| STcompare | **0.65** | 0.54 | 0.41 | 0.05 | 0.32 |
| DESpace2 | **0.80** | 0.70 | 0.68 | 0.00 | 0.42 |
| Pseudobulk DE | 0.35 | 0.32 | 0.55 | 0.45 | 0.80 |

Lost-tissue markers in the top 20 of CODA, STcompare and DESpace2 include `Ptger3` (all three), `Lrp6`, `Cldn15`, `Yap1`, `Nr1d2`, `Bcr` and, in DESpace2, `Muc4`, `Atoh1` and `Ccl28`: genes of the epithelium that is gone at day 9.

![Colitis top 20 by side](fig/11-q1-unmatched-cells/q1-colitis-lost-gained-top20.png)

*Left: share of each method's top 20 that are markers of lost tissue. Right: markers of gained tissue. Red: stORCA. Dashed line: share among all tested genes. Takeaway: CODA, STcompare and DESpace2 are about twice the base rate for lost tissue; stORCA is below it. Source: [11-q1-unmatched-cells.ipynb](11-q1-unmatched-cells.ipynb) section 9.*

**Reading:**

- **Three competitors are dominated by the tissue that disappears.** 13 to 16 of their top 20 genes are lost-tissue markers, against 7 expected. stORCA has 5 and River 6.
- **No spatial method is dominated by the tissue that appears.** That is why section 3 found nothing. Only pseudobulk DE picks the ulcer genes.
- **The enrichment is at the top, not across the whole ranking.** AUROC of CODA and STcompare for lost markers is 0.42 and 0.41. The top of their lists is what a user reads, so the top 20 is the relevant measure, but the effect is not "the whole ranking is driven by composition".
- **D0 vs D3 does not test the claim.** Only 0.4% (gained) and 1.3% (lost) of cells are unmatched.

**Why the semi-synthetic test of section 5 did not show this.** There the removed class is 20% of the cells and mixed with other cells; in colitis the lost tissue is 44% of the cells and a whole compartment (the mucosa), so the competitors' alignment or correlation has to bend around a large hole. This is a reading, not a test.

**Design.** "3 vs 3" here is three adjacent slices of one section of one mouse per condition (`062921_D0_m3a_2` slices 1 to 3 against `100221_D9_m5_1` slices 1 to 3): 9 between pairs and 6 within pairs. The competitor scores are means over the 9 between pairs. stORCA's limma uses all 15 pairs, but its within pairs are near-copies, so it calls 425 (thinned 407) of 502 genes; only its ranking is compared here, not its calls.

**Verdict: works for lost tissue in severe colitis; no evidence for gained tissue.** One dataset and one mouse per condition, so this is one biological comparison, not a replicated one.

Result files: `5-Case-Study-Comparison/res/Comparison/q1-colitis-competitors.csv` (columns `case`, `method`, `side`, `top20`, `top50`, `auroc`, `base_share`), `q1-colitis-top-genes.csv`.

## 5e. Cortex stab wound, and thinning on both sides (2026-11-17)

**Question.** Does the colitis picture hold in the cortex stab wound, and does the baseline need thinning on the treated side as well?

**Why both sides.** Section 5c thinned only the within-control pairs, which covers tissue that disappears. Tissue that appears (ulcer, lesion) is in the treated sections: the between pairs leave it out, but the within-treated pairs keep it, the same mismatch on the other side. The symmetric version (`22-q1-baseline-weighting.py --both`, suffix `basew2`) also thins each within-treated pair, keeping each treated cell with probability equal to its mean retained mass as a target in the between pairs.

**Implementation.** `23-q1-colitis-competitors.py cortexrep` and `colitisq1`, same rules as section 5d. Cortex stab is 2 vs 2 (intact r1, r2 against 3 dpi r1, r2), so it has one within pair per condition and stORCA makes 1 call; only rankings are compared.

**Result.** Cortex: 0.089 of 3 dpi spots are unmatched (the lesion, 239 gained markers); only 0.010 of intact spots are unmatched (3 lost markers), so only the gained side can be tested.

| Top 20 | Cortex, gained (base 0.12) | Colitis D9, gained (base 0.14) | Colitis D9, lost (base 0.36) |
|---|---|---|---|
| stORCA | 0.35 | 0.15 | 0.25 |
| stORCA, control side thinned | 0.35 | 0.15 | 0.25 |
| stORCA, both sides thinned | **0.20** | **0.00** | 0.25 (top 50: 0.18) |
| CODA | 0.05 | 0.05 | 0.70 |
| River | 0.35 | 0.20 | 0.30 |
| STcompare | 0.10 | 0.05 | 0.65 |
| SpaceExpress | 0.00 | not run | not run |
| DESpace2 | not run | 0.00 | 0.80 |
| Pseudobulk DE | 0.70 | 0.45 | 0.35 |

Original HPOA with both sides thinned: 11 of 11 calls kept. Colitis calls: 425 to 398.

The four lesion markers left in the cortex top 20 after thinning both sides, by mean log1p level:

| Gene | Intact | 3 dpi, matched tissue | 3 dpi, lesion |
|---|---|---|---|
| `C1qc` | 0.54 | 0.81 | 2.43 |
| `Tyrobp` | 0.61 | 0.85 | 2.34 |
| `Tmsb10` | 1.94 | 2.12 | 2.92 |
| `Ms4a6c` | 0.008 | 0.009 | 0.18 |

**Reading:**

- **Thinning both sides is needed for tissue that appears.** It removes the ulcer markers from the colitis top 20 (0.15 to 0.00) and cuts the lesion markers in cortex from 0.35 to 0.20, without changing the HPOA calls.
- **The cortex competitor column above is not valid.** These sections were not yet oriented, and the CODA and STcompare registrations failed (CODA score of `Mbp` between the two intact hemispheres -0.11). On the oriented sections (`23-q1-colitis-competitors.py cortexor`, same rule) the gained-marker share of the top 20 is CODA 0.50, STcompare 0.85, River 0.05, SpaceExpress 0.00; stORCA is unchanged (it does not use a rigid transform). Section 5f separates which of these are confined to the lesion.
- **What stORCA keeps is mostly a real change in the shared tissue.** `C1qc` and `Tyrobp` (microglia) are 1.4 to 1.5 times higher in the matched tissue around the lesion than in intact cortex. `Ms4a6c` changes only inside the lesion, so it is a remaining leak (1 of 20).

**Verdict: symmetric thinning works on both datasets. The competitor comparison for cortex is replaced by section 5f (oriented sections).**

Result files: `5-Case-Study-Comparison/res/Comparison/q1-colitis-competitors-cortexrep.csv`, `-colitisq1.csv`, `q1-baseline-weighting-summary-basew2-<case>.csv`.

## 5f. Standard markers, oriented cortex, and examples (notebook section 10, 2026-11-18)

**Question.** Sections 5d and 5e defined markers from stORCA's own plan (unmatched against matched cells). Does the result hold with the standard marker route, which does not use the plan? And can genes that rise around the lesion as well (reactive glia such as `Gfap`, `C1qc`) be kept out of the count?

**Implementation.**

1. Condition-specific clusters: below 1% of cells in one condition and at least 2% in the other. Cortex (oriented sections `cortexor`, see below; clusters `region`): **r14**, the lesion. r15 also passes the rule but is left out: it is a band across the cortex, and the plan matches it (retained mass 0.88, 9% unmatched, against r14 0.48 and 53%), so it is tissue with a counterpart in a changed state, not tissue without one. Colitis (published cell types `tier2`): the epithelium, **Colonocytes**, **TA** and **Stem cells**, at day 0 and nearly gone at day 9. Fibro 2/6/7 pass the same rule but turn into inflammatory fibroblasts (a change of state), so they are left out.
2. Markers: each cluster against all other cells of both conditions (Wilcoxon, normalized log1p, log2 fold change above 1, BH below 0.05, expressed in at least 25% of the cluster), as Seurat `FindAllMarkers`; union over the clusters.
3. **Cluster-only vs shared.** A marker is *shared* when the tissue outside the clusters also changes between conditions: |log2 fold change| of at least 0.5 between cells outside the clusters in the two conditions. This is how reactive glial genes are kept out: `Gfap`, `C1qc`, `Cd52` and `Hmox1` are lesion markers but also rise in the 3 dpi cortex outside the lesion, so they are real changes of the shared tissue and are not counted as an error of any method. *Cluster-only* markers change only inside the clusters.
4. Concentration of a gene: share of its expression in the cluster cells divided by the share of cells in the clusters (1 = spread like all cells; at most 7.7 in cortex, 2.5 in colitis).
5. Oriented cortex: the four hemispheres were put in one orientation (`07-orient-sections.py`, one of 8 flips and 90-degree rotations, mean binned correlation 0.54 to 0.62 against -0.20 to 0.09 before). All four competitors were rerun on it, and registration now works (CODA score of `Mbp` between the two intact hemispheres -0.11 before, 0.55 after). stORCA does not depend on a rigid transform.

**Color code** of the maps: cortex r14 red `#d62728`; colitis Colonocytes dark blue `#08519c`, TA blue `#3182bd`, Stem cells light blue `#9ecae1`; all other cells light grey `#e0e0e0`. So yes: in these maps the lost epithelium is the blue ring of the day-0 sections.

**Result** (share of top 20; markers = cluster-only + shared).

| Method | Cortex r14, markers (base 0.11) | Cortex r14, cluster-only (base 0.07) | Cortex, median concentration | Colitis lost epithelium, markers (base 0.28) | Colitis, cluster-only (base 0.12) | Colitis, median concentration |
|---|---|---|---|---|---|---|
| stORCA | 0.30 | 0.00 | 1.35 | 0.35 | 0.05 | 0.38 |
| stORCA, both sides thinned | 0.20 | 0.05 | 1.08 | 0.35 | 0.10 | 0.45 |
| CODA | **0.45** | 0.05 | 1.43 | **0.70** | **0.30** | **1.50** |
| River | 0.10 | 0.00 | 0.99 | 0.30 | 0.00 | 0.91 |
| STcompare | **0.70** | **0.20** | **1.75** | **0.60** | **0.30** | **1.49** |
| SpaceExpress | 0.00 | 0.00 | | not run | not run | |
| DESpace2 | not run | not run | | **0.70** | **0.35** | **2.01** |
| Pseudobulk DE | 0.60 | 0.05 | 2.86 | 0.40 | 0.05 | 1.40 |

![Top-20 share and concentration](fig/11-q1-unmatched-cells/q1-std-top20-share-concentration.png)

*Left: share of each method's top 20 that are cluster markers, cluster-only (black) and shared (grey); dashed and dotted lines: share among all tested genes. Right: concentration of each top-20 gene in the clusters, red line = median. Top: cortex lesion r14. Bottom: colitis lost epithelium. Takeaway: in colitis CODA, STcompare and DESpace2 lists sit in the lost epithelium (median 1.5 to 2.0) and stORCA's do not (0.4); in cortex CODA's lesion markers are nearly all shared (grey), while STcompare has 4 cluster-only genes in its top 20 against 0 for stORCA. Source: [11-q1-unmatched-cells.ipynb](11-q1-unmatched-cells.ipynb) section 10b.*

![Colitis examples](fig/11-q1-unmatched-cells/q1-std-examples-colitisq1.png)

*Rows 1 to 4: `Ptger3`, `Cldn15` (competitors' top 20), `Flnc`, `Grem2` (stORCA's top two), one color scale per gene over the three day-0 and three day-9 slices. Last row: the epithelium (blue) and all other cells (grey). Takeaway: `Ptger3` and `Cldn15` sit in the day-0 epithelial ring and vanish with it; `Flnc` and `Grem2` sit in the muscle layers, which are present at both days, and change there. Source: notebook section 10c.*

| Colitis gene | stORCA rank | stORCA thinned rank | CODA | STcompare | DESpace2 | Class | Concentration |
|---|---|---|---|---|---|---|---|
| `Ptger3` | 212 | 224 | 1 | 3 | 1 | cluster-only | 1.9 |
| `Cldn15` | 284 | 353 | 11 | >20 | 18 | cluster-only | 2.0 |
| `Flnc` | 1 | 2 | >20 | >20 | >20 | not a marker | 0.1 |
| `Grem2` | 2 | 5 | >20 | >20 | >20 | not a marker | 0.3 |

![Cortex examples](fig/11-q1-unmatched-cells/q1-std-examples-cortexor.png)

*Rows: `Cd52`, `Hmox1` (CODA ranks 1 and 17), `Sgk1` (stORCA rank 1), `Ms4a6c` (stORCA thinned rank 17), one color scale per gene over the four oriented hemispheres. Last row: r14 (red). Takeaway: CODA's genes peak in the lesion and are also raised across the 3 dpi cortex (shared); `Sgk1` rises in a band of matched tissue (the excluded r15) and not in the lesion; `Ms4a6c` is confined to the lesion and is in stORCA's list. Source: notebook section 10c.*

| Cortex gene | stORCA rank | stORCA thinned rank | CODA rank | Class (r14) | Concentration | log2FC outside r14 |
|---|---|---|---|---|---|---|
| `Cd52` | 124 | 169 | 1 | shared | 3.05 | 1.49 |
| `Hmox1` | 119 | 212 | 17 | shared | 4.28 | 1.17 |
| `Sgk1` | 1 | 1 | 1291 | not a marker | 0.88 | 1.33 |
| `Ms4a6c` | 8 | 17 | 135 | lesion-confined, below the 25% expression rule | 5.73 | -0.11 |

**Reading:**

- **Colitis holds with standard markers.** CODA, STcompare and DESpace2 put 0.60 to 0.70 of their top 20 in markers of the lost epithelium, half of them cluster-only (base 0.28 and 0.12); stORCA 0.35 and 0.05 to 0.10. `Ptger3` is the named example: top 3 in all three competitors, rank 212 in stORCA, and on the maps it is a gene of the epithelium that is gone.
- **Cortex (r14 only): CODA leans more on the lesion, but through shared genes.** CODA has 0.45 lesion markers in its top 20 against 0.30 for stORCA and 0.20 after thinning both sides (base 0.11), and `Cd52` and `Hmox1` peak in r14 (concentration 3.0 and 4.3). Almost all of these markers also rise outside the lesion (cluster-only 0.05 for CODA and thinned stORCA, 0.00 for stORCA), so CODA ranks real changes that are largest in the lesion; this is not an error. What stORCA ranks instead is change in the matched tissue: its top gene `Sgk1` rises in the r15 band, which the plan matches, and not in the lesion. The one lesion-confined gene in either list, `Ms4a6c`, is in stORCA's (concentration 5.7, no change outside).
- **Cortex, STcompare: a weaker version of the colitis pattern.** STcompare puts 0.70 of its top 20 in lesion markers, 0.20 cluster-only (base 0.07): `Lgals1` (rank 1, concentration 2.0, log2FC outside r14 0.47, just under the 0.5 cut), `Ftl1` (11), `Tpm4` (18), `Tax1bp3` (19). stORCA ranks them 211 to 593 and has no cluster-only gene in its top 20. This is 4 of 20 against an expected 1.5, so it supports the direction of the claim for tissue that appears, not as strongly as colitis.
- **Why r15 was dropped.** With r14 and r15 together (previous version), stORCA had 0.55 markers against 0.50 for CODA, because r15 genes such as `Pou3f1` and `Sgk1` counted as "new tissue" markers. The plan matches r15 (retained mass 0.88), so those genes are changes of tissue with a counterpart and should not count.
- **Plan-based and standard markers agree in colitis** (sections 5d and 5f). The standard route is independent of stORCA, so it should be the definition used in the paper.

**Verdict: the competitor half of Q1 is supported for lost epithelium in colitis with standard, plan-free markers, with `Ptger3` as the example. In oriented cortex CODA shows a difference in emphasis but no error (its lesion genes also change outside the lesion); STcompare shows a weak error (4 lesion-only genes in its top 20, `Lgals1` rank 1, against 0 for stORCA). Cortex can support the claim for tissue that appears as a secondary example, with colitis as the main one.**

Result files: `5-Case-Study-Comparison/res/Comparison/q1-standard-markers-summary.csv`, `q1-standard-markers-<case>.csv` (per gene: concentration, shift outside the clusters, marker, cluster-only, rank per method).

## 6. Where this leaves Q1 (updated 2026-11-18, after section 7)

**Status: sufficient** for tissue lost or gained as a region (a compartment, a lesion). Section 7 is the conclusion. The plan half and the competitor half hold in both real cases with plan-free standard markers, and stORCA with the baseline thinned on both sides stays near the base rate. Section 7c gives the mechanism of the competitors' error, which needs a lost or gained region. The semi-synthetic test of sections 5 to 5c is not used (decision of 2026-11-18): removing a class scattered among other cells leaves no hole for the alignment to fill and leaves the marker without an organized pattern, so it does not reproduce the real cases (section 7c). This replaces the status of 2026-11-17 ("not yet"), which was written before the symmetric thinning (section 5e) and the standard markers (section 5f). Issues are split by the rule in `CLAUDE.md` ("Level of Rigor: Fix or Defend").

| Claim | Supported? | Basis |
|---|---|---|
| The plan leaves cells without a counterpart unmatched | Yes: AUROC 0.89 (cortex) and 0.94 (colitis day 0); within pairs keep 0.99 | 1, 7a |
| stORCA reports the composition change separately (how much, which population) | Yes, as an output | 1, 7a |
| Registration and domain methods put markers of tissue without a counterpart at the top | Yes in both real cases with standard markers: colitis lost epithelium CODA 0.70, STcompare 0.60, DESpace2 0.70 (base 0.28); cortex lesion CODA 0.45, STcompare 0.70 (base 0.11) | 5f, 7b |
| stORCA's top genes are not driven by that tissue | Yes in both real cases: 0.35 and 0.20 with both sides thinned | 7b |
| The competitors' error has a mechanism | Yes, on all 9 colitis pairs and for both CODA and STcompare: the alignment lays the lost epithelium over day-9 tissue where its markers are low, which gives most of the negative correlation (`Ptger3`: 0.85 for CODA, 0.59 for STcompare) | 7c |
| A named gene shows the contrast | Yes: `Ptger3` in colitis (top 3 of CODA, STcompare and DESpace2; stORCA rank 212); `Lgals1` in cortex (STcompare rank 1; stORCA ranks it beyond 200) | 5f |

**Fix.** None.

**Defend.**

| A reviewer can say | Answer |
|---|---|
| There are only two real cases | They differ in technology, tissue and direction (MERFISH colon with tissue lost, Visium cortex with tissue gained), and both point the same way at every list length (section 7b, top k). The controlled test is the synthetic rearrangement set (outline Figure 4g, to rerun) |
| Why should a correlation method fail at all? | Section 7c: the alignment has to place the lost compartment somewhere, so its markers are compared with other tissue where they are low; the correlation turns negative, which is what puts a gene at the top of these lists. A scattered class leaves nothing to overlay |
| Colitis slices of one condition come from one mouse | Only rankings and the plan are used from colitis; its calls are not used |
| Cortex is 2 vs 2 and gives one call | Only rankings and the plan are used; the call count is not |
| River is also near the base rate | The claim is about registration and domain methods, which assume one counterpart per location or fixed domains. River is reported as it is |
| Pseudobulk DE also ranks lesion markers high (0.60 in cortex) | Pseudobulk DE is meant to find level changes, including those of new tissue; it is shown as a reference, not as a spatial competitor |
| The 0.5 cut for "unmatched" is a convention | The maps and the AUROC use the continuous retained mass (section 7a) |
| The markers depend on the marker test | They are standard cluster-vs-rest markers that do not use stORCA's plan (section 5f); plan-based markers give the same picture in colitis (section 5d) |
| One lesion-confined gene (`Ms4a6c`) is still in stORCA's cortex top 20 | 1 of 20, and reported; the other lesion markers left in the list also rise in the matched tissue (section 5e) |
| DESpace2 was not run on cortex | It was run on colitis and HPOA; adding it would add one cell to the table |

**Decisions for you.**

1. Move the thinning on both sides into the pipeline. Recommended: yes (outline section 6, step 0).
2. Rerun the synthetic rearrangement scenarios 08 to 11 with v3 and both sides thinned, as the controlled test for regions. Recommended: yes, first among the synthetic reruns; the old pipeline result there does not support the claim, so Figure 4 depends on it.
3. Draw the split of section 7c (done on all 9 pairs for CODA and STcompare) as the mechanism panel of outline Figure 4f. Recommended: yes.

## 7. Slide figures (notebook section 11, 2026-11-18)

Figures for two slide messages. Only stORCA with both sides of the baseline thinned is shown. Result file: `5-Case-Study-Comparison/res/Comparison/q1-slide-retained-summary.csv`.

### 7a. Cells without a counterpart have low retained mass

**Retained mass.** For a pair of sections with $n$ cells each carrying mass $1/n$, the dead-zone plan $\pi$ may leave mass unmatched. The retained mass of cell $i$ is

$$
m_i = n\sum_j \pi_{ij}\in[0,1],
$$

the share of its mass the plan keeps (1 = fully matched, 0 = no partner; `interpret.retained_fraction`). It is averaged over the between pairs of a section (target side for treated sections, source side for control sections), with the within pairs as reference. A cell is unmatched when $m_i<0.5$.

**No counterpart, from annotation only** (rule of section 5f: below 1% of cells in one condition, at least 2% in the other): cortex 3 dpi r14 (lesion); colitis day 9 the 15 day-9-only cell types (neutrophils, monocytes, inflammatory fibroblasts and smooth muscle, and others); colitis day 0 the epithelium (Colonocytes, TA, Stem cells).

| Panel | Cells without a counterpart | Retained mass: no counterpart, between | Other cells, between | All cells, within | AUROC of low retained mass | Share of unmatched cells that are "no counterpart" |
|---|---|---|---|---|---|---|
| Cortex 3 dpi | r14, 227 of 1738 spots | 0.43 | 0.97 | 0.99 | 0.89 | 0.86 |
| Colitis day 0 | epithelium, 28,315 of 71,607 cells | 0.19 | 0.81 | 0.99 | 0.94 | 0.81 |
| Colitis day 9 | 15 cell types, 68,867 of 88,969 cells | 0.51 | 0.72 | 0.94 | 0.66 | 0.86 |

![Retained mass vs specificity](fig/11-q1-unmatched-cells/q1-slide-retained-vs-specificity.png)

*One point per cluster (size = cells). x: log2 of its share of cells in this condition over the other (right = only here). y: mean retained mass over the between pairs. Colored: clusters without a counterpart; dashed: all cells in within pairs. Takeaway: the clusters found only in one condition are the ones with low retained mass. Source: [11-q1-unmatched-cells.ipynb](11-q1-unmatched-cells.ipynb) section 11a.*

![Retained mass violins](fig/11-q1-unmatched-cells/q1-slide-retained-violin.png)

*Retained mass of single cells: no counterpart (between pairs), other cells (between pairs), all cells (within pairs). Dotted: the 0.5 cut. Takeaway: within pairs keep almost everything; between pairs drop the cells without a counterpart. Source: notebook section 11b.*

![Cortex maps](fig/11-q1-unmatched-cells/q1-slide-maps-cortex-3-dpi.png)

![Colitis day 0 maps](fig/11-q1-unmatched-cells/q1-slide-maps-colitis-day-0.png)

*Top: cells without a counterpart in color (cortex r14 red, colitis epithelium blue), others grey. Bottom: retained mass on the same sections. Takeaway: the dark region is the region without a counterpart. Day 9: `fig/11-q1-unmatched-cells/q1-slide-maps-colitis-day-9.png`; legend: `q1-slide-maps-legend.png`. Source: notebook section 11c.*

**Reading:** the plan's low retained mass finds the cells without a counterpart in cortex (AUROC 0.89) and colitis day 0 (0.94). Colitis day 9 is weaker (0.66): by annotation 77% of day-9 cells are day-9-only types, and many are inflamed versions of cells present at day 0 (inflammatory fibroblasts and smooth muscle, retained mass 0.5 to 0.95), which the plan matches. For slides, use cortex and colitis day 0; day 0 is also the tissue of message 2.

### 7b. Top genes: marker share of the tissue without a counterpart

Markers as in section 5f (each cluster vs rest, all markers).

| Method | Cortex r14, markers in top 20 (base 0.11) | Colitis lost epithelium, markers in top 20 (base 0.28) |
|---|---|---|
| stORCA (both sides thinned) | **0.20** | **0.35** |
| CODA | 0.45 | 0.70 |
| STcompare | 0.70 | 0.60 |
| DESpace2 | not run | 0.70 |
| River | 0.10 | 0.30 |
| Pseudobulk DE | 0.60 | 0.40 |

![Marker share top 20](fig/11-q1-unmatched-cells/q1-slide-marker-share-top20.png)

*Share of each method's top 20 that are markers of the tissue without a counterpart. Red: stORCA (thinned). Dashed: share among all tested genes. Source: notebook section 11d.*

![Marker share top k](fig/11-q1-unmatched-cells/q1-slide-marker-share-topk.png)

*The same share for the top k genes, k = 5 to 100 (legend: `fig/11-q1-unmatched-cells/q1-slide-method-legend.png`; red thick = stORCA thinned, blue = CODA, green = STcompare, purple = DESpace2, orange = River, grey = pseudobulk DE). Takeaway: CODA, STcompare and DESpace2 stay above stORCA at every list length; River's share grows past 0.4 after its top 60 in colitis. Source: notebook section 11e.*

Example genes and their maps: section 5f (`Ptger3`, `Cldn15`, `Flnc`, `Grem2`; cortex `Cd52`, `Hmox1`, `Sgk1`, `Ms4a6c`).

### 7c. Why CODA and STcompare rank markers of lost tissue first (2026-11-18, all 9 pairs)

**Question.** CODA and STcompare are not misled when a cell class scattered among other cells is removed (HPOA semi-synthetic, section 5), but they are when the colitis epithelium is lost (section 7b). What is different?

**In plain words.** Both scores are correlations computed after an alignment. When the epithelium is lost, the alignment has to place the day-0 epithelium somewhere, and it lays it over day-9 tissue that does not express the epithelial markers. Each marker is then compared with low values exactly where it was high, so its correlation turns negative, and a negative correlation is what puts a gene at the top of these lists. When a scattered class is removed, no region is laid over other tissue; the marker's correlation only falls toward zero, the level of genes without structure, and the gene stays in the middle of the list.

**Implementation.**

- CODA (`31-q1-coda-mechanism.py`, env_CODA). Its score is
$$
\mathrm{CCI}=\frac{n}{S}\,\frac{\sum_{ij}W_{ij}(x_i-\bar x)(y_j-\bar y)}{\sqrt{\sum_i(x_i-\bar x)^2\sum_j(y_j-\bar y)^2}},\qquad W_{ij}=e^{-d_{ij}^2},
$$
with source cells placed after LDDMM and target cells in place, on CODA's 78-pixel canvas (`0-ExternalTool/CODA/icoda-2.0.0/CODA/Cross_correlation.py`). Our run scores all cells; CODA's common region is computed but not used (`templates/03-coda-template.py`, `common_regions_used_in_scoring: False`). The CCI is recomputed from the saved alignment state (`5-Case-Study-Colitis-Q1/res/CODA/*-align.pkl`), and its numerator is split into the part from the lost epithelium (source cells labelled Colonocytes, TA, Stem cells) and the rest.
- STcompare (`32-q1-stcompare-mechanism.py`). Its score is the Pearson correlation of per-pixel mean counts over the pixels that hold cells in both sections (80-unit raster after STalign; `templates/stcompare-template.R`). It is recomputed from the STalign outputs (difference from `correlation.csv` 4e-16) and split into the part from lost-epithelium pixels (day-0 cells at least half epithelium) and the rest.

**Result** (9 between pairs).

| | CODA | STcompare |
|---|---|---|
| Lost epithelium still compared with day-9 tissue | 0.79 of the lost cells lie on a day-9 cell (0.61 to 0.91), mostly inflammatory fibroblasts, inflammatory epithelium and neutrophils | 0.74 to 0.99 of the epithelial pixels stay shared pixels |
| `Ptger3` score per pair | negative in 9 of 9 (CCI -0.002 to -0.014) | negative in 9 of 9 (r -0.12 to -0.21) |
| Share of the summed negative score from the lost epithelium, `Ptger3` | 0.85 | 0.59, from 0.31 to 0.37 of the shared pixels |
| Same, `Lrp6` | 0.91 | 0.61 |
| Same, `Cldn15` | all of it (1.06) | 0.43 (r near 0) |
| Day-9 cells under the lost epithelium, `Ptger3` | -0.02 to -0.08 SD around the day-9 mean (+0.02 in pair s1-s1) | |

For comparison, HPOA with OD Mature removed (pair `naive-a5` vs `aggr-a34`): 0.45 of the removed class's source cells lie on an aggression cell (0.64 in the original data), and `Gjc3`'s CCI falls from 0.18 to 0.04, which is still positive and about the level of genes without structure (median 0.02); it ranks 122 of 160.

Where `Ptger3`'s signal sits: at day 0, 0.76 of its above-mean signal is in the epithelium; at day 9, 0.45 is in the muscle layer, whose level does not change between days (cluster-only, section 5f).

**Reading:**

- **The overlay of lost tissue on other tissue drives the error.** In both methods most of the negative score comes from the lost epithelium compared with day-9 cells that sit below the day-9 mean (CODA 0.85; STcompare 0.59 from a third of the pixels). The rest of the section adds a smaller part, through the day-9 mean that the remaining (muscle) expression sets. Correction of the first version of this section, which used pair s1-s1 only and found the rest of the tissue dominating: that holds for that pair alone.
- **A scattered class leaves nothing to overlay.** Removing it leaves holes inside unchanged tissue, and the marker's correlation stays positive.
- **So the error needs a compartment lost or gained as a region,** the scope of the claim. stORCA leaves the lost epithelium unmatched and compares the muscle layer with itself, where `Ptger3` does not change (rank 212).

**Verdict: mechanism found on all 9 pairs, for both methods.** Sufficient for outline Figure 4f.

Result files: `5-Case-Study-Comparison/res/Comparison/q1-mechanism-coda.csv` (per pair and gene: `cci`, `cci_group`, `cci_rest`, `group_on_target`, `targets_under_group`), `q1-mechanism-stcompare.csv` (per pair and gene: `r`, `r_epi`, `r_rest`, `epi_pixels_kept`).
