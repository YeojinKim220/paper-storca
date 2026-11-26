# Q3 beyond DE: which stORCA calls neither pseudobulk DE nor DESpace2 detects, in ARTISTA and in NRDR V1, and what the examples look like

This note explains the notebook [13-q3-beyond-de.ipynb](13-q3-beyond-de.ipynb) section by section. It follows one line: (1) in ARTISTA, how stORCA's calls overlap with DESpace2 and with pseudobulk DE; (2) the ARTISTA calls that neither detects, and why they give no example; (3) the same overlap in NRDR V1, with cortical layers as domains; (4) two NRDR genes whose change is visible on the maps, with one sampled matching; (5) a 4 vs 4 test with the anterior sections added, and why the examples are not layer DE at 2 vs 2; (6) the layer markers among the 4 vs 4 calls and the moved L2/3 to L4 boundary; (7) what can be claimed.

The line supports the outline row "DSE finds genes that DE cannot" (section 9 of [0-paper-outline-natcomm.md](../0-Paper-Draft/0-paper-outline-natcomm.md)) and the panels Figure 5f and Figure 6e. The notebook was rewritten on 2026-11-16:
- The bar chart of DE classes became a Venn diagram of stORCA, DESpace2 and pseudobulk DE.
- The ARTISTA example genes were dropped, because their maps show no difference between the groups that is visible by eye.
- The "matched" panel now shows one sampled hard matching instead of the average over matchings.
- The STARmap PLUS AD section was removed, because it did not support the claim (1 call, more calls on false labels, and a profile computed without stORCA output).
- NRDR V1 with layer domains is the new example dataset.

The outline also asks for the split by type (pattern calls against amplitude calls). The notebook still does not make it; see the Defend table.

All figures are copied unchanged from the notebook (PDF in `5-Case-Study-Comparison/fig/`, PNG copies in `5-Case-Study-Comparison/fig/13-q3-beyond-de/`). Paths are relative to the project root unless they are links.

**Data.**

- ARTISTA (axolotl brain regeneration, Stereo-seq): 2 DPI, 3 sections, against 20 DPI, 3 sections. 3000 panel genes, 782 tested by stORCA v3, 115 calls. Domains: injured or uninjured hemisphere by dorsal or ventral (`compartment`), the annotation DESpace2 uses.
- NRDR V1 posterior (mouse visual cortex MERFISH, Xie, Jain, Xu et al. 2025, PNAS): normal-reared (NR) animals a and b against dark-reared (DR) animals a and b, P28. 500 genes, 377 tested, 32 calls. Domains: cortical layers, built for this comparison (section 3).

**Methods compared.**

1. stORCA call: one-sided unweighted limma on pair ROS, BH $<0.05$, as in [12-q2-replicate-calibration.md](12-q2-replicate-calibration.md).
2. Pseudobulk DE (`02-compare-methods.py`, function `pseudobulk_de`): limma on $\log_2(\mathrm{CPM}+1)$ of summed counts, one pseudobulk per section (global) or per section and domain (at least 20 cells). A gene is pseudobulk DE when it is global DE or DE in at least one domain, BH $<0.05$.
3. DESpace2: native FDR $<0.05$. DESpace2 tests whether the condition changes the expression differently between domains (an interaction of condition and domain on pseudobulk counts). A change that is the same in every domain is not what it tests for.

All three are compared on the genes stORCA tested, so that every method is judged on the same genes.

## 0. Summary

| Step | Finding |
|---|---|
| 1. ARTISTA overlap | Of 115 stORCA calls, DESpace2 calls 25 and misses 90. Of the 90, 62 are pseudobulk DE (mostly uniform changes, outside what DESpace2 tests) and 28 are detected by neither. DESpace2 calls 29 genes stORCA does not (7 ribosomal) |
| 2. ARTISTA examples | The 28 are sparse and their maps show no difference visible by eye. ARTISTA supports the count, not an example |
| 3. NRDR overlap | stORCA 32 calls; DESpace2 on layer domains 0 calls; 13 of the 32 are global or layer pseudobulk DE; 19 are detected by neither |
| 4. NRDR examples | `Prkca`: the high L2/3 and L4 expression of NR falls to the L5 level in DR, so the depth gradient flattens. `Trpc3`: the L4 band of NR fades in DR. Both are seen in both animals of each group, and in one sampled matching the residual sits on the L2/3 to L4 band. Neither gene is pseudobulk DE (smallest layer FDR 0.10 and 0.11), and DESpace2 FDR is 1.00. Both are near misses of layer DE: in L4 both NR sections lie above both DR sections (log2 fold change about -0.9, p 0.006 and 0.008), but BH over 2000 layer tests needs p < 0.0019 |
| 5. NRDR 4 vs 4 | With the anterior sections and a same-animal covariate: 82 calls, largest false-labeling count 1 of 17, 23 of the 32 posterior calls kept (the losses are weak one-animal calls). Pseudobulk at 4 vs 4 finds most posterior examples (15 of 19), including `Prkca` and `Trpc3`. Replication, not a new main result |
| 6. L2/3 to L4 boundary | 21 corrected 4 vs 4 calls stay non-DE, mostly layer markers. In DR the L2/3 to L4 boundary lies deeper (normalised L4 width 0.26 against 0.32, L5 unchanged), and 14% to 16% of the neurons in the L4 band carry the L2/3 label against 5% to 7% in NR (no overlap). A change of laminar organisation that domain labels absorb; a candidate, not yet claimed |
| 7. Status | Sufficient. The claim is worded as measured: "not detected by pseudobulk DE or DESpace2 at the same replicate design". The examples show that stORCA needs fewer replicates, not that a layer test cannot see them |

## 1. ARTISTA: overlap of stORCA, DESpace2 and pseudobulk DE (notebook section 1)

**Question.** Which stORCA calls does DESpace2 miss, and are those simply DE genes?

**In plain words.** DESpace2 asks: "does the condition change this gene more in one domain than in another?" Pseudobulk DE asks: "does the total of this gene change, in the whole section or in one domain?" stORCA asks: "does the spatial pattern of this gene change, beyond the differences between replicates?" A Venn diagram of the three call sets shows which stORCA calls are new and which are already found by a simpler test.

**Implementation** (notebook section 1, from `res/Comparison/artista-gene-table.csv`, columns `storca_call`, `despace2_fdr`, `de_global`, `de_domain`). Universe: the 782 genes stORCA tested. 5 of the 59 DESpace2 calls fall outside it and are not drawn.

![ARTISTA Venn diagram](fig/13-q3-beyond-de/q3-artista-venn.png)

*Red: stORCA calls. Blue: DESpace2 calls. Grey: pseudobulk DE (global or domain). The outlined red region holds the stORCA calls that neither other test detects. Takeaway: 28 calls are new to both. Source: [13-q3-beyond-de.ipynb](13-q3-beyond-de.ipynb) section 1.*

**Result.**

| Region | Genes |
|---|---|
| stORCA only | 28 |
| stORCA and pseudobulk DE, not DESpace2 | 62 |
| stORCA and DESpace2, not pseudobulk DE | 2 |
| All three | 23 |
| DESpace2 and pseudobulk DE, not stORCA | 24 |
| DESpace2 only | 5 |
| Pseudobulk DE only | 165 |

**Reading.**

- **DESpace2 misses 90 of the 115 stORCA calls.** Most of them (62) are pseudobulk DE. These are changes of level that DESpace2 does not test for by design, and they are not counted as "beyond DE" here.
- **28 calls are detected by neither.** This is the count the claim rests on in ARTISTA.
- **DESpace2 calls 29 tested genes that stORCA does not** (24 + 5), 7 of them ribosomal. The claim is not that stORCA contains DESpace2. The two answer different questions.

**Verdict: works.** The Venn diagram gives the count directly and does not depend on how "neither" is defined beyond the two tests.

## 2. ARTISTA: the calls that neither detects (notebook section 2)

**Question.** Can one of the 28 genes serve as an example?

**Implementation.** The table lists the 28 genes with stORCA $t$ and BH, mean ROS within and between, the FDR of each baseline, and the between-pair rank of CODA, River and SpaceExpress among 3000 genes.

**Result.** The previous version of this notebook showed five of them (`B2M`, `ARL4D`, `ANXA2`, `VIM`, `GFAP`). Looked at again, and with ten more genes drawn for this report (`TLCD1`, `CTF1`, `ARRDC2` twice, `XBP1`, `RAPGEF6`, `PCDH7`, `PTGR1` and two unnamed loci), they are sparse. The 2 DPI and 20 DPI maps show no difference a reader can see. `B2M` and `ANXA2` also had domain means that visibly differ.

**Verdict: ARTISTA supports the count, not an example.** The examples are taken from NRDR V1, where the change is visible (section 4).

## 3. NRDR V1 posterior: layer domains and the same overlap (notebook section 3)

**Question.** In a tissue with clear domains, does stORCA call genes that a domain test at the same design does not?

**In plain words.** Visual cortex is built in layers, so a domain method has its best case here. If stORCA finds changes that a layer-by-layer test misses, the claim does not depend on a weak domain annotation.

**Implementation** (`5-Case-Study-Comparison/18-nrdr-layer-domains.py`).

1. The prepared sections carry cell classes and neuronal subclasses from the original study, not spatial domains. Each cell gets the layer that is most common among its 30 nearest excitatory neurons, with the subclasses grouped as L2/3; L4; L5 (L5 IT, PT, NP); L6 (L6 CT, IT, L6b).
2. Pseudobulk DE with these layers as domains (`res/Comparison/nrdr-pos-layer-de.csv`).
3. DESpace2 on the four sections with the layers as domains, 2 vs 2 (`5-Case-Study-NRDR-V1/res/DESpace2/despace2-v1-rep1-nrdr-pos-layer-scores.csv`). The DESpace2 template was relaxed from "exactly 3 vs 3" to "the same number, at least 2, per condition" for this run; the 3 vs 3 benchmark runs are unchanged.

![NRDR layer domains](fig/13-q3-beyond-de/q3-nrdr-layer-domains.png)

*One panel per section (legend: `fig/13-q3-beyond-de/q3-nrdr-layer-legend.png`; green L2/3, orange L4, purple L5, pink L6). Takeaway: every section contains all four layers in the right order, so the sections cover the same depth of cortex although they are cut at different angles. Source: [13-q3-beyond-de.ipynb](13-q3-beyond-de.ipynb) section 3.*

| Layer | nr-a | nr-b | dr-a | dr-b |
|---|---|---|---|---|
| L2/3 | 1640 | 3061 | 1546 | 2033 |
| L4 | 1530 | 1821 | 852 | 1009 |
| L5 | 937 | 1438 | 901 | 1192 |
| L6 | 2336 | 2448 | 2364 | 1987 |

![NRDR Venn diagram](fig/13-q3-beyond-de/q3-nrdr-venn.png)

*As in section 1, on the 377 genes stORCA tested. DESpace2 has no calls, so its circle is empty. Source: [13-q3-beyond-de.ipynb](13-q3-beyond-de.ipynb) section 3.*

**Result.**

| Method | Genes tested | Calls (FDR or BH $<0.05$) | Calls among stORCA's 377 genes | Smallest FDR or BH | Nominal $p<0.05$ |
|---|---|---|---|---|---|
| stORCA (replicate limma, one-sided) | 377 | 32 | 32 | 0.020 | 100 |
| DESpace2, layer domains | 500 | 0 | 0 | 0.372 | 34 (25 expected by chance) |
| Pseudobulk DE, global | 500 | 17 | 16 | 0.0007 | 88 |
| Pseudobulk DE, any layer | 500 | 36 | 32 | 0.0001 | not computed |
| Pseudobulk DE, global or layer | 500 | 36 | 32 | | |

| Overlap among the 32 stORCA calls | Genes |
|---|---|
| Also pseudobulk DE (global or layer) | 13 |
| Neither pseudobulk DE nor DESpace2 | 19 |
| DESpace2 nominal $p<0.05$ (not a call) | 6: `Egr4`, `Nr4a2`, `Ptchd4`, `Shisa6`, `Slc24a3`, `Stard8` |

**How DESpace2 came out.** The run completed normally (`despace2-v1-rep1-nrdr-pos-layer-provenance.json`, status complete; DESpace 2.2.2, edgeR quasi-likelihood F test). The design has 16 pseudobulk samples (2 conditions x 2 animals x 4 layers) and 8 coefficients (condition, layer, condition x layer), so 8 residual degrees of freedom. It tested all 500 panel genes, not only stORCA's 377. The smallest FDR is 0.372 (`Stac`, `Cacna1h`, `Rspo1`), and 34 genes reach nominal $p<0.05$, about the 25 expected by chance. So DESpace2 finds no layer-specific change beyond chance at 2 vs 2; restricting the FDR to the 377 genes lowers each FDR by at most a factor 377/500, so the smallest would still be about 0.28. Source: `5-Case-Study-NRDR-V1/res/DESpace2/despace2-v1-rep1-nrdr-pos-layer-native-gene-scores.csv` (columns `PValue`, `FDR`).

With the cell-class domains used before, 22 of the 32 calls were not DE. With layers 19 are not, so 3 calls (`Stard8`, `Scube1`, `Ptchd4`) turn out to be layer DE. Their L2/3 band is lost in DR, and the layer test sees it.

**Verdict: works.** The domain test has its best case here and still misses 19 of 32 calls.

## 4. NRDR V1 examples (notebook section 4)

**Question.** Is there a stORCA call that neither pseudobulk DE nor DESpace2 detects and whose change a reader can see?

**Selection.** Among the 19 genes of section 3, maps of 14 were drawn for this report. `Prkca` and `Trpc3` show the change most clearly and are shown. Each example has three figures:

1. **Maps.** Each cell is coloured by the mean log1p expression of its 30 nearest cells. Single-cell MERFISH counts are sparse, and the smoothing is for display only; the score uses unsmoothed expression.
2. **Layer profile.** Mean log1p expression per layer, one line per section.
3. **One sampled matching** (between pair nr-a against dr-a). The score averages hard matchings sampled from the transport plan. In each one, every retained nr-a cell receives exactly one dr-a cell. The panels show the nr-a expression, the expression of the dr-a cell matched to each nr-a cell in the first sampled matching, and their difference. Grey cells are dropped in this matching (3%).

The previous notebook drew as "matched" the mean over all matchings of the matched target expression. That is close to the plan times $Y$, which smooths the target and is not what one matching looks like. It is replaced by one sampled matching, via the new outputs `y_sample` and `residual_sample` of `storca.interpret.residual_maps`.

**`Prkca`** (stORCA BH 0.039; ROS within 0.07, between 0.27; global $\log_2$ fold change -0.66, FDR 0.17; smallest layer FDR 0.10; DESpace2 FDR 1.00).

![Prkca maps](fig/13-q3-beyond-de/q3-nrdr-prkca-maps.png)

*nr-a, nr-b (NR), dr-a, dr-b (DR), shared colour scale. Takeaway: a bright band in the upper layers of both NR sections, a flat field in both DR sections. Source: [13-q3-beyond-de.ipynb](13-q3-beyond-de.ipynb) section 4.*

![Prkca layer profile](fig/13-q3-beyond-de/q3-nrdr-prkca-layer-profile.png)

*Blue: NR sections. Orange: DR sections. Takeaway: in NR, L2/3 and L4 are at 0.57 to 0.73 and fall toward L6; in DR, L2/3 and L4 drop to 0.38 to 0.53, close to L5. L5 and L6 hardly change. Source: [13-q3-beyond-de.ipynb](13-q3-beyond-de.ipynb) section 4.*

![Prkca one sampled matching](fig/13-q3-beyond-de/q3-nrdr-prkca-sampled-matching.png)

*Left: nr-a expression. Middle: expression of the dr-a cell matched to each nr-a cell in one sampled matching, drawn at the nr-a position. Right: difference; red means higher in NR. Takeaway: the residual is positive along the L2/3 to L4 band and near zero in the deep layers. Source: [13-q3-beyond-de.ipynb](13-q3-beyond-de.ipynb) section 4.*

**`Trpc3`** (stORCA BH 0.038; ROS within 0.12, between 0.27; global $\log_2$ fold change -0.49, FDR 0.40; smallest layer FDR 0.11; DESpace2 FDR 1.00).

![Trpc3 maps](fig/13-q3-beyond-de/q3-nrdr-trpc3-maps.png)

*Takeaway: the narrow middle band (L4) of both NR sections fades in both DR sections. Source: [13-q3-beyond-de.ipynb](13-q3-beyond-de.ipynb) section 4. The layer profile and the sampled matching are in `fig/13-q3-beyond-de/q3-nrdr-trpc3-layer-profile.png` and `-sampled-matching.png`: L4 drops from 0.37 to 0.46 to 0.24 to 0.26, and L2/3 and L6 do not move.*

**What kind of change is this?** It is restricted to one or two layers. The layer means do move, but with 2 animals per group neither the global test nor the layer test reaches FDR 0.05 (near misses; section 5 shows why). DESpace2 calls nothing at this design. stORCA calls both genes on the same four sections, because the change has a spatial form that ROS measures and that replicates do not share.

**Verdict: works.** Both genes show a change that a reader can see in both animals of each group, and no domain-based test detects it at the same design.

Result files: `res/Comparison/nrdr-pos-gene-table.csv`, `res/Comparison/nrdr-pos-layer-de.csv`, `5-Case-Study-NRDR-V1/data/layer/nrdr-pos-<label>-layer.h5ad`, the DESpace2 file above; figures `fig/q3-nrdr-*.pdf`.

## 5. NRDR V1, 4 vs 4: anterior and posterior sections together (notebook section 5, test run)

**Question.** If the anterior sections are added, does the posterior result hold, and does pseudobulk then find the same genes?

**In plain words.** Each NRDR animal has an anterior and a posterior V1 section. Using both doubles the sections but not the animals: the two sections of one animal share the animal's own differences. This run checks whether the 2 vs 2 calls replicate with more data, and whether the "not DE" examples were only a matter of power.

**Implementation.**

1. stORCA on all eight sections (`5-Case-Study-NRDR-V1/03-run-storca-both.py`): 28 pairs (16 between, 12 within), pair covariate `cross_position` (the two sections come from different positions), false labelings stratified by position (17).
2. Refit with a second pair covariate `same_animal` (`5-Case-Study-NRDR-V1/04-refit-both-same-animal.py`, stored pair scores, no new matching). Reason below.
3. Pseudobulk at 4 vs 4 (`27-q3-nrdr-4v4-pseudobulk.py`): design condition + position, global and per layer. This treats the two sections of one animal as independent, so it favours DE.

**Result.**

| Design | Genes tested | Calls | Largest false-labeling calls | 2 vs 2 calls kept | Calls not pseudobulk DE at 4 vs 4 |
|---|---|---|---|---|---|
| 2 vs 2 posterior (main result) | 377 | 32 | 0 (of 2) | 32 of 32 | 4 |
| 4 vs 4, `cross_position` | 375 | 103 | 5 (of 17) | 27 of 32 | 30 |
| 4 vs 4, `cross_position` + `same_animal` | 296 | 82 | 1 (of 17) | 23 of 32 | 21 |

**Why the same-animal covariate.** Four of the twelve within pairs join the two sections of one animal. On cross-position pairs their ROS is lower than that of within pairs of different animals (median over genes 0.194 against 0.239; lower in 81% of genes), and such pairs never occur among the between pairs. They lower the within mean and inflate the condition effect: 103 calls fall to 82 with the covariate. The covariate leaves 296 genes, because genes with a missing pair are dropped (this removes `Axin2` and `Dcbld2`).

**The posterior genes.** `Prkca`, `Trpc3`, `Slc24a3` and `Nptx2` become strong (BH < 0.001); `Kcnk2` stays at 0.042. The weak 2 vs 2 calls that one animal drives drop (`Nrxn1` 0.12, `Sorcs2` 0.15). Pseudobulk at 4 vs 4 calls 124 genes, and 15 of the 19 posterior calls that were not DE at 2 vs 2 become DE or layer DE, among them `Prkca`, `Trpc3` and `Slc24a3` ([28-q3-nrdr-finer-than-layer.ipynb](28-q3-nrdr-finer-than-layer.ipynb) section 2).

**Why `Prkca` and `Trpc3` are not layer DE at 2 vs 2** ([28-q3-nrdr-finer-than-layer.ipynb](28-q3-nrdr-finer-than-layer.ipynb) section 4).

![Prkca depth and layers](fig/28-q3-nrdr-finer-than-layer/q3-nrdr-prkca-depth-layer-box.png)

*Left: mean log1p count per cell along cortical depth (bins of 0.125 layer), one line per section with one standard error; blue NR a, b, red DR a, b. Middle: kNN-30 smoothed expression of the cells of each layer (diamond: mean). Right: what the layer test sees, one pseudobulk log2 CPM per section and layer, with the layer FDR. Takeaway: in L2/3 and L4 both NR sections lie above both DR sections. Source: [28-q3-nrdr-finer-than-layer.ipynb](28-q3-nrdr-finer-than-layer.ipynb) section 4.*

![Trpc3 depth and layers](fig/28-q3-nrdr-finer-than-layer/q3-nrdr-trpc3-depth-layer-box.png)

*Same layout. Takeaway: the NR peak sits in L4 and the top of L5; in L4 both NR sections lie above both DR sections. Source: as above.*

| Gene | Layer | log2 fold change (DR vs NR) | p | FDR |
|---|---|---|---|---|
| `Prkca` | L2/3 | -0.86 | 0.014 | 0.16 |
| `Prkca` | L4 | -0.92 | 0.006 | 0.10 |
| `Trpc3` | L4 | -0.93 | 0.008 | 0.11 |

The layer test separates the groups in L4, but it has two sections per group (2 residual degrees of freedom) and BH runs over 2000 tests (500 genes x 4 layers), so passing needs p < 0.0019. The global test dilutes a one- or two-layer change over the whole section (FDR 0.17 and 0.40). These examples are therefore near misses of layer DE for lack of power, not changes that a layer summary cannot see. Depth bins add only modestly: the largest change at bin resolution is 1.16 to 1.33 times the change of its layer (median over the 30 genes 1.15).

**Verdict: works as a replication, changes the reading of the examples.** The 4 vs 4 run replicates the posterior calls (23 of 32, the losses are the weak one-animal calls) and keeps the false labelings near zero. It also shows that the posterior examples are found by layer pseudobulk once more sections are added. The 2 vs 2 posterior run stays the main result, because 4 vs 4 adds sections, not animals.

Result files: `5-Case-Study-NRDR-V1/res/stORCA/storca-v3-rep1-nrdr-both-limma-{genes,splits}{,-animal}.csv`, `res/Comparison/q3-nrdr-4v4-pseudobulk.csv`.

## 6. Layer markers in the 4 vs 4 calls: the L2/3 to L4 boundary moves (notebook section 6)

**Question.** 21 corrected 4 vs 4 calls are not pseudobulk DE even at 4 vs 4, and most are layer markers (`Cux1`, `Scnn1a`, `Otof`, `Whrn`, `Tle4`, `Pou3f2`, `Syt2`, `Nefm`, `Kirrel3`, `Cntn5`). Every DR section also has a smaller share of L4 neurons. Is L4 thinner, are L4 neurons labelled as L2/3, or is it the angle of the cut?

**In plain words.** If the layer boundaries themselves move, the total amount of a layer marker can stay the same while its band shifts or narrows. A test on layer domains takes the layer labels as given, so it absorbs exactly this change.

**Implementation** (`29-q3-nrdr-l4-thickness.py`). Per section, the depth axis is the direction in which the layer index of excitatory neurons rises (L2/3 = 1 to L6 = 4). The tangential axis is cut into 250 um strips; in each strip each layer boundary is the depth that best separates neurons above and below it, and the pial edge is the 1st percentile of all cells. Widths are divided by the distance from the pial edge to the bottom of L5, so an oblique cut, which stretches all layers alike, cancels. Inside the L4 band the share of excitatory neurons with each label is counted. Strip medians per section.

| Section | L4 share of neurons | L2/3 width | L4 width | L5 width | L4 band: L4 labels | L4 band: L2/3 labels |
|---|---|---|---|---|---|---|
| pos nr-a | 0.29 | 0.43 | 0.32 | 0.26 | 0.90 | 0.07 |
| pos nr-b | 0.25 | 0.47 | 0.27 | 0.27 | 0.92 | 0.05 |
| ant nr-a | 0.29 | 0.41 | 0.35 | 0.29 | 0.92 | 0.05 |
| ant nr-b | 0.29 | 0.44 | 0.33 | 0.22 | 0.88 | 0.06 |
| pos dr-a | 0.17 | 0.48 | 0.29 | 0.25 | 0.82 | 0.14 |
| pos dr-b | 0.19 | 0.51 | 0.26 | 0.24 | 0.81 | 0.14 |
| ant dr-a | 0.21 | 0.50 | 0.24 | 0.24 | 0.79 | 0.16 |
| ant dr-b | 0.18 | 0.50 | 0.26 | 0.24 | 0.80 | 0.16 |

![L4 boundary](fig/13-q3-beyond-de/q3-nrdr-l4-thickness.png)

*Neurons per layer label along normalised depth (0 = pial edge, 1 = bottom of L5), one panel per section; purple L2/3, blue L4, green L5, yellow L6; dashed lines: the L4 band (strip medians). Takeaway: in DR the L2/3 distribution reaches deep into the L4 band, and the L4 peak is lower. Source: [13-q3-beyond-de.ipynb](13-q3-beyond-de.ipynb) section 6.*

**Result.**

1. Not the cut: L5 width is unchanged (0.24 against 0.26), while L4 narrows (0.26 against 0.32) by the amount L2/3 widens (0.50 against 0.44). Only the L2/3 to L4 boundary moves.
2. The cleanest signal is the mixing: inside the L4 band 14% to 16% of excitatory neurons carry the L2/3 label in all four DR sections, against 5% to 7% in all four NR sections. The two ranges do not overlap.
3. Thinner L4 or changed identity cannot be told apart, because the boundary is defined from the same transcriptomic labels. The mixing pattern (L2/3-type neurons at L4 depth) fits a change of identity better. Either way it is a change of laminar organisation caused by the condition, with the total expression of the markers unchanged.

**Verdict: candidate, not yet in the claim.** This is the kind of change that a domain test cannot see, because the domain labels move with it. It rests on two animals per group and on the 4 vs 4 run, and the posterior 2 vs 2 calls do not contain these markers. It needs the decision in section 7.

Result files: `res/Comparison/q3-nrdr-l4-thickness.csv`, `res/Comparison/q3-nrdr-l4-thickness-strips.csv`; figure `fig/q3-nrdr-l4-thickness.pdf` (legend `fig/q3-nrdr-l4-thickness-legend.pdf`).

## 7. Where this leaves Q3

| Claim | Supported? | Basis |
|---|---|---|
| stORCA calls genes that DESpace2 misses | Yes: 90 of 115 in ARTISTA, 32 of 32 in NRDR | 1, 3 |
| Some of them are not pseudobulk DE either | Yes: 28 of 115 (ARTISTA), 19 of 32 (NRDR, layer domains) | 1, 3 |
| A named gene shows such a change on the maps | Yes: `Prkca`, `Trpc3` (NRDR) | 4 |
| The calls replicate when more sections are added | Yes: 23 of 32 kept at 4 vs 4 with a same-animal covariate; losses are weak one-animal calls | 5 |
| The examples are invisible to a layer test | No. They are near misses of layer DE at 2 vs 2 and become layer DE at 4 vs 4. The claim is the sample size, not the blind spot | 5 |
| stORCA finds a change that domain labels absorb | Candidate: the L2/3 to L4 boundary moves in DR (layer markers, 4 vs 4). Not claimed yet | 6 |
| The change has equal domain means | Not claimed. The examples are layer-restricted changes that the domain tests do not reach at this design | 4 |
| The split by type (pattern against amplitude) required by the outline | No evidence yet | |

**Status: sufficient.** The rewritten notebook answers the four points raised: the Venn diagram replaces the bar chart, the examples are visible on the maps, the matched panel shows one sampled matching, and the section that did not support the claim (AD) is gone. No item conflicts with the claim as worded. Issues are split by the rule in `CLAUDE.md` ("Level of Rigor: Fix or Defend").

**Fix.** None.

**Defend.**

| A reviewer can say | Answer |
|---|---|
| "Not detected" is not "no difference"; `Prkca` drops by about a third in L2/3 and L4 | The claim is "not detected by pseudobulk DE or DESpace2 at the same replicate design", and the examples are described as layer-restricted changes. All methods see the same four sections, so the comparison is fair |
| The examples are only a question of power: with 4 vs 4 pseudobulk finds them | Agreed, and this is the claim: stORCA calls them with two animals per group, where the layer test needs twice the sections (section 5). DESpace2 misses them even on eight sections |
| The 4 vs 4 run treats two sections of one animal as replicates | It is reported as a replication only. The same-animal covariate removes the inflation (103 to 82 calls), and the main result stays the 2 vs 2 posterior run |
| NRDR has 2 animals per group, so every test is weak | That is the setting in which the comparison is made. stORCA's calibration at this design rests on Q2 (0 calls on the false labelings, LIBD and HPOA as the main nulls) |
| The layer domains were built by us | They come from the subclass labels of the original study by a majority vote of 30 neighbours. All sections show the four layers in the right order. DESpace2 cannot run without domains, and cortical layers are its most favourable case |
| DESpace2 calls nothing, so it is not a fair competitor at 2 vs 2 | It is run with its native settings on the same data. A domain test has few pseudobulk observations at small designs; that is a property of the approach |
| DESpace2 calls 29 genes in ARTISTA that stORCA does not | The claim is not that stORCA contains DESpace2. DESpace2 tests a condition-by-domain interaction of levels; 7 of the 29 are ribosomal |
| The ARTISTA calls that neither test detects have no visible example | Their count rests on the calibrated replicate test (Q2). The visible examples are from NRDR |
| The L4 domain has fewer cells in DR (852 and 1009 against 1530 and 1821), so `Trpc3` may reflect composition | For DSE a change of composition and a change per cell are both a spatial change. The text says "the L4 band fades", not "lower per cell". Section 6 shows where the cells went: the L2/3 to L4 boundary lies deeper in DR, and not because of the angle of the cut |
| The maps are smoothed | For display only; the score uses unsmoothed expression. The layer profile uses raw per-cell values |
| One sampled matching is shown, out of many | It is an illustration of one of the matchings the score averages over; the call comes from the average and from the replicate test, not from this panel |
| The calls are not split by pattern and amplitude type | The split is a join with the Q5 decomposition table and is made when Figure 5f is drawn. The counts do not depend on it |
| Cosmetic: old ARTISTA and AD figure files remain in `fig/` | One line; delete when the figure folder is cleaned |

**Decisions for you.**

1. Whether to link the NRDR examples to the original study in the text. Checked on 2026-11-17 (`0-Data/Mouse-NRDR-2024/pnas.202421022.pdf`): the study reports that in dark-reared V1 the L2/3 type-identity genes keep their sublayer order, L2/3A-specific genes are relatively unchanged, and L2/3B- and L2/3C-specific genes are down-regulated (its Fig. 3G). The loss of the `Prkca` and `Trpc3` band in upper layers in dark-reared sections goes in the same direction. Whether these two genes are type B or C genes needs the study's Dataset S1, which is not on disk. Recommended: one sentence "in line with the reported down-regulation of L2/3B and C genes" once Dataset S1 confirms the two genes; until then no biological sentence.
2. Q5 ([15-q5-interpretation.ipynb](15-q5-interpretation.ipynb)) draws the same averaged "matched" panel. Recommended: switch it to `y_sample` in the same way, a change of one line.
3. Whether to use the moved L2/3 to L4 boundary (section 6) as the "domain labels absorb it" example. It is the strongest example of that kind so far, but it comes from the 4 vs 4 run, rests on two animals per group, and its biology (thinner L4 or changed identity) is open. Recommended: keep it as a supplementary observation and do not build the Q3 claim on it until it is checked against the source study (Dataset S1 or its L4 results).
