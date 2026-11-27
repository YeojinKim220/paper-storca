# Supplementary Methods

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

**Replicates and seeds.** For each scenario and strength we generated three sections per condition. Gene parameters were shared across strengths, conditions and replicates (base seed 20261124, offset by scenario). Cell-type assignments, cell-level noise and count sampling had their own seeds per scenario, replicate and condition, and these seeds were reused across strengths, so that the strength series differs only in $s$.

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

DESpace2 requires domain labels and uses replicate sections, so it was given the true domains and all six sections and contributes one ranking per scenario and strength. A uniform-marginal transport plan for stORCA was computed as a sensitivity check and is not shown in Figure 2 (AUROC within 0.03 of the partial plan at strength 1).

### S2.4. Metrics on simulated tissue

**Detection (Figure 2b left, 2c).** Positives were the ten focal genes and negatives the 100 unchanged genes (domain and cell-type markers); decoys were left out. We computed AUROC, with half credit for ties, and average precision $\mathrm{AP}=\sum_j(R_j-R_{j-1})P_j$ over distinct thresholds, reported as AUPRC (positive fraction $10/110$).

**Global-shift specificity (Figure 2b right).** We computed AUROC of the ten focal genes against the ten decoys, and counted decoys and focal genes among the 15 highest-ranked of all 120 genes.

Each metric was computed per section pair and then averaged over the three pairs; DESpace2 contributes its single value. The heatmaps use $s=1$; the curves use all five strengths.

### S2.5. Implanted changes in human cortex

**Sections and design.** We used six LIBD DLPFC Visium sections from three donors with two sections each: 151507, 151669 and 151673 as controls and 151509, 151671 and 151675 as treated, in matching donor order. We kept the measured coordinates, the manual layer labels and the common 3,000-gene panel, and changed only the counts of 40 selected genes. Each donor therefore contributes one control and one treated section, and the comparison between conditions includes the real variation between sections of one donor and between donors. We implanted the three spatial changes and the global shift of the simulated benchmark (Supplementary Methods S2.2), with cortical layers in the role of domains and the same log-scale strengths $s\in\{0.5,1,1.5,2\}$ (levels 1 to 4).

**Genes.** We started from the genes kept by the stORCA Moran filter on the unmodified sections, without mitochondrial and ribosomal protein genes (MT-, RPS and RPL; 1,061 genes), and kept those with mean count at least 0.3 over the spots of the layers present in all six sections (layers 3 to 6 and white matter; 191 genes). For each gene we measured layer enrichment as in the pseudobulk analysis of [Maynard et al., 2021](https://doi.org/10.1038/s41593-020-00787-0): in each section we summed counts per layer, converted the sums to log2 counts per million, and took the difference between one layer and the mean of the other layers; this log2 fold change was averaged over the six sections. We used only genes without a layer pattern, defined as an absolute log2 fold change below 0.5 in every layer (77 genes). With unpatterned genes, the only layer structure in an implanted gene is the one we placed, and a global shift cannot change the visible contrast of an existing pattern. The ten unpatterned genes with the highest mean count received the within-layer shift, because the shift moves existing counts and needs enough of them to move. A random draw from the remaining genes (seed 20261126) gave ten genes each for the amplitude change, the layer DE change and the global shift. Amplitude genes were assigned in turn to layers 3, 4, 5 and 6, the cortical layers present in every donor (three, three, two and two genes). The same genes were used at all four levels.

**Base patterns in both conditions.** In the simulated benchmark every changed gene already has a spatial pattern in both conditions, and the amplitude and within-domain changes act on that pattern. We therefore first gave amplitude and within-shift genes a layer pattern in all six sections: each spot of the gene's layer (its assigned layer for amplitude genes, layer 5 for within-shift genes) had its expected count scaled by $e^{1}$. The base was drawn once per section and used at every level, so the control sections are the same at all levels. Layer DE genes and decoys had no base pattern.

**Changes.** In each treated section, on top of the base, let $m_5$ be the gene's mean in layer 5, and $m_A$ and $m_B$ the means of the deep and superficial halves of layer 5, with $n_A$ and $n_B$ spots.

| Change (panel label) | Treated section | Simulated counterpart |
|---|---|---|
| Layer DE | Layer-5 mean raised to $m_5\,e^{s}$ | Domain DE |
| Within shift | $m'_B=(1-t)\,m_B$ and $m'_A=m_A+t\,m_B\,n_B/n_A$, with $t=1-e^{-s}$; the expected layer-5 total is kept | Within-domain shift |
| Amplitude change | Each spot of the assigned layer scaled by $e^{s}$, so the base pattern rises from $e^{1}$ to $e^{1+s}$ | Amplitude increase |
| Global shift (decoy) | Every spot scaled by $e^{s}$ | Decoys |

With $t=1-e^{-s}$ the superficial half falls by $s$ on the log scale ($t=0.39$, 0.63, 0.78 and 0.86 at levels 1 to 4), matching the $+s$ of the simulated shift. The within shift keeps the layer-5 mean, so a test of layer means cannot see it, whereas the layer DE change raises the layer-5 mean.

**Same anatomy in every donor.** We placed the layer DE change and the within shift in layer 5 because it is present in all sections of the three donors, whereas layers 1 and 2 are missing in one donor. The depth of a layer-5 spot was its distance to the nearest layer-4 spot, and the deep half consisted of the spots with depth above the median. The shift therefore moves expression toward layer 6 in every section, with no orientation step.

**Count operations.** To scale the expected count of a spot by a factor $f>1$, we added a Poisson count with mean $(f-1)\,x$ to its observed count $x$; scaling every spot of a region in this way keeps the shape of the pattern within it. To raise a group mean from $m$ to $m'$ (layer DE, deep half), we added independent Poisson counts with mean $m'-m$ to each spot; to lower it (superficial half), we thinned each count binomially with probability $m'/m$. Spots outside the changed regions and genes outside the 40 selected were untouched, and control sections carried only the base patterns. The random generator was seeded with (20261126, section, 0) for the base and (20261126, section, level) for the changes.

### S2.6. Running the methods on cortex implants

**stORCA.** At each of the four levels, stORCA used the replicate design of the main Methods (Methods) on nine between-condition and six within-condition pairs (SysVI 400 epochs, batch 128; ROS clipped to $[0,2]$; Moran and denominator filter; within-condition thinning by source-cell availability; limma with variance trend; one-sided test). Genes were ranked by the moderated $t$ statistic of the between-condition effect, and calls were made at one-sided BH-adjusted $P<0.05$. We also refitted the contrast for the nine reassignments of whole sections that differ from the true grouping.

**Comparison methods.** Each method was run at its published defaults. CODA (seed 42), River (100 epochs, seed 42), SpaceExpress (4 embedding dimensions, 100 epochs, spline degrees of freedom 300, seed 42) and STcompare (square raster of resolution 310, seed 42) were run on each of the nine between-condition pairs, and their oriented scores were averaged over the pairs. Because implants change counts but not coordinates, STcompare reused one coordinate-only STalign transform per pair across levels. DESpace2 (seed 42) was run once per level on all six sections, with the manual layer labels as the domain key. These are the labels from which the implanted regions were defined, so DESpace2 is given the exact layer of the layer DE and amplitude changes; the within shift stays inside layer 5 and keeps its mean.

### S2.7. Metrics on cortex implants

All methods were evaluated on the same genes: those tested by stORCA at each level (664, 642 and 588 genes at levels 1, 2 and 3). The Moran filter does not use condition labels, and the evaluated set contained all 50 implanted genes at levels 1 and 2 and 49 at level 3, and all 20 decoys at every level. A method was reported at a level when it had finite scores for at least 50 genes; SpaceExpress fits flagged by its zero-variance check, and FDR values of exactly 0, which the implementation returns as a sentinel for such fits, were set to missing.

| Metric | Positives | Negatives | Panel |
|---|---|---|---|
| AUROC and AP per change type | Ten genes of that type | Unchanged genes (not implanted, not decoys) | 2d left, 2e |
| Overall AUROC and AP | All implanted genes | All other genes, including decoys | 2d right |
| AUROC against decoys | All implanted genes | The 20 decoys | 2d right |
| Top-50 composition | Implanted genes and decoys counted among the 50 highest-ranked genes | | Supplementary Fig. S2 |

For stORCA we also counted calls among implanted genes, unchanged genes and decoys, and the largest number of calls over the nine reassignments.

### S2.8. Scope of the two benchmarks

The simulated benchmark compares stORCA with single-pair methods on single section pairs, so it tests the score, not the replicate design. The cortex benchmark tests the full replicate design on three sections per condition. Implanted genes were drawn from genes with measurable spatial structure, and performance describes recovery among such genes. DESpace2 received the true domains in both benchmarks; in real data domains must be estimated, so its results here are an upper bound for a domain test. At implant levels 1 and 2 stORCA made no call, because these changes did not exceed the difference between sections of the same condition from different donors at three sections per condition.
