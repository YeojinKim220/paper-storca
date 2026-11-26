# Q2 replicate 보정: 단일 쌍 순위가 무엇을 잡는지, 가짜 라벨에서 replicate 대조가 어떻게 행동하는지, 단일 쌍 null이 왜 너무 좁은지, 어떤 예시가 살아남는지

이 노트는 노트북 [12-q2-replicate-calibration.ipynb](12-q2-replicate-calibration.ipynb)를 section 순서대로 설명한다. 흐름은 하나다. (1) 문제: 단일 쌍 방법의 상위 "조건" 유전자는 replicate 두 개를 비교해도 상위에 오고, 단일 쌍 검정은 replicate 쌍에서 대부분의 유전자를 call한다. (2) 확인: stORCA의 replicate 대조는 가짜 라벨에서 call을 내지 않고, replicate 설계는 어떤 점수의 순위든 바로잡으며, 그 설계를 call로 바꾸는 것은 ROS뿐이다. (3) 원인: 한 쌍 안의 변동은 replicate 사이의 변동보다 훨씬 작다. (4) 예시 유전자와, 각 예시가 지도를 보고도 살아남는지. (5) 무엇을 주장할 수 있고 무엇을 먼저 고쳐야 하는지.

이 흐름은 outline의 claim 3, replicate 보정 ([0-paper-outline-natcomm.md](../0-Paper-Draft/0-paper-outline-natcomm.md)의 Figure 3)을 뒷받침한다. outline의 Figure 3b는 이제 section 1b이고, section 1c는 한 쌍을 그 쌍의 유전자만으로 보정할 수 있는지 검사하며, 2026-11-16 재실행부터 colitis도 포함된다. 아직 어긋나는 점이 하나 있어 여기 적는다. section 1의 겹침 결과는 HPOA에서만 모든 방법에 성립한다. CODA는 대부분의 데이터에서 깨끗해 보이지만, 그것은 대부분 유전자 집합의 인공물이다 (section 1).

모든 그림은 노트북 그림을 그대로 복사했다 (PDF는 `5-Case-Study-Comparison/fig/`, PNG 사본은 `5-Case-Study-Comparison/fig/12-q2-replicate-calibration/`). 링크가 아닌 경로는 프로젝트 루트 기준이다. "이 보고서에서 계산"이라고 표시한 숫자는 저장된 결과 파일에서 계산했고 노트북에는 없다.

**데이터.** 여러 replicate가 있는 case study 여섯 개. within 쌍은 같은 조건의 두 section을 비교하므로, 그 안의 차이는 정의상 replicate 변동이다. between 쌍은 control section과 처리 section을 비교한다.

| Case | 설계 | Between 쌍 | Within 쌍 | 가짜 라벨 | stORCA가 검정한 유전자 |
|---|---|---|---|---|---|
| LIBD DLPFC (조건 없음, null 데이터) | 3 vs 3 | 9 | 6 | 9 | 3000개 중 664 |
| HPOA (naive vs aggression) | 3 vs 3 | 9 | 6 | 9 | 160개 중 149 |
| NRDR V1 posterior (정상 사육 vs 암 사육) | 2 vs 2 | 4 | 2 | 2 | 500개 중 377 |
| NRDR V1 anterior | 2 vs 2 | 4 | 2 | 2 | 500개 중 363 |
| ARTISTA (2 DPI vs 20 DPI) | 3 vs 3 | 9 | 6 | 9 | 3000개 중 782 |
| Colitis (D0 vs D3) | 3 vs 4 | 12 | 9 | 34 | 989개 중 490 |

여기의 colitis는 `5-Case-Study-Colitis-Replicate`다: 마우스마다 section 하나의 slice 1, D0 마우스 `m3a`, `m6`, `m7` 대 D3 마우스 `m1`~`m4` (biological replicate). 2026-11-16에 고른 slice 세트 (D0 `0629-m3a-r2` slice 1~3, D3 `0924-m1-r1` 또는 `0924-m3-r1` slice 1~3)는 조건마다 한 마우스의 slice 셋을 쓰므로 이것과 다르다. 보정에는 마우스 단위 설계가 맞다. 한 마우스의 slice들은 replicate 변이를 과소평가하기 때문이다 (Q1에서 그런 설계는 502개 중 425개 유전자를 call한다).

**점수.** 유전자 $g$와 쌍 $p$에 대해, $x$는 source 발현, $y$는 매칭된 target 발현, $Q(v)=\tilde v^\top W\tilde v$는 중심화한 공간 이차형식이다.

$$
\mathrm{ROS}_{g,p}=\frac{Q(x-y)}{Q(x)+Q(y)},\qquad
\Delta_g=\overline{\mathrm{ROS}}_{g,\text{between}}-\overline{\mathrm{ROS}}_{g,\text{within}} .
$$

ROS는 두 section이 그 유전자의 공간 구조를 공유하면 0 근처, 전혀 공유하지 않으면 1 근처다. $\Delta_g$는 between 쌍이 within 쌍보다 얼마나 높은지다. call은 쌍 점수에 대한 $\Delta_g>0$의 one-sided unweighted limma 검정, BH $<0.05$이다.

**v3 pipeline의 규칙.**

1. 유전자 gate: study의 모든 section에서 Moran's I가 $\le 0.03$이면 유전자 전체를 뺀다.
2. 평가 가능성: 쌍의 60% 미만에서만 점수를 낼 수 있으면 유전자 전체를 뺀다.
3. 남은 유전자는 모든 쌍의 ROS를 쓴다. Blank probe는 검정하지 않는다.

## 0. Summary

| 단계 | 결과 |
|---|---|
| 1. 문제 | HPOA에서 각 방법의 between 상위 20 유전자 중 0.50~0.80이 within 상위 20에도 든다 (우연 수준 0.13). HPOA 밖에서는 섞여 있다: River 0.15~0.63, ARTISTA의 SpaceExpress 0.94, CODA 0.00~0.14. CODA의 낮은 값은 panel 전체 유전자로 순위를 매긴 탓이다. ARTISTA에서 stORCA가 검정한 782개로 한정하면 CODA는 0.14에서 0.55로 오른다 |
| 1b. 단일 쌍 검정 | stORCA의 이전 단일 쌍 검정, SpaceExpress, STcompare가 within 쌍에서 유전자의 34%~94%를 call한다 (데이터별 중앙값). 기대값은 5%다. between 쌍은 0.00~0.18만 더 높다 |
| 1c. Gene-bulk null | 각 유전자를 같은 쌍에서 구조 강도가 가장 가까운 유전자 50개와 비교하면, within 쌍 call이 34%~94%에서 2%~8% (BH)로 떨어진다. between 쌍에서는 replicate 설계 call의 18%~77%를 회수한다 (p < 0.05). within 쌍에서는 0%~14%다. 나아졌지만 아직 쓸 수 있는 단일 쌍 검정은 아니다. within 쌍은 명목 수준보다 높고, 전체 call 비율은 between과 within이 같으며, BH에서는 replicate 설계 call의 0%~55%만 회수한다 |
| 2. Replicate 대조 | LIBD: 진짜 라벨과 가짜 라벨 9개 모두에서 664개 중 0 call. HPOA: 11 call, 가짜 라벨에서 0. NRDR: 32, 11 call, 가짜 라벨에서 0, 다만 가짜 라벨이 2개뿐이다. ARTISTA: 115 call, 가짜 라벨 9개 중 1개가 18. Colitis: 27 call, 가짜 라벨 34개 중 1개가 26 |
| 2b. Replicate 설계, 점수 | replicate 설계로 읽으면, LIBD 밖의 방법·데이터 조합 19개 중 15개에서 진짜 라벨의 상위 효과가 가장 크다. 모든 방법이 그렇다. LIBD에서는 10개 중 4위다 |
| 2c. 네 비교 | 1 vs 1은 모든 방법에서 두 읽기 모두 실패한다. replicate 설계는 모든 방법의 순위를 바로잡는다. 그 설계를 call로 바꾸는 것은 ROS뿐이다 (경쟁 방법 0~3 call, ARTISTA의 River만 예외) |
| 3. 원인 | ROS의 replicate 분산은 한 쌍 안 매칭 분산의 26~155배다 (유전자 중앙값). 한 쌍 안에서 만든 null은 replicate 차이를 담을 수 없다 |
| 4. 위양성 예시 | `Blank_2`, `Mki67`, `Oxt`는 성립한다. `Gbx2`는 예시로는 성립하지만 노트북 설명이 틀렸다. `Sema4d`는 성립하지 않는다: replicate 변동이 아니라 pseudobulk DE 유전자다 (전역 FDR 0.005) |
| 5. 진양성 예시 | `Cpne5`는 성립한다 (within ROS 0.23, between 0.55, BH 0.008). 다만 River와 SpaceExpress도 높게 매기고 전역 DE 유전자다 |
| 6. Fix 또는 defend | 수정 네 개: River 예시 빼기, `Gbx2` 문장 고치기, 26 call이 나온 colitis 가짜 라벨 확인, section 1 그림을 모든 방법에서 같은 유전자로 순위 매기기. 나머지 문제는 section 6에 방어 논리와 함께 적었다 |

## 1. 단일 쌍 방법: between 상위 유전자가 within 쌍에서도 상위인가? (노트북 section 1)

**질문.** 한 쌍의 section으로 유전자 순위를 매기는 방법이라면, 그 방법의 상위 "조건" 유전자는 두 section이 같은 조건일 때의 상위 유전자와 다른가?

**쉽게 말하면.** 어떤 방법으로 naive section과 aggression section을 비교해, 가장 "변한" 유전자 20개를 적는다. 이번에는 아무것도 변하지 않은 naive section 두 개를 비교해 다시 20개를 적는다. 두 목록이 거의 같으면, 첫 목록을 aggression의 효과로 읽을 수 없다. 그 방법은 두 section 사이에서 늘 다른 유전자를 찾고 있는 것이다.

**왜 중요한가.** CODA, River, STcompare, SpaceExpress는 한 쌍을 비교하고 replicate 수준의 검정이 없다. 이 검사는 그 출력을 조건 효과로 읽을 수 있는지 자체를 묻는다. 그들 중 누구에게도 없는 replicate 설계가 필요한 이유다.

**구현** (`5-Case-Study-Comparison/02-compare-methods.py`, 노트북은 `res/Comparison/<case>-method-summary.csv`의 `top_between_in_top_within` 열을 읽는다).

1. 방법마다 모든 쌍이 고유 점수를 받는다. 클수록 차등적이도록 방향을 맞춘다 (CODA: CCI의 음수, River: 순위의 음수, STcompare: 상관의 음수, SpaceExpress: 점수의 음수, "stORCA single pair": ROS).
2. 유전자마다 between 쌍 평균과 within 쌍 평균을 따로 구한다.
3. 각 평균의 상위 $N$ 유전자를 고른다. $N=\max(20,\ \text{stORCA call 수})$. 그래서 LIBD, HPOA, NRDR anterior는 $N=20$, NRDR posterior는 32, ARTISTA는 115다.
4. 겹침을 보고한다.

$$
\text{overlap}=\frac{|\text{top}_N(\text{between})\cap\text{top}_N(\text{within})|}{N} .
$$

방법은 case의 모든 쌍에 결과가 있어야 하며, 아니면 빠진다. 그래서 STcompare는 HPOA에만, SpaceExpress는 HPOA와 ARTISTA에만 있고, River는 LIBD에 없다.

![between 상위 유전자와 within 상위 유전자의 겹침](fig/12-q2-replicate-calibration/q2-top-between-in-top-within.png)

*데이터마다 막대 묶음 하나, 방법마다 막대 하나 (legend: `fig/12-q2-replicate-calibration/q2-method-legend.png`). 높이: between 상위 $N$ 유전자 중 within 상위 $N$에도 든 비율. 요점: HPOA에서는 모든 방법이 0.50 이상이다. 출처: [12-q2-replicate-calibration.ipynb](12-q2-replicate-calibration.ipynb) section 1.*

**결과.** 노트북 값과, $n$개 중 $N$개를 무작위로 두 번 고를 때의 우연 수준 $N/n$ (이 보고서에서 계산):

| Case | $N$ | stORCA single pair | CODA | River | STcompare | SpaceExpress | 우연, stORCA 검정 유전자 | 우연, panel 전체 |
|---|---|---|---|---|---|---|---|---|
| LIBD | 20 | 0.70 | 0.00 | 실행 안 함 | 실행 안 함 | 실행 안 함 | 0.03 | 0.007 |
| HPOA | 20 | 0.80 | 0.75 | 0.60 | 0.55 | 0.50 | 0.13 | 0.13 |
| NRDR posterior | 32 | 0.47 | 0.09 | 0.53 | 실행 안 함 | 실행 안 함 | 0.08 | 0.06 |
| NRDR anterior | 20 | 0.35 | 0.00 | 0.15 | 실행 안 함 | 실행 안 함 | 0.06 | 0.04 |
| ARTISTA | 115 | 0.64 | 0.14 | 0.63 | 실행 안 함 | 0.94 | 0.15 | 0.04 |
| Colitis | 27 | 0.63 | 0.07 | 0.81 | 실행 안 함 | 실행 안 함 | 0.06 | 0.03 |

**stORCA 단일 쌍 점수도 같은 문제가 있다 (0.35~0.80).** 점수만으로는 해결되지 않는다. 해결하는 것은 replicate 설계다.

**방법 사이의 비교가 공정한가?** 아직 아니다. stORCA 행은 stORCA가 검정한 유전자 (ARTISTA에서 782개)만 순위를 매기고, 다른 행은 panel 전체 (3000개)를 매긴다. CODA의 상위 목록은 공간 구조가 거의 없는 유전자로 채워진다: ARTISTA에서 CODA의 between 상위 115개 중 4개만 검정된 782개에 든다. 같은 782개로 한정하면 (이 보고서에서 `res/Comparison/<case>-gene-table.csv`로 계산):

| Case | CODA, 전체 유전자 | CODA, stORCA 검정 유전자 | River, 전체 유전자 | River, stORCA 검정 유전자 |
|---|---|---|---|---|
| LIBD | 0.00 | 0.10 | 실행 안 함 | 실행 안 함 |
| HPOA | 0.75 | 0.70 | 0.60 | 0.60 |
| NRDR posterior | 0.09 | 0.09 | 0.53 | 0.53 |
| NRDR anterior | 0.00 | 0.00 | 0.15 | 0.15 |
| ARTISTA | 0.14 | 0.55 | 0.63 | 0.66 |
| Colitis | 0.07 | 0.11 | 0.81 | 0.81 |

**판정: 부분적.** "단일 쌍 방법의 상위 조건 유전자는 대부분 상위 replicate 유전자다"는 HPOA에서 다섯 점수 모두에, 대부분의 데이터에서 River, SpaceExpress, stORCA 단일 쌍 ROS에 성립한다. NRDR와 LIBD의 CODA에는 성립하지 않는다 (우연 수준). outline은 "경쟁 방법이 잘 보정된 경우도 보여라"고 하므로 NRDR의 CODA는 그림에 넣는다. 다만 거기서 낮은 겹침은 CODA의 상위 목록이 불안정하다는 뜻이지 맞다는 뜻이 아니라는 설명을 붙인다.

결과 파일: `5-Case-Study-Comparison/res/Comparison/<case>-method-summary.csv` (열 `top_between_in_top_within`), `<case>-gene-table.csv` (열 `<method>_between`, `<method>_within`).

## 1b. 단일 쌍 검정: replicate 쌍에서 call되는 유전자 (노트북 section 1b)

**질문.** 단일 쌍 검정이 같은 조건의 두 section을 비교하면 유전자를 몇 개 call하는가?

**쉽게 말하면.** section 1은 순위를 봤다. 어떤 방법은 한 쌍에 대해 유전자마다 p-value도 준다. 그런 검정을 naive section 두 개에 적용한다. 아무것도 변하지 않았으므로 모든 call은 위양성이고, FDR 0.05에서 보정된 검정은 유전자의 약 5%를 call해야 한다. 절반을 call한다면 그 p-value는 "조건이 이 유전자를 바꿨다"가 아니라 "이 두 section은 똑같지 않다"를 재는 것이고, 그것은 어떤 두 section에서도 참이다. outline의 panel 3b다.

**구현** (노트북 section 1b; 각 방법의 쌍별 결과 파일).

1. 한 쌍에서 모든 유전자에 p-value를 주는 방법:
   - **stORCA single pair**: 우리의 이전 단일 쌍 검정. 매칭 residual의 sign-flip 검정 (9999번), 그 쌍에서 검정한 유전자에 대해 BH (`res/SysVI/<pair prefix>-ratio-capgene-scores.csv`, 열 `pvalue_adj_bh`). outline은 이것을 실패하는 방법 중 하나로 보이라고 한다.
   - **SpaceExpress**: 고유의 유전자별 FDR (열 `fdr`), FDR $<0.05$에서 call.
   - **STcompare**: 공간 상관의 permutation p-value (`pValuePermuteX`와 `pValuePermuteY` 중 큰 값), 쌍마다 BH. STcompare는 유사성을 검정하므로, 유의하게 양의 상관이 아닌 유전자를 차등으로 센다.
2. 쌍마다: call된 유전자 수를 그 쌍에서 방법이 검정한 유전자 수로 나눈다. Blank probe는 뺀다.
3. within 쌍과 between 쌍을 따로 보인다. CODA와 River는 p-value가 없어 section 1에 남는다.

![within 쌍과 between 쌍에서의 단일 쌍 검정](fig/12-q2-replicate-calibration/q2-single-pair-test-call-fraction.png)

*방법마다 panel 하나, 가로축은 데이터. 회색 점: within 쌍 (같은 조건). 색 점: between 쌍. 검은 눈금: 중앙값. 점선: 0.05 (legend: `fig/12-q2-replicate-calibration/q2-single-pair-test-legend.png`). 요점: within 쌍은 0.34~0.94이고 0.05 근처에 오지 않는다. 출처: [12-q2-replicate-calibration.ipynb](12-q2-replicate-calibration.ipynb) section 1b.*

**결과.**

| Case | 방법 | 쌍당 검정 유전자 | Within 쌍, 중앙값 (범위) | Between 쌍, 중앙값 |
|---|---|---|---|---|
| LIBD | stORCA single pair | 1081 | 0.52 (0.42~0.62) | 0.40 |
| HPOA | stORCA single pair | 151 | 0.94 (0.93~0.98) | 0.97 |
| HPOA | SpaceExpress | 155 | 0.34 (0.25~0.39) | 0.37 |
| HPOA | STcompare | 160 | 0.73 (0.38~0.95) | 0.89 |
| NRDR posterior | stORCA single pair | 392 | 0.77 (0.65~0.88) | 0.95 |
| NRDR anterior | stORCA single pair | 397 | 0.84 (0.82~0.86) | 0.84 |
| ARTISTA | stORCA single pair | 957 | 0.59 (0.51~0.65) | 0.63 |
| ARTISTA | SpaceExpress | 3000 | 0.61 (0.55~0.71) | 0.63 |
| ARTISTA | STcompare | 3000 | 0.90 (0.87~0.93) | 0.94 |
| Colitis | stORCA single pair | 516 | 0.87 (0.70~0.92) | 0.89 |

**모든 단일 쌍 검정이 replicate 쌍에서 유전자의 34%~94%를 call한다. 5% 수준의 7~19배다.** between 쌍은 0.00~0.18만 더 높고, 조건이 없는 LIBD에서는 within 쌍이 between 쌍보다 높다 (0.52 대 0.40). 따라서 단일 쌍 p-value는 조건 효과와 replicate 변동을 구분하지 못한다. 이유는 section 3에 있다: 단일 쌍 검정의 null은 한 쌍 안의 변동만 안다.

**판정: 성립.** outline panel 3b의 직접 증거이고, 검정이 있는 세 방법 모두에 성립한다.

결과 파일: `res/Comparison/q2-four-comparisons.csv` (열 `1v1 test, within`); 쌍별 파일은 위에 적었다.

## 1c. 그 쌍의 다른 유전자로 만든 단일 쌍 null: gene-bulk empirical null (노트북 section 1c)

**질문.** replicate 없이, 같은 쌍의 다른 유전자를 null로 써서 한 쌍을 보정할 수 있는가?

**쉽게 말하면.** section 1b는 단일 쌍 검정의 null이 매칭 잡음만 알기 때문에 대부분의 유전자를 call한다는 것을 보였다. `99-Notes/03-one-vs-one-analysis-history.md` (section 3.4)의 gene-bulk null은 각 유전자를 반 친구와 비교해 상대평가한다. 반 친구는 같은 쌍에서 구조 강도가 가장 가까운 다른 유전자 50개다. 구조 강도를 맞추는 이유는 구조가 약한 유전자는 변화가 없어도 ROS가 높기 때문이다. 유전자의 ROS가 반 친구들의 전형적인 ROS보다 훨씬 높으면 call한다. 다른 section은 쓰지 않는다. 대가는 가정 하나다: 대부분의 유전자는 변하지 않으므로, 반 친구가 "변화 없음"의 모습을 보여 준다.

**구현** (노트북 section 1c; stORCA가 남긴 유전자의 v3 ROS, `storca-v3-rep1-<case>-limma-pair-scores.csv`).

1. 구조 강도 $\ell_g=\log\,\mathrm{median}_s z_{\mathrm{den},s}$ (열 `z_den_median`, 양수인 유전자).
2. 쌍 $p$의 유전자 $g$에 대해, 같은 쌍에서 $\ell$이 $\ell_g$에 가장 가까운 다른 유전자 50개의 집합 $N_g$를 잡는다:

$$
z_g=\frac{\mathrm{ROS}_g-\mathrm{median}_{h\in N_g}\mathrm{ROS}_h}{1.4826\cdot\mathrm{MAD}_{h\in N_g}\mathrm{ROS}_h},\qquad p_g=1-\Phi(z_g),
$$

   그 쌍의 유전자에 대해 BH.
3. 데이터마다 두 가지를 본다: within 쌍에서 call된 유전자 비율 (위양성), 그리고 section 2의 replicate 설계 call (진짜 라벨) 중 한 쌍에서 call되는 비율을 between 쌍과 within 쌍에서 비교한 것.

![Gene-bulk null](fig/12-q2-replicate-calibration/q2-gene-bulk-null.png)

*왼쪽: section 1b의 sign-flip 검정 (FDR < 0.05). 가운데: gene-bulk null (FDR < 0.05). 오른쪽: replicate 설계 call 중 gene-bulk null이 한 쌍에서 call한 비율 (p < 0.05). 회색: within 쌍. 빨강: between 쌍. 검은 눈금: 중앙값. 점선: 0.05. 요점: 거짓 call은 명목 수준 근처로 떨어지고, between 쌍에서는 replicate 설계 유전자가 within 쌍보다 훨씬 자주 잡힌다. 출처: [12-q2-replicate-calibration.ipynb](12-q2-replicate-calibration.ipynb) section 1c.*

**결과** (쌍에 대한 중앙값; "회수"는 replicate 설계 call 중 한 쌍에서 call된 비율).

| Case | 쌍 | Sign flip, call 비율 (BH) | Gene bulk, call 비율 (p < 0.05) | Gene bulk, call 비율 (BH) | Replicate call 회수 (p < 0.05) | 회수 (BH) |
|---|---|---|---|---|---|---|
| LIBD | within | 0.52 | 0.12 | 0.05 | call 없음 | call 없음 |
| LIBD | between | 0.40 | 0.10 | 0.04 | call 없음 | call 없음 |
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

**gene-bulk null은 과다 call의 대부분을 없애고, between 쌍에서는 맞는 유전자를 가리킨다.** within 쌍은 BH에서 0.52~0.94에서 0.02~0.08로 떨어진다. between 쌍에서는 $p<0.05$에서 replicate 설계 call의 18%~77%를 찾고, within 쌍에서는 0%~14%다.

**그래도 한 쌍으로 call을 낼 수 있게 되지는 않는다.**
- within 쌍이 여전히 명목 수준보다 높다: $p<0.05$에서 7%~14%, BH에서 2%~8%. 정확한 null이라면 각각 약 5%, 약 0이어야 한다.
- 전체 call 비율이 within 쌍과 between 쌍에서 같다 ($p<0.05$에서 0.10~0.14). 한 쌍의 call로는 그 쌍에 조건 효과가 있는지 알 수 없다.
- BH에서는 replicate 설계 call의 0% (HPOA)~55% (NRDR anterior)만 회수한다.
- 이 null은 "이 쌍 안에서, 이 유전자의 ROS가 구조에 비해 높은가?"에 답하고, 대부분의 유전자가 변하지 않는다고 가정한다. 전사체의 많은 부분이 변하면 반 친구도 같이 올라간다 (노트 03의 colitis D3 대 D9: replicate null 35 call에 대해 8 call).

**판정: 보정은 나아지지만, 한 쌍은 보정되지 않는다는 결론은 그대로다.** gene-bulk null은 지금까지 잰 단일 쌍 방법 중 가장 낫고, replicate가 없을 때 순위용으로 제시할 수 있다. call에는 여전히 replicate 설계가 필요하다.

결과 파일: `res/Comparison/q2-gene-bulk-null-pairs.csv` (쌍마다 한 행).

## 2. stORCA: 진짜 라벨 대 가짜 라벨 (노트북 section 2)

**질문.** 조건을 따르지 않는 방식으로 section을 두 그룹에 나누면, stORCA는 그래도 유전자를 call하는가?

**쉽게 말하면.** naive 3개와 aggression 3개가 있을 때, 진짜 라벨은 naive 3개를 한 그룹에 넣는다. 가짜 라벨은 예를 들어 naive 2개와 aggression 1개를 한 그룹에 넣는다. 가짜 라벨에서 "between" 쌍은 진짜 between 쌍과 replicate 쌍이 섞인 것이므로, 보정된 검정이라면 call이 없거나 거의 없어야 한다. LIBD는 더 엄격하다: 조건 자체가 없으므로 진짜 라벨에서도 0 call이어야 한다.

**구현** (`storca/replicate_case_studies.py`의 limma 단계; 노트북은 `<case folder>/res/stORCA/storca-v3-rep1-<case>-limma-splits.csv`에서 `weighting == "unweighted"` 행의 `limma_bh_one` 열을 읽는다).

1. 분석 단위: 쌍 점수. 3 vs 3이면 유전자당 점수 15개 (between 9, within 6), 2 vs 2면 6개 (between 4, within 2).
2. 유전자별 모형: $\mathrm{ROS}_{g,p}=\alpha_g+\Delta_g\,b_p+\varepsilon_{g,p}$, between 쌍이면 $b_p=1$, within 쌍이면 0. 귀무가설은 $\Delta_g=0$, 대립은 $\Delta_g>0$. limma의 moderated $t$ (구조 강도에 대한 trend가 있는 eBayes)를 one-sided로 쓰고, 검정한 유전자에 대해 BH.
3. 같은 크기의 두 그룹으로 section을 나누는 다른 모든 방법에 같은 fit을 반복한다. 3 vs 3은 가짜 라벨 9개, 2 vs 2는 2개다.
4. 노트북은 진짜 라벨의 call 수와 가짜 라벨의 최대 call 수를 보고한다.

**설계의 통계적 결과.** 쌍 점수 15개는 section 6개에서 나오므로 독립이 아닌데, limma p-value는 독립인 것처럼 다룬다. 가짜 라벨이 그 점을 확인한다. 2 vs 2에서는 확인이 약하다: 가짜 라벨이 2개뿐이라, NRDR의 "가짜 라벨에서 0 call"은 2개 중 0이다.

**예시 (HPOA, `res/Comparison/hpoa-gene-table.csv`에서).**

| 유전자 | 평균 ROS, within | 평균 ROS, between | $\Delta$ | $t$ | BH | Call |
|---|---|---|---|---|---|---|
| `Cpne5` | 0.231 | 0.545 | 0.314 | 4.93 | 0.008 | 예 |
| `Oxt` | 0.676 | 0.868 | 0.192 | 기록 없음 | 0.173 | 아니오 |

`Oxt`가 between ROS가 더 높으므로 (0.868) 단일 쌍 순위에서는 맨 위에 온다. 그러나 replicate끼리 이미 다르므로 (0.676) 퍼짐에 비해 초과분이 작다. `Cpne5`는 between ROS가 낮지만 replicate끼리 일치하므로 (0.231) 초과분이 뚜렷하다.

![진짜 라벨 대 가짜 라벨](fig/12-q2-replicate-calibration/q2-storca-true-vs-null-calls.png)

*빨강: 진짜 라벨의 call. 회색: 가짜 라벨 중 가장 많은 call 수. 요점: LIBD는 0과 0이다. 출처: [12-q2-replicate-calibration.ipynb](12-q2-replicate-calibration.ipynb) section 2.*

**결과.**

| Case | 검정 유전자 | Call, 진짜 라벨 | call이 하나라도 있는 가짜 라벨 | 가짜 라벨의 최대 call |
|---|---|---|---|---|
| LIBD | 664 | 0 | 9개 중 0 | 0 |
| HPOA | 149 | 11 | 9개 중 0 | 0 |
| NRDR posterior | 377 | 32 | 2개 중 0 | 0 |
| NRDR anterior | 363 | 11 | 2개 중 0 | 0 |
| ARTISTA | 782 | 115 | 9개 중 1 | 18 |
| Colitis, 3 vs 4 | 490 | 27 | 34개 중 7 | 26 |

**가짜 라벨의 call은 위양성인가?** 늘 그렇지는 않다. 실제 효과가 있는 데이터에서는 가짜 라벨도 진짜 대조의 일부를 품는다. 두 경우를 봐야 한다 (이 보고서에서 `limma-splits.csv`로 계산):

- ARTISTA: 18 call이 나온 라벨은 `dpi2-r1, dpi2-r2, dpi20-r1` 대 `dpi2-r3, dpi20-r2, dpi20-r3`이다. 같은 라벨이 2 대 20 DPI time-course 실행에서는 10 call을 낸다. 일반적인 보정 실패가 아니라 특정 section (`dpi2-r3` 또는 `dpi20-r1`)을 가리킨다.
- Colitis: 라벨 하나 (`D0-m3a, D0-m6, D3-m2` 대 나머지)가 26 call을 내서 진짜 라벨 (27)과 거의 같다. 다른 하나 (`D3-m1, D3-m2, D3-m3` 대 나머지)는 10을 내지만, 진짜와 section 하나만 다르므로 call이 나올 만하다.

**판정: null 데이터 (LIBD)와 HPOA에서 성립; ARTISTA와 colitis는 section 확인이 필요하다.** "보정됨"은 일반적 진술이 아니라 "LIBD와 HPOA의 모든 가짜 라벨에서 0 call"로 써야 한다.

같은 replicate 대조를 경쟁 방법의 쌍 점수에 적용한 결과는 이제 노트북 section 2c에 있다.

결과 파일: `<case folder>/res/stORCA/storca-v3-rep1-<case>-limma-splits.csv` (열 `labeling`, `group_a`, `limma_bh_one`).

## 2b. 점수로 읽은 replicate 설계: 진짜 라벨과 가짜 라벨의 상위 효과 (노트북 section 2b)

**질문.** replicate 설계는 쓰되 검정은 없이, 각 방법의 점수 순위가 조건을 가리키는가?

**쉽게 말하면.** section 2는 call을 셌다. 여기서는 같은 설계를 점수로만 읽는다. 유전자마다 between 쌍 평균 점수에서 within 쌍 평균 점수를 뺀다. 차이가 가장 큰 유전자 20개 (stORCA call이 더 많으면 그만큼)를 골라 차이를 평균한다: 그 라벨의 "상위 효과"다. 모든 가짜 라벨에도 같은 것을 한다. 점수와 설계가 조건을 replicate 변동과 구분한다면, 진짜 라벨의 상위 효과가 가장 커야 한다. 조건이 없는 LIBD에서는 진짜 라벨이 두드러지지 않아야 한다.

**구현** (노트북 section 2b).

1. 각 방법의 쌍 점수는 section 1과 같이 클수록 차등적이도록 맞추고, stORCA가 검정한 유전자로 한정한다 (모든 방법이 같은 유전자 집합).
2. 각 라벨 $L$ (진짜와 section 2의 모든 가짜)에 대해:

$$
\Delta_g^{L}=\overline{s}_{g,\text{between}(L)}-\overline{s}_{g,\text{within}(L)},\qquad
T^{L}=\operatorname{mean}\{\Delta_g^{L}: g\in\text{top}_N(\Delta^{L})\},
$$

   $s$는 방법의 점수, $N$은 section 1과 같다.
3. 모든 라벨 중 $T$로 매긴 진짜 라벨의 순위 (1 = 가장 큼)와, 점수 단위가 다른 방법을 한 축에 놓기 위해 $T^{\text{true}}$를 가짜 라벨 $T$의 중앙값으로 나눈 값을 보고한다.

![진짜 라벨과 가짜 라벨의 상위 효과](fig/12-q2-replicate-calibration/q2-replicate-score-true-vs-null.png)

*방법마다 panel 하나, 가로축은 데이터, log 축. 마름모: 진짜 라벨. 회색 점: 가짜 라벨. 파선: 가짜 라벨의 중앙값 (legend: `fig/12-q2-replicate-calibration/q2-replicate-score-legend.png`). 요점: 대부분의 데이터와 방법에서 마름모가 모든 회색 점 위에 있고, LIBD에서는 아니다. 출처: [12-q2-replicate-calibration.ipynb](12-q2-replicate-calibration.ipynb) section 2b.*

**결과.** 상위 효과로 매긴 진짜 라벨의 순위 (1 = 가장 큼).

| Case | 라벨 수 | stORCA ROS | CODA | River | STcompare | SpaceExpress |
|---|---|---|---|---|---|---|
| LIBD (조건 없음) | 10 | 4 | 4 | 실행 안 함 | 실행 안 함 | 실행 안 함 |
| HPOA | 10 | 1 | 1 | 1 | 1 | 6 |
| NRDR posterior | 3 | 1 | 3 | 1 | 실행 안 함 | 실행 안 함 |
| NRDR anterior | 3 | 1 | 1 | 1 | 실행 안 함 | 실행 안 함 |
| ARTISTA | 10 | 1 | 1 | 1 | 1 | 1 |
| Colitis | 35 | 3 | 18 | 1 | 실행 안 함 | 실행 안 함 |

stORCA ROS에서 진짜 라벨의 상위 효과는 가짜 라벨 중앙값의 2.8배 (HPOA), 4.2배 (NRDR posterior), 1.6배 (NRDR anterior), 2.4배 (ARTISTA), 1.5배 (colitis)이고, LIBD에서는 1.1배다.

**읽기:**

- **replicate 설계는 거의 모든 점수의 순위를 바로잡는다.** LIBD 밖에서 진짜 라벨은 방법·데이터 조합 19개 중 15개에서 1위다. 예외는 NRDR posterior와 colitis의 CODA, HPOA의 SpaceExpress, colitis의 stORCA다.
- **LIBD는 null답게 행동한다.** 그곳에서 돌린 두 방법 모두 진짜 라벨이 10개 중 4위다.
- **Colitis는 확인이 필요하다.** stORCA에서 가짜 라벨 두 개가 진짜보다 상위 효과가 크다. section 2의 26 call 가짜 라벨과 같은 신호다.

따라서 section 1의 문제는 점수가 아니라 단일 쌍 설계에 있다: 어떤 점수든 replicate 설계로 읽으면 조건을 상위에 둔다. 설계만으로 얻지 못하는 것은 오류율을 아는 call이고, section 2c가 그것을 보인다.

**판정: 성립; colitis가 확인할 한 경우다.**

결과 파일: 노트북에서 쌍 점수로 계산 (`02-compare-methods.py`, 함수 `pair_scores`); 요약은 `res/Comparison/q2-four-comparisons.csv` (열 `rep score, true rank`).

## 2c. 네 비교를 나란히 (노트북 section 2c)

**질문.** 2 x 2 격자 (한 쌍 또는 replicate 설계, 점수 또는 검정)에서 각 방법은 어디에 있는가?

**구현** (노트북 section 2c, `res/Comparison/q2-four-comparisons.csv`로 저장). 1 vs 1 점수 열은 section 1의 겹침을 stORCA가 검정한 유전자로 다시 계산한 것이다. rep 검정 열은 stORCA는 자체 limma fit을, 다른 방법은 `02-compare-methods.py`가 그 쌍 점수에 적용한 같은 replicate 대조 (plain limma, one-sided, BH)를 쓴다 (열 `contrast_limma_bh`, `contrast_null_max`).

**결과.**

| Case | 방법 | 1v1 점수: between 상위가 within 상위에 | 1v1 검정: within 쌍당 call 비율 | rep 점수: 진짜 라벨 순위 | rep 검정: call (가짜 라벨 최대) |
|---|---|---|---|---|---|
| LIBD | stORCA | 0.70 | 0.52 | 10개 중 4 | 0 (0) |
| LIBD | CODA | 0.10 | 검정 없음 | 10개 중 4 | 0 (1) |
| HPOA | stORCA | 0.80 | 0.94 | 10개 중 1 | 11 (0) |
| HPOA | CODA | 0.70 | 검정 없음 | 10개 중 1 | 0 (0) |
| HPOA | River | 0.60 | 검정 없음 | 10개 중 1 | 3 (2) |
| HPOA | STcompare | 0.55 | 0.73 | 10개 중 1 | 1 (0) |
| HPOA | SpaceExpress | 0.50 | 0.34 | 10개 중 6 | 1 (1) |
| NRDR posterior | stORCA | 0.47 | 0.77 | 3개 중 1 | 32 (0) |
| NRDR posterior | CODA | 0.09 | 검정 없음 | 3개 중 3 | 0 (0) |
| NRDR posterior | River | 0.53 | 검정 없음 | 3개 중 1 | 0 (0) |
| NRDR anterior | stORCA | 0.35 | 0.84 | 3개 중 1 | 11 (0) |
| NRDR anterior | CODA | 0.00 | 검정 없음 | 3개 중 1 | 0 (0) |
| NRDR anterior | River | 0.15 | 검정 없음 | 3개 중 1 | 0 (0) |
| ARTISTA | stORCA | 0.64 | 0.59 | 10개 중 1 | 115 (18) |
| ARTISTA | CODA | 0.55 | 검정 없음 | 10개 중 1 | 1 (0) |
| ARTISTA | River | 0.66 | 검정 없음 | 10개 중 1 | 46 (1) |
| ARTISTA | SpaceExpress | 0.90 | 0.60 | 10개 중 1 | 3 (0) |
| Colitis | stORCA | 0.63 | 0.87 | 35개 중 3 | 27 (26) |
| Colitis | CODA | 0.11 | 검정 없음 | 35개 중 18 | 0 (1) |
| Colitis | River | 0.81 | 검정 없음 | 35개 중 1 | 1 (7) |

**열마다 읽기:**

1. **1 vs 1은 두 읽기 모두 실패한다.** 순위는 replicate 사이에서도 반복되고 (section 1), 검정은 replicate 쌍에서 유전자의 3분의 1에서 거의 전부를 call한다 (section 1b). 잴 수 있는 모든 방법에 성립하고, stORCA 자체의 단일 쌍 검정도 포함된다.
2. **replicate 설계는 모든 방법의 순위를 바로잡는다** (section 2b).
3. **그 설계를 call로 바꾸는 것은 ROS뿐이다.** stORCA는 조건이 있는 모든 데이터에서 call을 내고 LIBD에서는 내지 않는다. 경쟁 방법의 점수에 같은 대조를 쓰면 0~3 call이고, 예외는 하나다 (ARTISTA의 River, 46). 차이를 만드는 것은 fit이 아니다: 경쟁 방법에 쓴 plain limma를 ROS에 쓰면 HPOA, ARTISTA, NRDR posterior에서 10, 104, 23 call이고, 가짜 라벨에서는 최대 0, 11, 0이다 (`<case>-method-summary.csv`, 행 `stORCA single pair`).

**따라서 claim 3은 두 부분 모두 성립한다: replicate 설계가 필요하고, 그 replicate 검정을 쓸 수 있게 만드는 것은 공통 척도의 점수다.**

**판정: 성립.** 주장에 반하는 칸은 colitis 하나 (27 call 대 가짜 라벨 하나의 26)이고, section 6의 Fix 항목이다.

## 3. 왜 단일 쌍 검정이 과신하는가 (노트북 section 3)

**질문.** 한 쌍 안에서 볼 수 있는 ROS의 변동은 replicate 쌍 사이의 변동에 비해 얼마나 큰가?

**쉽게 말하면.** 단일 쌍 검정은 가진 한 쌍에서 null을 만들어야 한다. 예를 들어 세포 매칭을 다시 뽑는다. 그것은 같은 두 section을 다시 매칭하면 점수가 얼마나 안정적인지를 알려 준다. 다른 동물을 썼다면 점수가 얼마나 움직였을지는 알려 주지 않는다. 두 번째가 첫 번째의 100배라면, 단일 쌍 검정은 "이 차이가 내 매칭 잡음보다 큰가?"를 묻는 셈이고 거의 모든 유전자가 통과한다.

비슷하게 들리는 두 양을 구분한다:

- **매칭 SD**: 한 쌍 안에서 매칭을 bootstrap으로 다시 뽑을 때 ROS의 SD (열 `boot_sd`).
- **Replicate SD**: case의 within 쌍들 사이 ROS의 SD.

**구현** (노트북 section 3, `storca-v3-rep1-<case>-limma-pair-scores.csv`에서 남은 유전자, 이름이 `rep-`로 시작하는 쌍).

1. 유전자별 매칭 분산 $=\operatorname{mean}_p(\texttt{boot\_sd}_{g,p}^2)$, within 쌍에 대해.
2. 유전자별 replicate 분산 $=\operatorname{Var}_p(\mathrm{ROS}_{g,p})$, 같은 within 쌍에 대해.
3. 유전자별 비율, 그다음 유전자에 대한 중앙값.

![replicate 분산 대 매칭 분산](fig/12-q2-replicate-calibration/q2-replicate-vs-matching-variance.png)

*막대: replicate 분산을 매칭 분산으로 나눈 값의 유전자 중앙값, log 축. 파선: 비율 1. 요점: 모든 데이터가 26 이상이다. 출처: [12-q2-replicate-calibration.ipynb](12-q2-replicate-calibration.ipynb) section 3.*

**결과.**

| Case | 매칭 SD 중앙값 | Replicate SD 중앙값 | 분산 비율 중앙값 |
|---|---|---|---|
| LIBD | 0.028 | 0.171 | 42 |
| HPOA | 0.010 | 0.113 | 155 |
| NRDR posterior | 0.012 | 0.056 | 26 |
| NRDR anterior | 0.012 | 0.147 | 143 |
| ARTISTA | 0.023 | 0.140 | 31 |

**따라서 한 쌍 안에서 만든 null은 SD로 5~12배 너무 좁다.** outline의 숫자 (colitis에서 약 0.006 대 0.15)와 맞는다.

주의할 점. NRDR에서 replicate 분산은 유전자당 값 2개의 분산이라 그 두 행은 거칠다. replicate SD는 두 조건의 within 쌍을 합친다. 어느 쪽도 26~155의 비율을 1로 끌어내릴 수 없다.

**경쟁 방법도 이것으로 설명되는가?** 비율은 ROS와 stORCA 자체의 매칭 bootstrap으로 잰 것이다. 검정이 있는 경쟁 방법은 결과를 section 1b에서 직접 쟀다: SpaceExpress와 STcompare는 replicate 쌍에서 유전자의 34%~90%를 call하고, 이는 한 쌍만 아는 null이 예측하는 대로다.

**판정: 성립.**

결과 파일: `<case folder>/res/stORCA/storca-v3-rep1-<case>-limma-pair-scores.csv` (열 `gene`, `pair`, `ROS`, `boot_sd`).

## 4. HPOA에서 경쟁 방법의 위양성 예시 (노트북 section 4)

**질문.** 경쟁 방법이 맨 위에 두는데, 눈으로 봐도 조건 효과가 아닌 유전자를 가리킬 수 있는가?

**선택 규칙.** 경쟁 방법마다: between 평균의 상위 20과 within 평균의 상위 20에 모두 들고 stORCA가 call하지 않은 유전자를 between 순위로 정렬한다. 다섯 방법이 모두 돈 HPOA를 쓴다. 노트북은 유전자마다 모든 방법의 쌍별 순위와 여섯 section의 발현 지도를 보인다.

**결과, 이 보고서를 위해 지도로 확인.**

| 유전자 | 선택한 방법 | Between 순위 / within 순위 (160개 중) | stORCA | section 중 최대 Moran's I | Pseudobulk DE | 지도에서 보이는 것 | 예시로 성립? |
|---|---|---|---|---|---|---|---|
| `Blank_2` | CODA, STcompare | CODA 3 / 2, STcompare 9 / 5 | 검정 안 함 (blank) | 해당 없음 | 해당 없음 | 음성 대조 probe, 신호 없음 | 예 |
| `Mki67` | STcompare | 5 / 4 | 유전자 gate로 빠짐 | 0.026 | 아니오 (전역 FDR 0.59) | 구조 없음 | 예 |
| `Gbx2` | CODA, STcompare | CODA 2 / 9, STcompare 1 / 8 | gate 통과, 60% 규칙으로 빠짐 | 0.109 (`naive-a6`) | domain FDR 0.049 | `naive-a6` 오른쪽 위에만 hotspot 하나 | 예, 설명 수정 필요 |
| `Oxt` | SpaceExpress | 1 / 18 | 검정함, BH 0.173 | 0.391 | 아니오 (전역 FDR 0.71) | 매우 희소; `naive-a6`에만 hotspot | 예 |
| `Sema4d` | River | 1 / 8 | 검정함, BH 0.157 | 0.141 | 예 (전역 FDR 0.005) | naive section이 aggression section보다 전체적으로 밝다 | 아니오 |

![Blank_2의 쌍별 순위](fig/12-q2-replicate-calibration/q2-example-fp-blank-2-ranks.png)

*방법마다 panel 하나. 회색: within 쌍마다의 순위. 빨강: between 쌍마다의 순위. 순위 1이 가장 차등적이다. 요점: CODA는 음성 대조 probe를 within이든 between이든 모든 쌍에서 2~30위에 둔다. River는 바닥 근처 (87~160위)에 둔다. 출처: [12-q2-replicate-calibration.ipynb](12-q2-replicate-calibration.ipynb) section 4a.*

![Oxt 지도](fig/12-q2-replicate-calibration/q2-example-fp-oxt-maps.png)

*윗줄: naive section. 아랫줄: aggression section. 공통 색 척도 (log1p counts). 요점: 강한 점은 `naive-a6`에만 있으므로, `naive-a6`가 낀 between 쌍은 조건이 아닌 이유로 다르다. 출처: [12-q2-replicate-calibration.ipynb](12-q2-replicate-calibration.ipynb) section 4b.*

**노트북 summary의 두 가지 수정.**

- **`Gbx2`는 "모든 section에서 Moran's I 0.03 이하"가 아니다.** Moran's I가 `naive-a6`에서 0.109, `aggr-a34`에서 0.036이다 (`5-Case-Study-HPOA-MERFISH/res/stORCA/storca-v3-rep1-hpoa-gene-gate.csv`). 규칙 1을 통과했고 규칙 2로 빠졌다. 바른 해석은 `Oxt`와 같다: 한 section에 hotspot이 있다. 그 문장은 `Mki67`에만 맞다.
- **`Sema4d`는 replicate 변동 위양성이 아니다.** River는 between 쌍 9개 모두에서 1~8위, within 쌍에서 4~52위에 두고, pseudobulk 검정도 수준이 다르다고 본다 (전역 FDR 0.005, domain FDR 0.003). River는 실제 수준 변화를 보고하고 있다. stORCA가 call하지 않는 이유는 공간 구조 변화 없는 수준 변화는 outline의 정의상 DSE가 아니기 때문이다. 이것은 Q2가 아니라 Q3 (어떤 종류의 변화인가)의 논점이다. 다른 River 후보도 같다: `Pak3`, `Cspg5`, `Mlc1`, `Cbln2` 모두 전역 FDR 0.005~0.023이다.

**따라서 HPOA에는 깨끗한 River 위양성이 없다.** River에 대해 정직한 진술은 "River의 상위 유전자는 DE 유전자이고, within 쌍에서도 높게 매긴다 (`Pak3`: between 2위, within 1위)"이다.

**blank 예시는 경쟁 방법에 공정한가?** 부분적이다. stORCA는 blank probe에 점수를 내지 않으므로 맞대결 결과가 아니다. CODA와 STcompare가 생물학이 없는 probe를 어디에 두는지만 보인다.

**판정: CODA, STcompare, SpaceExpress에는 성립 (`Blank_2`, `Mki67`, `Gbx2`, `Oxt`); River에는 실패 (`Sema4d`).**

결과 파일: `5-Case-Study-Comparison/res/Comparison/hpoa-gene-table.csv`; 그림 `fig/12-q2-replicate-calibration/q2-example-fp-<gene>-ranks.png`, `-maps.png`.

## 5. HPOA에서 stORCA call의 예시 (노트북 section 5)

**질문.** 모든 replicate에서 같은 변화가 지도에 보이는 call된 유전자가 있는가?

**선택 규칙.** $t$가 가장 큰 stORCA call.

**결과.** `Cpne5`: 평균 ROS within 0.231, between 0.545, $t=4.93$, BH 0.008.

| 방법 | Between 순위 | Within 순위 | 전체 |
|---|---|---|---|
| stORCA ROS | 31 | 109 | 149 |
| SpaceExpress | 2 | 93 | 155 |
| River | 14 | 61 | 160 |
| STcompare | 96 | 125 | 160 |
| CODA | 113 | 125 | 160 |

![Cpne5 지도](fig/12-q2-replicate-calibration/q2-example-tp-cpne5-maps.png)

*윗줄: naive. 아랫줄: aggression. 요점: naive section에서는 위아래 가장자리에 밝은 띠가 있고 (`naive-a5`, `naive-a6`에서 뚜렷, `naive-a7`에서 약함), aggression section 셋에서는 모두 약하다. 출처: [12-q2-replicate-calibration.ipynb](12-q2-replicate-calibration.ipynb) section 5.*

**이 예시가 보이는 것과 보이지 않는 것.** replicate 대조가 쓰는 within 대 between 분리를 보인다. 경쟁 방법보다 나은 점은 보이지 않는다: SpaceExpress와 River도 `Cpne5`를 높게 매기고, pseudobulk DE 유전자다 (전역 FDR 0.001). 또 단일 쌍 ROS 순위는 149개 중 31위에 그친다. within 쌍이 낮아서 최상위 call이 되는 것이고, 그것이 section 2의 요점이다.

**판정: 대조의 예시로는 성립; Q2에서 stORCA만 맞히는 call의 증거는 아직 없다.**

## 6. Q2의 현재 위치

| 주장 | 뒷받침되는가? | 근거 |
|---|---|---|
| 단일 쌍 점수의 between 상위 유전자는 대부분 within 상위 유전자다 | 부분적: HPOA의 모든 방법; 대부분 데이터의 River, SpaceExpress, 단일 쌍 ROS; CODA는 유전자 집합을 고친 뒤에만 | 1 |
| 조건이 없으면 replicate 대조는 call을 내지 않는다 | 예, LIBD (664개 중 0)와 HPOA의 가짜 라벨에서 | 2 |
| replicate 대조는 모든 데이터에서 보정되어 있다 | 보이지 않음: NRDR는 가짜 라벨 2개; ARTISTA (18)와 colitis (26)에서 가짜 라벨 하나씩 call | 2 |
| 단일 쌍 검정은 조건과 replicate 변동을 구분하지 못한다 | 예: 검정이 있는 모든 방법에서 within 쌍당 유전자의 34%~94% call | 1b |
| 쌍의 다른 유전자로 만든 null이 한 쌍을 보정한다 | 부분적: 거짓 call은 2%~8% (BH)로 떨어지고 between 쌍은 replicate 설계 유전자로 농축되지만, within 쌍은 명목 수준보다 높고 between 쌍도 within 쌍만큼 call된다 | 1c |
| replicate 설계는 어떤 점수든 조건을 상위에 두게 한다 | 예: LIBD 밖 19개 조합 중 15개에서 진짜 라벨 1위; LIBD에서는 아님 | 2b |
| replicate 설계만이 아니라 ROS가 replicate 검정을 작동하게 한다 | 예: 같은 대조에서 경쟁 방법은 0~3 call, ARTISTA의 River만 예외 | 2c |
| 단일 쌍 null은 너무 좁다 | ROS에서 예 (분산 비율 26~155) | 3 |
| p-value가 있는 경쟁 방법은 replicate 쌍에서 대부분의 유전자를 call한다 | 예 (section 1b) | 1b, 3 |
| 경쟁 방법은 음성 대조와 한 section의 hotspot을 상위에 둔다 | CODA, STcompare, SpaceExpress에서 예 | 4 |
| River의 상위 유전자는 replicate 변동이다 | 아니오. DE 유전자다 | 4 |

**상태: 아래 수정 뒤 충분.** section 1b, 1c, 2b, 2c로 2 x 2 격자의 모든 칸을 쟀고, 모두 claim 3과 같은 방향이다. gene-bulk null (1c)은 한 쌍의 보정을 크게 개선하지만, 한 쌍으로는 call을 낼 수 없다는 결론은 바뀌지 않는다. 아직 major로 판명될 수 있는 항목이 하나 있다: colitis, 가짜 라벨 하나가 27 대 26 call을 내고 section 2b에서도 진짜 라벨보다 위에 온다 (Fix 3). 문제는 `CLAUDE.md`의 규칙 ("Level of Rigor: Fix or Defend")에 따라 나눈다: 주장에 반하거나 쓰인 그대로 틀린 것은 고치고, 나머지는 방어 논리를 기록한다.

**Fix.**

1. River 예시를 뺀다. `Sema4d`는 DE 유전자라 "replicate 변동"의 반대를 보인다. 가장 단순한 방법: 위양성 그림에서 River panel을 빼고 `Blank_2`, `Mki67`, `Gbx2`, `Oxt`를 남긴다.
2. 노트북 summary의 `Gbx2` 문장을 "한 section (`naive-a6`)의 hotspot"으로 고친다.
3. 진짜 라벨 27 call에 대해 26 call을 내는 colitis 가짜 라벨을 확인한다 (재실행에 colitis가 포함되었다). Q2에서 "call은 replicate 변동을 넘는다"에 반하는 유일한 결과이고, section 2b도 같은 신호를 보인다 (진짜 라벨 35개 중 3위). 유력한 원인은 특이한 section 하나다 (`D0-m7` 또는 `D3-m2`, [16-colitis-sample-review.ipynb](16-colitis-sample-review.ipynb) 참고).
4. Section 1 그림: section 2c처럼 stORCA가 검정한 유전자로 겹침을 그린다. CODA 인공물 (ARTISTA에서 0.14 대 0.55)이 사라진다.

**Defend.**

| 리뷰어가 할 수 있는 말 | 답 |
|---|---|
| NRDR는 가짜 라벨이 2개뿐이다 | 2 vs 2 설계에서는 그 이상이 없다. 보정의 근거는 LIBD (664개 중 0)와 HPOA (가짜 라벨 9개에서 0 call)이고, NRDR는 call만 보탠다 |
| ARTISTA에서 가짜 라벨 9개 중 1개가 18 call을 낸다 | 9개 중 8개는 0이고 18은 115보다 훨씬 작다. 실제 효과가 있는 데이터에서는 가짜 라벨도 진짜 대조의 일부를 품는다 |
| 쌍 점수는 section을 공유하므로 독립이 아니다 | 가짜 라벨이 정확히 이것을 확인하고, 효과가 없는 곳에서는 0 call을 낸다 |
| CODA는 NRDR와 LIBD에서 겹침이 우연 수준이다 | 그곳의 상위 목록은 맞는 것이 아니라 쌍 사이에서 불안정한 것이다: 공간 구조가 없는 유전자로 채워져 있고, blank probe가 2~30위다 |
| 분산 비율은 각 경쟁 방법의 null이 아니라 ROS로 잰 것이다 | 비율은 데이터의 성질이다: replicate끼리는 한 쌍을 다시 매칭할 때보다 훨씬 많이 다르다. 한 쌍으로 만든 어떤 null에도 해당한다 |
| 모든 경쟁 방법이 모든 데이터에서 돌지는 않았다 | 다섯 방법 모두 HPOA에서 돌았고, 모든 데이터에서 최소 두 방법이 돌았다. 실행을 늘리면 panel이 늘 뿐 결론은 바뀌지 않는다 |
| STcompare는 차이가 아니라 유사성을 검정한다 | 변화를 찾을 때 그 출력은 그렇게 읽는다. 그래도 replicate 사이에서 유전자의 73%~90%가 "유사하지 않음"이라, 그 라벨은 조건에 대한 정보가 없다 |
| 실패하는 단일 쌍 검정에 stORCA 자신의 것이 들어 있다 | 우리의 이전 검정이고, outline 계획대로 실패하는 방법 중 하나로 보인다. 논문의 검정은 replicate 대조다 |
| section 1c의 gene-bulk null이 한 쌍을 보정하므로 replicate가 필요 없다 | 거짓 call 대부분을 없애지만, within 쌍이 BH에서 2%~8%로 남고, 전체 call 비율이 within과 between에서 같으며, replicate 설계 call의 0%~55%만 회수한다. 또 대부분의 유전자가 변하지 않는다고 가정한다. replicate가 없을 때 순위용으로 제시하고, 검정으로는 제시하지 않는다 |
| section 2b는 replicate 설계가 어떤 점수로도 작동함을 보이므로 ROS는 필요 없다 | 순위에는 그렇고, 논문도 그렇게 쓴다. call에서는 plain limma를 ROS에 쓰면 HPOA, ARTISTA, NRDR posterior에서 10, 104, 23 call이고, 같은 fit을 CODA, STcompare, SpaceExpress 점수에 쓰면 0~3이다 |
| NRDR에서 라벨이 3개라 3개 중 1위는 약하다 | 그렇게 보고한다. 순위 근거는 3 vs 3 데이터 (라벨 10개)에 둔다 |
| stORCA는 blank probe에 점수를 내지 않는다 | 이 예시는 경쟁 방법이 음성 대조를 어디에 두는지를 보인다. 맞대결 결과로 제시하지 않는다 |
| `Cpne5`도 DE 유전자이고 River와 SpaceExpress도 높게 매긴다 | 이 예시는 within 대 between 대조를 보인다. call이 DE이기도 할 수 있다 |

**결정할 것.**

1. River panel을 뺄지, 다른 데이터에서 River 예시를 찾을지. 권장: 뺀다.
2. 26 call이 나오는 colitis 가짜 라벨 때문에 section을 하나 뺄지. 권장: 노트북 16을 본 뒤 결정; section 제거는 당신이 정한다.
