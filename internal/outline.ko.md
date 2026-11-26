# Nature Communications 투고를 위한 stORCA 논문 구성안

최종 수정: 2026-11-20 (4차 수정: 모든 figure의 상태를 동결된 v4 파이프라인과 2026-11-19에 끝난 결과, 즉 동물 효과를 넣은 synthetic v2 시나리오와 LIBD implant 벤치마크에 맞춤; triage는 15절). 2026-11-20 오후 추가: synthetic v2 시나리오 11개 중 6개의 경쟁 방법 지표, LIBD implant의 모든 경쟁 방법과 decoy, HPOA pattern swap, 실행 시간과 메모리, 6 vs 6 거짓 labeling의 원인 ("2026-11-20 오후"로 표시). 2026-11-20 저녁 추가: claim 5 (하나의 척도, Figure 6)를 보류하여 논문의 claim은 4개다. 이전: 2026-11-18 (질문 하나, 진짜 변화 대 그렇게 보일 뿐인 변화; 1, 5, 6절을 새로 씀). 상태: 논의용 제안. 3, 4절과 7~12절은 군데군데 2026-11-10 framing을 따르며, Results 절이 합의되면 맞춘다.

가제 (제안): **stORCA separates real from apparent changes in spatial gene expression across replicate tissue sections**

이 구성안을 만들 때 읽은 자료: method 초안 [0-method-v2.md](0-method-v2.md), 이 폴더의 result 초안 `1-`~`4-result-*.md`, colitis 리포트 ([REPORT-paper-comparison.md](REPORT-paper-comparison.md), [REPORT-colitis-expanded.md](REPORT-colitis-expanded.md)), embryo 리포트 ([embryo-dse/REPORT-embryo-dse.md](embryo-dse/REPORT-embryo-dse.md)), 현재 파이프라인 검토 문서 [29-framework-review-reviewer-defense.md](../5-Case-Study-Colitis/29-framework-review-reviewer-defense.md)와 [pvalue-design-history.md](../5-Case-Study-Colitis/pvalue-design-history.md). 최근 case study (aging, axolotl, DLPFC, HPOA)의 결과 폴더는 열어보지 않았으므로 아래에서 상태를 "미확인"으로 표시했다.

## 1. Main claim

2026-11-18 수정. 논문은 질문 하나를 던진다: **두 조건을 비교할 때, 공간 유전자 발현의 변화는 조건 효과인가, 아니면 그렇게 보일 뿐인가?**

**우산 claim.** stORCA는 조건에 따른 공간 유전자 발현 변화를 검출하고, 기존 방법이 변화로 보고하는 두 가지 가짜와 구분한다. 하나는 replicate section 사이의 변동이고, 다른 하나는 다른 조건에 대응 조직이 없는 조직이다. 보고하는 변화마다 무엇이 바뀌었는지 (pattern 또는 amplitude)와 어디서인지로 유형을 붙인다.

| # | Claim | 한 줄 내용 | Figure | 현재 근거 |
|---|---|---|---|---|
| 1 | Score는 모든 종류의 변화를 본다 | ROS (1 빼기 spatial concordance)는 pattern 변화와 amplitude 변화에 모두 반응하고 global shift는 무시한다. Registration score (CODA, STcompare)는 amplitude 변화를, domain 검정 (DESpace2)은 amplitude 변화와 domain 안 이동을 놓친다. stORCA는 설계된 모든 유형에 순위를 매긴다 (LIBD implant에서 AUROC 0.85~1.00) | 2 | 아직: v4는 LIBD implant와 synthetic 6개 유형 중 4개에서 순위가 좋지만, 한 조건에서 구조가 없는 유전자를 gene rule이 뺀다 (경계 띠, domain 안 cell type DE; 15절 Fix 1). 2026-11-20 문구 변경: LIBD implant에서 River도 맹점이 없으므로 "유일한 방법"을 뺌 |
| 2 | 가짜 1: replicate 변동 | Single-pair 방법은 replicate section 두 장에서 유전자의 34~94%를 call한다. ROS와 replicate 설계 (between pair 빼기 within pair)는 조건이 없으면 call하지 않고 (LIBD 662개 중 0; LIBD implant: 어떤 level, 어떤 replicate 수에서도 거짓 call 없음), 조건 효과가 replicate 변동을 넘을 때 call한다 (HPOA 11, NRDR 32와 11, ARTISTA 113). 같은 설계를 경쟁 방법 score에 쓰면 ARTISTA의 River를 빼고 call은 0~3개다 | 3 | Q2 (v4), call이 있는 데이터셋 5개와 LIBD; fix 후 충분. 3 vs 3의 power는 크지 않다 (15절, Defend) |
| 3 | 가짜 2: 대응 조직이 없는 조직 | Partial plan은 대응 세포가 없는 세포를 매칭하지 않는다 (AUROC 0.89, 0.94). Replicate baseline을 양쪽에서 thinning하면 stORCA 상위 20개 중 그 조직의 marker는 0.20과 0.35 (base 0.11, 0.28)이고, CODA, STcompare, DESpace2는 0.50~0.70이다 | 4 | Q1 7절 (v4); region 형태로 잃거나 생긴 조직에 대해 충분. Synthetic 통제 실험: stORCA 쪽 완료 (probe를 낮게 매김), 경쟁 방법 쪽 미수집 |
| 4 | 무엇이 어디서 바뀌었나, DE 너머 | 모든 call에 pattern, amplitude, mixed 유형을 붙이고 조직 위에 보인다. Call 일부는 같은 설계에서 두 pseudobulk DE 검정 어느 쪽으로도 검출되지 않는다 (ARTISTA 113개 중 31, NRDR 32개 중 22; v4 표) | 5 | Q3, Q5 (v4 노트북 2026-11-19 재실행; 리포트는 아직 v3 숫자); 충분 |
| 5 | 보류: 비교를 가로지르는 하나의 척도 | $\Delta$는 비교끼리 견줄 수 있는 effect size다. 재생 time course에서 10~15 DPI에 가장 크다 | 6 | **보류** (2026-11-20 결정): 당분간 main claim에 넣지 않는다. Figure 6과 Q4는 그대로 둔다. 보류 전: Q4 (v4), fix 후 충분; synthetic 척도 확인은 모든 유형에서 성립하지는 않는다 (15절 Fix 4) |

Claim 1~4가 main claim이다: score는 여러 형태의 공간 변화를 찾고, 그것을 replicate 변동과 구분하고, 대응 조직이 없는 조직에 속지 않으며, DE 너머로 무엇이 어디서 바뀌었는지 말한다. Claim 5는 보류다 (2026-11-20). 행은 근거와 함께 남기고, 15절의 전체 상태에는 넣지 않는다.

**세 강점의 역할.**

| 강점 | 역할 | 이유 |
|---|---|---|
| Replicate 설계 | 뼈대 (Fig 3) | 근거가 가장 넓고 (데이터셋 6개, 기술 3종) 공격하기 가장 어렵다. Within pair는 정의상 replicate 변동이다 |
| 대응 세포가 없는 세포 | 차별점 (Fig 4) | Registration (CODA, STcompare)은 모든 위치에 대응점이 하나 있다고 가정하고, domain 검정 (DESpace2)은 한 구획이 사라지면 함께 움직이는 domain 수준을 비교한다. Partial plan은 그 가정을 하지 않는다 |
| Amplitude (ROS) | 측정 도구 (Fig 2, 5, 6) | Headline이 아니다. Replicate 설계가 call을 내게 하는 성질이고 (Q2 2c절), correlation이 놓치는 amplitude 변화를 잡고, call마다 유형을 준다 |

"Registration 불필요"와 "여러 platform에서 작동"은 headline claim이 아니라 귀결이자 근거다.

**"Uncertainty"를 headline에서 뺀 이유.**

- 이 논문의 Figure 3이 한 쌍 안의 matching 분산이 replicate 분산보다 26~155배 작다는 것을 보여준다 (Q2 3절). 제목에 "uncertainty-aware"가 있으면 "어떤 uncertainty이고, 얼마나 크며, 보정되어 있는가"라는 질문을 부르고, matching 쪽 답은 "작다"이다.
- 14절의 미결 이슈는 2번 의미 (세포에 대응 세포가 있는가)로 정리한다. 논문에서는 "대응 세포가 없는 세포"라고 부른다. Sampled matching은 claim이 아니라 score를 계산하는 방식으로 Methods에 남긴다.
- 두 가짜가 그 단어로 말하려던 내용을 그대로 말하고, 읽는 사람이 그림으로 떠올릴 수 있다.

## 2. Score: spatial concordance로서의 ROS

Source 그래프 위의 centered 이차형식을 $Q(v)=\tilde v^\top W \tilde v$, $Q(x,y)=\tilde x^\top \bar W \tilde y$로 쓰면

$$
\mathrm{ROS}=\frac{Q(x-y)}{Q(x)+Q(y)}=1-\frac{2\,Q(x,y)}{Q(x)+Q(y)} .
$$

Lin의 concordance correlation coefficient는 평균 차이를 제거하면 $2s_{xy}/(s_x^2+s_y^2)$이다. 따라서 $1-\mathrm{ROS}$는 공분산을 공간 가중 공분산으로 바꾼 concordance coefficient다. Concordance coefficient를 correlation 항과 scale 항으로 나누는 고전적 분해도 그대로 옮겨진다.

$$
1-\mathrm{ROS}=\rho_W\cdot C(\kappa),\qquad
\rho_W=\frac{Q(x,y)}{\sqrt{Q(x)\,Q(y)}},\qquad
C(\kappa)=\frac{2}{\kappa+1/\kappa},\quad \kappa=\sqrt{Q(x)/Q(y)} .
$$

$\rho_W$는 pattern 모양의 일치도, $C(\kappa)$는 pattern amplitude의 일치도다. 순수한 amplitude 변화 $y=a\,x$는 $\rho_W=1$, $\mathrm{ROS}=(1-a)^2/(1+a^2)$을 주며 method 초안과 같다.

| 통계량 | 비유 | 답하는 질문 | 한계 |
|---|---|---|---|
| Spatial cross-correlation (CODA, STcompare) | Pearson correlation | 패턴의 모양이 같은가? | 패턴이 절반으로 약해져도 1 |
| 차이에 대한 Moran's I | 존재 여부의 검정 | 차이가 공간적으로 조직되어 있는가? | 실제 section에서는 답이 항상 "예" (replicate에서 유전자의 92~96%); effect size가 아님 |
| ROS | 1 − concordance | 공간 구조 중 얼마가 공유되지 않는가? | 분해는 $Q(x),Q(y)>0$인 경우에만 보고 |

논문에서 쓰는 세 가지 귀결:

1. **CODA, STcompare와의 차별화**가 취향이 아니라 통계량의 성질이 된다.
2. **분해가 공짜로 따라온다**: 모든 call에 pattern 성분과 amplitude 성분이 붙는다 (claim 4).
3. **Replicate 설계가 통계량에서 나온다.** Concordance coefficient는 반복 측정 간 agreement를 재려고 만들어졌다. Within-condition pair는 replicate 간 baseline 불일치를, between-condition pair는 조건 간 불일치를 주고, $\Delta$는 그 초과분이다. 그래서 pair score에 대한 선형 모델이 자연스러운 추론이다.

글을 쓰기 전 확인할 것: colitis 노트북에서 이미 쓰는 ρκ 분해가 이것과 같은지; "spatial concordance"가 같은 통계량에 대해 다른 곳에서 쓰인 적이 없는지 (bivariate Moran, Lee's L은 관련 통계량이므로 인용해야 함).

## 3. 경쟁 구도

| 방법 | 게재처 | 필요 조건 | 통계량 | Matching uncertainty | Replicate 보정 | 변화의 종류 |
|---|---|---|---|---|---|---|
| River | Nat Commun 2025 | 비교 가능한 slice, condition 라벨 | Deep model의 attribution score | 없음 | 없음, 순위만 | 없음 |
| CODA | Nat Commun 2026 | Rigid + LDDMM registration | Alignment 후 spatial cross-correlation | 없음, 변형 하나 | 없음, 순위만 | 없음, amplitude를 못 봄 |
| STcompare | bioRxiv 2025 | 구조적으로 대응되는 조직, STalign, rasterization | Pixel correlation, fold-change similarity | 없음, 변형 하나 | 없음, single pair | 부분적, 별도의 검정 두 개 |
| DESpace2 | Bioinformatics 2026 | 샘플 간 공유되는 spatial domain | edgeR interaction | Domain을 주어진 것으로 취급 | 있음 | 없음 |
| SpaceExpress | bioRxiv 2024 (우리 랩) | 학습된 intrinsic 좌표계 | Spline interaction | 좌표를 주어진 것으로 취급 | 있음 | 없음 |
| stORCA | 본 연구 | Raw count와 native 좌표 | ROS (spatial concordance) | 있음, soft하고 partial한 plan에서 sampled matching | 있음 | 있음, pattern과 amplitude |

참고:

- Diffeomorphism에 의한 registration은 모든 위치에 정확히 하나의 대응점이 있다고 가정한다. 생기거나 사라지는 조직 (궤양, 손상 부위, 새로운 세포 집단)은 그 가정을 깬다. 이것이 claim 1의 구체적 대비이며, 새 cell type이 매칭을 받지 못하는 day 9 severe colitis 결과가 그 예시다.
- 리뷰어에 River, CODA, STcompare, DESpace 저자가 포함될 가능성이 높다. 각 방법을 같은 설정에서 권장 parameter로 돌려야 한다.
- SpaceExpress는 우리 랩의 방법이므로 baseline에 포함하고 관계를 명시한다. SpaceExpress는 학습 가능한 공유 좌표계가 필요하고, stORCA는 그것이 실패하는 조직을 대상으로 한다.

## 4. 비슷한 Nature Communications 논문들은 어떻게 했는가

이 절을 위해 읽은 것: SLAT (PMC 전문), CODA (게재 논문의 bioRxiv 전문), STcompare (bioRxiv 전문), River (abstract만, 논문 페이지 접근 불가), Squair et al. 2021 (abstract 수준). Stereopy와 scNiche (둘 다 Nat Commun 2025)는 검색에 나왔지만 읽지 않았다.

| 논문 | 그룹 | Main figure 수 | 논증의 형태 |
|---|---|---|---|
| SLAT, Nat Commun 2023 | Gao lab, Peking University | 4 | Architecture; 3개 technology에서 정확도와 runtime 벤치마크; technology와 modality를 넘는 heterogeneous alignment; 발달 case 1개 |
| River, Nat Commun 2025 | 저자 2명, Fudan | 미확인 | Simulation 후 서로 무관한 생물학적 맥락 4개 (embryo, 당뇨 testis, lupus spleen, 생존과 연관된 breast cancer) |
| CODA, Nat Commun 2026 | Fudan, Q. Nie가 senior 공저자 | 6 | Pipeline; global alignment 벤치마크; 5개 설정의 local alignment; 질환 case 1개 (artery); common-domain 추출; 4개 조직으로 일반화. 총 14개 데이터셋, gene score에 유의성 검정 없음 |
| STcompare, bioRxiv 2025 | Fan lab, JHU | 2 | Autocorrelation 하에서 false positive를 통제하는 simulation; replicate sanity check; kidney injury case 1개 |
| Squair et al., Nat Commun 2021 | Courtine lab (큰 그룹) | 미확인 | Replicate를 모델링하지 않는 single-cell DE가 수백 개의 false discovery를 만든다는 것을 보이고 pseudobulk로 해결 |

따라 할 만한 패턴:

1. **작은 그룹의 method 논문에서는 폭이 통화다.** 최소 3개 technology와 4개 이상의 조직. 우리는 이미 MERFISH, Xenium, Stereo-seq, Visium 데이터를 갖고 있다.
2. **간결한 본문.** Main figure 4~6개, figure당 claim 하나.
3. **같은 데이터의 기존 논문에 고정된 질환 case 1개.** 먼저 일치, 그다음 새로운 것.
4. **Runtime과 memory panel**이 모든 논문에 있다.
5. **Calibration 논증은 잘 통한다.** Squair et al.이 "기본 검정에 replicate baseline이 없어서 부풀려진다"의 선례다. 우리의 replicate 결과는 그 spatial pattern 버전이며 아직 발표되지 않았다.

이들 중 누구도 하지 않은 것: 실제 replicate에서 검증한 오류 통제, alignment 불확실성의 전파, 각 call의 유형별 해석, 단계별 ablation.

## 5. 제목과 abstract

**muscat 제목이 작동하는 방식.** "muscat detects subpopulation-specific state transitions from multi-sample multi-condition single-cell transcriptomics data" (Crowell et al., Nat Commun 2020)는 네 부분으로 되어 있다. 도구, 평이한 동사, 구체적이고 새로운 대상 ("subpopulation-specific state transitions", 통계량이 아니라 생물학적 대상), 그리고 분야가 무시해 온 데이터 설정 ("multi-sample multi-condition")이다. 아래 후보들은 이 모양을 지키고 논문의 질문을 대상 자리에 넣었다.

| # | 제목 | 단어 수 | 각 부분이 대응하는 곳 | 위험 |
|---|---|---|---|---|
| 1 (추천) | **stORCA separates real from apparent changes in spatial gene expression across replicate tissue sections** | 14 | "apparent" = 두 가짜, Fig 3과 4; "real" = 유형과 위치가 붙은 call, Fig 2, 5, 6; "replicate tissue sections" = 설계, muscat의 "multi-sample"에 해당 | "무엇을 기준으로 real인가?" Abstract 두 번째와 세 번째 문장이 답한다: replicate 변동을 넘고, 대응 조직이 없는 조직이 아니다 |
| 2 | stORCA detects condition-driven pattern and amplitude changes in spatial gene expression from multi-sample tissue sections | 15 | muscat에 가장 가깝고 세 강점을 모두 담는다 | 처음 읽을 때 "pattern and amplitude"는 전문 용어다. Fig 4가 빠진다 |
| 3 | stORCA detects spatial expression patterns that shift, strengthen or fade between conditions beyond replicate variation | 15 | 가장 생생하다: shift = pattern 변화, strengthen 또는 fade = amplitude 변화 | Fig 4가 빠진다 |
| 4 | Most spatial expression changes reported between conditions are replicate variation or tissue without a counterpart | 15 | Squair et al. 2021처럼 문제를 먼저 말한다 | 추천하지 않는다. Q2 1절은 HPOA에서만 모든 방법에 성립하므로 "most"는 보이지 않았다 |

기록으로 남기는 이전 제목: "Uncertainty-aware detection of differential spatial expression across conditions" (2026-11-10; 1절의 이유로 뺌), "stORCA separates condition-driven spatial expression changes from replicate variation and cells without counterparts" (2026-11-18 초안; 정확하지만 밋밋함).

**기존 연구를 분류하는 축** (introduction 2문단): 기존 방법은 두 가지를 주어진 것으로 둔다. 한 조직의 모든 위치에 다른 조직의 대응점이 있다 (registration, 공유 domain). 그리고 section 한 쌍이 조건 효과를 보여준다 (single-pair 검정과 순위). 두 가정은 각각 가짜를 call로 바꾼다.

**빠진 능력** (introduction 3문단): 기존 방법은 정렬된 두 section 사이에서 공간 pattern이 다른 유전자에 순위를 매길 수 있지만, 그 차이가 replicate section 사이의 차이보다 큰지, 아니면 대응 조직이 없는 조직에서 오는지는 가리지 못한다.

Abstract 골격 (저널 형식 150단어):

1. 필요: 질병, 손상, 발생은 조직 안에서 유전자가 어디에 발현되는지, 그리고 그 공간 pattern이 얼마나 뚜렷한지를 바꾼다. 조건 간 공간 전사체 비교는 이런 변화를 찾기 위한 것이다.
2. 한계: 두 가지 가짜가 변화로 보고된다. 한 조건의 replicate section은 이미 서로 다르고, 잃거나 새로 생긴 조직에는 대응 조직이 없다. 기존 방법은 section 한 쌍을 비교하고 모든 위치에 대응점이 있다고 가정한다.
3. 여기서 우리는 stORCA를 제시한다. stORCA는 유전자의 공간 구조 중 두 section이 공유하지 않는 몫을 재고, 대응 세포가 없는 세포를 비교에서 빼고, 조건 간 pair가 replicate pair를 넘는 몫을 검정한다.
4. 근거: 실제 replicate section에 심은 설계된 변화에서 stORCA는 모든 유형에 순위를 매기고, registration score는 amplitude 변화를, domain 검정은 amplitude 변화와 domain 안 이동을 놓친다. 데이터셋 6개에서 single-pair 방법은 replicate section에서 유전자의 34~94%를 call하지만, stORCA는 조건이 없으면 call하지 않는다 (662개 중 0). Colitis와 피질 손상에서 registration과 domain 방법 상위 유전자의 50~70%는 대응 조직이 없는 조직의 marker이고, stORCA는 20~35%다 (base 11~28%). 모든 call에 유형과 위치가 붙고, 일부는 두 DE 검정 어느 쪽으로도 검출되지 않는다. 하나의 척도로 재생 time course를 따라간다.
5. 의의: replicate 변동과 조직 소실을 넘는 변화만, 무엇이 어디서 바뀌었는지와 함께 보고하는 공간 전사체 비교.

4번의 설계된 변화 문장은 LIBD implant에서 성립한다 (6절, Figure 2f). Synthetic 절반은 15절 Fix 1을 기다린다.

## 6. Results 흐름과 figure

2026-11-18 수정. Figure 하나가 Results 한 절이고, figure 하나에 claim 하나다. Synthetic, semi-synthetic, real data는 별도의 벤치마크 figure가 아니라 각자 검증하는 claim의 figure에 들어간다 (Squair et al. 2021과 같은 방식). Ablation도 마찬가지다.

아래 모든 표에서 쓰는 **상태 표기**.

| 상태 | 뜻 |
|---|---|
| **Done** | 현재 파이프라인 (v4, 2026-11-18 동결), 상태가 충분인 Q 리포트에 있음 |
| **Done, fix** | 결과는 있고, 목록에 있는 fix가 남음 |
| **Rerun** | 예전 파이프라인 (NRMI, single pair, 2026년 9월) 결과만 있음. 설계는 재사용 가능, 숫자는 불가 |
| **To run** | 아직 결과 없음 |
| **To draw** | Schematic, 또는 저장된 결과로 그릴 plot |

**파이프라인 동결 (2026-11-18 완료, v4).** ROS를 [0, 2]로 자르는 clip과 양쪽 baseline thinning이 패키지에 들어갔다 (`STORCA_CLIP=nonzero95 STORCA_GATE=gene STORCA_VERSION=v4`; Methods는 [0-method-v1.md](0-method-v1.md)). Q1~Q5 노트북은 2026-11-19에 v4 표로 다시 돌렸다. 변화는 작았다: LIBD call 0, HPOA 11, NRDR 32와 11, ARTISTA 115에서 113, colitis D0 vs D3 27에서 29. Q1, Q2, Q3, Q5 markdown 리포트는 아직 v3 숫자를 인용한다. 이 구성안의 숫자는 `5-Case-Study-Comparison/res/Comparison/`의 v4 표에서 읽었다.

### 개요

| Fig = Results 절 | Claim (figure 제목) | Synthetic | Semi-synthetic | Real | 상태 |
|---|---|---|---|---|---|
| 1 | 조건 간 공간 발현 변화는 진짜일 수도, 그렇게 보일 뿐일 수도 있다 | Toy 유전자 | | Fig 3, 4의 thumbnail | 방법 panel 그림 (2026-11-19); 가짜 panel to draw |
| 2 | ROS는 설계된 모든 종류의 공간 변화를 잡고, registration과 domain 방법은 하나씩 놓친다 | 동물 효과를 넣은 변화 유형 6개 (`3-BM-DSE-Scenario-v2` 02~07); 이상적 매칭에서의 score 비교 (`3-BM-DSE-Scores`) | 변화를 심은 LIBD DLPFC 3 vs 3 (`1-BM-DSE-Semi-LIBD`, 계획했던 HPOA 구축을 대체) | | Semi-synthetic done (STcompare 실행 중); synthetic stORCA done, Fix 1, 경쟁 방법 미수집 |
| 3 | Single-pair 방법은 replicate 변동을 변화로 보고하고, ROS를 쓴 replicate 설계는 그렇지 않다 | | 그룹당 section 2, 3, 6장의 LIBD implant | LIBD, HPOA, NRDR (두 영역), ARTISTA, colitis D0 vs D3 | Real done (v4), fix; semi-synthetic done |
| 4 | 대응 조직이 없는 조직이 registration과 domain 방법의 상위 목록을 채우고, stORCA의 목록은 채우지 않는다 | 동물 효과를 넣은 rearrangement 시나리오 (`3-BM-DSE-Scenario-v2` 08~12) | | Cortex stab wound, colitis D0 vs D9 | Real done (v4); synthetic stORCA done, Fix 2, 경쟁 방법 미수집 |
| 5 | stORCA는 변화마다 유형을 붙이고, DE와 domain 검정이 검출하지 못하는 변화를 찾는다 | Ground truth에 대한 유형 검증 (Fig 2 데이터) | | ARTISTA, NRDR, HPOA | Real done (v4); 유형 검증 to run |
| 6 | $\Delta$는 비교를 가로지르는 하나의 척도다 | 설계 강도에 대한 $\Delta$ (amplitude 변화만, Fix 4) | | ARTISTA time course | 보류 (claim 5). Real done, fix; amplitude 변화에 대해 synthetic done |

**Figure별 데이터셋** (폭: 기술 3종, 조직 6종).

| 데이터셋 | 기술 | 설계 | Figure |
|---|---|---|---|
| LIBD DLPFC (사람) | Visium | 3 vs 3, 조건 없음 | 3 (null 데이터셋) |
| HPOA, naive vs aggression | MERFISH | 동물 3 vs 3 | 2 (semi-synthetic 바탕), 3, 5 |
| NRDR V1, normal vs dark reared | MERFISH | 동물 2 vs 2 | 3, 5 |
| ARTISTA, axolotl 뇌 재생 | Stereo-seq | 시점마다 section 3 vs 3 | 3, 5, 6 |
| Colitis D0 vs D3 | MERFISH | 마우스 3 vs 4 | 3 |
| Colitis D0 vs D9 | MERFISH | slice 3 vs 3, 조건당 마우스 1마리 | 4 |
| Cortex stab wound | Visium | 반구 2 vs 2 | 4 |
| STARmap PLUS AD | STARmap PLUS | 8 vs 13개월 | 쓰지 않음 (Q4 7절) |

### Figure 1 (Results 1): 공간 변화는 진짜일 수도, 그렇게 보일 뿐일 수도 있다

Results 소제목: "stORCA separates condition effects from replicate variation and from tissue without a counterpart".

| Panel | 내용 | 데이터 | 출처 | 상태 |
|---|---|---|---|---|
| a | Toy 유전자 셋: global shift (pattern 변화 없음), amplitude 변화, pattern 변화 | Toy | | To draw |
| b | 가짜 1: 한 조건의 replicate section 두 장이 이미 다르다 (한 section에만 있는 hotspot) | Real thumbnail, HPOA `Oxt` | Q2 4절 | To draw |
| c | 가짜 2: 대응 조직이 없는 조직 (day 9에 사라진 day 0 상피; 피질 병변) | Real thumbnail | Q1 7a절 | To draw |
| d | 방법: embedding, partial plan, sampled matching과 source 조직 위의 ROS, retained mass로 baseline을 thinning한 replicate 설계 | Schematic | [01-storca-figure1-nov19.py](01-storca-figure1-nov19.py), legend [01-storca-figure1-nov19.txt](01-storca-figure1-nov19.txt) | Done (2026-11-19 v4 초안, thinning 단계 포함) |
| e | 유전자 하나의 출력: $\Delta$와 call, $\rho$, $\kappa$ 평면 위의 유형, residual map | Schematic | 위와 같음 | Done (같은 초안) |
| f | 기능 비교 격자 (3절 표) | | | To draw |

![Figure 1 draft of 2026-11-19](fig/01-storca-figure1-nov19.png)

*방법 panel의 v4 초안 (초안의 a~f가 여기의 panel d, e에 해당). 아직 빠진 것: toy 유전자와 두 가짜 (panel a~c). 그려진 panel 목록에 on/off 유형이 있으므로, 15절 Fix 1 이후의 gene rule과 맞춰야 한다.*

### Figure 2 (Results 2): ROS는 설계된 모든 종류의 변화를 잡는다

Results 소제목: "A spatial concordance score detects pattern and amplitude changes that correlation and domain tests miss". Claim 1. Real data를 보이기 전에 숫자가 무엇을 뜻하는지 설명하는 figure다.

| Panel | 내용 | 데이터 | 출처 | 상태 |
|---|---|---|---|---|
| a | 강도 0~2의 설계된 변화 유형 6개: domain DE, domain 안 cell type DE, domain 안 이동, 경계 띠, 공간 pattern의 amplitude 변화 (`svg-increase`), 고리 domain | Synthetic v2: v1 layout에 section마다 동물 효과 추가 (level offset SD 0.2, 유전자 10%에 hotspot) | `3-BM-DSE-Scenario-v2/01-data-generation/01-make-v2.py` | Done |
| b | 맹점 지도: 3 vs 3에서 방법 × 변화 유형별 AUROC | Synthetic v2 | stORCA: `3-BM-DSE-Scenario-v2/13-storca-v4/res/storca-v4-pooled-metrics.csv`; 전체 방법: 같은 폴더의 `res/all-methods-metrics.csv` | stORCA done, Fix 1 (두 유형 미검정). 경쟁 방법은 시나리오 11개 모두 done (2026-11-20 오후; 처음에 제출 한도로 빠진 task 22개를 재실행) |
| c | 강도 0의 null: FDR 0.05에서 call된 유전자 비율 | Synthetic v2 | 위와 같음 | stORCA는 02~06에서 0.00, 07에서 0.009. DESpace2는 02, 06에서 0.00이지만 고리 시나리오에서 0.145; SpaceExpress 0.28~0.40 |
| d | 이상적 매칭에서의 score ablation: ROS 대 cross-correlation (CODA와 STcompare의 통계량), 차이의 Moran's I, SpatialDE, SCI, Pearson | Synthetic | `3-BM-DSE-Scores` (NRMI: 설계 유전자 10개 중 10개, 10개 중 9개가 상위 20) | ROS로 rerun; cross-correlation 추가 |
| e | 설계 유전자에서의 분해: pattern 변화 유전자와 amplitude 변화 유전자가 $\rho_W$, $C(\kappa)$ 평면에서 각자의 영역에 놓인다 | Synthetic | b의 재실행에서 | To run (Q5의 미결 ground truth 항목) |
| f | 실제 조직, 실제 donor 간 변동: donor 3 vs 3 LIBD DLPFC에 유전자 40개를 심고 (domain DE, Layer 3 안 이동, amplitude, relocation 각 10개) level 3개에서 유형별 검출을 본다. v2는 순수 이동 10개와 global shift decoy 20개를 더한다 | Semi-synthetic | `1-BM-DSE-Semi-LIBD/res/evaluation-*.csv` | 여섯 방법 모두 level 3개에서 done, decoy 포함 (2026-11-20 오후) |
| f2 | 실제 동물에서의 pattern swap: HPOA 3 vs 3에 pattern은 바뀌고 평균은 그대로인 pseudo 유전자 9개 | Semi-synthetic | `1-BM-DSE-Semi/10-semi-v3-hpoa-swap.py`; 유전자 표 `5-Case-Study-Comparison/res/Comparison/hposwap-gene-table.csv` | Done (2026-11-20 오후); Supplementary 후보 |
| g | 세포 수에 따른 실행 시간과 메모리 | Colitis 2 vs 2 (pair 6개), downsampling | `8-BM-Runtime/res/runtime-rt*.csv` | Done (2026-11-20 오후): section당 세포 2,500, 5,000, 10,000, 20,000개에서 GPU 하나로 5.9, 11.0, 18.5, 40.4분; 20,000개에서 최대 RAM 4.5 GB, GPU 메모리 4.7 GB |

강도 1에서 예전 파이프라인의 AUROC, panel b의 미리보기 (숫자는 바뀐다):

| 변화 유형 | CODA | STcompare | DESpace2 | SpaceExpress | River | stORCA (예전) |
|---|---|---|---|---|---|---|
| Domain DE | 1.00 | 1.00 | 1.00 | 1.00 | 0.98 | 1.00 |
| Domain 안 cell type DE | 1.00 | 1.00 | 1.00 | 1.00 | 0.94 | 0.99 |
| Domain 안 이동 | 1.00 | 1.00 | 0.48 | 0.54 | 0.62 | 1.00 |
| Amplitude 변화 (`svg-increase`) | 0.39 | 0.13 | 1.00 | 0.91 | 0.93 | 1.00 |
| 경계 띠 | 1.00 | 1.00 | 0.90 | 0.67 | 0.19 | 0.71 |
| 고리 domain | 1.00 | 1.00 | 1.00 | 0.89 | 0.77 | 1.00 |

읽는 법: 경쟁 방법은 모두 chance 근처나 그 아래로 떨어지는 변화 유형이 하나씩 있다 (CODA와 STcompare는 amplitude 변화, DESpace2와 SpaceExpress는 domain 안 이동, River는 경계 띠). stORCA의 최저값은 0.71 (경계 띠)이다. 이 숫자에서는 "chance 근처로 떨어지는 변화 유형이 없는 유일한 방법"이 성립하고, figure 제목은 재실행 결과를 따라야 한다. 강도 0에서 예전 stORCA와 DESpace2는 FDR 0.05에서 유전자를 하나도 call하지 않았고, SpaceExpress는 0.16~0.33을 call했다.

**2026-11-19에 끝난 결과.**

*LIBD implant (panel f).* stORCA v4는 모든 level에서 모든 implant 유형에 순위를 매긴다 (level 1에서 AUROC 0.85~0.92, level 2에서 0.92~1.00, level 3에서 0.99~1.00). DESpace2는 amplitude 변화 (0.35, 0.69, 0.87)와 level 1의 Layer 3 안 이동 (0.57)을 놓친다. CODA는 모든 유형이 chance 아래 (0.07~0.55), SpaceExpress는 0.32~0.43 (level 2)이다. River는 모든 유형에서 0.93~1.00으로 stORCA와 같거나 더 좋다. 따라서 이 panel은 "registration과 domain 방법은 한 유형을 놓친다"를 뒷받침하고, "맹점이 없는 방법은 stORCA뿐"은 뒷받침하지 않는다. stORCA와 River를 가르는 것은 v2의 decoy 검정이다 (global level shift는 공간 변화가 아니다). Level 2에서 stORCA는 상위 50개에 positive 19개, decoy 0개를 두고, level 1에서는 둘을 가르지 못한다 (AUROC 0.51). River는 decoy에서 아직 돌리지 않았다.

![LIBD implant detection](fig/outline-nov20-libd-implant-detection.png)

*Panel f 후보. Implant 유형마다 심지 않은 유전자 전체에 대한 AUROC; 빈칸 = 아직 실행 안 됨 (STcompare 실행 중). 출처: [fig-outline-nov20.py](fig-outline-nov20.py).*

*LIBD implant, 2026-11-20 오후 완료분.* STcompare는 모든 유형을 chance 아래로 매기고 (0.06~0.52), SpaceExpress는 모든 level에서 0.22~0.45에 머문다. Decoy 검정 (v2: Layer 3 안의 순수 이동 10개가 양성, 모든 layer가 같은 배율로 오르는 유전자 20개가 음성)은 순위를 잘 매기는 방법들을 가른다. River는 모든 level에서 상위 50 안에 decoy 20개를 넣고 양성을 decoy보다 아래에 둔다 (양성 대 decoy AUROC 0.06, 0.02, 0.00). 즉 River의 높은 implant AUROC는 어떤 조건 차이든 순위를 매긴 결과다. DESpace2는 양성과 decoy를 가르지만 (0.75~0.86) 순수 이동을 놓친다 (0.17~0.20; 한 layer 안의 이동은 layer 수준을 바꾸지 않는다). stORCA v4는 순수 이동을 0.87, 0.94, 1.00으로 매기고 상위 50에 decoy를 2, 0, 3개 넣는다 (양성 대 decoy 0.51, 0.78, 0.90). Level 3에서 9개를 call하고 모두 양성이며 decoy는 없다. 이것이 "River는 implant를 stORCA만큼 잘 매긴다"에 대한 데이터로 된 답이다 (15절, Defend).

*HPOA pattern swap (panel f2, 2026-11-20 오후).* 원래 HPOA의 실제 call 11개를 음성에서 빼면, stORCA는 swap 유전자 9개를 AUROC 0.99로 매기고 (9개 모두 상위 20) 그중 8개를 call한다. CODA 0.81, STcompare 0.76, River 0.89, SpaceExpress 0.99 (score 방향은 `02-compare-methods.py`와 같이 클수록 더 변함). 다른 유전자 3개도 call된다. `Greb1`과 `Sp9`는 원래 HPOA에서 call 직전이었고 (BH 0.15), `Gda`는 swap의 원본 유전자 9개 중 하나라서 panel로 쓰기 전에 확인이 필요하다.

*Synthetic v2, 경쟁 방법 (2026-11-20 오후, 시나리오 11개 전부).* 강도 1의 AUROC (새 niche는 강도 0만 있어서 panel 4g에 있음):

| 시나리오 | CODA | STcompare | DESpace2 | SpaceExpress | River | stORCA v4 | stORCA v4 one pair |
|---|---|---|---|---|---|---|---|
| Domain DE | 1.00 | 1.00 | 0.99 | 1.00 | 0.64 | 0.99 | 1.00 |
| Domain 안 cell type DE | 1.00 | 1.00 | 0.73 | 0.98 | 0.56 | 0.96 (1.5와 2에서 0.01) | 1.00 |
| Domain 안 이동 | 1.00 | 1.00 | 0.48 | 0.56 | 0.72 | 1.00 | 0.99 |
| 경계 띠 | 1.00 | 1.00 | 0.48 | 0.54 | 0.75 | 0.00 (미검정) | 0.40 (1.5와 2에서 1.00) |
| Amplitude 변화 (`svg-increase`) | 0.39 | 0.13 | 0.99 | 0.90 | 0.80 | 1.00 | 0.86 |
| 고리 domain | 1.00 | 1.00 | 0.93 | 0.76 | 0.25 | 0.97 | 1.00 |
| Cell type 비율 | 1.00 | 1.00 | 1.00 | 1.00 | 0.22 | 0.83 | 1.00 |
| 새 cell type | 0.94 | 0.97 | 1.00 | 0.97 | 0.24 | 0.97 | 1.00 |
| Domain 확장 | 1.00 | 1.00 | 1.00 | 0.99 | 0.22 | 0.38 | 1.00 |
| 기하적 늘림 | 1.00 | 1.00 | 1.00 | 1.00 | 0.23 | 0.99 | 1.00 |

읽기. 동물 효과가 있으면 모든 경쟁 방법에 chance 근처나 아래로 떨어지는 유형이 하나 이상 있다. CODA와 STcompare는 amplitude 변화 (0.39, 0.13), DESpace2는 domain 안 이동과 경계 띠 (0.48), SpaceExpress도 같은 두 유형 (0.54~0.56), River는 대부분의 유형 (0.22~0.80; v1에서는 0.77~0.98). stORCA v4에는 셋이 있다. 경계 띠와 강도 1.5부터의 cell type DE (Fix 1, gene rule이 유전자를 뺌), 그리고 domain 확장 (Fix 2, limma t). One-pair와 $\Delta$ 읽기는 강도 1.5 이상에서 0.86 아래로 떨어지는 유형이 없으므로, "맹점이 없는 유일한 방법"은 두 fix 후에는 손에 닿지만 그 전에는 아니다. 강도 0에서 DESpace2는 null인 고리 시나리오에서 유전자의 14.5%, SpaceExpress는 모든 곳에서 22~41%를 call한다. stORCA는 02~07에서 0~0.9%다.

*Synthetic v2, stORCA v4 (panel b, c).* $\Delta$나 one-pair ROS로 매긴 순위는 강도 1 이상에서 domain DE, domain 안 이동, amplitude 변화, 고리 domain 모두 0.90~1.00이다. 두 유형은 점수가 매겨지지 않는다. 경계 띠 (모든 level)와 domain 안 cell type DE (level 4개 중 3개)에서 gene rule이 설계 유전자 10개를 빼고, 이 유전자들은 맨 뒤에 놓인다 (AUROC 0.01). 이 유전자들은 한 그룹에서 공간 구조가 없어서 (2026-11-20 오후 정정: cell type DE에서는 설계 효과가 cond1 section에 있고 cond2 section이 평평하므로, 그 시나리오에서 평평한 쪽은 control이 아니라 treated 그룹이다) 분모 기준을 너무 많은 pair에서 통과하지 못한다. One-pair ROS는 강도 1.5부터 같은 유전자를 1.00으로 매기므로, score는 이 유전자를 보고 gene rule이 지운다 (Fix 1). 강도 0의 null은 성립한다 (유전자의 0~0.9% call).

![Synthetic v2 stORCA AUROC](fig/outline-nov20-synthetic-v2-storca-auroc.png)

*stORCA v4의 세 가지 읽기에서 설계 유전자의 AUROC. 0 근처 값은 score가 낮아서가 아니라 gene rule에서 빠진 유전자다.*

Panel 설계 참고용 예전 그림: [amplitude change, ranking](../3-BM-DSE-Scenario/06-svg-increase/fig/svg-increase-benchmark-ranking-performance.pdf), [within-domain shift, ranking](../3-BM-DSE-Scenario/04-within-domain-shift/fig/within-domain-shift-benchmark-ranking-performance.pdf), [score comparison, top-20 capture](../3-BM-DSE-Scores/fig/top20-capture-v1-rep1.pdf).

### Figure 3 (Results 3): 가짜 1, replicate 변동

Results 소제목: "Single-pair comparisons report replicate variation as change". Claim 2. 출처 리포트: [12-q2-replicate-calibration.md](../5-Case-Study-Comparison/12-q2-replicate-calibration.md), 상태 fix 후 충분.

| Panel | 내용 | 데이터 | 상태 | 핵심 숫자 |
|---|---|---|---|---|
| a | 설계: within pair (정의상 replicate 변동)와 between pair | Schematic | To draw | |
| b | Single-pair 검정은 replicate section 두 장에서 대부분의 유전자를 call한다 | Real, 데이터셋 6개 | Done | Within pair마다 유전자의 34~94% (기대값 5%) |
| c | Single-pair 순위: between 상위 유전자가 within 상위 유전자이기도 하다 | Real | Done, fix 4: stORCA가 검정한 유전자로 다시 그림 | HPOA 상위 20의 0.50~0.80 (chance 0.13) |
| d | Replicate 설계, 참 label 대 거짓 label | Real | Done (v4), 15절 Fix 3: call 26개를 내는 colitis 거짓 labeling | LIBD 662개 중 0; HPOA 11 (거짓 label에서 0); NRDR 32와 11 (0); ARTISTA 113 (최대 17); colitis D0 vs D3 29 (26) |
| e | Ablation, 2 x 2 (single pair 또는 replicate 설계; score 또는 검정): 설계는 모든 score의 순위를 바로잡고, call로 바꾸는 것은 ROS뿐이다 | Real | Done; `q2-four-comparisons.csv`로 요약 plot을 그림 | 참 labeling이 19개 중 15개에서 1위; 경쟁 방법 call 0~3개 |
| f | 원인: 한 쌍 안의 matching 분산 대비 replicate 분산 | Real | Done | 26~155배 |
| g | 예시: replicate 변동인 경쟁 방법 상위 유전자 (`Blank_2`, negative control probe; `Oxt`, 한 section의 hotspot); stORCA call (`Cpne5`) | Real, HPOA | Done, fix 1과 2: River `Sema4d` 제거, `Gbx2` 문장 수정 | |
| h | Ground truth 대비 보정: 2 vs 2, 3 vs 3에서 경험적 FDR과 power | Semi-synthetic (LIBD, 변화를 심지 않은/심은 Fig 2f 데이터) | Done | 어떤 level, 어떤 replicate 수에서도 거짓 call 없음; 3 vs 3에서 level 1~3의 참 call은 40개 중 0, 0, 8개, DESpace2는 0, 7, 15개 (level 3에서 거짓 call 1개); 2 vs 2에서 call 0. 6 vs 6 설계 (인접 section 추가)는 참 call 11개를 내지만 거짓 labeling이 최대 312개를 내므로 Supplementary에 둔다 |

![LIBD implant calls](fig/outline-nov20-libd-implant-calls.png)

*Panel h 후보. 왼쪽: donor 3 vs 3에서 FDR 0.05의 call (검정 = 거짓 call). 오른쪽: 그룹당 section 수에 따른 stORCA의 level 2 참 call, implant가 없을 때의 call, 거짓 labeling 중 최대 call 수.*

![Single-pair tests on replicate pairs](../5-Case-Study-Comparison/fig/12-q2-replicate-calibration/q2-single-pair-test-call-fraction.png)

*Panel b. 데이터셋별로 within pair와 between pair에서 single-pair 검정이 call한 유전자 비율.*

![Replicate design, true against false labels](../5-Case-Study-Comparison/fig/12-q2-replicate-calibration/q2-storca-true-vs-null-calls.png)

*Panel d. 참 labeling과 모든 거짓 labeling에서의 stORCA call 수.*

![Replicate design read by scores](../5-Case-Study-Comparison/fig/12-q2-replicate-calibration/q2-replicate-score-true-vs-null.png)

*Panel e의 순위 부분. 방법마다 참 labeling과 거짓 labeling에서의 최상위 효과.*

![Replicate over matching variance](../5-Case-Study-Comparison/fig/12-q2-replicate-calibration/q2-replicate-vs-matching-variance.png)

*Panel f. Replicate 분산 대 matching 분산 비의 중앙값, log 척도.*

![Oxt maps](../5-Case-Study-Comparison/fig/12-q2-replicate-calibration/q2-example-fp-oxt-maps.png)

![Cpne5 maps](../5-Case-Study-Comparison/fig/12-q2-replicate-calibration/q2-example-tp-cpne5-maps.png)

*Panel g. `Oxt`는 경쟁 방법이 높게 매기는 한 section의 hotspot; `Cpne5`는 stORCA call (within ROS 0.23, between 0.55).*

Supplementary: gene-bulk null (replicate가 없을 때의 single-pair 순위; Q2 1c절).

### Figure 4 (Results 4): 가짜 2, 대응 조직이 없는 조직

Results 소제목: "Tissue without a counterpart fills the top lists of registration and domain methods". Claim 3. 출처 리포트: [11-q1-unmatched-cells.md](../5-Case-Study-Comparison/11-q1-unmatched-cells.md), 7절이 결론.

| Panel | 내용 | 데이터 | 상태 | 핵심 숫자 |
|---|---|---|---|---|
| a | 조직 위의 retained mass: 대응 조직이 없는 영역이 어두운 영역이다 | Real: cortex 3 dpi (병변 r14), colitis day 0 (상피) | Done | |
| b | Cluster별 retained mass 대 조건 특이성 | Real | Done | AUROC 0.89 (cortex), 0.94 (colitis day 0); within pair는 0.99 유지 |
| c | 각 방법 상위 20 중 대응 조직이 없는 조직의 marker 비율 | Real | Done (v4) | stORCA 0.20, 0.35 (base 0.11, 0.28); CODA 0.50, 0.70; STcompare 0.70, 0.65; DESpace2 0.70 (colitis); pseudobulk DE 0.60, 0.40; River 0.10, 0.30 (보여줌, Defend 참조) |
| d | 예시 | Real | Done | `Ptger3`: CODA, STcompare, DESpace2 상위 3, stORCA 212위, day 9에 사라진 상피 유전자; stORCA 상위 유전자 `Flnc`, `Grem2`는 두 시점 모두 있는 근육층에 있음 |
| e | Baseline ablation: thinning 없음, control 쪽, 양쪽 | Real과 HPOA | Done (Q1 5e절); to draw | 상위 20의 생긴 조직 marker: cortex 0.35에서 0.20, colitis day 9 0.15에서 0.00; HPOA는 call 11개 중 11개 유지 |
| f | Registration 방법이 틀리는 이유: 정렬이 사라진 구획을 marker가 낮은 다른 조직 위에 놓아 correlation이 음수가 된다 | Real: colitis D0 vs D9, CODA와 STcompare, 9개 pair | Done (Q1 7c절); to draw | 9일째 조직 위의 사라진 상피: CODA 세포의 0.79, STcompare pixel의 0.74~0.99; `Ptger3`는 두 방법 모두 9개 pair 중 9개에서 음수; 겹침이 음의 점수의 0.85 (CODA)와 0.59 (STcompare, pixel의 1/3에서)를 만듦 |
| g | Region을 잃거나 얻은 통제 실험 | Synthetic v2, 시나리오 08 (cell type 비율), 09 (새 cell type), 10 (domain 확장), 11 (새 niche), 12 (기하적 늘림) | 경쟁 방법 포함 v4 done (2026-11-20 오후); Fix 2; 보조 근거만 (아래) | stORCA는 바뀐 집단의 probe를 낮게 둔다 (limma t로 150~160개 중 평균 순위 95~125; one-pair ROS로 41~75). Domain 확장: 150개 중 121개와 130개 call (아래) |
| h | Matching ablation: partial plan 대 balanced plan (모든 세포를 강제로 매칭) | Real (cortex, colitis) 또는 synthetic (axis-redesign, `4-BM-Alighment-not-fininalize`) | 선택; panel c를 강화할 뿐 | |

![Cortex retained mass](../5-Case-Study-Comparison/fig/11-q1-unmatched-cells/q1-slide-maps-cortex-3-dpi.png)

![Colitis day 0 retained mass](../5-Case-Study-Comparison/fig/11-q1-unmatched-cells/q1-slide-maps-colitis-day-0.png)

*Panel a. 위: 대응 조직이 없는 세포를 색으로 (cortex r14 빨강, colitis 상피 파랑). 아래: 같은 section의 retained mass.*

![Retained mass against specificity](../5-Case-Study-Comparison/fig/11-q1-unmatched-cells/q1-slide-retained-vs-specificity.png)

*Panel b. Cluster 하나가 점 하나; 한 조건에만 있는 cluster는 retained mass가 낮다.*

![Marker share top 20](../5-Case-Study-Comparison/fig/11-q1-unmatched-cells/q1-slide-marker-share-top20.png)

![Marker share top k](../5-Case-Study-Comparison/fig/11-q1-unmatched-cells/q1-slide-marker-share-topk.png)

*Panel c. 각 방법 상위 20 (와 상위 k) 중 대응 조직이 없는 조직의 marker 비율; 빨강 = 양쪽 thinning한 stORCA.*

![Colitis examples](../5-Case-Study-Comparison/fig/11-q1-unmatched-cells/q1-std-examples-colitisq1.png)

*Panel d. `Ptger3`와 `Cldn15` (경쟁 방법 상위 20)는 day 0 상피 고리에 있다가 함께 사라진다; `Flnc`와 `Grem2` (stORCA 상위 2개)는 근육층 안에서 바뀐다.*

**세포 class를 뺀 semi-synthetic (HPOA, Q1 5~5c절): 쓰지 않음** (2026-11-18 결정). 다른 세포 사이에 흩어진 class를 빼면 정렬이 메울 구멍이 생기지 않고 marker에 조직된 패턴도 남지 않으므로, CODA의 correlation은 음수가 되지 않고 구조 없는 유전자 수준으로 떨어질 뿐이다 (`Gjc3` 0.18에서 0.04). panel a~d의 상황을 재현하지 못한다 (Q1 7c절). 통제 실험은 panel g다.

**예전 synthetic rearrangement 결과 (예전 파이프라인, partial plan thinning 없음).** 바뀐 집단의 비율이 커질수록 stORCA는 그 집단의 probe 유전자를 더 높게 매기고 (`ct-proportion`에서 평균 순위 84.7에서 61.2), `novel-niche`에서는 FDR 0.05에서 유전자의 0.83을 call한다. CODA와 STcompare는 모든 level에서 probe를 같은 순위 (30.5)에 두므로, 이 설계는 경쟁 방법이 속는다는 것도 보여주지 않는다. 현재 방법을 검증한 결과는 아니지만 위험 요소다. 재실행 결과도 같으면 Figure 4는 real data에만 기댄다. `domain-expansion`은 아직 지표가 수집되지 않았다.

**stORCA v4로 한 synthetic v2 재실행 (2026-11-19).** stORCA에 대해서는 위의 위험이 사라졌다. 모든 rearrangement 시나리오에서 probe는 아래쪽 절반에 놓이고 (panel g 표), one-pair 읽기가 replicate 읽기보다 probe를 더 높게 매기므로 여기서도 replicate 설계가 도움이 된다. 주의할 결과가 둘 있다. (1) Domain 확장: 강도 1에서 150개 중 121개, 강도 2에서 130개를 call한다. 시나리오 07~12의 background 유전자 100개는 모두 강한 domain marker이므로 (`3-BM-DSE-Scenario/01-data-generation/doc/01-data-generation-en.md`의 2026-11-19 정정), domain이 커지면 그 pattern은 실제로 움직인다. 이들의 $\Delta$는 작지만 (between ROS 0.018~0.028) within ROS가 0에 가까워서, limma t는 이 작고 일관된 변화를 설계 유전자보다 위에 둔다 (t로 AUROC 0.38, 0.25, $\Delta$로 1.00). (2) 강도 1의 cell type 비율: 설계되지 않은 유전자 21개를 call하고, 강도 0과 2에서는 0개와 1개다. 경쟁 방법 (2026-11-20 오후): CODA와 STcompare는 모든 rearrangement 시나리오에서 probe를 평균 순위 30.5~34.7에 둔다. 아무것도 재배치되지 않은 강도 0과 기하적 늘림에서도 같다. 즉 probe는 패턴이 강한 marker라서 변화와 관계없이 높게 매겨진다. DESpace2는 66~100, River는 104~113에 둔다. 따라서 v1과 마찬가지로 이 설계는 stORCA가 속지 않는다는 것을 보여주지만 (t로 50~125, domain 확장이 커지면 82, 125, 125로 내려감), registration 방법이 대응 조직이 없는 조직에 속는다는 것은 보여주지 못한다. Panel 4g는 보조 근거로 남고, claim 3은 panel a~f에 기댄다.

![Synthetic v2 stORCA calls](fig/outline-nov20-synthetic-v2-storca-calls.png)

![Synthetic v2 calls legend](fig/outline-nov20-synthetic-v2-calls-legend.png)

*시나리오와 강도별 stORCA v4 call (symlog 축). 초록: call된 설계 (focal) 유전자, 10개 중. 빨강: call된 다른 유전자.*

### Figure 5 (Results 5): 무엇이 어디서 바뀌었나, DE 너머

Results 소제목: "stORCA types each change and finds changes that DE and domain tests do not detect". Claim 4. 출처 리포트: [13-q3-beyond-de.md](../5-Case-Study-Comparison/13-q3-beyond-de.md) (충분)와 [15-q5-interpretation.md](../5-Case-Study-Comparison/15-q5-interpretation.md) (보인 범위에서 충분).

| Panel | 내용 | 데이터 | 상태 | 핵심 숫자 |
|---|---|---|---|---|
| a | 모든 call을 $\rho$, $\kappa$ 평면에 놓고 유형 비율을 보임 | Real: ARTISTA, NRDR, HPOA | Done (v4) | Pattern, mixed, amplitude: ARTISTA 59, 44, 10; NRDR 14, 14, 4; HPOA 2, 3, 6 |
| b | 같은 설계에서 DESpace2, pseudobulk DE와의 겹침 | Real: ARTISTA, NRDR | Done (v4 표; Q3 리포트 갱신 필요) | ARTISTA call 113개, DESpace2가 call하지 않은 것 89개, 두 pseudobulk DE 검정 (global, domain별) 어느 쪽도 call하지 않은 것 31개; NRDR call 32개, DESpace2 0개, 두 pseudobulk 검정 모두 아닌 것 22개 |
| c | 두 검정 모두 검출하지 못한 예시: `Prkca`, `Trpc3` (dark rearing에서 L2/3~L4 띠가 흐려짐), sampled matching 하나와 함께 | Real: NRDR | Done | 가장 작은 layer FDR 0.10, 0.11; DESpace2 FDR 1.00 |
| d | 유형 예시: `CDKN1B` (amplitude), `FABP7` (pattern), residual map 포함 | Real: ARTISTA | Done | |
| e | 생물학적 확인: 원 논문 보고대로 dark-reared V1에서 activity 유전자가 올라간다 | Real: NRDR | Done; to draw | Call된 유전자 7개 중 7개에서 $\ell>0$; pseudobulk와 부호가 11개 중 11개 일치 |
| f | DE 너머 call의 유형별 분할 | Real | To run (Q3와 Q5 표의 join) | |
| g | 위치를 숫자로: niche 또는 cell type별 residual 농축 | Real | To run, 또는 "지도로 보임"이라고 명시 | |

![rho-kappa plane](../5-Case-Study-Comparison/fig/15-q5-interpretation/q5-rho-kappa-plane.png)

*Panel a. 데이터셋마다 모든 call을 pattern 일치도와 amplitude 일치도로 배치.*

![ARTISTA Venn](../5-Case-Study-Comparison/fig/13-q3-beyond-de/q3-artista-venn.png)

![NRDR Venn](../5-Case-Study-Comparison/fig/13-q3-beyond-de/q3-nrdr-venn.png)

*Panel b. 같은 설계에서 stORCA call 대 DESpace2와 pseudobulk DE.*

![Prkca maps](../5-Case-Study-Comparison/fig/13-q3-beyond-de/q3-nrdr-prkca-maps.png)

![Prkca one sampled matching](../5-Case-Study-Comparison/fig/13-q3-beyond-de/q3-nrdr-prkca-sampled-matching.png)

*Panel c. NRDR section 네 장의 `Prkca`, 그리고 L2/3~L4 띠에 놓인 sampled matching 하나의 residual.*

![CDKN1B maps](../5-Case-Study-Comparison/fig/15-q5-interpretation/q5-artista-amplitude-xiclnr-cdkn1bhs-maps.png)

![FABP7 maps](../5-Case-Study-Comparison/fig/15-q5-interpretation/q5-artista-pattern-fabp7nr-maps.png)

*Panel d. `CDKN1B`는 amplitude call; `FABP7`은 pattern call.*

Supplementary: NRDR 4 vs 4 재현 (call 82개, posterior call 32개 중 23개 유지); 움직인 L2/3~L4 경계 (후보); replicate 초과분에 대한 유형 (call의 66~76%가 유형 유지).

### Figure 6 (Results 6): 비교를 가로지르는 하나의 척도

Results 소제목: "$\Delta$ follows the course of regeneration on one scale". Claim 5, 2026-11-20부터 보류. 출처 리포트: [14-q4-effect-size.md](../5-Case-Study-Comparison/14-q4-effect-size.md), 상태 fix 후 충분.

| Panel | 내용 | 데이터 | 상태 | 핵심 숫자 |
|---|---|---|---|---|
| a | 설계: 2 DPI 대 5, 10, 15, 20 DPI | Schematic | To draw | |
| b | 비교마다 call 수와 거짓 label에서의 최대 call 수 | Real: ARTISTA | Done | Call 117, 249, 331, 155개; 거짓 label 최대 0, 0, 43, 12 |
| c | 시점마다 $\Delta$를 한 축에 | Real | Done | 유전자 684개의 중앙값 0.047, 0.094, 0.099, 0.058 |
| d | 유전자마다 궤적과 정점 시점 | Real | Done | 정점이 5, 10, 15, 20 DPI인 유전자 38, 132, 168, 88개 |
| e | 예시: 커지는 변화 (`DDIT4`, 20 DPI에서 $\Delta$ 0.50)와 일시적 변화 (`ZIC1`, 15 DPI section 네 개 모두에서 등쪽 정중선을 가로지르는 띠) | Real | Done (2026-11-19 `NPTXR`을 `ZIC1`으로 교체) | `ZIC1` $\Delta$ 5~20 DPI에서 0.03, 0.16, 0.47, 0.05; 15 DPI BH 0.002 |
| f | 한 쌍 안의 순위는 비교끼리 견줄 수 없다 | Real | Done; to draw | 같은 유전자의 순위가 pair에 따라 47에서 1062까지 |
| g | 척도 확인: amplitude 변화의 설계 강도에 따라 $\Delta$가 커진다 | Synthetic v2 (`svg-increase`) | Done; Fix 4 (범위를 "모든 변화 유형"에서 줄임) | 강도 0.5~2에서 설계 유전자의 $\Delta$ 중앙값 0.008, 0.041, 0.114, 0.234. Domain DE에서 $\Delta$는 평평하고 (0.49~0.57), domain 안 이동에서는 떨어진다 (between ROS 0.31, 0.13, 0.08) |

![Calls per comparison](../5-Case-Study-Comparison/fig/14-q4-effect-size/q4-artista-timecourse-calls.png)

*Panel b. 비교마다 call 수와 거짓 labeling 중 최대 call 수.*

![Delta per time point](../5-Case-Study-Comparison/fig/14-q4-effect-size/q4-artista-delta-distribution.png)

*Panel c. 모든 시점에서 검정된 유전자의 $\Delta$.*

![Trajectories](../5-Case-Study-Comparison/fig/14-q4-effect-size/q4-artista-delta-trajectories.png)

*Panel d. 한 번 이상 call된 유전자의 궤적, 정점 시점별로 묶음.*

![DDIT4 ROS per pair](../5-Case-Study-Comparison/fig/14-q4-effect-size/q4-artista-increasing-ddit4-pair-ros.png)

*Panel e. `DDIT4`, 시점마다 모든 between pair와 within pair의 ROS.*

Supplementary: depth를 맞춘 downsampling; clip의 영향 (call 837개 중 829개 유지).

### Supplementary와 source data 항목

- Parameter sensitivity (K, ε, δ, matching 수, graph k), gene-holdout embedding, 두 scoring 방향, depth를 맞춘 downsampling.
- limma null simulation과 R limma 비교; unweighted 대 weighted; one-sided 대 two-sided.
- Single-pair 순위를 위한 gene-bulk null (Q2 1c절).
- Geometric stretch (`3-BM-DSE-Scenario/12`)와 plan C로 한 axis-redesign alignment 교체 (`4-BM-Alighment-not-fininalize`).
- NRDR 4 vs 4 재현과 L2/3~L4 경계 (Q3 5, 6절).
- Embryo 발생 series와 다른 single-pair 분석, 기술적 순위로 표시.
- 전체 p-value 설계 이력을 Supplementary Note로.
- Concordance 항등식과 분해의 유도, non-PSD 주의사항 포함.

### Results를 위한 실행 목록, 순서대로

| 순서 | 작업 | Figure | 크기 |
|---|---|---|---|
| 0 | ~~파이프라인 동결~~ (2026-11-18 완료, v4) | 전체 | |
| 1 | ~~Q2~Q5 limma fit 재실행~~ (2026-11-19 완료); v4 숫자를 Q1, Q2, Q3, Q5 리포트에 옮김 | 3, 4, 5 | 작음 |
| 2 | 15절 Fix 1: 한 조건에서 구조가 없는 유전자에 대한 gene rule; 시나리오 02, 03, 05와 LIBD implant 재채점 | 2 | 작음~중간 (재채점) |
| 3 | ~~Synthetic v2 시나리오 02~12의 경쟁 방법 지표 수집~~ (2026-11-20 오후 done) | 2, 4 | |
| 4 | Fix 2: 목록 순위에 쓸 통계량과 작고 일관된 변화에 대한 call 규칙을 정하고 재채점 | 2, 4 | 작음 |
| 5 | ~~LIBD implant의 STcompare; v2 decoy에서 모든 경쟁 방법~~ (2026-11-20 오후 done) | 2 | |
| 6 | 리포트 fix: Q2 (River panel, `Gbx2` 문장, colitis 거짓 labeling (Fix 3), 유전자 범위) | 3 | 작음 |
| 7 | `3-BM-DSE-Scores`를 ROS와 cross-correlation으로 재실행 (panel 2d) | 2 | 작음 |
| 8 | 저장된 결과로 plot과 join: 2 x 2 요약, baseline ablation, 기전 panel (4f), DE 너머 call의 유형, activity 유전자, 순위 표 | 3, 4, 5, 6 | 작음 |
| 9 | ~~실행 시간과 메모리 (panel 2g)~~ (2026-11-20 오후 done); plot은 그릴 것 | 2 | |
| 10 | Figure 1: toy 유전자와 두 가짜 (panel a~c) | 1 | 작음 |

## 7. 기존 작업의 배치

2026-11-18에 6절의 figure별 표로 대체되었다. 그 표에 실험별 상태도 있다. 기록용으로 남긴다.

| 기존 실험 | 폴더 | 새 위치 | 그대로 재사용 가능? |
|---|---|---|---|
| Synthetic v1~v4 | `1-BM-DSE-Synthetic` | Fig 4a, b | 설계는 가능, 숫자는 불가 |
| Semi-synthetic v1, v2 | `1-BM-DSE-Semi` | Fig 4g | 설계는 가능, 숫자는 불가 |
| 이상적 매핑에서의 score 비교 | `3-BM-DSE-Scores` | Fig 2c | ROS로 재실행, cross-correlation 추가 |
| Multi-replicate 전략 | `3-BM-MultiReplicate` | Fig 4c | 설계만; 추론은 이제 limma |
| Axis-redesign, dissociation, coverage collapse | `11-axis-redesign-benchmark`, `4-BM-Alighment-not-fininalize` | Fig 4e, f | Plan C로 재실행 |
| Real 데이터 DSE, 방향 안정성 | `1-BM-DSE-Real` | Fig 3f, Supplementary | 예전 파이프라인 |
| DSE 대 DE, SVG | `2-BM-DSE-DESVG` | Fig 6e | 재실행 |
| Local Moran 해석 | `2-BM-DSE-Interpretation` | Fig 5d 방식 | 방법 재사용 가능 |
| p-value 진단, 노트북 21~26 | `5-Case-Study-Colitis` | Fig 3, Supplementary Note | 가능 |
| ρκ 분해 | `5-Case-Study-Colitis` | Fig 2b, Fig 5c | 2절과 대조해 확인 필요 |
| Day 9 severe의 매칭되지 않는 cell type | 위치 기입 필요 | Fig 2d | Plan C로 확인 필요 |

## 8. Case study 선택

| 데이터셋 | Technology | 조건당 replicate | 제안 역할 | 상태 |
|---|---|---|---|---|
| DSS colitis (Ranganathan 2024) | MERFISH | 건강 3, day 3 4마리 가용 | Fig 2d, Fig 3, Fig 5 | 2 vs 2 완료, 3 vs 3 미실행 |
| Aging brain (Allen 2023 또는 Sun 2024) | MERFISH | 여러 마리 | Fig 3f와 Fig 6 주 case | SysVI 결과 존재, 미확인 |
| HPOA (Moffitt 2018) | MERFISH | 여러 마리 | Fig 3f calibration, semi-synthetic 기반 | 예전 파이프라인 |
| DLPFC | Visium | Donor | Negative control, platform 폭 | 미확인 |
| Axolotl 재생 (ARTISTA) | Stereo-seq | 적음 | Fig 6d, 큰 기하 변화 | 미확인 |
| AD Xenium | Xenium | 불명 | Fig 6d | Legacy |
| Cortex stab, spinal injury | (폴더 참조) | 불명 | Fig 6d 또는 Supplementary | Sardine과 비교됨 |
| NRDR | MERFISH | 제한적 | Supplementary | 예전 파이프라인 |
| Mouse embryo (MOSTA) | Stereo-seq | 없음 | Supplementary, 기술적 | 예전 파이프라인, 1 vs 1 |

선택 규칙: 조건당 최소 3마리가 있는 데이터셋만 본문의 생물학적 claim을 담을 수 있다. 나머지는 순위, effect size, 유형으로만 보여준다.

## 9. 주장할 것과 주장하지 않을 것

| 주장 | 사용 여부 |
|---|---|
| stORCA는 matching uncertainty를 score에 전파한다 | 예. Fig 2e의 ablation과 함께 |
| ROS는 pattern과 amplitude에 민감한 spatial concordance 척도다 | 예 |
| 각 call에 유형과 위치가 붙는다 | 예. Fig 4d에서 검증 |
| Single-pair 공간 검정은 replicate 변동에 대해 보정되어 있지 않다 | 예. 여러 데이터셋과 방법에서 |
| stORCA는 replicate로 false discovery를 통제한다 | 예. 현재 파이프라인 벤치마크와 3 vs 3 permutation FDR 이후 |
| Registration이나 domain 라벨이 필요 없다 | 예. 귀결로서 |
| 변화는 niche 또는 domain 규모에서 검출된다 | 예. 명시적으로 서술 |
| DSE는 DE가 찾지 못하는 유전자를 찾는다 | 측정된 형태로만, 유형별로 나누어: pattern call 대 amplitude call |
| "Uncertainty-aware"가 각 매칭의 보정된 신뢰도를 뜻한다 | 아니오. 두 출처를 한 번 정의하고 그 범위를 지킨다 |
| 세포 수준 correspondence | 아니오. Partner 거리가 100~150 세포 |
| Single-pair p-value가 condition 효과를 식별한다 | 아니오. Single-pair 출력은 유형과 위치가 붙은 순위 |
| "Day 3 colitis에서 FDR 5%로 10개 유전자"; "FDR 유전자 200~438개가 severity를 따른다" | 아니오. 현재 근거로는 불가; 두 번째는 무효인 검정에 기반 |
| 최고의 alignment 방법 | 아니오. Downstream DSE의 안정성을 주장 |

## 10. 예상 리뷰어 지적과 답변 위치

| 지적 | 답변 위치 | 남은 작업 |
|---|---|---|
| Score가 CODA의 cross-correlation이다 | 2절의 항등식, Fig 2a: correlation 대 concordance, 차이는 amplitude 항 | CODA 실행 |
| Bivariate Moran과 Lee's L이 이미 있다 | 인용; 우리의 기여는 concordance 형태, 그 분해, replicate에 걸친 사용 | 문헌 확인 |
| Matching uncertainty는 작다 (0.006), 왜 전파하나 | Fig 2e와 Fig 3d: 버리면 score가 달라지고, replicate 변동과는 다른 출처다 | Ablation |
| Plan의 퍼짐은 생물학이 아니라 entropy parameter다 | Fig 2d: 같은 ε에서 퍼짐이 조직 상태에 따라 달라진다; ε 민감도는 Supplementary | Plan C로 재실행 |
| Embedding의 불확실성이 무시된다 | Fig 2f | Seed 5개 |
| Amplitude call은 결국 DE다 | Fig 5f, Fig 6e | Pseudobulk baseline |
| 구조가 약한 유전자에서 분해가 불안정하다 | 구조 필터 위에서만 보고; Methods에 명시 | 없음 |
| 그룹당 2마리; 한 마리가 call을 좌우한다 | Fig 5a, b, leave-one-animal-out | 3 vs 3, 3 vs 4 |
| Condition이 처리 날짜와 겹친다 | Methods와 limitation | 데이터 저자에게 문의 |
| Embedding에서의 유전자 double dipping | Supplementary, gene-holdout embedding | 실행 |
| 방향 비대칭 | Supplementary, 양방향 | 양방향 scoring |
| Precision weight가 call을 좌우한다 | Unweighted limma를 주 결과로 | 결정 후 재실행 |
| On/off 유전자가 clipping으로 제외된다 | Concordance 관점에서 이는 $C(\kappa)\to0$의 극한이다; score되도록 clip 변경 | 결정 필요 |
| 벤치마크가 기술된 방법과 다르다 | 공개 패키지로 Fig 2~4 재생성 | ROS, 분해, limma를 `storca/`로 이동 |
| Replicate가 없으면 어떻게 하나 | Discussion: 유형과 위치가 붙은 순위, 외부 replicate null, 한계 명시 | 본문 작성만 |

## 11. 투고 전 작업 순서

1. 파이프라인을 동결하고 ROS, 그 분해, plan C, limma 경로를 `storca` 패키지로 옮긴다.
2. Colitis 3 vs 3과 3 vs 4를 permutation FDR과 함께 실행. Colitis가 Fig 5를 담당할 수 있는지 결정된다.
3. Fig 2 실험: cross-correlation을 포함한 설계 유전자 score 비교, sampled 대 argmax와 barycentric, embedding seed, plan C의 day 9 severe 예시.
4. 다른 두 데이터셋과 경쟁 방법으로 replicate-null 분석 (Fig 3).
5. Amplitude와 pattern DSE 부류, 중간 규모 null 유전자, replicate 설계를 포함한 현재 파이프라인 synthetic 벤치마크 (Fig 4a~d).
6. Plan C로 axis-redesign 재실행 (Fig 4e, f).
7. 유형별로 나눈 pseudobulk 비교 (Fig 5f, Fig 6e).
8. Replicate가 많은 두 번째 case study (Fig 6).
9. 강건성 supplement (holdout, 양방향, depth).
10. 동결된 패키지 기준으로 Methods 재작성 후, 이 폴더의 template으로 Results 작성.

2번과 3번은 비용이 낮고 framing을 결정하므로 대규모 재실행보다 먼저 한다.

## 12. Fallback

- **3 vs 3 colitis에서도 call이 적다.** Colitis는 calibration과 matching uncertainty 데이터셋 (Fig 2d, Fig 3)으로 남기고, 해석 case는 동물이 가장 많은 데이터셋으로 옮긴다.
- **어떤 설정에서도 sampled matching이 alignment 하나와 차이가 없다.** Claim 1을 soft하고 partial한 matching 자체 (대응 세포가 없는 세포를 억지로 매칭하지 않음)로 줄이고 day 9 severe 결과로 보인다. 제목의 단어는 replicate와 이것에 기댄다.
- **경쟁 방법이 replicate에서 잘 보정되어 있다.** Fig 3은 panel 하나로 줄이고 무게를 claim 2와 4로 옮긴다.
- **어디서나 call 대부분이 amplitude 변화다.** 이 framing이 이미 포괄한다. 비중을 보고하고, 그런 유전자에 대한 방법의 기여는 annotation 없는 localization이라고 명시한다.
- **현재 파이프라인이 synthetic 벤치마크에서 예전보다 못하다.** 글을 쓰기 전에 원인을 조사한다. Figure마다 다른 파이프라인을 섞지 않는다.

## 13. 출처

- River: [Nature Communications 2025, doi 10.1038/s41467-025-61476-9](https://www.nature.com/nature-index/article/10.1038/s41467-025-61476-9)
- CODA: [bioRxiv 2025.06.05.653933](https://www.biorxiv.org/content/10.1101/2025.06.05.653933.full.pdf), 게재본 [Nature Communications 2026, doi 10.1038/s41467-026-72862-2](https://www.nature.com/nature-index/article/10.1038/s41467-026-72862-2)
- STcompare: [bioRxiv 2025.11.21.689847](https://www.biorxiv.org/content/10.1101/2025.11.21.689847.full.pdf)
- DESpace2: [bioRxiv 2025.06.30.662268](https://www.biorxiv.org/content/10.1101/2025.06.30.662268.full.pdf)
- SpaceExpress: [bioRxiv 2024.12.19.628720](https://www.biorxiv.org/content/10.1101/2024.12.19.628720.full.pdf)
- SLAT: [Nature Communications 2023, PMC10636043](https://pmc.ncbi.nlm.nih.gov/articles/PMC10636043)
- OSTA book의 differential spatial patterns 장: [bioconductor.org](https://bioconductor.org/books/release/OSTA/pages/mult-diff-spatial-patterns.html)
- Squair et al. 2021, single-cell DE의 false discovery: [Nature Communications](https://infoscience.epfl.ch/record/289583/files/s41467-021-25960-2.pdf)
- Lin 1989, concordance correlation coefficient (Biometrics 45:255): 기억에 의한 인용이며 이번 세션에서 원문을 확인하지 않음.

## 14. 미결 이슈: "matching uncertainty"의 의미

2026-11-12에 기록. 2026-11-18에 2번 의미로 정리했다 (1절): 논문은 대응 세포가 없는 세포를 말하고, sampled matching은 score를 계산하는 방식으로 Methods에 남긴다.

Umbrella claim의 "the uncertainty of matching cells across conditions"는 두 가지로 읽힐 수 있고, 논문은 하나로 정해야 한다.

1. **누구와 매칭되는가**: 세포 하나에 그럴듯한 대응 세포가 여러 개 있을 수 있으므로, matching을 샘플링하고 그 퍼짐을 점수에 전파한다.
2. **대응 세포가 있는가**: 세포에 대응 세포가 아예 없을 수 있으므로 (새로 생기거나 사라진 세포 집단), 억지로 매칭하지 않고 점수에서 제외한다 (soft, partial matching).

중요한 이유:

- 쌍 내부 matching resampling 변동 (약 0.006)이 replicate 변동 (약 0.15)보다 약 25배 작고, bootstrap precision weight가 모든 데이터셋에서 불안정해 unweighted limma를 주 분석으로 쓴다. 따라서 1번 의미의 주장 ("matching uncertainty를 전파하면 결과가 좋아진다")은 방어하기 어렵다.
- 2번 의미의 주장은 그 분산의 크기와 무관하다. 구조적 성질이다. Diffeomorphism 기반 경쟁 방법 (CODA, STcompare)은 모든 위치에 대응 세포가 정확히 하나 있다고 가정한다.
- 25배 차이는 replicate 주장을 오히려 뒷받침한다. 한 쌍 안의 resampling으로 만든 null은 너무 좁아서 단일 쌍 검정은 과신한다.

현재 1번 의미로 쓰인 부분: claim 1 (1절), field gap bullet과 "what none of them did" 문장, abstract 3번, Figure 2 제목과 panel 2e, propagation에 관한 "주장할 것" 행 (9절)과 reviewer 반론 행 (10절). 2번 의미는 12절의 fallback에만 있다.

2번 의미의 실제 데이터 검증안: colitis와 ARTISTA에서 강제 (balanced) matching 대 partial matching을 비교하고, 상위 유전자 중 대응 없는 세포 집단 marker의 비율을 본다.

## 15. 2026-11-20 상태 점검: fix 또는 defend

읽은 결과: `5-Case-Study-Comparison/res/Comparison/`의 v4 Q 표 (노트북 2026-11-19 재실행), stORCA v4로 돌린 synthetic v2 (`3-BM-DSE-Scenario-v2/13-storca-v4`), LIBD implant 벤치마크 (`1-BM-DSE-Semi-LIBD/res`). 항목마다 그것이 받치는 1절의 claim에 비추어 판정했다.

| Figure | Claim | 판정 |
|---|---|---|
| 1 | 방법 | 충분 (방법 panel은 그림; 가짜 panel은 그릴 것) |
| 2 | 1, score는 모든 종류의 변화를 본다 | 아직: 문구를 바꾸면 LIBD implant에서 충분; synthetic은 Fix 1과 경쟁 방법 지표가 필요 |
| 3 | 2, replicate 변동 | Fix 3과 Q2 리포트 fix 후 충분 |
| 4 | 3, 대응 조직이 없는 조직 | Real data에서 충분; synthetic panel g는 Fix 2와 경쟁 방법 지표가 필요 |
| 5 | 4, DE 너머 | 충분 (v4 숫자를 Q3, Q5 리포트에 옮길 것) |
| 6 | 5, 하나의 척도 (보류) | 2026-11-20부터 보류; 다시 다루면 Fix 4 후 충분 |

**전체 상태: Figure 2 때문에 아직이다. Figure 3~5는 아래 fix 후 충분하다. Figure 6 (claim 5)은 보류다.**

**Fix.**

1. **Gene rule이 한 조건에서 구조가 없는 유전자를 뺀다** (Fig 2b; claim 1과 충돌). 경계 띠와 domain 안 cell type DE에서 설계 유전자 10개가 대부분의 level에서 검정되지 않아 맨 뒤에 놓이고 (AUROC 0.01), one-pair ROS는 강도 1.5부터 같은 유전자를 1.00으로 매긴다. 같은 상황 때문에 domain DE 유전자의 within ROS가 약 0.5가 되고 (평평한 조건의 within pair는 noise와 noise를 비교), 그래서 domain DE 유전자 10개 중 1~4개만 call된다. 가장 단순한 fix (stORCA tuning): 어느 한 그룹에서라도 구조가 있는 유전자는 구조 기준을 통과시키고, 한 그룹의 within pair는 그 그룹에서 유전자에 구조가 있을 때만 점수를 매기거나, 그런 유전자를 Figure 1 초안에 이미 있는 on/off 유형으로 보고한다 (10절의 "On and off genes" 행). 02, 03, 05와 LIBD implant를 재채점한다. SysVI나 plan은 다시 돌릴 필요가 없다. Cell type DE에서의 기전 (2026-11-20 오후 확인, rep 1, c1-r1에서 c2-r1): 강도가 커지면 partial plan이 효과를 지닌 source 세포를 버린다 (domain A의 CT0: 강도 1, 1.5, 2에서 보존 1.00, 0.44, 0.16; 설계 유전자 발현 상위 10% 세포는 1.00, 0.34, 0.09). 유전자 110개 panel에서 강하게 오른 유전자 10개가 이 세포들을 embedding에서 새 상태로 만들기 때문이다. 그러면 between pair는 남은 세포로 유전자를 재고, 분모 기준을 통과하지 못하며 (between pair 중 쓸 수 있는 비율 98%, 8%, 1%), 유전자가 빠진다. One-pair ROS는 여전히 변화를 본다 (between ROS 약 1.1). 그래서 예전 single-pair 파이프라인 (균일 plan)과 one-pair reading은 이 시나리오를 0.99~1.00으로 매긴다.
2. **Limma t가 작고 일관된 변화를 큰 변화보다 위에 둔다** (Fig 4g; 독자가 보게 될 우산 claim과 충돌). Domain 확장에서 stORCA는 150개 중 121개와 130개를 call한다. Background 유전자는 domain marker이므로 그 pattern은 실제로 움직이지만, $\Delta$는 0.02로 설계 유전자의 약 0.5와 비교된다. $\Delta$로 매기면 설계 유전자가 맨 앞에 오고 (AUROC 1.00), t로 매기면 그렇지 않다 (0.38, 0.25). 가장 단순한 fix: 상위 목록은 $\Delta$로 매기고 (claim 5가 이미 $\Delta$를 척도로 삼는다), call은 최소 효과를 두고 한다 (작은 $\Delta_0$, 예를 들어 0.05에 대한 limma `treat`). 그다음 HPOA, NRDR, ARTISTA가 call 대부분을 유지하는지 확인한다. Fix와 Defend 사이에서 확실하지 않다: call은 실제 pattern 변화이므로 "stORCA는 layout이 바뀌었다고 보고한다"로 방어할 수도 있다. 다만 domain이 커진 뒤 유전자의 87%를 call하는 그림은 리뷰어가 기억할 그림이므로 Fix를 추천한다.
3. **Colitis D0 vs D3: 거짓 labeling 하나가 참 label의 29개에 대해 26개를 call한다** (Fig 3d; "call이 replicate 변동을 넘는다"와 충돌). Q2부터 열려 있던 항목이다 (거기서 Fix 3). 가장 단순한 fix: colitis D0 vs D3는 single-pair panel (b, c)에 두고, replicate 설계가 call을 내는 데이터셋 목록에서는 뺀다. 그 call이 거짓 labeling과 구분되지 않는다고 한 줄로 쓴다.
4. **"모든 변화 유형에서 $\Delta$가 설계 강도와 함께 커진다"는 틀렸다** (Fig 6g). $\Delta$는 amplitude 변화에서 커지고, domain DE에서 평평하고, domain 안 이동에서 떨어진다. 가장 단순한 fix: panel 6g를 강도가 효과 자체를 키우는 유형인 amplitude 변화로 줄인다 (위 표에 반영함). Claim 5는 time course에 기대므로 영향이 없다. Claim 5와 함께 보류 (2026-11-20).
5. **"Chance 근처로 떨어지는 변화 유형이 없는 유일한 방법"은 LIBD implant에서 틀렸다.** River도 모든 유형을 0.93~1.00으로 매긴다 (claim 1, abstract). 이번 수정에서 처리함: claim은 이제 registration과 domain 방법이 한 유형을 놓친다고 말한다. Decoy 실행 (2026-11-20 오후)이 River의 순위가 무엇까지 잡는지 보여준다. 모든 level에서 상위 50 중 20개가 수준만 바뀐 decoy이고 양성은 decoy보다 아래에 놓인다 (AUROC 0.00~0.06). stORCA는 level 2부터 둘을 가른다 (0.78, 0.90). 동물 효과가 있는 synthetic v2에서 River는 0.22~0.80으로 떨어진다.

**Defend.**

| 리뷰어가 할 수 있는 말 | 답 |
|---|---|
| LIBD implant 3 vs 3에서 stORCA는 level 2에서 call 0개, DESpace2는 7개다 | DESpace2는 수작업 layer label을 받아서 implant를 심은 바로 그 layer를 검정한다. stORCA는 label을 쓰지 않는다. stORCA는 어떤 level과 설계에서도 거짓 call이 없고, level 2부터 모든 유형을 0.92 이상으로 매긴다. Power는 효과 크기와 replicate 수에 따라 커지고, Fix 1은 control에서 평평한 유전자의 power를 올릴 것으로 예상한다 |
| River는 LIBD implant를 stORCA만큼 잘 매긴다 | River는 조건을 예측하는 유전자에 순위를 매기고 검정이 없다. LIBD decoy (모든 layer가 같은 배율로 오르고 공간 변화는 없음)에서 River는 decoy를 실제 공간 변화보다 위에 둔다 (AUROC 0.00~0.06, 상위 50 중 decoy 20개). stORCA는 둘을 가른다 (level 2, 3에서 0.78, 0.90). Synthetic 데이터에 동물 효과를 넣으면 River는 0.22~0.80으로 떨어진다. Claim 1은 registration과 domain score가 보지 못하는 것에 관한 것이다 |
| River의 상위 20에는 사라진 조직의 marker가 stORCA보다 적다 (0.10, 0.30) | River는 위치끼리 비교하지 않으므로 깨질 대응 가정이 없다. Claim 3은 registration과 domain 방법에 관한 것이다. River도 panel에 보인다 |
| LIBD 6 vs 6 설계는 거짓 labeling에서 최대 312개를 call한다 | 한 donor의 인접 section은 기술적 반복이다. 한 donor의 두 section을 같은 쪽에 두는 거짓 labeling은 donor를 조건으로 바꾼다. 2026-11-20 오후 확인 (null 6 vs 6): 한 그룹에 각 donor의 section이 최대 2장인 labeling 108개는 모두 call 0이고, call은 한 그룹에 한 donor의 section이 3~4장 들어간 labeling에서 나온다 (최대 255). 보정에는 donor당 section 하나인 설계만 쓴다 |
| Cortex stab wound에서 stORCA는 1개만 call한다 | Figure 4는 call이 아니라 상위 목록을 비교한다. 반구 2 vs 2는 power가 작고, claim은 각 목록의 위쪽을 무엇이 채우는지에 관한 것이다 |
| Synthetic domain 안 이동에서 강도가 커질수록 call이 10개에서 0개로 준다 | 순위는 0.97~1.00을 유지한다. 줄어드는 것은 이 시나리오에서 강도와 함께 $\Delta$가 줄기 때문이고 (Fix 4), 검정 때문이 아니다 |
| 시나리오 11 (새 niche)에는 강도 0만 있다 | probe 순위와 함께 한 조건으로 보인다. 강도 series는 시나리오 08~10이 담당한다 |
| Synthetic rearrangement 실험은 CODA와 STcompare가 속는 것을 보여주지 않는다 | 맞다. 이들은 probe가 강한 marker라서 강도 0을 포함한 모든 level에서 probe를 높게 매긴다 (30.5~34.7). Panel 4g는 stORCA가 속지 않는다는 것만 보여주고, claim 3의 경쟁 방법 대비는 실제 cortex와 colitis 데이터 (panel a~f)에서 온다. 거기서는 사라진 조직이 하나의 region이고 registration이 그것을 다른 조직 위에 놓는다 |
| Q 리포트는 아직 v3 숫자를 인용한다 | v4 변화는 작다 (ARTISTA call 113 대 115, colitis 29 대 27). 구성안은 v4 표를 쓰고 리포트는 갱신한다 |
