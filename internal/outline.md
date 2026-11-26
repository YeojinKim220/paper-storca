# stORCA manuscript plan for Nature Communications

Last updated: 2026-11-20 (fourth revision: status of every figure brought to the frozen v4 pipeline and to the results finished on 2026-11-19, the synthetic v2 scenarios with an animal effect and the LIBD implant benchmark; triage in section 15). Afternoon addition on 2026-11-20: competitor metrics of synthetic v2 for 6 of 11 scenarios, all competitors and the decoys on the LIBD implants, the HPOA pattern swap, runtime and memory, and the cause of the 6 vs 6 false labelings (marked "2026-11-20 pm"). Evening addition on 2026-11-20: claim 5 (one scale, Figure 6) is on hold, so the paper carries four claims. Earlier: 2026-11-18 (one question, real against apparent change; sections 1, 5 and 6 rewritten). Status: proposal for discussion. Sections 3, 4 and 7 to 12 still follow the 2026-11-10 framing in places and will be aligned once the Results sections are agreed.

Working title (proposal): **stORCA separates real from apparent changes in spatial gene expression across replicate tissue sections**

Inputs read for this plan: the method draft [0-method-v2.md](0-method-v2.md), the result drafts `1-` to `4-result-*.md` in this folder, the colitis reports ([REPORT-paper-comparison.md](REPORT-paper-comparison.md), [REPORT-colitis-expanded.md](REPORT-colitis-expanded.md)), the embryo report ([embryo-dse/REPORT-embryo-dse.md](embryo-dse/REPORT-embryo-dse.md)), and the current-pipeline review in [29-framework-review-reviewer-defense.md](../5-Case-Study-Colitis/29-framework-review-reviewer-defense.md) and [pvalue-design-history.md](../5-Case-Study-Colitis/pvalue-design-history.md). Result folders of the newer case studies (aging, axolotl, DLPFC, HPOA) were not inspected, so their status is marked as unknown below.

## 1. Main claims

Revised on 2026-11-18. The paper asks one question: **when two conditions are compared, is a change in spatial gene expression a condition effect, or does it only look like one?**

**Umbrella claim.** stORCA detects condition-driven changes in spatial gene expression and separates them from two look-alikes that existing methods report as changes: the variation between replicate sections, and tissue that has no counterpart in the other condition. Each change it reports is typed by what changed (pattern or amplitude) and where.

| # | Claim | One-line content | Figure | Evidence now |
|---|---|---|---|---|
| 1 | The score sees every kind of change | ROS (one minus a spatial concordance) responds to pattern change and to amplitude change and ignores a global shift. Registration scores (CODA, STcompare) miss amplitude change and the domain test (DESpace2) misses amplitude change and shifts inside a domain; stORCA ranks every designed type (AUROC 0.85 to 1.00 on LIBD implants) | 2 | Not yet: v4 ranks well on LIBD implants and on 4 of 6 synthetic types, but the gene rule removes genes that have no structure in one condition (boundary band, cell-type DE in a domain; section 15, Fix 1). Wording changed on 2026-11-20: River also has no blind spot on LIBD implants, so "the only method" is dropped |
| 2 | Look-alike 1: replicate variation | Single-pair methods call 34 to 94% of genes on two replicate sections. The replicate design (between pairs minus within pairs) with ROS makes no call without a condition (LIBD 0 of 662; LIBD implants: no false call at any level or replicate number) and calls where the condition effect exceeds replicate variation (HPOA 11, NRDR 32 and 11, ARTISTA 113). The same design on competitor scores gives 0 to 3 calls, except River in ARTISTA | 3 | Q2 (v4), five datasets with calls plus LIBD; sufficient after fixes. Power at 3 vs 3 is modest (section 15, Defend) |
| 3 | Look-alike 2: tissue without a counterpart | The partial plan leaves cells without a counterpart unmatched (AUROC 0.89 and 0.94). With the replicate baseline thinned on both sides, 0.20 and 0.35 of stORCA's top 20 are markers of that tissue (base 0.11 and 0.28), against 0.50 to 0.70 for CODA, STcompare and DESpace2 | 4 | Q1 section 7 (v4); sufficient for tissue lost or gained as a region. Synthetic control: stORCA side done (probes ranked low), competitor side not collected |
| 4 | What changed and where, beyond DE | Each call is typed as pattern, amplitude or mixed and shown on the tissue. Part of the calls are detected by neither pseudobulk DE test at the same design (31 of 113 in ARTISTA, 22 of 32 in NRDR; v4 tables) | 5 | Q3, Q5 (v4 notebooks rerun 2026-11-19; reports still quote v3 numbers); sufficient |
| 5 | On hold: one scale across comparisons | $\Delta$ is an effect size that can be compared between comparisons; in a regeneration time course it is largest at 10 to 15 DPI | 6 | **On hold** (decision of 2026-11-20): not counted among the main claims for now; Figure 6 and Q4 are kept as they are. Before the hold: Q4 (v4), sufficient after fixes; the synthetic scale check does not hold for every type (section 15, Fix 4) |

Claims 1 to 4 are the main claims: the score finds many kinds of spatial change, it separates them from replicate variation, it is not misled by tissue without a counterpart, and it says what changed and where beyond DE. Claim 5 is on hold (2026-11-20); its row is kept with its evidence, and section 15 does not count it in the overall status.

**Roles of the three strengths.**

| Strength | Role | Why |
|---|---|---|
| Replicate design | Backbone (Fig 3) | Broadest evidence (six datasets, three technologies) and the hardest to attack: a within pair is replicate variation by construction |
| Cells without a counterpart | Distinctive feature (Fig 4) | Registration (CODA, STcompare) assumes one counterpart for every location, and domain tests (DESpace2) compare domain levels that move when a compartment is lost. A partial plan does not make that assumption |
| Amplitude (ROS) | Instrument (Fig 2, 5, 6) | Not a headline. It is the property that lets the replicate design give calls (Q2 section 2c), catches amplitude changes that correlation misses, and gives each call its type |

"No registration needed" and "works across platforms" are consequences and evidence, not headline claims.

**Why "uncertainty" left the headline.**

- The paper's own Figure 3 shows that the matching variance inside one pair is 26 to 155 times smaller than the replicate variance (Q2 section 3). A title with "uncertainty-aware" invites "which uncertainty, how large, is it calibrated?", and for matching the answer is "small".
- The open issue of section 14 is settled for meaning 2 (whether a cell has a counterpart). The paper calls it "cells without a counterpart". Sampled matchings stay in Methods as the way the score is computed, not as a claim.
- The two look-alikes say what the word was meant to say, and a reader can picture them.

## 2. The score: ROS as spatial concordance

Write $Q(v)=\tilde v^\top W \tilde v$ for the centered quadratic form on the source graph, and $Q(x,y)=\tilde x^\top \bar W \tilde y$. Then

$$
\mathrm{ROS}=\frac{Q(x-y)}{Q(x)+Q(y)}=1-\frac{2\,Q(x,y)}{Q(x)+Q(y)} .
$$

Lin's concordance correlation coefficient, after removing the mean difference, is $2s_{xy}/(s_x^2+s_y^2)$. So $1-\mathrm{ROS}$ is that coefficient with covariances replaced by spatially weighted covariances. The classical factorization of the concordance coefficient into a correlation term and a scale term carries over:

$$
1-\mathrm{ROS}=\rho_W\cdot C(\kappa),\qquad
\rho_W=\frac{Q(x,y)}{\sqrt{Q(x)\,Q(y)}},\qquad
C(\kappa)=\frac{2}{\kappa+1/\kappa},\quad \kappa=\sqrt{Q(x)/Q(y)} .
$$

$\rho_W$ measures agreement of pattern shape, $C(\kappa)$ agreement of pattern amplitude. A pure amplitude change $y=a\,x$ gives $\rho_W=1$ and $\mathrm{ROS}=(1-a)^2/(1+a^2)$, as in the method draft.

| Statistic | Analogue | Question it answers | Limitation |
|---|---|---|---|
| Spatial cross-correlation (CODA, STcompare) | Pearson correlation | Do the patterns have the same shape? | A pattern that fades to half strength still scores 1 |
| Moran's I of the difference | A test of existence | Is the difference spatially organized? | In real sections the answer is always yes (92 to 96% of genes on replicates); not an effect size |
| ROS | One minus concordance | How much of the spatial structure is not shared? | Decomposition is reported only where $Q(x),Q(y)>0$ |

Three consequences used in the paper:

1. **Positioning against CODA and STcompare** is a property of the statistic, not a matter of taste.
2. **The decomposition is free**: every call comes with a pattern component and an amplitude component (claim 4).
3. **The replicate design follows from the statistic.** The concordance coefficient was introduced to measure agreement between repeated measurements. Within-condition pairs give the baseline disagreement between replicates, between-condition pairs give the disagreement across conditions, and $\Delta$ is the excess. This is why a linear model on pair scores is the natural inference.

To verify before writing: that the ρκ decomposition already used in the colitis notebooks is this one; that "spatial concordance" has not been used for the same statistic elsewhere (bivariate Moran and Lee's L are related and must be cited).

## 3. Competitive landscape

| Method | Venue | Needs | Statistic | Matching uncertainty | Replicate calibration | Type of change |
|---|---|---|---|---|---|---|
| River | Nat Commun 2025 | Comparable slices, condition labels | Attribution scores of a deep model | No | No, ranking only | No |
| CODA | Nat Commun 2026 | Rigid plus LDDMM registration | Spatial cross-correlation after alignment | No, one deformation | No, ranking only | No, blind to amplitude |
| STcompare | bioRxiv 2025 | Structurally matched tissues, STalign, rasterization | Pixel correlation, fold-change similarity | No, one deformation | No, single pair | Partly, two separate tests |
| DESpace2 | Bioinformatics 2026 | Spatial domains shared across samples | edgeR interaction | Domains taken as given | Yes | No |
| SpaceExpress | bioRxiv 2024 (our lab) | Learned intrinsic coordinates | Spline interaction | Coordinates taken as given | Yes | No |
| stORCA | this work | Raw counts and native coordinates | ROS (spatial concordance) | Yes, sampled matchings from a soft, partial plan | Yes | Yes, pattern and amplitude |

Notes:

- Registration by a diffeomorphism assumes that every location has exactly one counterpart. Tissue that appears or disappears (an ulcer, an injury site, a new cell population) violates that assumption. This is the concrete contrast for claim 1, and the day 9 severe colitis result, where a new cell type receives no match, is its illustration.
- Reviewers will very likely include authors of River, CODA, STcompare or DESpace. Each must be run in the same settings with recommended parameters.
- SpaceExpress is from our own lab and must be included as a baseline, with the relation stated: it needs a learnable shared coordinate system, stORCA targets tissues where that fails.

## 4. What comparable Nature Communications papers did

Read for this section: SLAT (full text via PMC), CODA (bioRxiv full text of the published paper), STcompare (bioRxiv full text), River (abstract only, the article page was not accessible), Squair et al. 2021 (abstract level). Stereopy and scNiche (both Nat Commun 2025) surfaced in the search but were not read.

| Paper | Group | Main figures | Shape of the argument |
|---|---|---|---|
| SLAT, Nat Commun 2023 | Gao lab, Peking University | 4 | Architecture; benchmark on 3 technologies with accuracy and runtime; heterogeneous alignment across technologies and modalities; one developmental case |
| River, Nat Commun 2025 | Two authors, Fudan | not verified | Simulation, then four unrelated biological contexts (embryo, diabetic testis, lupus spleen, breast cancer with survival association) |
| CODA, Nat Commun 2026 | Fudan, with Q. Nie as a senior co-author | 6 | Pipeline; global alignment benchmark; local alignment across 5 settings; one disease case (artery); common-domain extraction; generalization across 4 more tissues. 14 datasets in total, no significance test for its gene scores |
| STcompare, bioRxiv 2025 | Fan lab, JHU | 2 | Simulation with false-positive control under autocorrelation; replicate sanity check; one kidney injury case |
| Squair et al., Nat Commun 2021 | Courtine lab (large group) | not verified | Shows that single-cell DE without replicate modelling produces hundreds of false discoveries; pseudobulk fixes it |

Patterns worth copying:

1. **Breadth is the currency for methods from smaller groups.** At least three technologies and four or more tissues. We have MERFISH, Xenium, Stereo-seq and Visium data already.
2. **Lean main text.** Four to six main figures, each one claim.
3. **One disease case anchored to a published study of the same data**, agreement first and then what is new.
4. **Runtime and memory panel** in every one of them.
5. **A calibration argument travels well.** Squair et al. is the precedent for "the default test has no replicate baseline and therefore inflates". Our replicate result is the spatial-pattern analogue and is unpublished.

What none of them did: error control verified on real replicates, propagation of alignment uncertainty, a typed interpretation of each call, and stage-by-stage ablations.

## 5. Title and abstract

**How the muscat title works.** "muscat detects subpopulation-specific state transitions from multi-sample multi-condition single-cell transcriptomics data" (Crowell et al., Nat Commun 2020) has four parts: the tool, a plain verb, a specific new object ("subpopulation-specific state transitions", a biological thing, not a statistic), and the data setting the field had ignored ("multi-sample multi-condition"). The candidates below keep that shape and put the paper's question into the object.

| # | Title | Words | What each part maps to | Risk |
|---|---|---|---|---|
| 1 (recommended) | **stORCA separates real from apparent changes in spatial gene expression across replicate tissue sections** | 14 | "apparent" = the two look-alikes, Fig 3 and 4; "real" = calls that are typed and located, Fig 2, 5, 6; "replicate tissue sections" = the design, as "multi-sample" in muscat | "Real by what standard?" The abstract answers it in its second and third sentences: beyond replicate variation, and not tissue without a counterpart |
| 2 | stORCA detects condition-driven pattern and amplitude changes in spatial gene expression from multi-sample tissue sections | 15 | Closest to muscat; names all three strengths | "Pattern and amplitude" is jargon on first reading; Fig 4 is not in it |
| 3 | stORCA detects spatial expression patterns that shift, strengthen or fade between conditions beyond replicate variation | 15 | Most vivid: shift = pattern change, strengthen or fade = amplitude change | Fig 4 is not in it |
| 4 | Most spatial expression changes reported between conditions are replicate variation or tissue without a counterpart | 15 | Problem first, as Squair et al. 2021 | Not recommended: Q2 section 1 holds for every method only in HPOA, so "most" is not shown |

Earlier titles, kept for the record: "Uncertainty-aware detection of differential spatial expression across conditions" (2026-11-10; dropped for the reasons in section 1), and "stORCA separates condition-driven spatial expression changes from replicate variation and cells without counterparts" (2026-11-18 draft; accurate but flat).

**Axis that classifies prior work** (introduction paragraph 2): existing methods take two things as given. Every location in one tissue has a counterpart in the other (registration, shared domains), and one pair of sections shows the condition effect (single-pair tests and rankings). Each assumption turns a look-alike into a call.

**Missing capability** (introduction paragraph 3): existing methods can rank genes whose spatial pattern differs between two aligned sections, but cannot tell whether the difference exceeds the difference between replicate sections or comes from tissue that has no counterpart.

Abstract skeleton (150 words in the journal format):

1. Need: disease, injury and development change where genes are expressed in a tissue and how strongly their spatial pattern stands out, and comparisons of spatial transcriptomes between conditions are meant to find these changes.
2. Limitation: two look-alikes are reported as changes. Replicate sections of one condition already differ, and tissue that is lost or gained has no counterpart. Existing methods compare one pair of sections and assume that every location has a counterpart.
3. Here we present stORCA, which measures how much of a gene's spatial structure two sections do not share, leaves cells without a counterpart out of the comparison, and tests the excess of between-condition pairs over replicate pairs.
4. Evidence: on designed changes implanted into real replicate sections it ranks every type, where registration scores miss amplitude changes and domain tests miss amplitude changes and shifts inside a domain; across six datasets single-pair methods call 34 to 94% of genes on replicate sections, whereas stORCA makes no call without a condition (0 of 662); in colitis and cortical injury 50 to 70% of the registration and domain methods' top genes mark tissue without a counterpart, against 20 to 35% for stORCA (base 11 to 28%); each call is typed and located, and some are detected by neither DE test; on one scale it follows a regeneration time course.
5. Significance: comparisons of spatial transcriptomes that report only changes beyond replicate variation and tissue loss, with what changed and where.

The designed-change statement in step 4 holds for the LIBD implants (section 6, Figure 2f); the synthetic half waits for Fix 1 of section 15.

## 6. Results flow and figures

Revised on 2026-11-18. One Results section per figure and one claim per figure. Synthetic, semi-synthetic and real data go into the figure whose claim they test (as in Squair et al. 2021), not into a separate benchmark figure, and so do the ablations.

**Status words** used in every table below.

| Status | Meaning |
|---|---|
| **Done** | Current pipeline (v4, frozen 2026-11-18), in a Q report whose status is sufficient |
| **Done, fix** | Result exists; a listed fix remains |
| **Rerun** | Result exists with the old pipeline (NRMI, single pair, September 2026). The design is reusable, the numbers are not |
| **To run** | No result yet |
| **To draw** | Schematic, or a plot to make from saved results |

**Pipeline frozen (done 2026-11-18, v4).** The clip of ROS to [0, 2] and the baseline thinning on both sides are in the package (`STORCA_CLIP=nonzero95 STORCA_GATE=gene STORCA_VERSION=v4`; Methods in [0-method-v1.md](0-method-v1.md)). The Q1 to Q5 notebooks were rerun on the v4 tables on 2026-11-19. The change was small: LIBD 0 calls, HPOA 11, NRDR 32 and 11, ARTISTA 115 to 113, colitis D0 vs D3 27 to 29. The Q1, Q2, Q3 and Q5 markdown reports still quote the v3 numbers; the numbers in this outline are read from the v4 tables in `5-Case-Study-Comparison/res/Comparison/`.

### Overview

| Fig = Results section | Claim (figure title) | Synthetic | Semi-synthetic | Real | Status |
|---|---|---|---|---|---|
| 1 | A change in spatial expression between conditions can be real or only look real | Toy genes | | Thumbnails from Fig 3 and 4 | Method panels drawn (2026-11-19); look-alike panels to draw |
| 2 | ROS detects every designed kind of spatial change, where registration and domain methods miss one | Six change types with an animal effect (`3-BM-DSE-Scenario-v2` 02 to 07); score comparison on an ideal mapping (`3-BM-DSE-Scores`) | LIBD DLPFC 3 vs 3 with implanted changes (`1-BM-DSE-Semi-LIBD`, replaces the planned HPOA build) | | Semi-synthetic done (STcompare running); synthetic stORCA done with Fix 1, competitors not collected |
| 3 | Single-pair methods report replicate variation as change; the replicate design with ROS does not | | LIBD implants at 2, 3 and 6 sections per group | LIBD, HPOA, NRDR (two regions), ARTISTA, colitis D0 vs D3 | Real done (v4), fix; semi-synthetic done |
| 4 | Tissue without a counterpart fills the top lists of registration and domain methods, not stORCA's | Rearrangement scenarios with an animal effect (`3-BM-DSE-Scenario-v2` 08 to 12) | | Cortex stab wound, colitis D0 vs D9 | Real done (v4); synthetic stORCA done with Fix 2, competitors not collected |
| 5 | stORCA types each change and finds changes that DE and domain tests do not detect | Typing against ground truth (Fig 2 data) | | ARTISTA, NRDR, HPOA | Real done (v4); typing validation to run |
| 6 | $\Delta$ is one scale across comparisons | $\Delta$ against designed strength (amplitude change only, Fix 4) | | ARTISTA time course | On hold (claim 5). Real done, fix; synthetic done for the amplitude change |

**Datasets by figure** (breadth: three technologies, six tissues).

| Dataset | Technology | Design | Figures |
|---|---|---|---|
| LIBD DLPFC (human) | Visium | 3 vs 3, no condition | 3 (null dataset) |
| HPOA, naive vs aggression | MERFISH | 3 vs 3 animals | 2 (semi-synthetic base), 3, 5 |
| NRDR V1, normal vs dark reared | MERFISH | 2 vs 2 animals | 3, 5 |
| ARTISTA, axolotl brain regeneration | Stereo-seq | 3 vs 3 sections per time point | 3, 5, 6 |
| Colitis D0 vs D3 | MERFISH | 3 vs 4 mice | 3 |
| Colitis D0 vs D9 | MERFISH | 3 vs 3 slices, one mouse per condition | 4 |
| Cortex stab wound | Visium | 2 vs 2 hemispheres | 4 |
| STARmap PLUS AD | STARmap PLUS | 8 vs 13 months | Not used (Q4 section 7) |

### Figure 1 (Results 1): a spatial change can be real or only look real

Results heading: "stORCA separates condition effects from replicate variation and from tissue without a counterpart".

| Panel | Content | Data | Source | Status |
|---|---|---|---|---|
| a | Three toy genes: a global shift (no change of pattern), an amplitude change, a pattern change | Toy | | To draw |
| b | Look-alike 1: two replicate sections of one condition already differ (a hotspot in one section) | Real thumbnail, HPOA `Oxt` | Q2 section 4 | To draw |
| c | Look-alike 2: tissue without a counterpart (the day-0 epithelium that is gone at day 9; the cortical lesion) | Real thumbnail | Q1 section 7a | To draw |
| d | Method: embedding, partial plan, sampled matchings and ROS on the source tissue, replicate design with the baseline thinned by retained mass | Schematic | [01-storca-figure1-nov19.py](01-storca-figure1-nov19.py), legend [01-storca-figure1-nov19.txt](01-storca-figure1-nov19.txt) | Done (v4 draft of 2026-11-19, thinning step included) |
| e | Output per gene: $\Delta$ and call, type on the $\rho$, $\kappa$ plane, residual map | Schematic | same | Done (same draft) |
| f | Capability grid (table of section 3) | | | To draw |

![Figure 1 draft of 2026-11-19](fig/01-storca-figure1-nov19.png)

*v4 draft of the method panels (a to f of the draft map to panels d and e here). Still missing: the toy genes and the two look-alikes (panels a to c). The drawn panel list names an on/off type; it must match the gene rule after Fix 1 of section 15.*

### Figure 2 (Results 2): ROS detects every designed kind of change

Results heading: "A spatial concordance score detects pattern and amplitude changes that correlation and domain tests miss". Claim 1. The figure explains what the number means before any real data is shown.

| Panel | Content | Data | Source | Status |
|---|---|---|---|---|
| a | Six designed change types at strengths 0 to 2: domain DE, cell-type DE within a domain, within-domain shift, boundary band, amplitude change of a spatial pattern (`svg-increase`), ring domain | Synthetic v2: v1 layouts plus an animal effect per section (level offset SD 0.2, hotspots in 10% of genes) | `3-BM-DSE-Scenario-v2/01-data-generation/01-make-v2.py` | Done |
| b | Blind-spot map: AUROC per method and change type, 3 vs 3 | Synthetic v2 | stORCA: `3-BM-DSE-Scenario-v2/13-storca-v4/res/storca-v4-pooled-metrics.csv`; all methods: `res/all-methods-metrics.csv` in the same folder | stORCA done, Fix 1 (two types untested). Competitors done for all 11 scenarios (2026-11-20 pm; 22 tasks first lost to the submit limit were rerun) |
| c | Null at strength 0: share of genes called at FDR 0.05 | Synthetic v2 | same | stORCA 0.00 in 02 to 06, 0.009 in 07. DESpace2 0.00 in 02 and 06 but 0.145 in the ring scenario; SpaceExpress 0.28 to 0.40 |
| d | Score ablation on an ideal mapping: ROS against cross-correlation (the CODA and STcompare statistic), Moran's I of the difference, SpatialDE, SCI, Pearson | Synthetic | `3-BM-DSE-Scores` (NRMI: 10 of 10 and 9 of 10 designed genes in the top 20) | Rerun with ROS; add cross-correlation |
| e | Decomposition on designed genes: pattern-change and amplitude-change genes fall into their own region of the $\rho_W$, $C(\kappa)$ plane | Synthetic | from the rerun of b | To run (the open ground-truth item of Q5) |
| f | Real tissue, real donor variation: LIBD DLPFC 3 vs 3 donors with 40 implanted genes (domain DE, shift within Layer 3, amplitude, relocation; 10 each) at three levels; detection per type. v2 adds 10 pure shifts and 20 global-shift decoys | Semi-synthetic | `1-BM-DSE-Semi-LIBD/res/evaluation-*.csv` | Done for all six methods at three levels, decoys included (2026-11-20 pm) |
| f2 | Pattern swap in real animals: HPOA 3 vs 3 with 9 pseudo-genes whose pattern changes and whose mean does not | Semi-synthetic | `1-BM-DSE-Semi/10-semi-v3-hpoa-swap.py`; gene table `5-Case-Study-Comparison/res/Comparison/hposwap-gene-table.csv` | Done (2026-11-20 pm); candidate for the Supplementary |
| g | Runtime and memory against cell number | Colitis 2 vs 2 (6 pairs), downsampled | `8-BM-Runtime/res/runtime-rt*.csv` | Done (2026-11-20 pm): 5.9, 11.0, 18.5 and 40.4 min for 2,500, 5,000, 10,000 and 20,000 cells per section on one GPU; peak 4.5 GB RAM and 4.7 GB GPU memory at 20,000 |

Old-pipeline AUROC at strength 1, a preview of panel b (the numbers will change):

| Change type | CODA | STcompare | DESpace2 | SpaceExpress | River | stORCA (old) |
|---|---|---|---|---|---|---|
| Domain DE | 1.00 | 1.00 | 1.00 | 1.00 | 0.98 | 1.00 |
| Cell-type DE within a domain | 1.00 | 1.00 | 1.00 | 1.00 | 0.94 | 0.99 |
| Within-domain shift | 1.00 | 1.00 | 0.48 | 0.54 | 0.62 | 1.00 |
| Amplitude change (`svg-increase`) | 0.39 | 0.13 | 1.00 | 0.91 | 0.93 | 1.00 |
| Boundary band | 1.00 | 1.00 | 0.90 | 0.67 | 0.19 | 0.71 |
| Ring domain | 1.00 | 1.00 | 1.00 | 0.89 | 0.77 | 1.00 |

Reading: every competitor has one change type near or below chance (CODA and STcompare the amplitude change, DESpace2 and SpaceExpress the within-domain shift, River the boundary band); stORCA's lowest is 0.71 (boundary band). "The only method with no change type near chance" holds on these numbers, and the figure title must follow the rerun. At strength 0 the old stORCA and DESpace2 call 0 genes at FDR 0.05, SpaceExpress 0.16 to 0.33 of genes.

**Results finished on 2026-11-19.**

*LIBD implants (panel f).* stORCA v4 ranks every implant type at every level (AUROC 0.85 to 0.92 at level 1, 0.92 to 1.00 at level 2, 0.99 to 1.00 at level 3). DESpace2 misses the amplitude change (0.35, 0.69, 0.87) and, at level 1, the shift inside Layer 3 (0.57). CODA ranks every type below chance (0.07 to 0.55), SpaceExpress is at 0.32 to 0.43 (level 2). River ranks every type at 0.93 to 1.00, as well as or better than stORCA. So this panel supports "registration and domain methods miss a type", not "stORCA is the only method without a blind spot". What separates stORCA from River is the decoy test of v2 (a global level shift is not a spatial change); at level 2 stORCA puts 19 positives and 0 decoys in its top 50, at level 1 it does not separate them (AUROC 0.51). River has not been run on the decoys.

![LIBD implant detection](fig/outline-nov20-libd-implant-detection.png)

*Panel f candidate. AUROC of each implant type against all non-implanted genes; blank = not run yet (STcompare is running). Source: [fig-outline-nov20.py](fig-outline-nov20.py).*

*LIBD implants, completed on 2026-11-20 pm.* STcompare ranks every type below chance (0.06 to 0.52) and SpaceExpress stays at 0.22 to 0.45 at all levels. The decoy test (v2: 10 pure shifts inside Layer 3 as positives, 20 genes whose every layer rises by the same factor as negatives) separates the methods that rank well. River puts 20 decoys in its top 50 at every level and ranks the positives below the decoys (AUROC positives against decoys 0.06, 0.02, 0.00), so its high implant AUROC comes from ranking any condition difference. DESpace2 separates positives from decoys (0.75 to 0.86) but misses the pure shift (0.17 to 0.20, a shift inside one layer leaves the layer level unchanged). stORCA v4 ranks the pure shift at 0.87, 0.94 and 1.00 and puts 2, 0 and 3 decoys in its top 50 (positives against decoys 0.51, 0.78, 0.90); at level 3 it calls 9 genes, all positives, none a decoy. This answers "River ranks the implants as well as stORCA" with data (section 15, Defend).

*HPOA pattern swap (panel f2, 2026-11-20 pm).* With the 11 real HPOA calls removed from the negatives, stORCA ranks the 9 swapped genes at AUROC 0.99 (all 9 in its top 20) and calls 8 of them. CODA 0.81, STcompare 0.76, River 0.89 and SpaceExpress 0.99 (score orientation as in `02-compare-methods.py`, larger = more changed). Three other genes are called: `Greb1` and `Sp9` were near calls on the original HPOA case (BH 0.15), and `Gda` is one of the nine source genes of the swap, so its call needs a look before the panel is used.

*Synthetic v2, competitors (2026-11-20 pm, all 11 scenarios).* AUROC at strength 1 (novel niche has strength 0 only and is in panel 4g):

| Scenario | CODA | STcompare | DESpace2 | SpaceExpress | River | stORCA v4 | stORCA v4 one pair |
|---|---|---|---|---|---|---|---|
| Domain DE | 1.00 | 1.00 | 0.99 | 1.00 | 0.64 | 0.99 | 1.00 |
| Cell-type DE in a domain | 1.00 | 1.00 | 0.73 | 0.98 | 0.56 | 0.96 (0.01 at 1.5 and 2) | 1.00 |
| Within-domain shift | 1.00 | 1.00 | 0.48 | 0.56 | 0.72 | 1.00 | 0.99 |
| Boundary band | 1.00 | 1.00 | 0.48 | 0.54 | 0.75 | 0.00 (untested) | 0.40 (1.00 at 1.5 and 2) |
| Amplitude change (`svg-increase`) | 0.39 | 0.13 | 0.99 | 0.90 | 0.80 | 1.00 | 0.86 |
| Ring domain | 1.00 | 1.00 | 0.93 | 0.76 | 0.25 | 0.97 | 1.00 |
| Cell-type proportion | 1.00 | 1.00 | 1.00 | 1.00 | 0.22 | 0.83 | 1.00 |
| Novel cell type | 0.94 | 0.97 | 1.00 | 0.97 | 0.24 | 0.97 | 1.00 |
| Domain expansion | 1.00 | 1.00 | 1.00 | 0.99 | 0.22 | 0.38 | 1.00 |
| Geometric stretch | 1.00 | 1.00 | 1.00 | 1.00 | 0.23 | 0.99 | 1.00 |

Reading. With an animal effect every competitor has at least one type near or below chance: CODA and STcompare the amplitude change (0.39, 0.13), DESpace2 the within-domain shift and the boundary band (0.48), SpaceExpress the same two (0.54 to 0.56), River most types (0.22 to 0.80; it was 0.77 to 0.98 in v1). stORCA v4 has three: the boundary band and cell-type DE from strength 1.5 (Fix 1, genes removed by the gene rule) and domain expansion (Fix 2, the limma t). Its one-pair and $\Delta$ readings have none below 0.86 at strength 1.5 and above, so "the only method with no blind spot" is within reach after the two fixes and not before. At strength 0, DESpace2 calls 14.5% of genes on the null ring scenario and SpaceExpress 22 to 41% everywhere; stORCA calls 0 to 0.9% in 02 to 07.

*Synthetic v2, stORCA v4 (panels b and c).* Ranking by $\Delta$ or by the one-pair ROS is at 0.90 to 1.00 for domain DE, within-domain shift, amplitude change and ring domain at strength 1 and above. Two types are not scored: in the boundary band (all levels) and in cell-type DE within a domain (three of four levels) the gene rule drops the 10 designed genes, which then rank last (AUROC 0.01). These genes have no spatial structure in one group (correction of 2026-11-20 pm: in cell-type DE the designed effect sits in the cond1 sections and the cond2 sections are flat, so it is the treated group that is flat there, not the control), so the denominator criterion fails in too many pairs. The one-pair ROS ranks the same genes at 1.00 from strength 1.5, so the score sees them and the gene rule removes them (Fix 1). The null at strength 0 holds (0 to 0.9% of genes called).

![Synthetic v2 stORCA AUROC](fig/outline-nov20-synthetic-v2-storca-auroc.png)

*AUROC of the designed genes in three readings of stORCA v4. Values near 0 are genes removed by the gene rule, not genes ranked last on their score.*

Old figures, for the panel design: [amplitude change, ranking](../3-BM-DSE-Scenario/06-svg-increase/fig/svg-increase-benchmark-ranking-performance.pdf), [within-domain shift, ranking](../3-BM-DSE-Scenario/04-within-domain-shift/fig/within-domain-shift-benchmark-ranking-performance.pdf), [score comparison, top-20 capture](../3-BM-DSE-Scores/fig/top20-capture-v1-rep1.pdf).

### Figure 3 (Results 3): look-alike 1, replicate variation

Results heading: "Single-pair comparisons report replicate variation as change". Claim 2. Source report: [12-q2-replicate-calibration.md](../5-Case-Study-Comparison/12-q2-replicate-calibration.md), status sufficient after fixes.

| Panel | Content | Data | Status | Key number |
|---|---|---|---|---|
| a | Design: within pairs (replicate variation by construction) and between pairs | Schematic | To draw | |
| b | Single-pair tests call most genes on two replicate sections | Real, six datasets | Done | 34 to 94% of genes per within pair (5% expected) |
| c | Single-pair rankings: the top between genes are also top within genes | Real | Done, fix 4: redraw on the genes stORCA tested | HPOA 0.50 to 0.80 of the top 20 (chance 0.13) |
| d | Replicate design, true against false labels | Real | Done (v4), Fix 3 of section 15: colitis false labeling with 26 calls | LIBD 0 of 662; HPOA 11 (0 on false labels); NRDR 32 and 11 (0); ARTISTA 113 (at most 17); colitis D0 vs D3 29 (26) |
| e | Ablation, 2 x 2 (one pair or replicate design; score or test): the design repairs the ranking of every score, only ROS turns it into calls | Real | Done; summary plot to draw from `q2-four-comparisons.csv` | True labeling first in 15 of 19; competitors 0 to 3 calls |
| f | Cause: replicate variance against the matching variance inside one pair | Real | Done | 26 to 155 times |
| g | Examples: competitor top genes that are replicate variation (`Blank_2`, a negative-control probe; `Oxt`, a hotspot in one section); a stORCA call (`Cpne5`) | Real, HPOA | Done, fixes 1 and 2: drop River `Sema4d`, correct the `Gbx2` sentence | |
| h | Calibration against ground truth: empirical FDR and power at 2 vs 2 and 3 vs 3 | Semi-synthetic (LIBD, Fig 2f data without and with implants) | Done | No false call at any level or replicate number; true calls 0, 0 and 8 of 40 at levels 1 to 3 (3 vs 3), against 0, 7 and 15 for DESpace2 (one false call at level 3); 0 calls at 2 vs 2. The 6 vs 6 design (adjacent sections added) gives 11 true calls but its false labelings give up to 312, so it stays in the Supplementary |

![LIBD implant calls](fig/outline-nov20-libd-implant-calls.png)

*Panel h candidate. Left: calls at FDR 0.05 with 3 vs 3 donors (black = false calls). Right: stORCA true calls at level 2, calls without implants, and the largest count over false labelings, against sections per group.*

![Single-pair tests on replicate pairs](../5-Case-Study-Comparison/fig/12-q2-replicate-calibration/q2-single-pair-test-call-fraction.png)

*Panel b. Share of genes called by single-pair tests on within and between pairs, per dataset.*

![Replicate design, true against false labels](../5-Case-Study-Comparison/fig/12-q2-replicate-calibration/q2-storca-true-vs-null-calls.png)

*Panel d. stORCA calls on the true labeling against every false labeling.*

![Replicate design read by scores](../5-Case-Study-Comparison/fig/12-q2-replicate-calibration/q2-replicate-score-true-vs-null.png)

*Panel e, ranking half. Top effect under the true and the false labelings, for every method.*

![Replicate over matching variance](../5-Case-Study-Comparison/fig/12-q2-replicate-calibration/q2-replicate-vs-matching-variance.png)

*Panel f. Median ratio of replicate variance to matching variance, log scale.*

![Oxt maps](../5-Case-Study-Comparison/fig/12-q2-replicate-calibration/q2-example-fp-oxt-maps.png)

![Cpne5 maps](../5-Case-Study-Comparison/fig/12-q2-replicate-calibration/q2-example-tp-cpne5-maps.png)

*Panel g. `Oxt`, a hotspot in one section that competitors rank high; `Cpne5`, a stORCA call (within ROS 0.23, between 0.55).*

Supplementary: the gene-bulk null (single-pair ranking when no replicate exists; Q2 section 1c).

### Figure 4 (Results 4): look-alike 2, tissue without a counterpart

Results heading: "Tissue without a counterpart fills the top lists of registration and domain methods". Claim 3. Source report: [11-q1-unmatched-cells.md](../5-Case-Study-Comparison/11-q1-unmatched-cells.md), whose section 7 is the conclusion.

| Panel | Content | Data | Status | Key number |
|---|---|---|---|---|
| a | Retained mass on the tissue: the region without a counterpart is the dark region | Real: cortex 3 dpi (lesion r14), colitis day 0 (epithelium) | Done | |
| b | Retained mass against condition specificity, per cluster | Real | Done | AUROC 0.89 (cortex), 0.94 (colitis day 0); within pairs keep 0.99 |
| c | Share of each method's top 20 that are markers of the tissue without a counterpart | Real | Done (v4) | stORCA 0.20 and 0.35 (base 0.11 and 0.28); CODA 0.50 and 0.70; STcompare 0.70 and 0.65; DESpace2 0.70 (colitis); pseudobulk DE 0.60 and 0.40; River 0.10 and 0.30 (shown, see Defend) |
| d | Examples | Real | Done | `Ptger3`: top 3 of CODA, STcompare and DESpace2, rank 212 in stORCA, an epithelial gene gone at day 9; stORCA's top genes `Flnc` and `Grem2` sit in muscle present at both days |
| e | Ablation of the baseline: no thinning, control side, both sides | Real and HPOA | Done (Q1 section 5e); to draw | Gained-tissue markers in the top 20: cortex 0.35 to 0.20, colitis day 9 0.15 to 0.00; HPOA keeps 11 of 11 calls |
| f | Why registration methods fail: the alignment lays the lost compartment over other tissue where its markers are low, so their correlation turns negative | Real: colitis D0 vs D9, CODA and STcompare, 9 pairs | Done (Q1 section 7c); to draw | Lost epithelium on day-9 tissue: CODA 0.79 of the cells, STcompare 0.74 to 0.99 of the pixels; `Ptger3` negative in 9 of 9 pairs for both; the overlay gives 0.85 (CODA) and 0.59 (STcompare, from a third of the pixels) of its negative score |
| g | Controlled test with a region lost or gained | Synthetic v2, scenarios 08 (cell-type proportion), 09 (novel cell type), 10 (domain expansion), 11 (novel niche), 12 (geometric stretch) | Done v4 with competitors (2026-11-20 pm); Fix 2; supportive only (below) | stORCA puts the probes of the changed population low (mean rank 95 to 125 of 150 to 160 under the limma t; 41 to 75 under the one-pair ROS). Domain expansion: 121 and 130 of 150 genes called (below) |
| h | Matching ablation: partial plan against a balanced plan (every cell forced to match) | Real (cortex, colitis) or synthetic (axis-redesign, `4-BM-Alighment-not-fininalize`) | Optional; it would only strengthen panel c | |

![Cortex retained mass](../5-Case-Study-Comparison/fig/11-q1-unmatched-cells/q1-slide-maps-cortex-3-dpi.png)

![Colitis day 0 retained mass](../5-Case-Study-Comparison/fig/11-q1-unmatched-cells/q1-slide-maps-colitis-day-0.png)

*Panel a. Top: cells without a counterpart in color (cortex r14 red, colitis epithelium blue). Bottom: retained mass on the same sections.*

![Retained mass against specificity](../5-Case-Study-Comparison/fig/11-q1-unmatched-cells/q1-slide-retained-vs-specificity.png)

*Panel b. One point per cluster; clusters found in one condition only have low retained mass.*

![Marker share top 20](../5-Case-Study-Comparison/fig/11-q1-unmatched-cells/q1-slide-marker-share-top20.png)

![Marker share top k](../5-Case-Study-Comparison/fig/11-q1-unmatched-cells/q1-slide-marker-share-topk.png)

*Panel c. Share of each method's top 20 (and top k) that are markers of the tissue without a counterpart; red = stORCA with both sides thinned.*

![Colitis examples](../5-Case-Study-Comparison/fig/11-q1-unmatched-cells/q1-std-examples-colitisq1.png)

*Panel d. `Ptger3` and `Cldn15` (competitors' top 20) sit in the day-0 epithelial ring and vanish with it; `Flnc` and `Grem2` (stORCA's top two) change in the muscle layers.*

**Semi-synthetic removal of a cell class (HPOA, Q1 sections 5 to 5c): not used** (decision of 2026-11-18). Removing a class scattered among other cells leaves no hole for the alignment to fill and leaves the marker without an organized pattern, so CODA's correlation only falls to the level of genes without structure (`Gjc3` 0.18 to 0.04) instead of turning negative. It does not reproduce the situation of panels a to d (Q1 section 7c). The controlled test is panel g.

**Old synthetic rearrangement result (old pipeline, no partial-plan thinning).** As the share of the changed population grows, stORCA ranks the probe genes of that population higher (mean rank 84.7 to 61.2 in `ct-proportion`), and in `novel-niche` it calls 0.83 of genes at FDR 0.05. CODA and STcompare put the probes at the same rank (30.5) at every level, so this design does not show them misled either. It does not test the current method, but it is a risk: if the rerun looks the same, Figure 4 rests on real data only. `domain-expansion` has no collected metrics yet.

**Synthetic v2 rerun with stORCA v4 (2026-11-19).** The risk above is gone for stORCA: in every rearrangement scenario the probes rank in the lower half (table in panel g), and the one-pair reading ranks them higher than the replicate reading, so the replicate design helps here too. Two results need attention. (1) Domain expansion: 121 of 150 genes called at strength 1 and 130 at strength 2. All 100 background genes in scenarios 07 to 12 are strong domain markers (correction of 2026-11-19 in `3-BM-DSE-Scenario/01-data-generation/doc/01-data-generation-en.md`), so when the domain grows their pattern really moves; their $\Delta$ is small (between ROS 0.018 to 0.028) but the within ROS is near 0, and the limma t then ranks these small, consistent changes above the designed genes (AUROC 0.38 and 0.25 under t, 1.00 under $\Delta$). (2) Cell-type proportion at strength 1: 21 non-designed genes called, against 0 and 1 at strengths 0 and 2. Competitors (2026-11-20 pm): CODA and STcompare put the probes at mean rank 30.5 to 34.7 in every rearrangement scenario, and also at strength 0 and in the geometric stretch where nothing is rearranged, so the probes are strongly patterned markers that they rank high regardless of the change. DESpace2 puts them at 66 to 100 and River at 104 to 113. So, as in v1, this design shows that stORCA is not misled (probes at 50 to 125 under t, moving down as domain expansion grows: 82, 125, 125), but it does not show the registration methods misled by tissue without a counterpart. Panel 4g stays supportive; claim 3 rests on panels a to f.

![Synthetic v2 stORCA calls](fig/outline-nov20-synthetic-v2-storca-calls.png)

![Synthetic v2 calls legend](fig/outline-nov20-synthetic-v2-calls-legend.png)

*stORCA v4 calls per scenario and strength (symlog axis). Green: designed (focal) genes called, of 10. Red: other genes called.*

### Figure 5 (Results 5): what changed and where, beyond DE

Results heading: "stORCA types each change and finds changes that DE and domain tests do not detect". Claim 4. Source reports: [13-q3-beyond-de.md](../5-Case-Study-Comparison/13-q3-beyond-de.md) (sufficient) and [15-q5-interpretation.md](../5-Case-Study-Comparison/15-q5-interpretation.md) (sufficient for what it shows).

| Panel | Content | Data | Status | Key number |
|---|---|---|---|---|
| a | Every call on the $\rho$, $\kappa$ plane, with the share of types | Real: ARTISTA, NRDR, HPOA | Done (v4) | Pattern, mixed, amplitude: ARTISTA 59, 44, 10; NRDR 14, 14, 4; HPOA 2, 3, 6 |
| b | Overlap with DESpace2 and pseudobulk DE at the same design | Real: ARTISTA, NRDR | Done (v4 tables; Q3 report to update) | ARTISTA 113 calls, 89 not called by DESpace2, 31 by neither pseudobulk DE test (global or per domain); NRDR 32 calls, DESpace2 0, 22 by neither pseudobulk test |
| c | Examples detected by neither test: `Prkca`, `Trpc3` (the L2/3 to L4 band fades in dark rearing), with one sampled matching | Real: NRDR | Done | Smallest layer FDR 0.10 and 0.11; DESpace2 FDR 1.00 |
| d | Type examples: `CDKN1B` (amplitude), `FABP7` (pattern), with residual maps | Real: ARTISTA | Done | |
| e | Biological check: activity genes rise in dark-reared V1, as the source study reports | Real: NRDR | Done; to draw | $\ell>0$ in 7 of 7 called genes; same sign as pseudobulk in 11 of 11 |
| f | Beyond-DE calls split by type | Real | To run (a join of the Q3 and Q5 tables) | |
| g | Location in numbers: residual enrichment by niche or cell type | Real | To run, or state "shown on maps" | |

![rho-kappa plane](../5-Case-Study-Comparison/fig/15-q5-interpretation/q5-rho-kappa-plane.png)

*Panel a. Every call placed by pattern agreement and amplitude agreement, per dataset.*

![ARTISTA Venn](../5-Case-Study-Comparison/fig/13-q3-beyond-de/q3-artista-venn.png)

![NRDR Venn](../5-Case-Study-Comparison/fig/13-q3-beyond-de/q3-nrdr-venn.png)

*Panel b. stORCA calls against DESpace2 and pseudobulk DE at the same design.*

![Prkca maps](../5-Case-Study-Comparison/fig/13-q3-beyond-de/q3-nrdr-prkca-maps.png)

![Prkca one sampled matching](../5-Case-Study-Comparison/fig/13-q3-beyond-de/q3-nrdr-prkca-sampled-matching.png)

*Panel c. `Prkca` in the four NRDR sections, and the residual of one sampled matching on the L2/3 to L4 band.*

![CDKN1B maps](../5-Case-Study-Comparison/fig/15-q5-interpretation/q5-artista-amplitude-xiclnr-cdkn1bhs-maps.png)

![FABP7 maps](../5-Case-Study-Comparison/fig/15-q5-interpretation/q5-artista-pattern-fabp7nr-maps.png)

*Panel d. `CDKN1B`, an amplitude call; `FABP7`, a pattern call.*

Supplementary: NRDR 4 vs 4 replication (82 calls, 23 of the 32 posterior calls kept); the moved L2/3 to L4 boundary (a candidate); typing on the excess over replicates (66 to 76% of calls keep their type).

### Figure 6 (Results 6): one scale across comparisons

Results heading: "$\Delta$ follows the course of regeneration on one scale". Claim 5, on hold since 2026-11-20. Source report: [14-q4-effect-size.md](../5-Case-Study-Comparison/14-q4-effect-size.md), status sufficient after fixes.

| Panel | Content | Data | Status | Key number |
|---|---|---|---|---|
| a | Design: 2 DPI against 5, 10, 15 and 20 DPI | Schematic | To draw | |
| b | Calls per comparison and the largest false-label count | Real: ARTISTA | Done | 117, 249, 331, 155 calls; false labels at most 0, 0, 43, 12 |
| c | $\Delta$ per time point on one axis | Real | Done | Medians 0.047, 0.094, 0.099, 0.058 over 684 genes |
| d | Trajectory and peak time of each gene | Real | Done | Peaks at 5, 10, 15, 20 DPI: 38, 132, 168, 88 genes |
| e | Examples: a rising change (`DDIT4`, $\Delta$ 0.50 at 20 DPI) and a transient change (`ZIC1`, a band across the dorsal midline in all four 15 DPI sections) | Real | Done (`NPTXR` replaced by `ZIC1` on 2026-11-19) | `ZIC1` $\Delta$ 0.03, 0.16, 0.47, 0.05 at 5 to 20 DPI; BH 0.002 at 15 DPI |
| f | A rank inside one pair cannot be compared across comparisons | Real | Done; to draw | One gene's rank goes from 47 to 1062 between pairs |
| g | Scale check: $\Delta$ rises with the designed strength of an amplitude change | Synthetic v2 (`svg-increase`) | Done; Fix 4 (scope reduced from "every change type") | Median $\Delta$ of the designed genes 0.008, 0.041, 0.114, 0.234 at strengths 0.5 to 2. In domain DE $\Delta$ is flat (0.49 to 0.57) and in the within-domain shift it falls (between ROS 0.31, 0.13, 0.08) |

![Calls per comparison](../5-Case-Study-Comparison/fig/14-q4-effect-size/q4-artista-timecourse-calls.png)

*Panel b. Calls per comparison, with the largest count over false labelings.*

![Delta per time point](../5-Case-Study-Comparison/fig/14-q4-effect-size/q4-artista-delta-distribution.png)

*Panel c. $\Delta$ of the genes tested at every time point.*

![Trajectories](../5-Case-Study-Comparison/fig/14-q4-effect-size/q4-artista-delta-trajectories.png)

*Panel d. Trajectory of each gene called at least once, grouped by peak time.*

![DDIT4 ROS per pair](../5-Case-Study-Comparison/fig/14-q4-effect-size/q4-artista-increasing-ddit4-pair-ros.png)

*Panel e. `DDIT4`, ROS of every between and within pair per time point.*

Supplementary: depth-matched downsampling; effect of the clip (829 of 837 calls kept).

### Supplementary and source-data items

- Parameter sensitivity (K, ε, δ, number of matchings, graph k), gene-holdout embedding, both scoring directions, depth-matched downsampling.
- limma null simulation and comparison with R limma; unweighted against weighted; one-sided against two-sided.
- Gene-bulk null for single-pair ranking (Q2 section 1c).
- Geometric stretch (`3-BM-DSE-Scenario/12`) and the axis-redesign alignment swap with plan C (`4-BM-Alighment-not-fininalize`).
- NRDR 4 vs 4 replication and the L2/3 to L4 boundary (Q3 sections 5, 6).
- Embryo developmental series and other single-pair analyses, labelled as descriptive rankings.
- Full p-value design history as a Supplementary Note.
- Derivation of the concordance identity and the decomposition, with the non-PSD caveat.

### Run list for the Results, in order

| Order | Work | Figures | Size |
|---|---|---|---|
| 0 | ~~Freeze the pipeline~~ (done 2026-11-18, v4) | all | |
| 1 | ~~Rerun the Q2 to Q5 limma fits~~ (done 2026-11-19); port the v4 numbers into the Q1, Q2, Q3 and Q5 reports | 3, 4, 5 | Small |
| 2 | Fix 1 of section 15: the gene rule for genes without structure in one condition; rescore scenarios 02, 03 and 05 and the LIBD implants | 2 | Small to medium (rescoring) |
| 3 | ~~Collect the competitor metrics of synthetic v2, scenarios 02 to 12~~ (done 2026-11-20 pm) | 2, 4 | |
| 4 | Fix 2: decide the ranking statistic for lists and the call rule for small, consistent changes; rescore | 2, 4 | Small |
| 5 | ~~STcompare on LIBD implants; all competitors on the v2 decoys~~ (done 2026-11-20 pm) | 2 | |
| 6 | Report fixes: Q2 (River panel, `Gbx2` sentence, colitis false labeling (Fix 3), gene universe) | 3 | Small |
| 7 | Rerun `3-BM-DSE-Scores` with ROS and cross-correlation (panel 2d) | 2 | Small |
| 8 | Plots and joins from saved results: 2 x 2 summary, baseline ablation, mechanism panel (4f), beyond-DE calls by type, activity genes, rank table | 3, 4, 5, 6 | Small |
| 9 | ~~Runtime and memory (panel 2g)~~ (done 2026-11-20 pm); plot to draw | 2 | |
| 10 | Figure 1: toy genes and the two look-alikes (panels a to c) | 1 | Small |

## 7. Where the existing work goes

Superseded on 2026-11-18 by the per-figure tables of section 6, which also give the status of each experiment. Kept for history.

| Existing experiment | Folder | New location | Reusable as is? |
|---|---|---|---|
| Synthetic v1 to v4 | `1-BM-DSE-Synthetic` | Fig 4a, b | Design yes, numbers no |
| Semi-synthetic v1, v2 | `1-BM-DSE-Semi` | Fig 4g | Design yes, numbers no |
| Score comparison on ideal mapping | `3-BM-DSE-Scores` | Fig 2c | Rerun with ROS, add cross-correlation |
| Multi-replicate strategies | `3-BM-MultiReplicate` | Fig 4c | Design only; inference is now limma |
| Axis-redesign, dissociation, coverage collapse | `11-axis-redesign-benchmark`, `4-BM-Alighment-not-fininalize` | Fig 4e, f | Rerun with plan C |
| Real-data DSE, direction stability | `1-BM-DSE-Real` | Fig 3f, Supplementary | Old pipeline |
| DSE against DE and SVG | `2-BM-DSE-DESVG` | Fig 6e | Rerun |
| Local Moran interpretation | `2-BM-DSE-Interpretation` | Fig 5d approach | Method reusable |
| p-value diagnostics, notebooks 21 to 26 | `5-Case-Study-Colitis` | Fig 3, Supplementary Note | Yes |
| ρκ decomposition | `5-Case-Study-Colitis` | Fig 2b, Fig 5c | To verify against section 2 |
| Day 9 severe unmatched cell type | location to be filled in | Fig 2d | To confirm with plan C |

## 8. Case study selection

| Dataset | Technology | Replicates per condition | Suggested role | Status |
|---|---|---|---|---|
| DSS colitis (Ranganathan 2024) | MERFISH | 3 healthy, 4 day 3 available | Fig 2d, Fig 3, Fig 5 | 2 vs 2 done, 3 vs 3 not run |
| Aging brain (Allen 2023 or Sun 2024) | MERFISH | Several | Fig 3f and Fig 6 main case | SysVI results exist, not inspected |
| HPOA (Moffitt 2018) | MERFISH | Several animals | Fig 3f calibration, semi-synthetic base | Old pipeline |
| DLPFC | Visium | Donors | Negative control, platform breadth | Not inspected |
| Axolotl regeneration (ARTISTA) | Stereo-seq | Few | Fig 6d, strong geometry change | Not inspected |
| AD Xenium | Xenium | Unknown | Fig 6d | Legacy |
| Cortex stab, spinal injury | (see folders) | Unknown | Fig 6d or Supplementary | Compared with Sardine |
| NRDR | MERFISH | Limited | Supplementary | Old pipeline |
| Mouse embryo (MOSTA) | Stereo-seq | None | Supplementary, descriptive | Old pipeline, 1 vs 1 |

Selection rule: a dataset can carry a main-text biological claim only if it has at least three animals per condition. Everything else is shown as rankings, effect sizes and types.

## 9. What to claim and what not to claim

| Claim | Use it? |
|---|---|
| stORCA propagates matching uncertainty into the score | Yes, with the ablation of Fig 2e |
| ROS is a spatial concordance measure sensitive to pattern and amplitude | Yes |
| Each call is typed and localized | Yes, validated in Fig 4d |
| Single-pair spatial tests are not calibrated against replicate variation | Yes, on several datasets and methods |
| stORCA controls false discoveries with replicates | Yes, after the current-pipeline benchmark and 3 vs 3 permutation FDR |
| No registration or domain labels needed | Yes, as a consequence |
| Changes are detected at niche or domain scale | Yes, and say so explicitly |
| DSE finds genes that DE cannot | Only in the measured form, split by type: pattern calls against amplitude calls |
| "Uncertainty-aware" means calibrated confidence for each match | No. Define the two sources once and keep to them |
| Cell-level correspondence | No. Partner distance is 100 to 150 cells |
| Single-pair p-values identify condition effects | No. Single-pair output is a ranking with type and location |
| "10 genes at FDR 5% in day 3 colitis"; "200 to 438 FDR genes follow severity" | No. Not with the current evidence; the second rests on the invalid test |
| Best alignment method | No. Claim stability of downstream DSE |

## 10. Expected reviewer objections and where each is answered

| Objection | Answer location | Open work |
|---|---|---|
| The score is CODA's cross-correlation | Section 2 identity, Fig 2a: correlation against concordance, the difference is the amplitude term | Run CODA |
| Bivariate Moran and Lee's L already exist | Cite; our contribution is the concordance form, its decomposition and its use across replicates | Literature check |
| Matching uncertainty is tiny (0.006), why propagate it | Fig 2e and Fig 3d: it changes the score when discarded, and it is a different source from replicate variation | Ablation |
| The spread of the plan is the entropy parameter, not biology | Fig 2d: at fixed ε the spread varies with tissue state; ε sensitivity in Supplementary | Rerun with plan C |
| Uncertainty of the embedding is ignored | Fig 2f | Five seeds |
| Amplitude calls are just DE | Fig 5f, Fig 6e | Pseudobulk baseline |
| Decomposition is unstable for weak-structure genes | Reported only above the structure filter; stated in Methods | None |
| Two mice per group; calls driven by one animal | Fig 5a, b, leave-one-animal-out | 3 vs 3, 3 vs 4 |
| Condition confounded with processing date | Methods and limitations | Ask the data authors |
| Double dipping of genes in the embedding | Supplementary, gene-holdout embedding | Run it |
| Direction asymmetry | Supplementary, both directions | Score both |
| Precision weights drive the calls | Unweighted limma as primary | Decide and rerun |
| On and off genes are excluded by clipping | In the concordance view these are the limit $C(\kappa)\to0$; change the clip so they are scored | Decision needed |
| Benchmarks do not match the method described | Fig 2 to 4 regenerated with the released package | Move ROS, decomposition and limma into `storca/` |
| What if I have no replicates | Discussion: ranking with type and location, external replicate null, stated limits | Text only |

## 11. Work before submission, in order

1. Freeze the pipeline and move ROS, its decomposition, plan C and the limma path into the `storca` package.
2. Colitis 3 vs 3 and 3 vs 4 with permutation FDR. Decides whether colitis can carry Fig 5.
3. Fig 2 experiments: designed-gene score comparison including cross-correlation, sampled against argmax and barycentric, embedding seeds, day 9 severe example with plan C.
4. Replicate-null analysis on two more datasets and with competitor methods (Fig 3).
5. Current-pipeline synthetic benchmark with amplitude and pattern DSE classes, medium-scale null genes and a replicate design (Fig 4a to d).
6. Axis-redesign rerun with plan C (Fig 4e, f).
7. Pseudobulk comparison split by type (Fig 5f, Fig 6e).
8. Second replicate-rich case study (Fig 6).
9. Robustness supplements (holdout, both directions, depth).
10. Rewrite Methods from the frozen package, then Results in the template of this folder.

Items 2 and 3 are cheap and decide the framing, so they come before the large reruns.

## 12. Fallbacks

- **3 vs 3 colitis still gives few calls.** Colitis stays as the calibration and matching-uncertainty dataset (Fig 2d, Fig 3) and the interpretation case moves to the dataset with the most animals.
- **Sampled matchings do not differ from a single alignment in any setting.** Claim 1 shrinks to the soft and partial matching itself (cells with no counterpart are not forced to match), shown by the day 9 severe result, and the title word rests on replicates plus that.
- **Competitors are well calibrated on replicates.** Fig 3 shrinks to a panel and the weight moves to claims 2 and 4.
- **Most calls are amplitude changes everywhere.** Already covered by the framing: report the shares, and state that the method's contribution for those genes is annotation-free localization.
- **Current pipeline underperforms the old one in the synthetic benchmark.** Investigate before writing. Do not mix pipelines across figures.

## 13. Sources

- River: [Nature Communications 2025, doi 10.1038/s41467-025-61476-9](https://www.nature.com/nature-index/article/10.1038/s41467-025-61476-9)
- CODA: [bioRxiv 2025.06.05.653933](https://www.biorxiv.org/content/10.1101/2025.06.05.653933.full.pdf), published as [Nature Communications 2026, doi 10.1038/s41467-026-72862-2](https://www.nature.com/nature-index/article/10.1038/s41467-026-72862-2)
- STcompare: [bioRxiv 2025.11.21.689847](https://www.biorxiv.org/content/10.1101/2025.11.21.689847.full.pdf)
- DESpace2: [bioRxiv 2025.06.30.662268](https://www.biorxiv.org/content/10.1101/2025.06.30.662268.full.pdf)
- SpaceExpress: [bioRxiv 2024.12.19.628720](https://www.biorxiv.org/content/10.1101/2024.12.19.628720.full.pdf)
- SLAT: [Nature Communications 2023, PMC10636043](https://pmc.ncbi.nlm.nih.gov/articles/PMC10636043)
- Differential spatial patterns chapter, OSTA book: [bioconductor.org](https://bioconductor.org/books/release/OSTA/pages/mult-diff-spatial-patterns.html)
- Squair et al. 2021, false discoveries in single-cell DE: [Nature Communications](https://infoscience.epfl.ch/record/289583/files/s41467-021-25960-2.pdf)
- Lin 1989, concordance correlation coefficient (Biometrics 45:255): cited from memory, not retrieved in this session.

## 14. Open issue: what "matching uncertainty" means

Recorded on 2026-11-12. Resolved on 2026-11-18 for meaning 2 (section 1): the paper speaks of cells without a counterpart, and sampled matchings stay in Methods as the way the score is computed.

The phrase "the uncertainty of matching cells across conditions" in the umbrella claim can mean two different things, and the paper must commit to one:

1. **Which partner**: a cell may have several plausible counterparts, so matchings are sampled and their spread is propagated into the score.
2. **Whether there is a partner**: a cell may have no counterpart at all (a new or lost cell population), so it is not forced to match and is left out of the score (soft, partial matching).

Why this matters:

- Within-pair matching resampling variation (about 0.006) is about 25 times smaller than replicate variation (about 0.15), and bootstrap precision weights were unstable in every dataset, so unweighted limma is the primary analysis. A claim of type 1 ("propagating matching uncertainty improves the result") is therefore hard to defend.
- A claim of type 2 does not depend on the size of that variance. It is a structural property: competitors based on a diffeomorphism (CODA, STcompare) assume exactly one counterpart for every location.
- The 25-fold gap still supports the replicate claim: a null built by resampling within one pair is far too narrow, so single-pair tests are overconfident.

Text currently written with the type 1 meaning: claim 1 (section 1), the field-gap bullet and the "what none of them did" line, abstract step 3, the Figure 2 title and panel 2e, and the "what to claim" row on propagation (section 9) and the reviewer-objection row on propagation (section 10). The type 2 meaning appears only as a fallback in section 12.

Proposed real-data test for type 2: forced (balanced) against partial matching in colitis and ARTISTA, comparing how many top genes are markers of the unmatched cell population.

## 15. Status review of 2026-11-20: fix or defend

Results read: the v4 Q tables in `5-Case-Study-Comparison/res/Comparison/` (notebooks rerun 2026-11-19), synthetic v2 with stORCA v4 (`3-BM-DSE-Scenario-v2/13-storca-v4`), and the LIBD implant benchmark (`1-BM-DSE-Semi-LIBD/res`). Each item is judged against the claim of section 1 it serves.

| Figure | Claim | Verdict |
|---|---|---|
| 1 | Method | Sufficient (method panels drawn; look-alike panels to draw) |
| 2 | 1, the score sees every kind of change | Not yet: sufficient on LIBD implants after the rewording; synthetic needs Fix 1 and the competitor metrics |
| 3 | 2, replicate variation | Sufficient after Fix 3 and the Q2 report fixes |
| 4 | 3, tissue without a counterpart | Sufficient on real data; synthetic panel g needs Fix 2 and the competitor metrics |
| 5 | 4, beyond DE | Sufficient (port the v4 numbers into the Q3 and Q5 reports) |
| 6 | 5, one scale (on hold) | On hold since 2026-11-20; sufficient after Fix 4 if taken up again |

**Overall status: not yet, because of Figure 2. Figures 3 to 5 are sufficient after the listed fixes. Figure 6 (claim 5) is on hold.**

**Fix.**

1. **The gene rule drops genes that have no structure in one condition** (Fig 2b; conflicts with claim 1). In the boundary band and in cell-type DE within a domain, the 10 designed genes are untested at most levels, so they rank last (AUROC 0.01), while the one-pair ROS ranks them at 1.00 from strength 1.5. The same situation makes the within ROS of domain-DE genes about 0.5 (the within pairs of the flat condition compare noise with noise), which is why only 1 to 4 of 10 domain-DE genes are called. Simplest fix (stORCA tuning): let the structure criterion pass a gene that is structured in either group, and score the within pairs of a group only where the gene has structure in that group, or report such genes as the on/off type the Figure 1 draft already names (section 10 row "On and off genes"). Rescore 02, 03, 05 and the LIBD implants; no new runs of SysVI or the plan are needed. Mechanism in cell-type DE, checked on 2026-11-20 pm (rep 1, c1-r1 to c2-r1): as strength grows the partial plan drops the source cells that carry the effect (domain A, CT0: retained 1.00, 0.44 and 0.16 at strengths 1, 1.5 and 2; the top 10% of cells by designed-gene expression 1.00, 0.34, 0.09), because ten strongly raised genes in a 110-gene panel make those cells a new state in the embedding. The between pairs then measure the gene on the cells that remain, their denominator criterion fails (usable in 98%, 8% and 1% of between pairs), and the gene is removed. The one-pair ROS still sees the change (between ROS about 1.1), which is why the old single-pair pipeline (uniform plan) and the one-pair reading score this scenario at 0.99 to 1.00.
2. **The limma t ranks small, consistent changes above large ones** (Fig 4g; conflicts with the umbrella claim as a reader will see it). In domain expansion stORCA calls 121 and 130 of 150 genes. The background genes are domain markers, so their pattern really moves, but their $\Delta$ is 0.02 against about 0.5 for the designed genes. Ranked by $\Delta$ the designed genes come first (AUROC 1.00); ranked by t they do not (0.38, 0.25). Simplest fix: rank top lists by $\Delta$ (claim 5 already makes $\Delta$ the scale) and call with a minimum effect (limma `treat` against a small $\Delta_0$, for example 0.05), then check that HPOA, NRDR and ARTISTA keep most calls. Unsure between Fix and Defend: the calls are real pattern changes, so it could be defended as "stORCA reports that the layout changed". Fix is recommended because 87% of genes called after a domain grows is the picture a reviewer will remember.
3. **Colitis D0 vs D3: one false labeling gives 26 calls against 29 on the true labels** (Fig 3d; conflicts with "calls exceed replicate variation"). This is open since Q2 (Fix 3 there). Simplest fix: keep colitis D0 vs D3 in the single-pair panels (b, c) and drop it from the list of datasets where the replicate design gives calls; say in one line that its calls cannot be told apart from a false labeling.
4. **"$\Delta$ rises with the designed strength in every change type" is false** (Fig 6g). $\Delta$ rises for the amplitude change, is flat for domain DE and falls for the within-domain shift. Simplest fix: reduce panel 6g to the amplitude change, the type in which strength scales the effect itself (done in the table above). Claim 5 rests on the time course and is not affected. On hold with claim 5 (2026-11-20).
5. **"The only method with no change type near chance" is wrong on the LIBD implants**, where River also ranks every type at 0.93 to 1.00 (claim 1, abstract). Done in this revision: the claim now says that registration and domain methods miss a type. The decoy run (2026-11-20 pm) shows what River's ranking also picks up: 20 of its top 50 are level-only decoys at every level, and the positives rank below the decoys (AUROC 0.00 to 0.06), while stORCA separates them from level 2 (0.78, 0.90). With an animal effect (synthetic v2) River drops to 0.22 to 0.80.

**Defend.**

| A reviewer can say | Answer |
|---|---|
| At 3 vs 3 on LIBD implants stORCA makes 0 calls at level 2, where DESpace2 makes 7 | DESpace2 is given the manual layer labels and tests the very layers the implants were placed in; stORCA uses no labels. stORCA makes no false call at any level or design and ranks every type at 0.92 or above from level 2. Power rises with effect size and replicate number, and Fix 1 is expected to raise it for genes that are flat in the control |
| River ranks the LIBD implants as well as stORCA | River ranks condition-predictive genes and has no test. On the LIBD decoys (every layer raised by one factor, no spatial change) it ranks the decoys above the true spatial changes (AUROC 0.00 to 0.06, 20 decoys in its top 50), where stORCA separates them (0.78 and 0.90 at levels 2 and 3); with an animal effect in the synthetic data it falls to 0.22 to 0.80. Claim 1 is about what registration and domain scores cannot see |
| River's top 20 hold fewer markers of the lost tissue than stORCA's (0.10 and 0.30) | River does not compare locations, so it makes no correspondence assumption to break; claim 3 is about registration and domain methods. River is shown in the panel |
| The 6 vs 6 LIBD design gives up to 312 calls on false labelings | Adjacent sections of one donor are technical repeats; a false labeling that puts both sections of a donor on one side turns the donor into the condition. Checked on 2026-11-20 pm (null 6 vs 6): the 108 labelings with at most two sections of each donor in a group give 0 calls in every case; the calls come from labelings with 3 or 4 sections of one donor in a group (up to 255). Only designs with one section per donor are used for calibration |
| stORCA makes 1 call in the cortex stab wound | Figure 4 compares top lists, not calls; 2 vs 2 hemispheres give little power, and the claim is about what fills the top of each list |
| Calls in the synthetic within-domain shift drop from 10 to 0 as strength grows | The ranking stays at 0.97 to 1.00; the drop comes from $\Delta$ shrinking with strength in this scenario (Fix 4), not from the test |
| Scenario 11 (novel niche) has only strength 0 | It is shown as one condition, with the probe rank; scenarios 08 to 10 carry the strength series |
| The synthetic rearrangement test does not show CODA and STcompare misled | True: they rank the probes high (30.5 to 34.7) at every level, including strength 0, because the probes are strong markers. Panel 4g only shows that stORCA is not misled; the competitor contrast of claim 3 comes from the real cortex and colitis data (panels a to f), where the lost tissue is a region the registration lays over other tissue |
| Q reports still quote v3 numbers | The v4 changes are small (113 against 115 calls in ARTISTA, 29 against 27 in colitis); the outline uses the v4 tables and the reports will be updated |
