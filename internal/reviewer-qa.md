# Reviewer Q&A

## 1. Figure 2: cortex implants (DLPFC)

### Q1. Layer enrichment in selected unpatterned genes

**Reviewer concern.** Seven of the 40 implanted genes (*MAN1A2*, *GLUL*, *NCL*, *HLA-C*, *NCOR1*, *H3F3B*, *FTL*) have a layer enrichment with *q* < 0.05, so they are not free of layer structure.

**Response.** The selection rule is an effect size, absolute log2 fold change below 0.5 in every layer, and these seven are all at 0.49 or less (Supplementary Methods S2.5). The implanted base pattern is 1.44 on the log2 scale and the weakest change (*s* = 0.5) is 0.72, so the existing difference is small next to what was implanted (Fig. 2d, e; Supplementary Fig. 5, 6).

### Q2. Supplying manual layer labels to DESpace2

**Reviewer concern.** DESpace2 is given the manual layer labels from which the implanted regions were defined.

**Response.** DESpace2 requires domain labels and was run as published with the annotations it would receive in practice (Supplementary Methods S2.6). Because those annotations directly define four of the implant geometries, DESpace2's layer-DE and amplitude metrics serve as an upper bound for a domain test (Fig. 2d; Supplementary Methods S2.8). The within shift stays inside layer 5 and preserves the layer mean, so the true labels do not help it there.

### Q3. DESpace2 BiocParallel numerical errors

**Reviewer concern.** DESpace2 logs show BiocParallel errors (`NA/NaN/Inf in foreign function call`) for some genes.

**Response.** This occurs when DESpace2 runs at its default settings on these Visium sections and matches behavior observed across earlier cortex runs (Supplementary Methods S2.6). Any gene whose model fit fails receives no score and is omitted from DESpace2's evaluated gene metrics, while all benchmark runs completed without stalling (Fig. 2d, e).

### Q4. Patchy IGKC expression in plasma cells

**Reviewer concern.** *IGKC*, a within-shift gene, has patchy expression from plasma cells, so its maps do not look like a clean layer band.

**Response.** *IGKC* was chosen strictly by the pre-specified selection rule as one of the ten unpatterned genes with the highest mean count, not selected visually (Supplementary Methods S2.5). Because those plasma-cell patches appear in both control and treated sections, and the within shift strictly transfers layer-5 counts from the superficial half to the deep half (Supplementary Fig. 5, 6), the focal condition difference resides cleanly inside layer 5.

### Q5. Reusing STalign coordinate transforms in STcompare

**Reviewer concern.** STcompare reuses STalign transforms computed for an earlier version of the benchmark.

**Response.** The STalign registration step operates strictly on spatial coordinates, while the semi-synthetic implants modify gene counts without moving or filtering spots (Supplementary Methods S2.6). Across all six Visium sections (Fig. 2d, e), we verified that spot barcodes, coordinates, and total spot counts match the transform inputs identically.

### Q6. Unpatterned decoys in cortex versus patterned decoys in simulation

**Reviewer concern.** Decoys (global shift) were drawn only from unpatterned genes; on a layered gene a uniform fold change is not removed exactly by log1p centering, so cortex may hide a weakness.

**Response.** We drew cortex decoys from unpatterned genes so that the global shift acts as a pure change in overall level and the only layer structure belongs to the focal implants (Fig. 2d; Supplementary Methods S2.5). Patterned decoys are tested directly in the simulated benchmark where every decoy marks a full domain (Supplementary Methods S2.2), and at *s* = 1.0 stORCA achieves AUROC 0.94 against decoys versus 0.00 for River and STcompare percent similarity (Fig. 2b; Supplementary Fig. 2; Supplementary Methods S2.4).

## 2. Statistical design and ROS properties

### Q7. Clipping ROS to [0, 2] and Moran filtering

**Reviewer concern.** Isn't clipping ROS to $[0,2]$ ad hoc, or filtering genes at Moran *I* > 0.03 arbitrary?

**Response.** Zero-diagonal Moran weights exclude single-cell self-weight shot noise at the cost of slight indefiniteness, whereas direct substitution of a naturally $[0,2]$-bounded PSD lag operator $W^\top W$ injects shot noise back into both numerator and denominator and eliminates real calls in HPOA (11 to 0) and NRDR (32 to 0) (Methods). `Moran I > 0.03` is label-free independent filtering that excludes genes without baseline spatial structure before condition labels enter, and clipping preserves 94% to 100% of calls while bounding small-denominator extremes (Fig. 5b).

### Q8. Directional asymmetry in forward versus reverse projections

**Reviewer concern.** Why can forward ($A\to B$) and reverse ($B\to A$) projections call different genes, for instance in HPOA?

**Response.** Under registration-free soft transport, projecting target expression onto a reference cell graph introduces intrinsic variance attenuation ($\alpha^2 < 1$), so $A\to B$ tests loss of condition-$A$ spatial patterns (11/11 calls with `naive > aggr`) while $B\to A$ tests emergence of condition-$B$ patterns (17/20 calls with `aggr > naive`) (Methods). Both directions remain null-calibrated under sample-label permutation (`null_max = 0`), and users can inspect either direction or combined bidirectional *P* values (Fig. 3, Fig. 5b).

### Q9. Non-independence of section pairs in 3 vs 3 replicate designs

**Reviewer concern.** A 3 vs 3 replicate design gives only 9 false labelings and correlated pairs.

**Response.** A 3 vs 3 design matches standard spatial transcriptomics replicate cohorts and is complemented by replicate-scaling checks across 2 vs 2, 3 vs 3, and 6 vs 6 sections plus consistency across four to six real datasets (Methods). Primary statistical inference uses empirical Bayes variance moderation in limma rather than permutation calibration alone, and exhaustive section-label swaps show zero false-positive inflation on LIBD, HPOA, NRDR, and DLPFC implant levels L1 to L3 (Fig. 2d; Fig. 3).

### Q10. Lesion-only marker fractions in Cortex 3 dpi versus Colitis

**Reviewer concern.** In Cortex 3 dpi, CODA and stORCA show closer lesion-only marker fractions than in Colitis.

**Response.** In Cortex 3 dpi, reactive glial transcripts genuinely elevate across intact tissue outside the lesion boundary (`shared` markers), whereas in Colitis D0 versus D9 an entire epithelial compartment is lost at day 9 and registration/domain competitors fill their top rankings with unmatched epithelial markers across all 9 section pairs (Fig. 4a, b, c).

## 3. Benchmark cohorts and robustness

### Q11. Partial OT dummy-cell exclusions on added tissue

**Reviewer concern.** Partial OT's zero-cost dummy cell can drop intact source cells when target tissue gains a novel compartment.

**Response.** This behavior reflects matching only shared biological mass $\min(\sum a_i, \sum b_j)$ without forcing false geometric distortion (Methods). stORCA exports per-cell retained mass $r_i$ and spatial retention maps so investigators inspect unmatched regions directly (Fig. 4a, b).

### Q12. Shared SysVI hyperparameters across datasets

**Reviewer concern.** SysVI hyperparameters (`prior = "vamp"`, `kl_weight = 1`, `z_distance_cycle_weight = 5`) might appear tuned per dataset.

**Response.** `prior = "vamp"` is the scvi-tools default and `kl_weight = 1`, `z_distance_cycle_weight = 5` come verbatim from the official scvi-tools SysVI tutorial, applied identically without dataset-specific hyperparameter tuning across all synthetic and real benchmarks (Methods).

### Q13. Monte Carlo stability across 50 stochastic matchings

**Reviewer concern.** Reusing one thinning seed and drawing 50 stochastic matchings introduces Monte Carlo variance.

**Response.** Across cohorts, empirical resampling variance across stochastic matching seeds is 26- to 155-fold smaller than biological replicate variance across sections (Fig. 3c), making matching-seed fluctuations negligible relative to limma between-versus-within testing (Methods).

### Q14. Exclusion of time-course cohorts from main two-condition claims

**Reviewer concern.** Time-course cohorts are excluded from the main two-condition claims.

**Response.** Developmental and regeneration time courses exhibit 2- to 3-fold shifts in total sequencing depth and non-monotonic effect magnitudes when gross tissue morphology reorganizes, so the primary claims focus on well-posed pairwise condition comparisons where replicate variance baselines hold cleanly (Fig. 5b; Methods).
