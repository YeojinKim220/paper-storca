# Q4 effect size: Delta ROS를 비교 사이에 견줄 수 있는지, ARTISTA time course가 무엇을 보이는지, 어떤 예시 유전자가 성립하는지, 범위를 벗어난 ROS를 자르면 척도가 어떻게 공통으로 유지되는지

이 노트는 노트북 [14-q4-effect-size.ipynb](14-q4-effect-size.ipynb)를 section별로 설명한다. 하나의 흐름을 따른다: (1) ARTISTA time course의 비교 네 개와 가짜 라벨 점검; (2) 변화의 크기 $\Delta$를 시점 사이에 한 축에 놓기; (3) 유전자별 궤적; (4) 예시 유전자 두 개를 지도와 section별 count로 확인한 결과; (5) 한 쌍 안의 순위가 같은 일을 할 수 없는 이유; (6) ROS의 유효 범위를 벗어난 쌍 점수; (7) AD 연령 비교; (8) 무엇을 주장할 수 있고 무엇을 먼저 고쳐야 하는지.

이 흐름은 outline claim 3의 뒷부분 ("ROS는 공통 척도의 effect size다")과 [0-paper-outline-natcomm.md](../0-Paper-Draft/0-paper-outline-natcomm.md)의 궤적 panel Figure 5g, Figure 6d를 뒷받침한다. outline에서 벗어난 점이 세 가지 있어서 여기서 밝힌다. 첫째, outline은 궤적을 colitis severity series로 계획했는데 노트북은 ARTISTA time course를 쓴다. 둘째, "공통 척도"는 가정했을 뿐 검정하지 않았다: sequencing depth가 시점 사이에 2~3배 다르고, $\Delta$가 정점인 곳에서 depth도 극단이다. 셋째, 쌍 점수의 약 3%가 ROS가 가질 수 있는 범위 밖에 있고, $\Delta$는 평균이라 거기에 민감하다. 2026-11-17부터 limma 전에 모든 쌍 ROS를 0~2로 자른다 (`19-q4-clip-refit.py`). call과 time course의 그림은 거의 바뀌지 않는다 (section 6). 자르기는 여기에만 적용했고, 다른 노트북은 아직 자르지 않은 v3 표를 읽는다.

모든 그림은 노트북에서 그대로 가져왔다 (PDF는 `5-Case-Study-Comparison/fig/`, PNG 사본은 `5-Case-Study-Comparison/fig/14-q4-effect-size/`). 경로는 링크가 아니면 project root 기준이다. "이 보고서에서 계산"이라고 표시한 숫자는 저장된 결과 파일이나 prepared section에서 구한 것으로 노트북에는 없다.

**데이터.**

- ARTISTA time course (`5-Case-Study-ARTISTA-Timecourse`): 같은 유전자 panel의 section 16개. 각 비교는 2 DPI 대 이후 시점 하나이므로, 같은 2 DPI section 세 개가 네 비교 모두의 기준이다.

| 비교 | Section | Between 쌍 | Within 쌍 | 가짜 라벨 수 | 세포당 count 중앙값, 이후 시점 |
|---|---|---|---|---|---|
| 2 vs 5 DPI | 3 vs 3 | 9 | 6 | 9 | 541~672 |
| 2 vs 10 DPI | 3 vs 3 | 9 | 6 | 9 | 461~561 |
| 2 vs 15 DPI | 3 vs 4 | 12 | 9 | 34 | 798~1486 |
| 2 vs 20 DPI | 3 vs 3 | 9 | 6 | 9 | 548~707 |

2 DPI section의 세포당 count 중앙값은 556~776이다 (이 보고서에서 `data/prepared/artistatc-*-prepared.h5ad`로 계산).

- STARmap PLUS AD: 8개월 (control 2 vs AD 2)과 13개월 (2 vs 2).

**Score.** 한 비교에서 유전자 $g$의 effect size는

$$
\Delta_g=\overline{\mathrm{ROS}}_{g,\text{between}}-\overline{\mathrm{ROS}}_{g,\text{within}},
$$

즉 limma 계수 `coef_unweighted`다. ROS는 두 section이 그 유전자의 공간 구조를 전부 공유하면 0, 전혀 공유하지 않으면 1이다. 1을 넘으면 반대 패턴이고, 유효 범위는 0~2다. call은 [12-q2-replicate-calibration.md](12-q2-replicate-calibration.md)와 같이 v3 표에 대한 one-sided unweighted limma, BH $<0.05$이고, 모든 쌍 ROS를 $[0,2]$로 자른 뒤 다시 적합했다 (파일 `limma-genes-clip.csv`, `limma-splits-clip.csv`).

## 0. Summary

| Step | Finding |
|---|---|
| 1. Call | 5, 10, 15, 20 DPI에서 117, 249, 331, 155 call (자른 ROS). 가짜 라벨 최대: 0, 0, 43 (15 DPI, 라벨 34개), 12. 15 DPI는 section이 네 개라서 call 수는 시점 사이에 비교할 수 없다 |
| 2. 한 축 위의 크기 | 모든 시점에서 검정된 684개 유전자의 $\Delta$ 중앙값: 0.047, 0.094, 0.099, 0.058. 10~15 DPI에서 가장 크다. depth와 아직 분리되지 않았다: 10 DPI가 세포당 count가 가장 낮고 15 DPI가 가장 높다 |
| 3. 궤적 | 한 번 이상 call된 426개 중 $\Delta$ 정점이 5, 10, 15, 20 DPI인 유전자는 38, 132, 168, 88개. 정점에 불확실성이 없다 |
| 4. 예시 | `DDIT4`는 20 DPI에서 분명한 증가로 성립한다 ($\Delta$ 0.50). 수준 변화다 (전역 $\log_2$ fold change 2.17). 일시적 예시는 `NPTXR` 대신 `ZIC1`이다 ($\Delta$ 0.03, 0.16, 0.47, 0.05; 15 DPI BH 0.002): 15 DPI section 네 개 모두에서 등쪽 정중선을 가로지르는 띠가 되고, 20 DPI에서 등가쪽 덩어리 두 개로 돌아온다. `NPTXR`은 10 DPI section 세 개 모두에서 평균 count가 약 40배 낮아서 뺐다 |
| 5. 순위 | 같은 유전자의 ROS 순위가 쌍마다 크게 다르다 (`ZIC1` 15 DPI에서 46~1059위). 이것은 stORCA 자신의 ROS에 대해 보인 것이고 River나 CODA에 대한 것이 아니다 |
| 6. 범위 밖과 자르기 | 비교마다 쌍 점수 360~373개 (2.0~3.3%)가 0 미만이거나 2 초과이고, 값은 -37에서 60까지다. 모든 쌍 ROS를 0~2로 자르면 call이 111, 250, 325, 151에서 117, 249, 331, 155로 바뀌고 잃는 call은 0, 3, 1, 4개다. $\Delta$ 중앙값은 최대 0.003 움직인다. time course 결과는 이 점수에 기대지 않는다 |
| 7. AD 연령 | 8개월에서 13개월로 $\Delta$가 일관되게 커지지 않는다. 쓸 수 없다 |
| 8. Fix 또는 defend | 자르기는 끝났다. 두 수정 모두 끝났다: `NPTXR`을 `ZIC1`으로 교체했고 (2026-11-19), 노트북 본문의 plaque 비율을 고쳤다 (1.75). depth와 나머지 문제는 section 8에 방어 논리와 함께 기록했다 |

## 1. ARTISTA: 비교별 call과 가짜 라벨 점검 (노트북 section 1)

**질문.** 크기를 비교하기 전에, 네 비교 각각이 유효한 replicate 분석인가?

**쉽게 말하면.** "어느 시점에 변화가 가장 큰가"를 묻기 전에, 각 비교가 Q2의 점검을 통과해야 한다: section을 시점과 무관하게 묶으면 call이 대부분 사라져야 한다.

**구현** (노트북 section 1. `5-Case-Study-ARTISTA-Timecourse/res/stORCA/storca-v3-rep1-artistatc<day>-limma-genes.csv`와 `-limma-splits.csv`의 `weighting == "unweighted"` 행).

1. Call: `adj_p_one_unweighted` $<0.05$인 유전자.
2. 가짜 라벨: section을 같은 크기의 그룹으로 나누는 다른 모든 방법. 노트북은 최댓값을 보고한다.
3. 검정 유전자에 대한 between 쌍과 within 쌍의 ROS 중앙값.

![비교별 call 수](fig/14-q4-effect-size/q4-artista-timecourse-calls.png)

*색 막대: 진짜 라벨의 call 수. 회색 막대: 가짜 라벨 중 최댓값. 핵심: 5, 10 DPI에서 회색은 0이다. Source: [14-q4-effect-size.ipynb](14-q4-effect-size.ipynb) section 1.*

**결과.**

| 비교 | 검정 유전자 | Call | Call이 하나라도 나온 가짜 라벨 | 최대 call | ROS 중앙값, within | ROS 중앙값, between |
|---|---|---|---|---|---|---|
| 2 vs 5 DPI | 753 | 117 | 9개 중 0 | 0 | 0.245 | 0.306 |
| 2 vs 10 DPI | 782 | 249 | 9개 중 0 | 0 | 0.255 | 0.373 |
| 2 vs 15 DPI | 878 | 331 | 34개 중 3 | 43 | 0.298 | 0.419 |
| 2 vs 20 DPI | 774 | 155 | 9개 중 1 | 12 | 0.289 | 0.374 |

section 6의 자르기 뒤 숫자다. 자르기 전에는 call 111, 250, 325, 151, 가짜 라벨 최대 0, 0, 40, 10이었다.

**15 DPI의 43 call은 위양성인가?** 대부분 아니다 (이 보고서에서 `limma-splits-clip.csv`로 계산). 3 vs 4 설계에서는 "가짜" 라벨 중 일부가 진짜 라벨과 section 하나만 다르다. 43 call이 나오는 라벨은 `dpi15-r2, dpi15-r3, dpi15-r4`를 한 그룹에, 2 DPI section 세 개와 `dpi15-r1`을 다른 그룹에 둔다. 11 call이 나오는 라벨은 옮겨진 15 DPI section만 다른 같은 종류다. 거기서는 call이 나오는 것이 자연스럽다. 20 DPI의 12 call은 `dpi2-r1, dpi2-r2, dpi20-r1` 대 나머지 라벨에서 나오는데, Q2에서 18 call을 내는 것과 같은 라벨이다. section을 들여다봐야 한다.

**설계의 통계적 귀결.** call 수는 변화의 크기를 재는 양이 아니다. 15 DPI는 쌍이 15개가 아니라 21개이고 검정 유전자도 더 많아서 검정력이 더 높다. 노트북의 나머지가 call 수가 아니라 $\Delta$를 쓰는 이유다.

**판정: 5, 10 DPI는 작동. 15 DPI는 진짜에 가까운 라벨을 분리하면 작동. 20 DPI는 section 점검 필요.**

## 2. ARTISTA: 한 축 위에 놓은 변화의 크기 (노트북 section 2)

**질문.** 2 DPI 대비 변화가 어떤 시점에서 다른 시점보다 더 큰가?

**쉽게 말하면.** 순위는 "이 유전자가 이 쌍에서 30번째로 많이 바뀌었다"고 말한다. p값은 "section이 이만큼 있을 때 이 변화가 우연일 가능성이 낮다"고 말한다. 둘 다 크기가 아니다. $\Delta$는 크기다: $\Delta=0.10$은 between 쌍이 replicate보다 그 유전자의 공간 구조를 10 percentage point 더 공유하지 못한다는 뜻이다. 이 단위는 다른 어떤 유전자를 측정했는지, section이 몇 개였는지에 달려 있지 않으므로, 5 DPI의 $\Delta$를 15 DPI의 $\Delta$ 옆에 놓을 수 있다. River와 CODA (한 쌍 안의 순위), DESpace2와 SpaceExpress (p값)는 이것을 주지 않는다.

**구현** (노트북 section 2).

1. 네 비교 모두에서 검정된 684개 유전자만 남긴다.
2. 네 비교의 $\Delta_g$ (`coef_unweighted`) 분포를 비교한다.

![시점별 Delta 분포](fig/14-q4-effect-size/q4-artista-delta-distribution.png)

*비교마다 violin 하나, 중앙값 표시. 점선: $\Delta=0$. 핵심: 10, 15 DPI의 중앙값이 5, 20 DPI의 약 두 배다. Source: [14-q4-effect-size.ipynb](14-q4-effect-size.ipynb) section 2.*

**결과** (684개 유전자).

| | 5 DPI | 10 DPI | 15 DPI | 20 DPI |
|---|---|---|---|---|
| $\Delta$ 중앙값 | 0.047 | 0.094 | 0.099 | 0.058 |
| $\Delta$ 평균 | 0.077 | 0.120 | 0.113 | 0.094 |
| 25%~75% | 0.008~0.127 | 0.042~0.179 | 0.035~0.174 | 0.017~0.146 |
| 최소, 최대 | -0.26, 0.59 | -0.20, 0.77 | -0.30, 0.59 | -0.27, 0.67 |

section 6의 자르기 뒤다. 자르기 전에는 최소와 최대가 -3.01과 6.61, 중앙값이 0.049, 0.096, 0.102, 0.058이었다.

**척도가 정말 공통인가?** 생물학 말고도 세 가지가 $\Delta$를 움직일 수 있다. 앞의 둘은 방어할 수 있고, 셋째는 자르기로 없어진다 (section 6):

- **Depth.** 10 DPI section은 세포당 count가 가장 낮고 (461~561), 15 DPI section은 가장 높다 (798~1486). $\Delta$ 중앙값이 가장 큰 두 시점이, depth가 2 DPI와 가장 많이, 서로 반대 방향으로 다른 두 시점이다. ROS는 log 척도의 전역 shift를 제거하지만, depth 변화는 `log1p`와 cap을 거치면 순수한 shift가 아니다. 노트북에는 이에 대한 대조가 없다.
- **Within 기준선.** $\Delta$는 두 그룹의 within 쌍을 빼므로, 기준선이 이후 시점에 따라 바뀐다 (within ROS 중앙값 0.238~0.294).
- **범위 밖 점수.** 자르기 전에는 0~2 범위의 점수에서는 나올 수 없는 $\Delta$ -3.01과 6.61이 있었다. 자른 뒤 $\Delta$는 -0.30~0.77에 있고 중앙값은 최대 0.003 움직인다 (section 6).

**판정: time course의 서술로는 작동.** 중앙값은 올랐다가 내려간다. depth는 방어할 수 있는 단서이고 (section 8), 리뷰어가 물으면 outline Supplementary에 이미 있는 depth를 맞춘 downsampling이 답한다.

## 3. ARTISTA: 유전자별 궤적 (노트북 section 3)

**질문.** 유전자마다 2 DPI 대비 변화가 가장 큰 시점은 언제인가?

**구현** (노트북 section 3).

1. 684개 중 한 비교 이상에서 call된 426개를 남긴다.
2. 정점 시점: $\Delta_g$가 가장 큰 비교.
3. 네 시점의 $\Delta_g$ heat map, 유전자는 정점 순으로 정렬.

![궤적](fig/14-q4-effect-size/q4-artista-delta-trajectories.png)

*행: 정점 시점 순으로 정렬한 426개 유전자. 열: 5, 10, 15, 20 DPI. 색: $\Delta$, 빨강이 양수. 핵심: 대부분의 유전자가 10 또는 15 DPI에서 정점이다. Source: [14-q4-effect-size.ipynb](14-q4-effect-size.ipynb) section 3.*

**결과.** 정점이 5, 10, 15, 20 DPI인 유전자: 38, 132, 168, 88개 (자른 ROS).

주의점. 정점은 noise가 있는 숫자 네 개 중 최댓값이고 구간이 없어서, 두 시점의 $\Delta$가 0.20과 0.21인 유전자는 우연히 한쪽에 배정된다. "한 번 이상 call"은 검정력이 가장 높은 15 DPI에 유리하다. 그리고 10 DPI에서 정점인 132개는 section 2의 depth 문제를 그대로 물려받는다.

**판정: 부분 성공. 정점에 불확실성이 붙기 전에는 서술용으로만 쓴다.**

## 4. ARTISTA: 예시 유전자 (노트북 section 4)

**질문.** 변화가 시간에 따라 커지는 유전자 하나와, 나타났다 사라지는 유전자 하나를 지도와 맞게 보일 수 있는가?

**노트북의 선택 규칙.**

1. 증가: $\Delta$가 5, 10, 15 DPI로 커지고, 20 DPI에서 15 DPI 값의 80% 이상을 유지하며, 20 DPI에서 call이다. 20 DPI의 $\Delta$가 가장 큰 것을 고른다.
2. 일시적: 10 또는 15 DPI에서 call이고, 정점이 10 또는 15 DPI이며, 5 DPI와 20 DPI의 $\Delta$가 정점의 절반 이하다. 정점이 가장 큰 것을 고른다.
3. 공통: 해당 시점 section에서 평균 log1p 발현이 0.3 초과여야 지도를 읽을 수 있다.

**결과 (이 보고서에서 확인).**

| 유전자 | 5, 10, 15, 20 DPI의 $\Delta$ | 5, 10, 15, 20 DPI의 BH | Section에서 보이는 것 | 성립? |
|---|---|---|---|---|
| `DDIT4` | 0.035, 0.091, 0.149, 0.502 | 0.52, 0.15, 0.016, 0.001 미만 | 평균 count가 2 DPI에서 0.30~0.47, 20 DPI에서 1.43~1.79. 20 DPI에서 section 전체가 더 밝음 | 예, 20 DPI에 대해 |
| `ZIC1` | 0.034, 0.156, 0.471, 0.054 | 0.25, 0.15, 0.002, 0.10 | dorsal pallium: 2, 5, 10, 20 DPI에서는 등가쪽 덩어리 두 개, 15 DPI에서는 section 네 개 모두에서 등쪽 정중선을 가로지르는 강한 띠 하나 | 예 |
| `NPTXR` (제외) | 0.025, 0.772, 0.285, 0.014 (v3) | 0.23, 0.001 미만, 0.021, 0.34 (v3) | 평균 count가 10 DPI section 세 개 모두에서 0.17~0.23, 나머지 13개 section에서 5.6~15.6 | 아니오 |

![DDIT4의 쌍별 ROS](fig/14-q4-effect-size/q4-artista-increasing-ddit4-pair-ros.png)

*비교마다 열 하나. 회색: within 쌍. 색: between 쌍. 핵심: between 쌍 (0.65~0.88)이 within 쌍 (0.12~0.49)과 떨어지는 것은 20 DPI뿐이고, 5, 10, 15 DPI에서는 둘이 겹친다. Source: [14-q4-effect-size.ipynb](14-q4-effect-size.ipynb) section 4.*

**`DDIT4`: 증가이지만 수준의 증가다.** 쌍 그림은 "20 DPI에서 이전 어느 시점보다 크다"를 뒷받침한다. 꾸준한 상승은 뒷받침하지 않는다: 앞의 세 값은 replicate 퍼짐 안에 있다. `DDIT4`는 20 DPI에서 전역 DE 유전자이기도 하므로 ($\log_2$ fold change 2.17), 이 예시는 $\Delta$가 pseudobulk도 보는 변화를 따라간다는 것을 보여준다.

![ZIC1의 쌍별 ROS](fig/14-q4-effect-size/q4-artista-transient-zic1-pair-ros.png)

*비교마다 열 하나. 회색: within 쌍. 색: between 쌍. 핵심: between 쌍 (0.16~1.12)이 within 쌍 (0.06~0.20)과 떨어지는 것은 15 DPI뿐이고, 5 DPI와 20 DPI에서는 다시 겹친다. Source: [14-q4-effect-size.ipynb](14-q4-effect-size.ipynb) section 4.*

![ZIC1 지도](fig/14-q4-effect-size/q4-artista-transient-zic1-maps.png)

*시점마다 section 하나 (replicate 1), 색 scale 공통. Source: [14-q4-effect-size.ipynb](14-q4-effect-size.ipynb) section 4.*

![ZIC1 전체 section](fig/14-q4-effect-size/q4-artista-transient-zic1-all-sections.png)

*16개 section 전체, kNN-15 평활 log1p, 색 scale 공통. 핵심: 등쪽 정중선을 가로지르는 띠는 15 DPI section 네 개 모두에 있고 나머지 12개에는 없다. Source: [14-q4-effect-size.ipynb](14-q4-effect-size.ipynb) section 4b.*

**`ZIC1`: 일시적인 패턴 변화이고, 수준 변화가 함께 있다.** 확인 (노트북 section 4b, v4 쌍 점수):

- 2, 5, 10, 20 DPI의 모든 section에서 이 유전자는 반구마다 하나씩, 등가쪽 덩어리 두 개에 있다. 15 DPI section 네 개 모두에서는 등쪽 정중선을 가로지르는 강한 띠 하나가 되고, 평균이 가장 높은 class가 `ntng1IN` (4개 중 3개) 또는 `scgnIN`으로 바뀐다. 20 DPI에서 두 덩어리로 돌아온다.
- depth만의 효과가 아니다. 15 DPI는 세포당 count가 가장 높지만, 전체 count 중 `ZIC1`의 비율도 높다: 10k당 9.7~12.8, 2, 5, 20 DPI는 5.6~8.3 (10 DPI는 8.1~10.8). 즉 약 1.5~2배의 수준 변화가 패턴 변화에 얹혀 있다. 본문은 "패턴만"이 아니라 "일시적 변화"라고 쓴다.
- 쌍 두 개에 기대지 않는다. 15 DPI의 between 쌍 12개 중 11개가 within 쌍 최댓값 (0.20)보다 크다. between 쌍은 높은 무리 (0.72~1.12)와 낮은 무리 (0.16~0.36)로 나뉘고, `dpi15-r4`는 2 DPI section 세 개 모두와 높은 무리에 있다. `dpi15-r4` 쌍 세 개를 빼도 $\Delta$는 0.38이다.
- 노트북에 선택 규칙 하나를 더했다: 한 시점의 평균 count가 모든 replicate에서 다른 section과 10배 넘게 다른 유전자는 건너뛴다 (`abrupt_level_shift`). 이 규칙이 `NPTXR`을 빼고, 다음 후보가 `ZIC1`이다.

**`NPTXR`을 뺀 이유** (이전 일시적 예시, 2026-11-17 확인):

![NPTXR 지도](fig/14-q4-effect-size/q4-artista-transient-nptxr-maps.png)

*시점마다 section 하나 (replicate 1), 색 scale 공통. 핵심: 이 유전자는 10 DPI section 전체에서 거의 없고, 다른 모든 시점에서는 같은 부위에서 강하다. 10 DPI panel이 작게 그려진 것은 조직에서 멀리 떨어진 세포 몇 개 때문이다. Source: [14-q4-effect-size.ipynb](14-q4-effect-size.ipynb) section 4.*


- 평균 count가 모든 10 DPI section에서 다른 모든 section보다 약 40배 낮다. 양옆의 5 DPI와 15 DPI도 정상이다.
- 10 DPI 밖에서 200 CPM을 넘는 640개 유전자 중, 10 DPI에서 4배 넘게 낮은 것은 이 유전자 하나뿐이다. 한 시점에서 모든 세포에서 꺼졌다가 돌아오는 유전자가 혼자라면, 재생보다 먼저 10 DPI 데이터의 probe, annotation, gene ID 문제를 의심해야 한다.
- 15 DPI 값은 쌍 두 개에 기대고 있다. 15 DPI 쌍 점수로 식을 따라가 보면:

| 쌍 | ROS 값 | 평균 |
|---|---|---|
| Within (9) | 0.08, 0.10, 0.04, 0.06, 0.06, 0.10, 0.04, 0.11, 0.07 | 0.073 |
| Between (12) | 0.19, 0.33, 0.31, 0.26, 1.20, 0.15, 0.88, 0.14, 0.12, 0.35, 0.15, 0.21 | 0.358 |

$\Delta = 0.358 - 0.073 = 0.285$. 큰 값 두 개, 1.20과 0.88은 `dpi2-r2` 대 `dpi15-r1`, `dpi2-r2` 대 `dpi15-r3`이다. 이 둘을 빼면 between 평균은 0.221, $\Delta$는 0.148이다.

같은 규칙의 다음 후보는 `ZIC1`, `TAC1`, `CCK`, `PENK`다. `ZIC1`은 15 DPI section 네 개에서 평균 count가 1.09~1.59이고 나머지 12개에서 0.37~0.56으로 replicate 사이에 일관되므로, 먼저 지도에서 확인할 만하다. `TAC1`과 `CCK`는 한 시점의 replicate 사이에서 10배씩 달라서 (2 DPI에서 0.03~0.31) 좋은 후보가 아니다.

**판정: `DDIT4`는 20 DPI에 대해 작동, `ZIC1`은 15 DPI의 일시적 예시로 작동. `NPTXR`은 제외.**

결과 파일: `5-Case-Study-ARTISTA-Timecourse/res/stORCA/storca-v3-rep1-artistatc<day>-limma-pair-scores.csv` (column `gene`, `pair`, `ROS`, `usable`, `blank`).

## 5. 한 쌍 안의 순위는 비교 사이에 견줄 수 없다 (노트북 section 5)

**질문.** 각 쌍 안에서 유전자의 순위가 $\Delta$의 역할을 대신할 수 있는가?

**쉽게 말하면.** 순위는 다른 유전자에 달려 있다. 15 DPI에 많은 유전자가 바뀌면, 자신의 변화는 그대로인 유전자도 순위가 떨어진다. 그래서 순위로는 한 유전자의 변화가 커졌는지 말할 수 없다.

**구현** (노트북 section 5). 예시 유전자 두 개와 각 비교에 대해: 모든 between 쌍에서 그 유전자 ROS의 전체 유전자 중 순위를 구하고, 가장 좋은 순위와 가장 나쁜 순위를 $\Delta$ 옆에 보고한다.

**결과.**

| 유전자 | Day | $\Delta$ | 가장 좋은 순위 | 가장 나쁜 순위 | 순위에 든 유전자 수 |
|---|---|---|---|---|---|
| `DDIT4` | 5 | 0.035 | 367 | 896 | 947 |
| `DDIT4` | 10 | 0.091 | 326 | 684 | 981 |
| `DDIT4` | 15 | 0.149 | 425 | 915 | 1155 |
| `DDIT4` | 20 | 0.502 | 140 | 255 | 949 |
| `ZIC1` | 5 | 0.034 | 639 | 826 | 947 |
| `ZIC1` | 10 | 0.156 | 61 | 907 | 981 |
| `ZIC1` | 15 | 0.471 | 46 | 1059 | 1155 |
| `ZIC1` | 20 | 0.054 | 705 | 893 | 949 |

**이것은 경쟁 방법에 대한 결과인가?** 아니다. 순위는 stORCA 자신의 ROS 순위다. 이 표가 보여주는 것은 한 쌍은 noise가 크고 쌍에 대한 평균이 필요하다는 것, 즉 Q2의 요점이다. River와 CODA에 대한 claim을 하려면 time course 쌍에서 그들의 순위가 필요한데, 이 데이터에서는 실행되지 않았다. 또 변화가 강할 때 (`DDIT4` 20 DPI)는 순위 범위가 좁다는 점도 눈여겨봐야 한다. 큰 효과는 순위에도 실린다. `ZIC1` 15 DPI는 $\Delta$가 더 크지만, 쌍이 높은 무리와 낮은 무리로 나뉘어 순위가 46~1059위로 흔들린다.

**판정: 부분 성공. 논리는 원칙적으로 맞지만, 이름을 든 경쟁 방법에 대한 증거가 없다.**

## 6. 주의: 범위를 벗어난 ROS (노트북 section 5b)

**질문.** ROS가 가질 수 있는 범위 밖의 쌍 점수가 얼마나 되고, call에까지 닿는가?

**쉽게 말하면.** ROS는 비율이다. 분모 $Q(x)+Q(y)$는 두 section에서 그 유전자의 공간 구조가 얼마나 있는지를 잰다. 어떤 쌍에서 구조가 거의 없는 유전자는 분모가 0에 가깝고, 공간 가중치 행렬이 양의 준정부호가 아니어서 음수가 될 수도 있다. 0에 가까운 수로 나누면 -37이나 60 같은 값이 나온다. v3의 규칙 3 ("남은 유전자는 모든 쌍을 쓴다")이 이런 값을 limma에 들여보낸다.

**여기서 왜 중요한가.** $\Delta$는 평균의 차이이고, limma의 분산은 제곱의 평균이다. 쌍 15개 중 값 하나가 60이면 둘 다 바뀐다. 따라서 $\Delta$의 크기가 주제인 노트북에서 이것은 겉모양의 문제가 아니다.

**결과** (노트북 section 5b. 검정 유전자, blank probe 제외).

| Day | 쌍 점수 | 0~2 밖 | 그중 평가 불가로 표시된 것 | 영향받는 유전자 | Call | 그런 쌍이 있는 call | 최소 ROS | 최대 ROS |
|---|---|---|---|---|---|---|---|---|
| 5 | 11295 | 373 | 114 | 193 | 111 | 16 | -26.17 | 4.03 |
| 10 | 11730 | 360 | 137 | 186 | 250 | 42 | -37.22 | 14.05 |
| 15 | 18438 | 370 | 139 | 187 | 325 | 52 | -5.08 | 6.41 |
| 20 | 11610 | 373 | 158 | 197 | 151 | 27 | -28.81 | 60.39 |

범위 밖 점수의 약 3분의 2는 pipeline 자신이 평가 가능하다고 표시한 쌍에 있다. 그래서 평가 불가 쌍만 빼서는 없어지지 않는다.

**각 수정안의 의미.**

| | 현재 (v3) | ROS를 0~2로 자름 | 분모가 양수인 matching만 사용 |
|---|---|---|---|
| limma에 들어가는 것 | 모든 쌍 점수, 어떤 값이든 | 모든 쌍, 한계 안 | 잘 정의된 비율만 |
| 극단값의 의미 | 임의적 | "공유 구조 없음" 또는 "반대" | 생기지 않음 |
| 유전자당 쌍 수 | 전부 | 전부 | 전부, 일부는 matching 수가 줄어듦 |
| 비용 | 약 190개 유전자에서 $\Delta$와 분산이 왜곡 | 원인을 가림 | score 정의가 바뀜, 재실행 필요 |

**먼저 시도한 것: 분모가 양수인 유전자만 남기는 filter** (`21-positive-denominator-filter.py`, 2026-11-17). 규칙 A는 모든 쌍에서 $\sum_s[Q_s(x)+Q_s(y)]>0$인 유전자만 남기고, 규칙 B는 모든 쌍에서 $\sum_s Q_s(x)>0$이고 $\sum_s Q_s(y)>0$이기를 요구한다.

| Case | 검정 | Call | A가 남긴 것 (유전자, call) | B가 남긴 것 (유전자, call) |
|---|---|---|---|---|
| 2 vs 5 DPI | 753 | 111 | 750, 110 | 712, 105 |
| 2 vs 10 DPI | 782 | 250 | 775, 250 | 741, 244 |
| 2 vs 15 DPI | 878 | 325 | 874, 324 | 812, 307 |
| 2 vs 20 DPI | 774 | 151 | 764, 151 | 733, 143 |
| ARTISTA 2 vs 20 | 782 | 115 | 771, 115 | 735, 112 |
| Colitis | 490 | 27 | 489, 27 | 473, 26 |
| HPOA, NRDR, LIBD, Allen | 149~664 | 0~32 | 0~2개 유전자 빼고 전부, call 전부 | 0~32개 유전자 빼고 전부, call 전부 |

**규칙 A는 비용이 작지만 문제를 없애지 못한다.** 범위 밖 점수 중 373개 중 371, 360개 중 346, 370개 중 362, 373개 중 358이 규칙 A를 통과하는 유전자에 있고, 거의 전부 (370, 346, 359, 356)가 $Q_r<0$이다: 음수인 것은 분모가 아니라 분자다. 그래서 분모 filter로는 범위를 고칠 수 없고, 자르기가 이를 고치는 가장 단순한 수정이다.

**자르기 적용** (`19-q4-clip-refit.py`, 2026-11-17). 저장된 쌍 점수 표에서 모든 쌍 ROS를 $[0,2]$로 자르고, 같은 v3 limma 적합을 모든 라벨로 다시 돌린다. matching이나 scoring은 다시 돌리지 않는다. 노트북은 이제 자른 표를 읽고, section 5b가 둘 다 보인다.

| Day | 자른 쌍 점수 (전체 유전자) | 이전 call | 이후 call | 유지 | 잃음 | 새로 얻음 | 이후 가짜 라벨 최대 (이전) |
|---|---|---|---|---|---|---|---|
| 5 | 815 | 111 | 117 | 111 | 0 | 6 | 0 (0) |
| 10 | 790 | 250 | 249 | 247 | 3 | 2 | 0 (0) |
| 15 | 1060 | 325 | 331 | 324 | 1 | 7 | 43 (40) |
| 20 | 806 | 151 | 155 | 147 | 4 | 8 | 12 (10) |

자른 개수가 첫 표의 범위 밖 개수보다 많은 것은 limma가 남긴 유전자만이 아니라 쌍 점수 파일의 모든 유전자를 세기 때문이다. $\Delta$ 중앙값은 0.047, 0.094, 0.099, 0.058 (이전 0.049, 0.096, 0.102, 0.058)이고, 정점 수는 38, 132, 168, 88 (이전 38, 133, 165, 88)이다.

**읽기:**

- **범위 밖 점수가 결과를 만든 것이 아니다.** call 837개 중 829개가 유지되고, time course의 모양이 같다.
- **자르기는 모든 쌍을 유지하고 의미가 바로 읽힌다**: 2인 점수는 "반대 패턴", 즉 한 쌍이 가장 크게 어긋나는 경우다.

**판정: 작동. 자르기는 결론을 바꾸지 않고 "공통 척도"와의 상충을 없앤다.** 결과 파일: `5-Case-Study-Comparison/res/Comparison/q4-clip-refit-summary.csv`, `5-Case-Study-ARTISTA-Timecourse/res/stORCA/storca-v3-rep1-artistatc<day>-limma-genes-clip.csv`.

## 7. STARmap PLUS AD: 8개월 대 13개월 (노트북 section 6)

**질문.** plaque가 더 많은 13개월에 $\Delta$가 더 큰가?

**구현** (노트북 section 6. `5-Case-Study-AD-STARmap/res/stORCA/storca-v3-rep1-ad-limma-genes-m8.csv`와 `-m13.csv`). limma 설계를 연령별로 section 2 vs 2에 적합한다 (between 쌍 4, within 쌍 2). Plaque는 disease section마다 센다. 2 vs 2에서는 call이 없으므로, 전체 분석에서 $t$가 가장 큰 유전자 10개의 $\Delta$만 비교한다.

![연령별 AD](fig/14-q4-effect-size/q4-ad-age-delta.png)

*왼쪽: disease section별 plaque 수. 오른쪽: 13개월 $\Delta$ 대 8개월 $\Delta$, 유전자마다 점 하나, 상위 10개는 빨강, 점선은 대각선. 핵심: 빨간 점이 대각선 양쪽에 있다. Source: [14-q4-effect-size.ipynb](14-q4-effect-size.ipynb) section 6.*

**결과.** Plaque: 8개월 88, 99개, 13개월 192, 136개로 1.75배다 (노트북 summary는 이제 1.75배라고 쓴다. 2026-11-17 전에는 약 1.6배라고 썼다). $\Delta$는 `C1qa` (0.153에서 0.248), `Nefh` (0.123에서 0.228), `Slc32a1` (0.097에서 0.313)에서 커지고, `Gfap` (0.162에서 0.124), `Clstn1` (0.228에서 0.098), `Nnat` (0.111에서 0.050), `Slc17a7` (0.097에서 -0.005), `Slco1a4` (0.123에서 0.037)에서 작아진다.

**실패한 이유.** 연령마다 within 쌍이 2개라 유전자 하나의 $\Delta$에 반복이 거의 없고, AD 전체 분석 자체가 보정되어 있지 않다 (call 1개, 가짜 라벨에서 최대 10. [13-q3-beyond-de.md](13-q3-beyond-de.md) section 4 참고).

**판정: 실패. 노트북이 올바르게 제외했다.**

## 8. Q4의 현재 위치

| Claim | 뒷받침되는가? | 근거 |
|---|---|---|
| time course의 각 비교가 가짜 라벨 점검을 통과한다 | 5, 10 DPI는 예. 15 DPI는 진짜에 가까운 라벨을 분리한 뒤. 20 DPI는 미결 | 1 |
| $\Delta$는 비교 사이에 공통 척도다 | 가정했을 뿐 검정하지 않음 (depth, 기준선) | 2 |
| 2 DPI 대비 변화는 10~15 DPI에 가장 크다 | 중앙값은 그렇다. depth가 배제되지 않음 | 2 |
| 유전자마다 정점 시점이 다르다 | 서술적. 불확실성 없음 | 3 |
| 이름을 댈 수 있는 유전자가 커지는 변화를 보인다 | 20 DPI에서 예: `DDIT4`, 수준 변화 | 4 |
| 이름을 댈 수 있는 유전자가 일시적 변화를 보인다 | 15 DPI에서 예: `ZIC1`, 15 DPI section 네 개 모두에서 등쪽 정중선의 띠, 수준 변화가 함께 있음 | 4 |
| River와 CODA의 순위는 비교 사이에 견줄 수 없다 | 보이지 않음. stORCA 자신의 순위뿐 | 5 |
| $\Delta$에 들어가는 모든 쌍 점수가 유효하다 | 자르기 뒤 예. 자르기는 call 837개 중 829개를 유지한다 | 6 |
| $\Delta$가 AD 진행을 따른다 | 아니오 | 7 |

**상태: 아래 수정 뒤 충분.** 자르기를 적용했고 time course의 그림은 그대로다 (section 6). 일시적 정점 예시는 이제 `ZIC1`이고 모든 section에서 성립한다 (section 4). 문제는 `CLAUDE.md`의 규칙 ("Level of Rigor: Fix or Defend")에 따라 나눈다.

**Fix.**

열린 항목 없음. 2026-11-19 완료: 16개 section 전체를 확인한 뒤 (노트북 section 4b) `NPTXR`을 `ZIC1`으로 교체했고, 10배 수준 급변 규칙을 선택에 넣었다.

**Defend.**

| 리뷰어가 할 수 있는 말 | 답 |
|---|---|
| 시점마다 depth가 다르다 | ROS는 공간 구조의 비율이고, 각 시점의 within 쌍을 뺀다. $\Delta$는 depth가 가장 낮은 곳 (10 DPI)과 가장 높은 곳 (15 DPI) 모두에서 크다. depth를 맞춘 downsampling은 outline Supplementary에 이미 계획되어 있다 |
| call 수의 검정력이 다르다 (15 DPI는 section 네 개) | 그래서 call 수가 아니라 $\Delta$를 비교한다 |
| 15 DPI의 가짜 라벨 하나가 43 call | 그 라벨은 진짜 라벨과 section 하나만 달라서 call이 나오는 것이 자연스럽다 |
| 20 DPI의 가짜 라벨 9개 중 1개가 12 call | 9개 중 8개는 0이고 12는 155보다 훨씬 작다 |
| 정점 시점에 구간이 없다 | 궤적은 서술적이고 그렇게 표시한다. outline Figure 5g와 같다 |
| `DDIT4`는 수준 변화이고 20 DPI에서만 분명하다 | $\Delta$가 DE 유전자를 따라가도 된다. 요점은 시간에 따른 크기다. 본문은 "꾸준한 상승"이 아니라 "20 DPI에서 가장 크다"고 쓴다 |
| 순위 표가 stORCA 자신의 단일 쌍 순위를 쓴다 | 이 논리는 한 쌍 안의 어떤 순위에도 성립한다. 본문은 River나 CODA가 아니라 "단일 쌍 순위"라고 쓴다 |
| 자르기는 score를 바꾸므로 방법 변경이다 | 모든 쌍을 유지하고 값을 score가 가질 수 있는 범위로 묶을 뿐이다. call 837개 중 829개가 유지된다 (section 6). 논문 전에 여기만이 아니라 모든 노트북에 적용해야 한다 |
| 연령별 AD에 경향이 없다 | 노트북이 이미 제외했다 |
| 겉모양: `dpi10-r1`과 `dpi20-r2`의 동떨어진 세포, 이전 `pgam1`, `faslg` 그림 파일 | 그림을 다시 그릴 때 각각 한 줄 |

**사용자가 결정할 것.**

1. 자르기를 pipeline (`storca/replicate_case_studies.py`, `fit_design` 앞)으로 옮겨 모든 데이터가 쓰게 할지. 권장: 옮긴다. 비교 네 개에서 검사했고, call 837개 중 8개를 잃고 23개를 새로 얻는다.
2. effect size 궤적을 ARTISTA에 둘지, outline이 지목한 colitis severity series로 옮길지. 권장: 모든 시점에 replicate가 있는 ARTISTA. outline에 적어 둔다.
