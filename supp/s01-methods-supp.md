# Supplementary Methods (Figures 2 to 5)

This document collects every setting behind Figures 2 to 5, written in the project manuscript style (`.claude/skills/manuscript-style/SKILL.md`). Section S2 (Figure 2) is complete; sections for Figures 3 to 5 will be added. It replaces the supplementary sections of `0-method-v3-supplementary.md`. The algorithm is in the main Methods ([English](0-method-v4.md) · [한국어](0-method-v4.ko.md)); the Figure 2 Results text and legend are in the current draft ([English](0-results-fig2-v4.md) · [한국어](0-results-fig2-v4.ko.md)).

## S2. Controlled benchmarks (Figure 2)

### S2.1. Two benchmarks and what each tests

Figure 2 asks which kinds of spatial change each method can detect. We used two benchmarks in which the changed genes are known. The simulated benchmark (Figure 2a to c) changes one feature of a spatial pattern at a time on a known geometry, so that a method's failure can be traced to the kind of change. The cortex benchmark (Figure 2d,e) places changes into measured Visium sections from three donors, so that the changes must be found against real variation among sections and donors, and stORCA can use its replicate design. Both benchmarks include decoy genes with a global shift, a change in mean expression that is the same in every cell, to test whether a method separates a spatial change from a change in level.

### S2.2. Simulated tissue

**Geometry.** Five scenarios used a $60\times60$ lattice divided into four vertical domains A to D, each 15 columns wide. The ring scenario kept the sites within radius 34 of the center of a $68\times68$ lattice and divided this disk into four concentric domains at radii 8.5, 17 and 25.5. Domains A, B, C and D contained equal mixtures of cell types (0, 1), (1, 2), (2, 3) and (3, 0); cell types were drawn independently for each section.

**Genes.** Each scenario had 120 genes in four classes, all with a spatial pattern in both conditions, so that a method could not separate changed from unchanged genes by the presence of a pattern alone.

| Class | Number | Baseline pattern | Condition 2 |
|---|---|---|---|
| Domain markers (unchanged) | 80 | One domain each, 20 per domain | Unchanged |
| Cell-type markers (unchanged) | 20 | One cell type each, five per type | Unchanged |
| Decoys | 10 | One domain each | $+s$ on the log mean in every cell |
| Focal genes | 10 | One domain other than the changed region (B, C or D; for the ring, the first, third or fourth ring; for the amplitude change, all four domains) | One designed change (table below) |

**Expression model.** For cell $i$ and gene $g$, counts were negative binomial with mean $\mu_{ig}$ and variance $\mu_{ig}+\mu_{ig}^2/\theta_g$, with

$$
\log\mu_{ig}=\beta_g+\alpha_g S_{ig}+\epsilon_{ig}+d_{ig},
$$

where $S_{ig}$ is the gene's domain or cell-type indicator centered over the section, $\beta_g\sim N(1.5,0.25^2)$, $\theta_g=|N(3,0.5^2)|$, $\epsilon_{ig}\sim N(0,0.3^2)$ is cell-level noise drawn separately for each section, and $d_{ig}$ is the designed change. Pattern amplitudes $\alpha_g$ took ten evenly spaced values from 1.0 to 2.4 for domain markers (eight genes per value), decoys and focal genes, and five values from 1.2 to 2.2 for cell-type markers. Giving decoys and focal genes the same amplitudes as the background prevents a method from finding changed genes by the strength of their baseline pattern.

**Designed changes.** For effect strength $s\in\{0,0.5,1,1.5,2\}$, the focal genes received the following change $d_{ig}$ (columns are zero-based):

| Scenario (panel label) | Change in the log mean of focal genes |
|---|---|
| Domain DE | $+s$ in domain A, condition 2 |
| Cell-type DE within a domain | $+s$ in cell type 0 of domain A, condition 2 |
| Within-domain shift | $+s$ in columns 0 to 6 of domain A in condition 1, and in columns 8 to 14 in condition 2 |
| Boundary band | $+s$ in columns 14 and 15 (the A and B boundary), condition 2 |
| Amplitude increase | $+s\,S_{ig}$ in condition 2, a stronger version of the existing pattern |
| Ring domain | $+s$ in the second concentric domain, condition 2 |

The within-domain shift moves expression from one side of domain A to the other while keeping the domain mean nearly unchanged; the boundary band changes 2 of 60 columns. These two scenarios therefore test changes that a test of domain means cannot see. At $s=0$ no gene changes; the designated focal genes are kept only to check that no method ranks them first before a change exists.

**Replicates and seeds.** For each scenario and strength we generated three sections per condition. Gene parameters were shared across strengths, conditions and replicates (base seed 20261124, offset by scenario). Cell-type assignments, cell-level noise and count sampling had their own seeds per scenario, replicate and condition, and these seeds were reused across strengths, so that the strength series differs only in $s$. Generator: [01-make-v3.py](../3-BM-DSE-Scenario-v3/01-data-generation/01-make-v3.py).

### S2.3. Running the methods on simulated tissue

Four of the six comparison methods (CODA, STcompare, River and SpaceExpress in its paired mode) compare one section with one section. We therefore paired replicate $r$ of condition 1 with replicate $r$ of condition 2, ran each single-pair method on the three pairs and averaged its metrics. stORCA was run in the same single-pair mode so that the comparison isolates the score.

| Method | Input | Settings | Score used (larger = more change) |
|---|---|---|---|
| stORCA | One section pair | SysVI 400 epochs, batch 128, seed 42; partial transport with $\delta=0$; 50 matchings (seed 42); no Moran or denominator filter, all 120 genes scored | Clipped ROS; 0 when the summed denominator is at most $10^{-12}$ |
| CODA | One section pair | Published template, seed $41+r$ | Negative spatial cross-correlation index (CCI) |
| STcompare | One section pair | STalign on coordinates ($dx=1$, blur 1.5, 10,000 iterations, seed 42; transform reused for identical geometry); square raster of resolution 2 | Negative spatial correlation; separately, negative percent similarity |
| River | One section pair | 100 epochs, seed $41+r$ | Negative position in the final ranked list |
| SpaceExpress | One section pair | Paired model, 4 embedding dimensions, 100 epochs, spline degrees of freedom 300, seed $41+r$; genes flagged by its zero-variance check after outlier filtering removed | Negative FDR |
| DESpace2 | All three sections per condition | Simulated domain labels as the domain key, seed 42 | Quasi-likelihood $F$ statistic |

DESpace2 requires domain labels and uses replicate sections, so it was given the true domains and all six sections and contributes one ranking per scenario and strength. A uniform-marginal transport plan for stORCA was computed as a sensitivity check and is not shown in Figure 2 (AUROC within 0.03 of the partial plan at strength 1). Runner: [03-run-methods.py](../3-BM-DSE-Scenario-v3/03-run-methods.py); stORCA: [02-run-storca-1v1.py](../3-BM-DSE-Scenario-v3/02-run-storca-1v1.py).

### S2.4. Metrics on simulated tissue

**Detection (Figure 2b left, 2c).** Positives were the ten focal genes and negatives the 100 unchanged genes (domain and cell-type markers); decoys were left out. We computed AUROC, with half credit for ties, and average precision $\mathrm{AP}=\sum_j(R_j-R_{j-1})P_j$ over distinct thresholds, reported as AUPRC (positive fraction $10/110$).

**Global-shift specificity (Figure 2b right).** We computed AUROC of the ten focal genes against the ten decoys, and counted decoys and focal genes among the 15 highest-ranked of all 120 genes.

Each metric was computed per section pair and then averaged over the three pairs; DESpace2 contributes its single value. The heatmaps use $s=1$; the curves use all five strengths. Collector: [06-collect-v3.py](../3-BM-DSE-Scenario-v3/06-collect-v3.py); values: [v3-summary-by-strength.csv](../3-BM-DSE-Scenario-v3/res/v3-summary-by-strength.csv); panels: [02b-fig2-v3-synthetic-panels.py](02b-fig2-v3-synthetic-panels.py).

### S2.5. Implanted changes in human cortex

**Sections and design.** We used six LIBD DLPFC Visium sections from three donors with two sections each: 151507, 151669 and 151673 as controls and 151509, 151671 and 151675 as treated, in matching donor order. We kept the measured coordinates, the manual layer labels and the common 3,000-gene panel, and changed counts only in the three treated sections. Each donor therefore contributes one control and one treated section, and the comparison between conditions includes the real variation between sections of one donor and between donors.

**Genes.** From genes kept by the stORCA Moran filter on the unchanged sections and with mean count at least 0.2, we drew ten genes for each change and 20 decoys (seed 20261118). We used the ratio of a gene's largest layer mean to its section mean, averaged over the three treated sections. Genes with ratio at least 2 (strongly layered) received the amplitude and relocation changes, which need a laminar pattern to act on; genes with ratio below 1.5 received the layer-3 increase, half-layer increase and redistribution, so that the change is not hidden by an existing layer-3 pattern. Decoys were ten genes from each of the two strata (ratio at least 2, below 1.5). The same genes were used at all three levels. Truth table: [implant-truth-v2.csv](../1-BM-DSE-Semi-LIBD/res/implant-truth-v2.csv).

**Changes.** In each treated section, let $m_l$ be the gene's mean in layer $l$, $\bar m$ its mean over all spots, and A and B the two halves of layer 3. Levels 1, 2 and 3 used $(s,a,t)=(0.5,0.25,1/3)$, $(1,0.5,2/3)$ and $(1.5,0.75,1)$.

| Change (panel label) | Target mean in the treated section |
|---|---|
| Layer-3 increase (Domain DE) | $m_3\,e^{s}$ |
| Half-layer increase (Within shift) | Mean of half A of layer 3 times $e^{s}$ |
| Weaker laminar pattern (Amplitude) | Each layer: $\bar m+(1-a)(m_l-\bar m)$ |
| Relocation (Relocation) | Over the layers present in all donors (3, 4, 5, 6, white matter), layer $i$ receives $(1-t)\,m_i+t\,m_{(i+2)\bmod 5}$ |
| Redistribution within layer 3 (Pure shift) | $m'_B=(1-t)\,m_B$ and $m'_A=m_A+t\,m_B\,n_B/n_A$; the expected layer total is kept |
| Global shift (decoy) | Every layer: $m_l\,e^{s}$ |

The half-layer increase also raises the layer-3 mean, whereas the redistribution keeps it. The redistribution is therefore the change that a test of layer means cannot see.

**Same anatomy in every donor.** The two halves of layer 3 were defined by the first principal axis of the layer-3 spot coordinates, split at the median. To make half A the same anatomical half in all three donors, we rotated the vector from the white-matter centroid to the layer-3 centroid by 90 degrees and oriented the principal axis to point along this tangent. Relocation used one cyclic permutation over the five layers present in all donors, so that each layer received expression from the same source layer in every donor. An earlier version (imp3v2) flipped half A in one donor and permuted different layer sets across donors; Figure 2 uses the corrected version (imp3v3).

**Count operations.** To raise a group mean from $m$ to $m'$ we added independent Poisson counts with mean $m'-m$ to each spot; to lower it we thinned each count binomially with probability $m'/m$. Spots outside the changed groups and all control sections were untouched. The random generator was seeded with (20261121, section, level). Generator: [06-make-implant-v3.py](../1-BM-DSE-Semi-LIBD/06-make-implant-v3.py); targets and achieved means: [implant-targets-v3.csv](../1-BM-DSE-Semi-LIBD/res/implant-targets-v3.csv).

### S2.6. Running the methods on cortex implants

**stORCA.** stORCA used the replicate design of the main Methods on nine between-condition and six within-condition pairs (SysVI 400 epochs, batch 128; ROS clipped to $[0,2]$; Moran and denominator filter; within-condition thinning by source-cell availability; limma with variance trend; one-sided test). Genes were ranked by the moderated $t$ statistic of the between-condition effect, and calls were made at one-sided BH-adjusted $P<0.05$. We also refitted the contrast for the nine reassignments of whole sections that differ from the true grouping.

**Comparison methods.** Each method was run at its published defaults. CODA (seed 42), River (100 epochs, seed 42), SpaceExpress (4 embedding dimensions, 100 epochs, spline degrees of freedom 300, seed 42) and STcompare (square raster of resolution 310, seed 42) were run on each of the nine between-condition pairs, and their oriented scores were averaged over the pairs. Because implants change counts but not coordinates, STcompare reused one coordinate-only STalign transform per pair across levels. DESpace2 (seed 42) was run once per level on all six sections, with the manual layer labels as the domain key. These are the same labels from which the implanted regions were defined, so DESpace2 is given the exact domains of four of the five changes. Runner: [07-run-imp3v3.py](../1-BM-DSE-Semi-LIBD/07-run-imp3v3.py).

### S2.7. Metrics on cortex implants

All methods were evaluated on the same genes: those tested by stORCA at each level (664, 642 and 588 genes at levels 1, 2 and 3). The Moran filter does not use condition labels, and the evaluated set contained all 50 implanted genes at levels 1 and 2 and 49 at level 3, and all 20 decoys at every level. A method was reported at a level when it had finite scores for at least 50 genes; SpaceExpress fits flagged by its zero-variance check, and FDR values of exactly 0, which the implementation returns as a sentinel for such fits, were set to missing.

| Metric | Positives | Negatives | Panel |
|---|---|---|---|
| AUROC and AP per change type | Ten genes of that type | Unchanged genes (not implanted, not decoys) | 2d left, 2e |
| Overall AUROC and AP | All implanted genes | All other genes, including decoys | 2d right |
| AUROC against decoys | All implanted genes | The 20 decoys | 2d right |
| Top-50 composition | Implanted genes and decoys counted among the 50 highest-ranked genes | | Supplementary Fig. S2 |

For stORCA we also counted calls among implanted genes, unchanged genes and decoys, and the largest number of calls over the nine reassignments. Collector: [08-collect-imp3v3.py](../1-BM-DSE-Semi-LIBD/08-collect-imp3v3.py); values: [imp3v3-summary-metrics.csv](../1-BM-DSE-Semi-LIBD/res/imp3v3-summary-metrics.csv); panels: [02d-fig2-dlpfc-imp3v3-panels.py](02d-fig2-dlpfc-imp3v3-panels.py).

### S2.8. Scope of the two benchmarks

The simulated benchmark compares stORCA with single-pair methods on single section pairs, so it tests the score, not the replicate design. The cortex benchmark tests the full replicate design on three sections per condition. Implanted genes were drawn from genes with measurable spatial structure, and performance describes recovery among such genes. DESpace2 received the true domains in both benchmarks; in real data domains must be estimated, so its results here are an upper bound for a domain test. At implant levels 1 and 2 stORCA made no call, because these changes did not exceed the difference between sections of the same condition from different donors at three sections per condition.
