# Methods: stORCA

Main-text Methods for the stORCA algorithm, written in the project manuscript
style (`.claude/skills/manuscript-style/SKILL.md`). It replaces the algorithm
sections (2 to 4) of `0-method-v3.md`; the dataset and case-study sections of
that file are unchanged. Panel-level settings for Figure 2 are in the
Supplementary Methods ([English](0-method-v4-supplementary.md) · [한국어](0-method-v4-supplementary.ko.md)).

## Overview

stORCA tests whether the spatial pattern of a gene differs between two conditions by more than it differs between sections of the same condition. For each pair of sections, it learns a shared cell state, matches cells that have a counterpart in the other section, and measures how much of a gene's spatial structure the two sections do not share. We call this measure the residual-to-original spatial ratio (ROS). With replicate sections, stORCA compares ROS on between-condition pairs with ROS on within-condition pairs and tests the excess gene by gene. We describe cells throughout; for Visium, a spot takes the place of a cell.

## Expression input

For each section we kept native coordinates and the measured gene panel; for sequencing-based assays we used 3,000 highly variable genes chosen with section as the batch (Methods, Datasets). Two transformations serve two purposes. To learn cell states, we normalized each cell to $10^4$ total counts over the genes shared by the pair and applied $\log(1+\cdot)$. To score a gene, we returned to its raw measurement $Y_{ig}$, applied $\log(1+Y_{ig})$ within each section and capped positive values at their 95th percentile, keeping zeros. The cap limits the leverage of a few very high measurements on a spatial quadratic form. Keeping the two transformations separate means that the gene being scored is compared on its own measured scale, while its tissue context is inferred from the whole panel.

## Learning a shared cell state for each pair

For each ordered source and target pair, we fitted a cross-system variational inference model (SysVI) to the normalized expression of both sections, with section of origin as the system covariate. A section covariate lets the decoder absorb measurement differences between sections, so that the 15-dimensional latent state describes cell state on a scale shared by both sections. The encoder and decoder each had two hidden layers of 256 units with batch normalization, rectified linear units and dropout 0.1, and received the section label at every hidden layer. Training minimized a Gaussian reconstruction loss, a Kullback–Leibler term against a five-component VampPrior and a cycle-consistency term with weight 5 that penalizes a change in the encoded state when the section label is switched. We trained for 400 epochs with batches of 128 cells, Adam (learning rate $10^{-3}$, weight decay $10^{-6}$) and seed 42, and used the posterior mean $\mu_i$ of every cell. Spatial coordinates are not used in training; they enter only when neighborhoods are built below. Supplementary Note S1 gives the loss terms as implemented in scvi-tools 1.4.2.

## Matching tissue with partial optimal transport

Two cells should be matched only when both the cell and the tissue around it agree. For each cell we averaged the latent means of its 20 nearest cells in its own section, including itself, to obtain a neighborhood vector $\nu_i$. After scaling $\mu_i$ and $\nu_i$ to unit length, we combined their cosine dissimilarities $d(v,w)=[1-\cos(v,w)]/2$ into one cost,

$$
C_{ij}=1-\bigl(1-d(\mu_i,\mu_j)\bigr)\bigl(1-d(\nu_i,\nu_j)\bigr),
$$

which is low only when the focal states and their neighborhoods are both similar. All physical distances are computed within a section, so the two sections keep their own origin and orientation and no registration is needed.

Some cells have no counterpart, for example tissue that is lost or gained between conditions. We estimated where this happens from the local balance of the two sections in the latent space, independently of the cost. Among the 50 nearest cells of each cell in the pooled latent space, we counted source and target cells $(c_s,c_t)$, formed $\ell=\log[(c_t+0.5)/n_t]-\log[(c_s+0.5)/n_s]$ for section sizes $n_s,n_t$, and averaged $\ell$ over the cell and the same 50 neighbors to obtain $\bar\ell$. Because sections of the same condition are also imbalanced to some degree, we set a tolerance $\delta$ as the 95th percentile of $|\bar\ell|$ over the cells of all within-condition pairs of a study, and only an imbalance beyond $\delta$ reduces a cell's capacity:

$$
a_i=\frac{\min\bigl(1,e^{\bar\ell_i+\delta}\bigr)}{n_s},\qquad
b_j=\frac{\min\bigl(1,e^{-\bar\ell_j+\delta}\bigr)}{n_t}.
$$

We transported the smaller of the two total capacities, placing a zero-cost dummy node on the side with less capacity, and solved the entropy-regularized problem with Sinkhorn scaling ($\varepsilon=0.02$). After removing the dummy couplings, the plan $\Pi$ gives each source cell a retained fraction $r_i=n_s\sum_j\Pi_{ij}$ and a distribution of partners $\Pi_{ij}/\sum_k\Pi_{ik}$; target cells have the analogous fraction $r'_j=n_t\sum_i\Pi_{ij}$. In a single-pair analysis without replicate sections, we set $\delta=0$.

## Sampling correspondences and the source graph

A transport plan is a distribution over matches, not a single match. We therefore drew 50 matchings from each plan. In each matching, source cell $i$ was kept with probability $r_i$ and given one target partner drawn from its row of the plan; the same matchings were used for every gene. We built one spatial graph on the source section, connecting each cell to its ten nearest cells with weight $\exp[-d_{ij}^2/(2\sigma^2)]$, where $\sigma$ is the median neighbor distance. We symmetrized the weights, set the diagonal to zero and normalized each row to sum to one. For matching $m$, $W_m$ is this graph restricted to the kept source cells, with the original weights retained. The matched target expression is placed on the same source cells, so that both expression fields are compared on one neighborhood system.

## The residual-to-original spatial ratio (ROS)

For one gene and matching $m$, let $x_m$ be the transformed source expression on the kept cells and $y_m$ the transformed expression of their sampled partners. With $\tilde v$ the vector $v$ centered on the kept cells, define the spatial quadratic form $q_m(v)=\tilde v^\top W_m\tilde v$, which is large when neighboring cells deviate from the mean in the same direction. Pooling over matchings,

$$
\mathrm{ROS}=\frac{\sum_m q_m(x_m-y_m)}{\sum_m\bigl[q_m(x_m)+q_m(y_m)\bigr]} .
$$

The numerator is the spatial structure of the matched difference, and the denominator is the spatial structure of the two expression fields themselves. ROS is 0 when the two fields have the same pattern and the same strength, 1 when they share no spatial structure, and 2 when the patterns are reversed. Three properties follow from this form. First, centering removes any change that is the same in every cell on the scoring scale, so a global shift does not raise ROS. Second, ROS responds to amplitude: if $y=ax$, the spatial correlation of the two fields is 1 but $\mathrm{ROS}=(1-a)^2/(1+a^2)$, which is 0.2 for a doubling. Third, ROS scales the residual by the structure of the original fields rather than by its own variance, as Moran's $I$ of the residual would; a weak residual and a strong residual of the same shape therefore receive different scores. Because $W_m$ has a zero diagonal and can have negative eigenvalues, a finite raw ROS can fall slightly outside $[0,2]$; for replicate inference we clipped it to that interval.

## Separating pattern and amplitude

ROS factors into a pattern term and an amplitude term. Writing $A=\sum_m q_m(x_m)$, $B=\sum_m q_m(y_m)$ and $C=\sum_m\tilde x_m^\top\tfrac12(W_m+W_m^\top)\tilde y_m$, the numerator equals $A+B-2C$ and, for $A,B>0$,

$$
1-\mathrm{ROS}=\rho_W\,\kappa,\qquad
\rho_W=\frac{C}{\sqrt{AB}},\qquad
\kappa=\frac{2\sqrt{AB}}{A+B}.
$$

$\rho_W$ is a spatially weighted correlation of the two patterns, and $\kappa$ equals 1 when the two patterns have the same spatial strength and decreases as their strengths diverge; $h=\tfrac12\log(B/A)$ gives the direction. With identity weights, the product is Lin's concordance correlation of the two centered profiles, and $\rho_W$ is Pearson correlation. We use this factorization to describe the type of a change (Figure 5); it does not enter the test.

## Testing condition effects across replicate sections

A difference between two sections of different conditions includes the difference between any two sections, which replicate sections of one condition already show. The replicate design measures this baseline directly. We scored every between-condition pair in the control-to-treated direction and every within-condition pair once, so three sections per condition give nine between-condition and six within-condition pairs.

Within-condition pairs can share tissue that has no counterpart in the other condition, which would make the baseline look more similar than it should. To compare like with like, we averaged each cell's retained fraction over all of its between-condition partners and used this availability as the probability of keeping the cell in within-condition matchings. We then recomputed the restricted graphs and quadratic forms. In the analyses of Figures 2, 3 and 5 the availability of the source cell was used; in the injury comparisons of Figure 4 we used the smaller of the availabilities of the source cell and its sampled partner (Supplementary Note S4).

We tested genes with spatial structure that the pairs can measure. A gene first needed Moran's $I>0.03$ on at least one section graph, a filter that does not use condition labels. For each pair and matching, we standardized the denominator $D_m=q_m(x_m)+q_m(y_m)$ by its standard deviation under independent random signs of the centered values,

$$
V_m(v)=\sum_{i<j}\bigl(w^{(m)}_{ij}+w^{(m)}_{ji}\bigr)^2\tilde v_i^2\tilde v_j^2,\qquad
z_m=\frac{D_m}{\sqrt{V_m(x_m)+V_m(y_m)}} ,
$$

and called a gene evaluable in a pair when neither section was constant and the minimum $z_m$ over the 50 matchings was at least 1. We tested genes evaluable in at least 60% of pairs, using their finite scores from all pairs.

For gene $g$ and pair $p$, we fitted the clipped ROS $T_{gp}$ with

$$
T_{gp}=\alpha_g+\beta_g B_p+\gamma_g H_p+\epsilon_{gp},
$$

where $B_p=1$ for between-condition pairs. With unequal group sizes we added $H_p$ ($-\tfrac12$ within the first group, $+\tfrac12$ within the second, 0 between), so that $\beta_g$ compares between-condition pairs with the equally weighted mean of the two within-condition groups. With only a few pairs per gene, gene-wise variances are unstable, and their size depends on how much spatial structure a gene has. We therefore moderated them with the limma empirical Bayes procedure with a variance trend on the mean log median $z_m$. We tested $\beta_g>0$ one-sided, because only an excess of the between-condition difference over the replicate difference is evidence of a condition effect, applied Benjamini–Hochberg correction across tested genes and called genes at adjusted $P<0.05$. Each pair had equal weight.

Section pairs share sections, so they are not independent. To check that calls depend on the condition labels and not on the particular sections, we refitted the contrast for every reassignment of whole sections to two groups of the original sizes (ten distinct partitions for three against three, including the true one), keeping plans, thinning and gene eligibility fixed.

## Single-pair scoring

When only one section per condition is compared, as for the simulated benchmark of Figure 2, there is no within-condition baseline. We then ranked all genes by the clipped ROS of that pair, with $\delta=0$, 50 matchings and no gene filter, so that every method was evaluated on every gene.

## Benchmarks and comparison methods

For Figure 2 we generated simulated tissues with six designed changes and implanted five designed changes into human DLPFC sections; Supplementary Methods S2 gives the generators, parameters, truth sets and metrics. We ran each comparison method as published, with its default settings. CODA ranked genes by the negative spatial cross-correlation index after its registration; STcompare registered coordinates with STalign, rasterized expression on a common grid and gave two rankings, spatial correlation and percent similarity; River ranked genes by their attribution in a network that predicts condition from expression and position; SpaceExpress tested condition-by-embedding interactions with natural splines; DESpace2 tested differential domain patterns with the supplied domain labels, replicate identifiers and conditions. We oriented every score so that a larger value meant more change. For pairwise methods in a replicate design, we averaged the oriented score over the between-condition pairs.

## Software

stORCA used Python 3.11, scvi-tools 1.4.2, PyTorch 2.8.0, Scanpy 1.11.5 and AnnData 0.12.6, with the transport scaling in double precision and a Python implementation of the limma empirical Bayes procedure. The code stores the transport marginals, sampled matchings and per-matching quadratic forms, so that every pair score and its decomposition can be recomputed without refitting a model. [Replicate analysis](../storca/replicate_case_studies.py) · [Scoring](../storca/scoring.py) · [Variance moderation](../storca/limma.py) · [Decomposition](../storca/interpret.py)
