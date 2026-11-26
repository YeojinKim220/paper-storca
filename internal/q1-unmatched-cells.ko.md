# Q1 unmatched 세포: plan이 새 세포를 빼는가, 경쟁 방법이 그 세포에 속는가, stORCA score는 그 세포에서 자유로운가

이 노트는 노트북 [11-q1-unmatched-cells.ipynb](11-q1-unmatched-cells.ipynb)를 section별로 설명한다. 한 줄을 따라간다: (1) dead-zone plan은 짝이 없는 세포를 unmatched로 남긴다; (2) 경쟁 방법이 그 세포의 marker를 목록 위쪽에 올리는가; (3) stORCA 자신의 score는 실제 데이터와 통제된 semi-synthetic 검사에서 그 세포에서 자유로운가; (4) 지금 주장할 수 있는 것과 바꿔야 할 것.

이 줄은 2026-11-18에 고친 outline의 claim 3, 짝 없는 조직을 뒷받침한다 ([0-paper-outline-natcomm.md](../0-Paper-Draft/0-paper-outline-natcomm.md)의 그림 4). **section 7 (2026-11-18)이 결론이다.** replicate 기준선을 양쪽에서 솎으면 plan의 낮은 retained mass가 짝 없는 조직을 찾고 (AUROC cortex 0.89, colitis 0일째 0.94), stORCA 상위 20개 중 그 조직의 marker는 0.20과 0.35로 CODA, STcompare, DESpace2의 0.45~0.70보다 낮다 (기준 0.11, 0.28). section 2~5f는 여기에 이른 과정을 기록한다. 그 판정은 양쪽 thinning과 표준 marker 전에 쓴 것이고, section 6은 section 7에 맞춰 갱신했다. section 5~5c의 semi-synthetic 검사는 쓰지 않는다 (2026-11-18 결정); 왜 실제 case를 재현하지 못하는지는 section 7c에 있다.

그림은 노트북에서 그대로 옮겼다 (PDF는 `5-Case-Study-Comparison/fig/`, PNG 복사본은 `5-Case-Study-Comparison/fig/11-q1-unmatched-cells/`). 링크가 아닌 경로는 프로젝트 루트 기준이다. 모든 숫자는 2026-11-17과 2026-11-18 노트북 실행 결과다.

**데이터.**

| Case | 폴더 | Control | Treated | Replicate |
|---|---|---|---|---|
| Colitis, 정상 대 9일째 (Cadinu et al. 2024, MERFISH) | `5-Case-Study-Colitis-Q1` | `062921_D0_m3a_2` slice 1~3 | `100221_D9_m5_1` slice 1~3 (ulcer neighbourhood MU8이 세포의 38~51%) | slice 3 대 3, 조건마다 마우스 한 마리라 technical replicate |
| Cortex stab wound (Visium) | `5-Case-Study-Cortex-Stab` | intact r1, r2 | 3 dpi r1, r2 | 2 대 2; 한 capture area의 두 반구가 한 동물에서 왔을 수 있다 |
| Semi-synthetic HPOA (MERFISH) | `5-Case-Study-HPOA-Synthetic` | naive a5, a6, a7 | aggression a34, a35, a36에서 세포 class 하나 제거 (OD Mature 또는 Astrocyte) | 동물 3 대 3 |

Colitis slice는 2026-11-16에 [17-q1-sample-gallery.ipynb](17-q1-sample-gallery.ipynb)에서 고른 것이다. stORCA는 v3 (`STORCA_CLIP=nonzero95`, `STORCA_GATE=gene`). 경쟁 방법 표는 `02-compare-methods.py`에서 나온다 (`res/Comparison/<case>-gene-table.csv`). DESpace2는 cortex에서 돌리지 않았다.

**Score.** between 쌍에서 dead-zone plan은 treated 세포마다 retained mass $m_i\in[0,1]$를 준다. plan이 남긴 질량의 비율이고, 완전히 매칭된 세포가 $m_i=1$이 되도록 맞춘 값이다. 규칙:

1. $m_i<0.5$이면 그 세포는 **unmatched**다 (세포 단위).
2. control 세포의 1% 미만이고 treated 세포의 2% 이상인 집단은 **새 집단**이다 (annotation 단위).
3. 유전자의 **unmatched 세포 enrichment**는

$$
E_g=\frac{\sum_{i\in U} x_{ig}\big/\sum_{i} x_{ig}}{|U|/n},
$$

이고, $x_{ig}$는 treated section의 log1p 발현, $U$는 unmatched 세포, $n$은 전체 treated 세포다. $E_g=1$이면 유전자가 전체 세포처럼 퍼져 있고, $E_g\gg1$이면 짝 없는 세포의 marker다.

## 0. Summary

| 단계 | 결과 |
|---|---|
| 1. plan이 새 세포를 뺀다 | Colitis: between 쌍에서 treated 세포의 0.469가 unmatched (0.413~0.537), within 쌍은 0.031. Cortex: 0.087 대 0.000이고, 병변 cluster r14가 unmatched 세포의 0.81. Semi-synthetic: 제거된 class의 0.92 (OD Mature)와 0.65 (Astrocyte)가 unmatched, 나머지 세포는 0.02~0.04 |
| 2. 상위 목록의 marker 비율 | Colitis는 해석할 수 없다: 9일째 neighbourhood 이름이 0일째에 없어서 "새 집단"이 treated 세포의 96%다. Cortex에서 (아직 방향을 맞추기 전, 5f 참고) 경쟁 방법 상위 20개의 marker는 20개 중 0~7개, stORCA는 5개. section 5f와 7b가 대신한다 (표준 marker, 사라진 조직 포함) |
| 3. 상위 유전자가 unmatched 세포에서 발현되는가 | 어떤 방법의 상위 20개도 그쪽에 몰려 있지 않다. 경쟁 방법의 $E_g$ 중앙값: colitis 0.56~0.79 (전체 검정 유전자 0.76), cortex 1.01~1.17 (전체 1.13). stORCA: 0.54와 1.39. 생긴 조직만 본 것이고, section 5d는 효과를 사라진 조직에서 찾는다 |
| 4. 예시 | 이 규칙으로는 없다. section 5f에 `Ptger3` (colitis)와 `Lgals1` (cortex, STcompare)이 있다 |
| 5. 통제된 검사 | OD Mature 세포를 빼면 stORCA 상위 20개에 제거된 class의 marker가 3개 늘고 (1→4) `Gjc3`, `Opalin`이 새 call이 된다. astrocyte를 빼면 3개 늘고 (2→5) `Aldh1l1`이 새 call이 된다. CODA, STcompare, stORCA 단일 쌍 score는 그대로이고, River와 SpaceExpress는 최대 2개 움직인다 |
| 5b. 이유 | 새는 것이 아니다: 제거된 세포는 남은 세포-matching의 5%. class를 빼면 between 쌍의 $Q_x+Q_y$가 줄고 (`Gjc3` 190k→26k) within naive 쌍은 그대로라서, between 쌍 ROS가 오르고 (0.17→0.28) 다른 세포에서 잰 기준선을 넘는다 |
| 5c. 검사 | within control 쌍을 between 쌍이 남기는 세포에서 재면 (retained mass로 thinning) OD Mature 제거가 만든 call 6개가 모두 사라진다. 남은 7개는 원래 call이고, 원래 HPOA는 11개 중 11개를 유지한다. astrocyte case는 그대로다 (`Aldh1l1` 남음). plan이 astrocyte 질량의 약 40%를 남기기 때문이다. 양쪽 thinning (`basew2`, section 7의 변형)에서는 call 10개가 남고 그중 4개가 원래 HPOA call이 아니다 (`Gjc3`, `Opalin`, `Pnoc`, `Th`; `Gjc3`, `Opalin`의 BH 0.045); 모든 변형에서 상위 20개 중 4개가 제거된 class의 marker다 (원래 1개) |
| 5d. Colitis, 사라진 조직 | D0 vs D9에서 CODA, STcompare, DESpace2 상위 20개의 0.70, 0.65, 0.80이 사라지는 상피의 marker다 (기준 0.36); stORCA 0.25, River 0.30. 궤양 (생긴 쪽) marker에 농축된 공간 방법은 없다 |
| 5f. 표준 marker | Cluster 대 나머지, shared 유전자 (cluster 밖에서도 바뀜)는 따로 셈. Colitis 사라진 상피: CODA, STcompare, DESpace2 상위 20개의 0.60~0.70 (cluster-only 0.30~0.35), stORCA 0.35 (0.05~0.10); 예시 `Ptger3`. 방향 맞춘 cortex, 병변 r14만: 상위 20개 중 CODA 0.45, STcompare 0.70, stORCA 0.30, thinning 0.20 (기준 0.11); CODA는 거의 모두 shared (cluster-only 0.05), STcompare는 cluster-only 0.20 (`Lgals1` 1위), stORCA 0.00 (기준 0.07) |
| 7a. Retained mass (결론) | 짝 없는 조직은 질량의 0.43 (cortex r14)과 0.19 (colitis 0일째 상피)를 유지하고, 다른 세포는 0.97과 0.81, within 쌍은 0.99다; AUROC 0.89와 0.94. Colitis 9일째는 약하다 (0.66) |
| 7b. 상위 유전자 (결론) | 상위 20개 중 짝 없는 조직의 marker (cortex, colitis): 양쪽 thinning한 stORCA 0.20과 0.35 (기준 0.11, 0.28); CODA 0.45와 0.70; STcompare 0.70과 0.60; DESpace2 0.70 (colitis); River 0.10과 0.30; pseudobulk DE 0.60과 0.40 |
| 7c. CODA와 STcompare가 속는 이유 (기전, 9개 pair) | 정렬이 사라진 상피를 9일째 조직 위에 놓는다 (CODA: 사라진 세포의 0.79가 9일째 세포 위; STcompare: 상피 pixel의 0.74~0.99가 공유 pixel로 남음). 거기서 marker는 9일째 평균보다 낮으므로 correlation이 음수가 된다 (두 방법 모두 9개 pair 중 9개에서 `Ptger3`). 이 겹침이 `Ptger3` 음의 점수의 0.85 (CODA)와 0.59 (STcompare)를 만든다. 흩어진 class를 빼면 (HPOA) 겹칠 것이 없고, marker의 CCI는 구조 없는 유전자 수준으로 떨어질 뿐이다 (`Gjc3` 0.18에서 0.04) |
| 6. 상태 (section 7 이후 갱신) | region 형태로 잃거나 생긴 조직에 대해 충분. semi-synthetic 검사 (section 5~5c)는 쓰지 않는다 |

## 1. stORCA가 unmatched로 남기는 treated 세포 (노트북 section 1과 5)

**질문.** treated section에 control에 없는 조직이 있으면, plan은 정확히 그 조직을 unmatched로 남기는가?

**쉽게 말하면.** dead-zone plan은 닮은 control 세포가 없으면 그 세포를 매칭하지 않을 수 있다. within 쌍 (control section 둘 또는 treated section 둘)에는 새로운 것이 없으므로 거의 모든 세포가 매칭되어야 한다. between 쌍은 새 조직을 빼고 나머지를 남겨야 한다.

**구현** (노트북 section 1; 저장된 plan `-ratio-ot.npz`에 `interpret.retained_fraction`).

1. 모든 쌍에서 target 세포마다 retained mass를 읽는다.
2. 같은 treated section을 쓰는 쌍들로 평균한다; annotation 집단별로 묶는다 (colitis `neigh`, cortex `region`).
3. 집단마다 between과 within 쌍의 unmatched 비율을 보고한다.

**결과.**

| Case | Unmatched, between 쌍 | Unmatched, within 쌍 | 가장 많이 빠지는 집단 |
|---|---|---|---|
| Colitis D0 vs D9 | 0.469 (0.413~0.537) | 0.031 (0.000~0.129) | LUM (lumen) 0.98, MU8 (ulcer mucosa) 0.64; 평활근 SM2 0.33, ME3 0.12 |
| Cortex intact vs 3 dpi | 0.087 (0.039~0.141) | 0.000 | r14 (병변; control의 0.1%, treated의 12.5%) 0.53; unmatched 세포의 0.81 |

![Colitis maps](fig/11-q1-unmatched-cells/q1-retained-maps-colitisq1.png)

*왼쪽 열: 9일째 slice마다 annotation neighbourhood (legend: `fig/11-q1-unmatched-cells/q1-population-legend-colitisq1.png`). 오른쪽 열: between 쌍으로 평균한 retained mass; 어두울수록 unmatched. 요점: lumen과 궤양 mucosa가 어둡고, 바깥 근육층은 밝다. 출처: [11-q1-unmatched-cells.ipynb](11-q1-unmatched-cells.ipynb) section 1b.*

![Cortex maps](fig/11-q1-unmatched-cells/q1-retained-maps-cortexrep.png)

*3 dpi 두 반구, 같은 배치 (legend: `fig/11-q1-unmatched-cells/q1-population-legend-cortexrep.png`). 요점: 병변만 어둡다. 출처: 노트북 section 1b.*

**집단 지도의 색 코드** (팔레트 tab20 다음 tab20b; 2026-11-18에 고쳤다. 그 전에는 colitis neighbourhood 22개가 20색을 나눠 써서 FOL1과 SM2, LUM과 SM3, ME1과 `others`가 같은 색이었다). 이 지도는 treated section만 보여준다: 사라진 0일째 상피는 여기에 없다 (section 5f 지도에 있다).

| Colitis neighbourhood | 색 | Colitis neighbourhood | 색 | Cortex cluster | 색 |
|---|---|---|---|---|---|
| FOL1 | 파랑 `#1f77b4` | MU2 | 자홍 `#e377c2` | r0 | 파랑 `#1f77b4` |
| LUM (lumen) | 연파랑 `#aec7e8` | MU3 | 연분홍 `#f7b6d2` | r1 | 연파랑 `#aec7e8` |
| ME1 | 주황 `#ff7f0e` | MU4 | 회색 `#7f7f7f` | r2 | 보라 `#9467bd` |
| ME2 | 연주황 `#ffbb78` | MU5 | 연회색 `#c7c7c7` | r3 | 연보라 `#c5b0d5` |
| ME3 | 초록 `#2ca02c` | MU6 | 올리브 `#bcbd22` | r4 | 갈색 `#8c564b` |
| ME4 | 연초록 `#98df8a` | MU7 | 연올리브 `#dbdb8d` | r5 | 연갈색 `#c49c94` |
| MES1 | 빨강 `#d62728` | MU8 (궤양 mucosa) | 청록 `#17becf` | r6 | 자홍 `#e377c2` |
| MES2 | 분홍 `#ff9896` | SM1 | 연청록 `#9edae5` | r7 | 연분홍 `#f7b6d2` |
| MES3 | 보라 `#9467bd` | SM2 (평활근) | 남색 `#393b79` | r8 | 회색 `#7f7f7f` |
| MU1 | 연보라 `#c5b0d5` | SM3 | 쪽빛 `#5254a3` | r9 | 연회색 `#c7c7c7` |
| MU10 | 갈색 `#8c564b` | others | 연남보라 `#6b6ecf` | r10 / r11 | 주황 `#ff7f0e` / 연주황 `#ffbb78` |
| MU11 | 연갈색 `#c49c94` | | | r12 / r13 | 초록 `#2ca02c` / 연초록 `#98df8a` |
| | | | | **r14 (병변)** / r15 | **빨강 `#d62728`** / 분홍 `#ff9896` |

그래서 colitis 지도의 파란 계열 셋은 LUM (연파랑, lumen 내용물), MU8 (청록, 궤양 mucosa, 생긴 조직), SM2 (남색, 평활근)이다.

**Colitis는 너무 쉬운가?** 한 면에서는 그렇다: 9일째에는 상피가 거의 없어서 (0일째 세포의 42%, 9일째 1%) 조직의 절반 가까이가 새것이다. Cortex가 더 깨끗한 경우다: 온전한 조직 안의 작은 병변 하나.

**판정: 작동.** claim의 plan 부분을 그대로 뒷받침한다.

결과 파일: 저장 파일 없음; 숫자는 노트북 section 1 출력에 있다.

## 2. 방법별 상위 목록의 marker 비율 (노트북 section 2와 3)

**질문.** 각 방법의 상위 유전자가 새 집단의 marker인가?

**구현.** Marker: 새 집단 세포 대 나머지 treated 세포의 Wilcoxon 검정 (scanpy) 상위 50개, log fold change 1 초과. 각 방법 상위 20, 50개 (stORCA가 검정한 유전자) 중 marker의 비율.

**결과.**

| 방법 | Colitis 상위 20 | Cortex 상위 20 |
|---|---|---|
| stORCA (replicate t) | 0.20 | 0.25 |
| stORCA 단일 쌍 | 0.10 | 0.30 |
| CODA | 0.15 | 0.00 |
| River | 0.20 | 0.35 |
| STcompare | 0.20 | 0.00 |
| SpaceExpress | 실행 안 함 | 0.00 |
| DESpace2 | 0.10 | 실행 안 함 |
| 전체 검정 유전자 중 marker | 502개 중 44개 (0.09) | 1940개 중 46개 (0.02) |

**어디서 틀리는가.** Colitis에서 9일째 neighbourhood (MU8, MU7, SM2, ME3, LUM)는 이름상 0일째에 없으므로, 규칙 2가 treated 세포의 96%를 "새것"으로 만들고 marker가 "9일째 유전자"가 된다. 그래서 colitis 열은 새 집단을 재지 못한다.

**판정: 부분 성공; colitis는 해석할 수 없고, cortex에서 stORCA의 우위가 없다.** 간극 유형: Fix (계획한 비교가 claim을 보여주지 못한다; section 6).

결과 파일: `5-Case-Study-Comparison/res/Comparison/colitisq1-gene-table.csv`, `cortexrep-gene-table.csv`.

## 3. 각 방법의 상위 유전자가 unmatched 세포에서 발현되는가? (노트북 section 3b)

**질문.** annotation 없이: 한 방법의 상위 유전자가 stORCA가 뺀 세포에 있는가?

**쉽게 말하면.** 어떤 방법이 새 조직에 속는다면, 그 상위 유전자는 주로 그 조직에서 발현되는 유전자일 것이고, 그 $E_g$ (Score 참고)는 전체 유전자 값보다 훨씬 클 것이다.

**구현.** stORCA가 검정한 모든 유전자의 $E_g$를 treated section 셋 (colitis) 또는 둘 (cortex)에서 section 1의 unmatched 세포로 계산한다; 각 방법 상위 20개의 중앙값.

![Enrichment in unmatched cells](fig/11-q1-unmatched-cells/q1-unmatched-enrichment-top20.png)

*case마다 한 panel. 막대: 각 방법 상위 20개 유전자의 $E_g$ 중앙값. 파선: 전체 검정 유전자의 중앙값. 빨간 점선: $E_g=1$. 요점: cortex의 stORCA 단일 쌍 score (3.05)를 빼면 어떤 방법도 파선보다 크게 위에 있지 않다. 출처: 노트북 section 3b.*

**결과.**

| 방법 | Colitis | Cortex |
|---|---|---|
| 전체 검정 유전자 | 0.76 | 1.13 |
| stORCA (replicate t) | 0.54 | 1.39 |
| stORCA 단일 쌍 | 0.94 | 3.05 |
| CODA | 0.56 | 1.17 |
| River | 0.72 | 1.01 |
| STcompare | 0.65 | 1.16 |
| DESpace2 | 0.79 | 실행 안 함 |

**읽기:**

- **이 두 데이터에서 경쟁 방법은 새 세포에 지배되지 않는다.** 중앙값이 전체 유전자 값과 같거나 낮다.
- **cortex에서 stORCA replicate score가 경쟁 방법보다 낮지 않다** (1.39 대 1.01~1.17).

**판정: 새 조직에 대해서는 claim의 근거로 실패.** 전제 (경쟁 방법이 속는다)는 생기는 조직에서는 보이지 않고, section 5d가 사라지는 조직에서 보인다.

결과 파일: `5-Case-Study-Comparison/res/Comparison/q1-unmatched-enrichment.csv` (열 `case`, `method`, `top`, `median_enrichment`).

## 4. 예시 (노트북 section 4)

**규칙.** 경쟁 방법 셋 이상의 상위 20개에 들고 stORCA call이 아닌 새 집단 marker.

**결과.** colitis 후보 0개, cortex 0개. 이름 있는 유전자는 **아직 근거 없음**.

## 5. 통제된 검사: 세포 class 하나를 뺀 semi-synthetic HPOA (노트북 section 6)

**질문.** 차이가 세포 class 하나가 사라진 것뿐일 때, 그 marker를 call하는 방법이 있는가, stORCA는 어떤가?

**왜 필요한가.** 실제 데이터에서는 새 집단과 공유 조직의 진짜 변화가 함께 오므로, 상위 목록의 marker가 진짜 변화일 수 있다. 여기서는 다른 모든 세포가 실제 발현과 위치를 그대로 가지므로, 원래 HPOA 대비 목록에 새로 들어온 제거 class의 marker는 세포가 짝을 잃었기 때문에만 들어온 것이다.

**구현** (`20-q1-hpoasyn-check.py`, 입력은 `hpoa`, `hpoasyn-odm`, `hpoasyn-astro`에 대한 `02-compare-methods.py`).

1. Marker: 원래 aggression section에서 제거 class 대 나머지 세포의 상위 10개 (Wilcoxon, log fold change 1 초과, BH 0.05 미만). OD Mature: `Ermn`, `Mbp`, `Ndrg1`, `Sgk1`, `Gjc3`, `Ttyh2`, `Lpar1`, `Opalin`, `Cck`, `Gnrh1`. Astrocyte: `Aqp4`, `Aldh1l1`, `Cxcl14`, `Mlc1`, `Pou3f2`, `Trh`, `Cspg5`, `Sst`, `Ttyh2`, `Sox8`.
2. 원래 표와 synthetic 표에서 각 방법 상위 20개 안의 marker 수를 센다.
3. between 쌍에서 제거 class의 naive 세포 retained mass (aggression section에서 짝을 잃는다).

**결과.**

| 방법 | OD Mature: 원래 | synthetic | Astrocyte: 원래 | synthetic |
|---|---|---|---|---|
| stORCA (replicate t) | 1 | **4** | 2 | **5** |
| marker인 stORCA call | 11개 중 1 | **14개 중 3** | 11개 중 2 | 8개 중 2 |
| stORCA 단일 쌍 | 0 | 0 | 1 | 1 |
| CODA | 0 | 0 | 0 | 0 |
| River | 3 | 1 | 5 | 5 |
| STcompare | 0 | 0 | 2 | 2 |
| SpaceExpress | 7 | 8 | 4 | 2 |

| 제거 class | Unmatched, 제거 class (between) | Unmatched, 나머지 세포 (between) |
|---|---|---|
| OD Mature | 0.922 | 0.044 |
| Astrocyte | 0.647 | 0.023 |

제거로 생긴 stORCA 새 call 중 marker: OD Mature에서 `Gjc3` (BH 0.157→0.042)와 `Opalin` (0.190→0.042), astrocyte에서 `Aldh1l1` (0.481→0.031). synthetic 실행은 embedding과 plan을 다시 학습하므로 marker 밖에서도 call이 바뀐다 (OD Mature: 11개 중 새로 6, 잃음 3; Astrocyte: 새로 1, 잃음 4).

**읽기:**

- **plan은 작동한다: 제거된 세포는 unmatched로 남는다.** 0.92와 0.65 대 나머지 세포 0.02~0.04.
- **score는 plan을 따르지 않는다.** 세포가 matching에서 빠졌는데도 stORCA replicate t는 그 marker를 더 높이 올리고, 셋이 call이 된다. Unmatched 세포는 이미 score에서 빠진다: 표본 matching마다 source 세포는 retained mass와 같은 확률로 남고, $Q_x$, $Q_y$, $Q_r$는 남은 세포와 그 짝에서만 계산한다 (`5-Case-Study-Colitis/22-nrmi-issue-frequency.py`). 이유는 section 5b가 보인다: 새는 것이 아니라 분모 때문이다.
- **경쟁 방법은 거의 영향을 받지 않는다.** CODA, STcompare, 단일 쌍 score는 그대로이고, River와 SpaceExpress는 최대 2개 움직인다.

**판정: 실패.** 간극 유형: Fix (major). 설명으로 넘길 수 없다: claim의 유일한 통제된 검사이고, score에 대해 반대를 보인다.

결과 파일: `5-Case-Study-Comparison/res/Comparison/q1-hpoasyn-marker-ranks.csv` (열 `scen`, `method`, `table`, `markers_in_top20`), `q1-hpoasyn-retained.csv`, `hpoasyn-odm-gene-table.csv`, `hpoasyn-astro-gene-table.csv`.

## 5b. 제거 class의 marker가 왜 call되는가 (노트북 section 7)

**질문.** 제거된 세포는 matching에서 빠지는데, 늘어난 불일치는 어디서 오는가?

**쉽게 말하면.** ROS는 비율 $Q_r/(Q_x+Q_y)$다. 분자가 커져서 (세포가 틀린 짝을 받아서) 오를 수도 있고, 분모가 작아져서 (맞출 공간 구조가 줄어서) 오를 수도 있다. `Gjc3`의 naive section 공간 구조 대부분은 oligodendrocyte 띠다. 그 띠를 빼면 다른 세포들의 약하고 흩어진 패턴만 남는다. 약한 패턴에서는 matching noise가 남은 구조에서 차지하는 몫이 커지므로, 틀린 짝이 없어도 ROS가 오른다.

**구현** (노트북 section 7; matching별 표 `-issue-matching.csv`, 그리고 score와 같은 matching, 가중치, 전처리로 다시 계산한 세포별 기여).

1. 쌍 종류 (within naive, within aggression, between)마다 $Q_x+Q_y$, $Q_r$, ROS의 평균을 원래와 synthetic 데이터에서 구한다.
2. source 세포마다 $Q_r$ 기여 $c_i=\sum_s \tilde r_i\,(W_s\tilde r)_i$를, 그 세포가 남은 matching $s$에 걸쳐 더한다 ($\sum_i c_i=Q_r$). 제거 class 세포의 $Q_r$ 몫을 남은 세포-matching 중 그 몫과 비교한다.

**결과.**

| 유전자 | 데이터 | $Q_x+Q_y$, within naive | $Q_x+Q_y$, between | ROS, within naive | ROS, within aggression | ROS, between |
|---|---|---|---|---|---|---|
| `Gjc3` | 원래 | 275k | 190k | 0.021 | 0.117 | 0.173 |
| `Gjc3` | synthetic | 276k | 26k | 0.021 | 0.165 | 0.279 |
| `Opalin` | 원래 | 135k | 89k | 0.056 | 0.147 | 0.199 |
| `Opalin` | synthetic | 135k | 7k | 0.056 | 0.401 | 0.475 |
| `Aldh1l1` | 원래 | 47k | 34k | 0.118 | 0.363 | 0.290 |
| `Aldh1l1` | synthetic | 47k | 21k | 0.132 | 0.407 | 0.483 |

| 유전자 | 데이터 | 제거 class, 남은 세포-matching 중 몫 | 제거 class, $Q_r$ 중 몫 |
|---|---|---|---|
| `Gjc3` | 원래 | 0.196 | 0.465 |
| `Gjc3` | synthetic | 0.051 | 0.267 |
| `Opalin` | 원래 | 0.196 | 0.558 |
| `Opalin` | synthetic | 0.051 | 0.320 |
| `Aldh1l1` | 원래 | 0.106 | 0.147 |
| `Aldh1l1` | synthetic | 0.049 | 0.143 |

(between 쌍 9개의 중앙값)

![Denominator and ROS by pair kind](fig/11-q1-unmatched-cells/q1-hpoasyn-qparts.png)

*유전자마다 한 열. 위: matching에 걸쳐 더한 $Q_x+Q_y$, log 척도. 아래: ROS. 회색: 원래 HPOA. 빨강: synthetic (aggression section에서 class 제거). 요점: synthetic에서 between 쌍의 분모는 1.6~12배 줄고 within naive 쌍은 그대로이며, between 쌍의 ROS가 오른다. 출처: [11-q1-unmatched-cells.ipynb](11-q1-unmatched-cells.ipynb) section 7.*

![Gjc3 Q_r maps](fig/11-q1-unmatched-cells/q1-hpoasyn-gjc3-qr-maps.png)

*쌍 `naive-a5`→`aggr-a34`. 왼쪽부터: `naive-a5`의 `Gjc3`; OD Mature 세포를 남는 matching 비율로 색칠 (나머지 세포 회색); 원래 데이터의 세포별 $Q_r$ 기여; synthetic 데이터의 같은 값, 같은 색 척도. 요점: synthetic 쌍에서 oligodendrocyte 띠 (위)는 거의 남지 않고, $Q_r$는 section 전체에 흩어진 세포에서 원래와 비슷한 크기로 나온다. `Opalin`과 `Aldh1l1`: `fig/11-q1-unmatched-cells/q1-hpoasyn-opalin-qr-maps.png`, `q1-hpoasyn-aldh1l1-qr-maps.png`. 출처: 노트북 section 7.*

**읽기:**

- **새는 것이 아니다.** 제거된 세포는 세포-matching의 5%에만 남고, $Q_r$ 몫도 원래보다 작다.
- **분모 때문이다.** between 쌍은 marker의 공간 구조 대부분을 잃고 (`Opalin`의 $Q_x+Q_y$가 89k에서 7k로), $Q_r$는 덜 줄어서 ROS가 오른다.
- **기준선이 다른 세포에서 잰다.** within naive 쌍은 양쪽에 그 class가 있어 낮은 ROS를 유지한다 (`Gjc3` 0.021). between 쌍은 그 class가 빠진 조직에서 유전자를 잰다. 그래서 "between 빼기 within"은 서로 다른 세포 집합에서 잰 일치도를 비교하게 되고, 그 차이가 call된다.

**call이 틀린 것인가?** 일부는 아니다: treated section은 실제로 marker의 공간 패턴을 잃었고, 매칭된 세포에 남은 패턴은 약하고 흐트러져 있다. 그러나 Q1이 분리한다고 주장하는 공유 조직의 변화는 아니다. 수정한다면 within control 쌍을 between 쌍이 남기는 것과 같은 종류의 세포에서 재야 한다 (예: control 세포마다 between 쌍에서의 retained mass로 가중). 방법 변경이다.

**판정: 기전을 찾았다.** plan은 작동하고, replicate 기준선이 plan을 따르지 않는다.

결과 파일: `5-Case-Study-Comparison/res/Comparison/q1-hpoasyn-qr-share.csv` (열 `gene`, `data`, `pair`, `class_share_of_cell_matchings`, `class_share_of_Qr`); $Q$ 표는 노트북 section 7 출력에 있다.

## 5c. 검사: replicate 기준선을 between 쌍이 남기는 세포에서 재기 (노트북 section 8)

**질문.** within control 쌍을 between 쌍이 남기는 세포와 같은 세포에서 재면, 제거된 class가 만든 call은 사라지고 진짜 call은 남는가?

**쉽게 말하면.** between 쌍에서 naive oligodendrocyte는 대부분 빠지므로, naive section끼리 비교할 때도 그 세포를 빼야 한다. 그래야 "between 빼기 within"의 양쪽이 같은 조직을 본다.

**구현** (`22-q1-baseline-weighting.py`, 2026-11-17). 두 변형; 둘 다 v3 limma 적합을 모든 라벨로 다시 돌린다.

1. **Thinning (`basew`).** source section $s$의 within control 쌍에서, source 세포 $i$를 scoring matching마다 추가 확률 $m_i$로 남긴다. $m_i$는 $s$에서 나가는 between 쌍들에서의 평균 retained mass다. matching과 짝은 그대로이고 세포만 솎는다. between 쌍은 그대로다.
2. **Hard (`hard`).** retained mass 0.5 미만 세포를 모든 matching에서 뺀다. between 쌍에서는 자기 retained mass로, within control 쌍에서는 between 쌍 평균으로.

대조: class가 빠지지 않은 원래 HPOA (call 11개가 남아야 한다); 각 적합의 가짜 라벨.

**결과.**

| 변형 | Case | 이전 call | 이후 call | 이후 call 중 원래 HPOA call | 잃음 | 얻음 | 가짜 라벨 최대 |
|---|---|---|---|---|---|---|---|
| Thinning | OD Mature 제거 | 14 | 7 | 7개 중 7 | `Cd24a`, `Gjc3`, `Greb1`, `Igf2r`, `Opalin`, `Pnoc`, `Rxfp1` | 없음 | 1 |
| Thinning | Astrocyte 제거 | 8 | 8 | 8개 중 7 | 없음 | 없음 | 0 |
| Thinning | 원래 HPOA | 11 | 11 | 11개 중 11 | 없음 | 없음 | 0 |
| Thinning | Colitis D0 vs D9 | 425 | 407 | 해당 없음 | 20 | 2 | 0 |
| Hard | OD Mature 제거 | 14 | 8 | 8개 중 6 | `Cd24a`, `Gjc3`, `Greb1`, `Igf2r`, `Ntsr1`, `Pnoc`, `Rxfp1` | `Lpar1` | 1 |
| Hard | Astrocyte 제거 | 8 | 8 | 8개 중 7 | 없음 | 없음 | 0 |
| Hard | 원래 HPOA | 11 | 9 | 9개 중 9 | `Adora2a`, `Cckbr` | 없음 | 0 |
| 양쪽 thinning (`basew2`, 2026-11-18) | OD Mature 제거 | 14 | 10 | 10개 중 6 | `Cd24a`, `Col25a1`, `Crhr1`, `Greb1`, `Rxfp1` | `Th` | 0 |
| 양쪽 thinning (`basew2`, 2026-11-18) | 원래 HPOA | 11 | 11 | 11개 중 11 | 없음 | 없음 | 0 |

**읽기:**

- **Thinning은 OD Mature 제거가 만든 call을 모두 없앤다** (`Gjc3`, `Opalin`과 marker가 아닌 call 네 개). 남는 것은 원래 call의 부분집합이다. 원래 HPOA는 바뀌지 않으므로, 여기서는 진짜 call을 잃지 않는다.
- **astrocyte case는 고치지 못한다.** `Aldh1l1`이 여전히 call이다 (BH 0.034; within ROS 0.30, between 0.48). astrocyte는 흩어져 있고, plan은 between 쌍에서 그 질량의 37~43%를 남긴다 (나머지 세포는 95~100%). 그래서 진짜 새는 부분이 남는다: 남은 astrocyte가 다른 class 세포와 짝이 된다. 기준선을 솎아서는 이것을 없앨 수 없다.
- **Hard 규칙은 더 나쁘다.** `Opalin`이 남고, OD Mature marker `Lpar1`이 새로 call되며, 원래 HPOA의 진짜 call 11개 중 2개를 잃는다.

**갱신 2026-11-18: 양쪽 thinning.** section 7은 section 5e의 대칭 변형을 쓴다. OD Mature case에서 이 변형은 위 결과를 되풀이하지 않는다: `Gjc3`와 `Opalin`이 call로 남고 (BH 0.045; control 쪽만 솎으면 0.069와 0.056), `Pnoc`도 남고, `Th`가 더해지며, 원래 call 두 개 (`Col25a1`, `Crhr1`)를 잃는다. control 쪽 변형은 `Gjc3`와 `Opalin`을 기준선 바로 위로 옮겼을 뿐이라 변형끼리 차이는 작다. 어떤 변형도 움직이지 못하는 것은 순위다: thinning 없음, control 쪽, 양쪽 모두에서 상위 20개 중 4개가 제거된 class의 marker다 (원래 HPOA 1개). astrocyte case는 양쪽 thinning으로 다시 돌리지 않았다.

**판정 (갱신): thinning은 흩어진 class의 call을 기준선 너머로 옮기지만 상위 20개 밖으로 밀어내지는 못한다.** semi-synthetic 검사는 논문에 쓰지 않는다 (2026-11-18 결정; section 7c).

결과 파일: `5-Case-Study-Comparison/res/Comparison/q1-baseline-weighting-summary-basew.csv`, `-hard.csv`, `-basew2-hpoasynodm.csv`, `-basew2-hpoa.csv`; `<case>/res/stORCA/storca-v3-rep1-<case>-limma-genes-basew.csv`, `-hard.csv`, `-basew2.csv`.

## 5d. Colitis: 생기는 조직과 사라지는 조직 (노트북 section 9)

**질문.** section 3은 새 조직만 셌다. colitis 9일째에는 상피도 사라진다. 경쟁 방법의 상위 유전자는 어느 쪽에서 오는가?

**쉽게 말하면.** 세포가 짝이 없는 경우는 두 가지다: treated section에 있는데 control에 비슷한 것이 없거나 (생긴 조직, 궤양), control에 있는데 treated section에 비슷한 것이 남아 있지 않다 (사라진 조직, 상피). section 전체를 비교하는 방법은 어느 쪽의 marker든 "바뀌었다"고 본다. stORCA의 plan은 둘 다 뺀다.

**구현** (`23-q1-colitis-competitors.py`, 2026-11-17).

1. Unmatched 세포: between 쌍으로 평균한 retained mass 0.5 미만. 생긴 조직은 target 쪽, 사라진 조직은 source 쪽.
2. 각 쪽의 marker: 그 조건의 unmatched 대 matched 세포 Wilcoxon (정규화 log1p, log fold change 1 초과, BH 0.05 미만), stORCA가 검정한 유전자 502개 중. annotation은 쓰지 않는다.
3. 방법마다: 상위 20, 50개 중 marker 비율을 전체 검정 유전자 중 비율과 비교하고, score의 AUROC를 구한다.

**결과** (D0 vs D9; D9 세포의 0.452와 D0 세포의 0.441이 unmatched; 생긴 쪽 marker 69개, 사라진 쪽 181개).

| 방법 | 사라진 쪽 marker, 상위 20 | 사라진 쪽, 상위 50 | 사라진 쪽, AUROC | 생긴 쪽 marker, 상위 20 | 생긴 쪽, AUROC |
|---|---|---|---|---|---|
| 전체 검정 유전자 (기준) | 0.36 | 0.36 | 0.50 | 0.14 | 0.50 |
| stORCA (replicate t) | **0.25** | 0.30 | 0.44 | 0.15 | 0.45 |
| stORCA, 기준선 thinning (section 5c) | **0.25** | 0.24 | 0.42 | 0.15 | 0.45 |
| stORCA 단일 쌍 | 0.15 | 0.20 | 0.52 | 0.15 | 0.34 |
| CODA | **0.70** | 0.48 | 0.42 | 0.05 | 0.44 |
| River | 0.30 | 0.44 | 0.62 | 0.20 | 0.51 |
| STcompare | **0.65** | 0.54 | 0.41 | 0.05 | 0.32 |
| DESpace2 | **0.80** | 0.70 | 0.68 | 0.00 | 0.42 |
| Pseudobulk DE | 0.35 | 0.32 | 0.55 | 0.45 | 0.80 |

CODA, STcompare, DESpace2 상위 20개의 사라진 조직 marker에는 `Ptger3` (셋 모두), `Lrp6`, `Cldn15`, `Yap1`, `Nr1d2`, `Bcr`, 그리고 DESpace2의 `Muc4`, `Atoh1`, `Ccl28`가 있다: 9일째에 사라진 상피의 유전자다.

![Colitis top 20 by side](fig/11-q1-unmatched-cells/q1-colitis-lost-gained-top20.png)

*왼쪽: 각 방법 상위 20개 중 사라진 조직 marker의 비율. 오른쪽: 생긴 조직 marker. 빨강: stORCA. 파선: 전체 검정 유전자 중 비율. 요점: CODA, STcompare, DESpace2는 사라진 조직에서 기준의 약 두 배이고, stORCA는 기준보다 낮다. 출처: [11-q1-unmatched-cells.ipynb](11-q1-unmatched-cells.ipynb) section 9.*

**읽기:**

- **경쟁 방법 셋이 사라지는 조직에 지배된다.** 상위 20개 중 13~16개가 사라진 조직 marker이고, 기대값은 7개다. stORCA는 5개, River는 6개다.
- **생기는 조직에 지배되는 공간 방법은 없다.** 그래서 section 3에서 아무것도 보이지 않았다. 궤양 유전자를 고르는 것은 pseudobulk DE뿐이다.
- **농축은 순위 전체가 아니라 위쪽에 있다.** 사라진 쪽 marker에 대한 CODA와 STcompare의 AUROC는 0.42와 0.41이다. 사용자가 읽는 것은 목록 위쪽이므로 상위 20이 맞는 척도이지만, "순위 전체가 구성 변화에 끌려간다"는 효과는 아니다.
- **D0 vs D3은 claim을 검사하지 못한다.** unmatched 세포가 0.4% (생긴 쪽)와 1.3% (사라진 쪽)뿐이다.

**section 5의 semi-synthetic 검사에서 왜 이것이 안 보였나.** 거기서 제거된 class는 세포의 20%이고 다른 세포와 섞여 있다. colitis에서 사라진 조직은 세포의 44%이고 구획 하나 전체 (mucosa)라서, 경쟁 방법의 정렬이나 상관이 큰 구멍을 돌아가야 한다. 이것은 해석이고 검사는 아니다.

**설계.** 여기서 "3 vs 3"은 조건마다 한 마우스의 한 section에서 나온 인접 slice 셋이다 (`062921_D0_m3a_2` slice 1~3 대 `100221_D9_m5_1` slice 1~3): between 쌍 9개, within 쌍 6개. 경쟁 방법 score는 between 쌍 9개의 평균이다. stORCA의 limma는 쌍 15개를 모두 쓰지만 within 쌍이 거의 복사본이라 502개 중 425개 (thinning 뒤 407개)를 call한다. 여기서는 call이 아니라 순위만 비교한다.

**판정: 심한 colitis의 사라진 조직에서 작동; 생긴 조직은 근거 없음.** 데이터 하나, 조건마다 한 마우스이므로 replicate된 비교가 아니라 생물학적 비교 하나다.

결과 파일: `5-Case-Study-Comparison/res/Comparison/q1-colitis-competitors.csv` (열 `case`, `method`, `side`, `top20`, `top50`, `auroc`, `base_share`), `q1-colitis-top-genes.csv`.

## 5e. Cortex stab wound, 그리고 양쪽 thinning (2026-11-17)

**질문.** colitis에서 본 그림이 cortex stab wound에서도 성립하는가, 그리고 기준선을 treated 쪽에서도 솎아야 하는가?

**왜 양쪽인가.** section 5c는 within control 쌍만 솎았고, 이것은 사라지는 조직을 다룬다. 생기는 조직 (궤양, 병변)은 treated section에 있다: between 쌍은 그것을 빼지만 within treated 쌍은 남긴다. 반대쪽의 같은 불일치다. 대칭 버전 (`22-q1-baseline-weighting.py --both`, suffix `basew2`)은 within treated 쌍도 솎는다. treated 세포마다 between 쌍에서 target으로서의 평균 retained mass와 같은 확률로 남긴다.

**구현.** `23-q1-colitis-competitors.py cortexrep`와 `colitisq1`, section 5d와 같은 규칙. Cortex stab은 2 vs 2 (intact r1, r2 대 3 dpi r1, r2)라 조건마다 within 쌍이 하나이고 stORCA call은 1개다; 순위만 비교한다.

**결과.** Cortex: 3 dpi spot의 0.089가 unmatched (병변, 생긴 쪽 marker 239개); intact spot은 0.010만 unmatched (사라진 쪽 marker 3개)라서 생긴 쪽만 검사할 수 있다.

| 상위 20 | Cortex, 생긴 쪽 (기준 0.12) | Colitis D9, 생긴 쪽 (기준 0.14) | Colitis D9, 사라진 쪽 (기준 0.36) |
|---|---|---|---|
| stORCA | 0.35 | 0.15 | 0.25 |
| stORCA, control 쪽 thinning | 0.35 | 0.15 | 0.25 |
| stORCA, 양쪽 thinning | **0.20** | **0.00** | 0.25 (상위 50: 0.18) |
| CODA | 0.05 | 0.05 | 0.70 |
| River | 0.35 | 0.20 | 0.30 |
| STcompare | 0.10 | 0.05 | 0.65 |
| SpaceExpress | 0.00 | 실행 안 함 | 실행 안 함 |
| DESpace2 | 실행 안 함 | 0.00 | 0.80 |
| Pseudobulk DE | 0.70 | 0.45 | 0.35 |

양쪽 thinning한 원래 HPOA: call 11개 중 11개 유지. Colitis call: 425에서 398.

양쪽 thinning 뒤 cortex 상위 20개에 남은 병변 marker 네 개, 평균 log1p 수준:

| 유전자 | Intact | 3 dpi, matched 조직 | 3 dpi, 병변 |
|---|---|---|---|
| `C1qc` | 0.54 | 0.81 | 2.43 |
| `Tyrobp` | 0.61 | 0.85 | 2.34 |
| `Tmsb10` | 1.94 | 2.12 | 2.92 |
| `Ms4a6c` | 0.008 | 0.009 | 0.18 |

**읽기:**

- **생기는 조직에는 양쪽 thinning이 필요하다.** colitis 상위 20개에서 궤양 marker를 없애고 (0.15→0.00), cortex에서 병변 marker를 0.35에서 0.20으로 줄이며, HPOA call은 바꾸지 않는다.
- **위 표의 cortex 경쟁 방법 열은 유효하지 않다.** 이 section은 방향을 맞추기 전이었고, CODA와 STcompare의 정렬이 실패했다 (두 intact 반구 사이 `Mbp`의 CODA score -0.11). 방향을 맞춘 section에서 (`23-q1-colitis-competitors.py cortexor`, 같은 규칙) 상위 20개 중 생긴 조직 marker 비율은 CODA 0.50, STcompare 0.85, River 0.05, SpaceExpress 0.00이다; stORCA는 그대로다 (강체 변환을 쓰지 않는다). 이 중 어느 것이 병변에만 있는지는 section 5f에서 나눈다.
- **stORCA에 남는 것은 대부분 공유 조직의 진짜 변화다.** `C1qc`와 `Tyrobp` (microglia)는 병변 주변 matched 조직에서 intact cortex보다 1.4~1.5배 높다. `Ms4a6c`는 병변 안에서만 바뀌므로 남은 누출이다 (20개 중 1개).

**판정: 대칭 thinning은 두 데이터에서 작동한다. cortex의 경쟁 방법 비교는 section 5f (방향 맞춘 section)로 대체한다.**

결과 파일: `5-Case-Study-Comparison/res/Comparison/q1-colitis-competitors-cortexrep.csv`, `-colitisq1.csv`, `q1-baseline-weighting-summary-basew2-<case>.csv`.

## 5f. 표준 marker, 방향을 맞춘 cortex, 예시 (노트북 section 10, 2026-11-18)

**질문.** section 5d와 5e는 stORCA 자신의 plan으로 marker를 정했다 (unmatched 대 matched 세포). plan을 쓰지 않는 표준 marker 방식으로도 결과가 유지되는가? 그리고 병변 주변에서도 함께 올라가는 유전자 (`Gfap`, `C1qc` 같은 반응성 glia)를 셈에서 뺄 수 있는가?

**구현.**

1. 조건 특이 cluster: 한 조건에서 세포의 1% 미만, 다른 조건에서 2% 이상. Cortex (방향을 맞춘 section `cortexor`, 아래 참고; cluster `region`): **r14**, 병변. r15도 규칙을 통과하지만 뺐다: cortex를 가로지르는 띠이고, plan이 이것을 매칭한다 (retained mass 0.88, unmatched 9%; r14는 0.48과 53%). 즉 짝이 있는 조직이 상태만 바뀐 것이지 짝 없는 조직이 아니다. Colitis (논문 cell type `tier2`): 상피, **Colonocytes**, **TA**, **Stem cells**, 0일째에 있고 9일째에 거의 없다. Fibro 2/6/7도 같은 규칙을 통과하지만 염증성 fibroblast로 바뀌는 것 (상태 변화)이라 뺐다.
2. Marker: 각 cluster 대 두 조건의 나머지 모든 세포 (Wilcoxon, normalized log1p, log2 fold change 1 초과, BH 0.05 미만, cluster 세포의 25% 이상에서 발현), Seurat `FindAllMarkers`와 같다; cluster에 대해 합집합.
3. **Cluster-only 대 shared.** cluster 밖 조직도 조건 사이에 바뀌면 marker를 *shared*로 둔다: 두 조건의 cluster 밖 세포 사이 |log2 fold change|가 0.5 이상. 반응성 glia 유전자는 이렇게 뺀다: `Gfap`, `C1qc`, `Cd52`, `Hmox1`은 병변 marker이지만 병변 밖 3 dpi cortex에서도 올라가므로 공유 조직의 진짜 변화이고, 어느 방법의 오류로도 세지 않는다. *Cluster-only* marker는 cluster 안에서만 바뀐다.
4. 유전자의 집중도: cluster 세포에 있는 발현 비율을 cluster 세포 비율로 나눈 값 (1 = 모든 세포처럼 퍼짐; 최대 cortex 7.7, colitis 2.5).
5. 방향을 맞춘 cortex: 네 반구를 한 방향으로 맞췄다 (`07-orient-sections.py`, 뒤집기와 90도 회전 8가지 중 하나, 평균 bin 상관 0.54~0.62, 전에는 -0.20~0.09). 경쟁 방법 넷을 모두 다시 돌렸고, 정렬이 이제 작동한다 (두 intact 반구 사이 `Mbp`의 CODA score, 전 -0.11, 후 0.55). stORCA는 강체 변환에 영향받지 않는다.

**색 코드** (지도): cortex r14 빨강 `#d62728`; colitis Colonocytes 진파랑 `#08519c`, TA 파랑 `#3182bd`, Stem cells 연파랑 `#9ecae1`; 나머지 세포는 연회색 `#e0e0e0`. 그래서 맞다: 이 지도에서 사라진 상피는 0일째 section의 파란 고리다.

**결과** (상위 20개 중 비율; marker = cluster-only + shared).

| 방법 | Cortex r14, marker (기준 0.11) | Cortex r14, cluster-only (기준 0.07) | Cortex, 집중도 중앙값 | Colitis 사라진 상피, marker (기준 0.28) | Colitis, cluster-only (기준 0.12) | Colitis, 집중도 중앙값 |
|---|---|---|---|---|---|---|
| stORCA | 0.30 | 0.00 | 1.35 | 0.35 | 0.05 | 0.38 |
| stORCA, 양쪽 thinning | 0.20 | 0.05 | 1.08 | 0.35 | 0.10 | 0.45 |
| CODA | **0.45** | 0.05 | 1.43 | **0.70** | **0.30** | **1.50** |
| River | 0.10 | 0.00 | 0.99 | 0.30 | 0.00 | 0.91 |
| STcompare | **0.70** | **0.20** | **1.75** | **0.60** | **0.30** | **1.49** |
| SpaceExpress | 0.00 | 0.00 | | 실행 안 함 | 실행 안 함 | |
| DESpace2 | 실행 안 함 | 실행 안 함 | | **0.70** | **0.35** | **2.01** |
| Pseudobulk DE | 0.60 | 0.05 | 2.86 | 0.40 | 0.05 | 1.40 |

![Top-20 share and concentration](fig/11-q1-unmatched-cells/q1-std-top20-share-concentration.png)

*왼쪽: 각 방법 상위 20개 중 cluster marker 비율, cluster-only (검정)와 shared (회색); 점선: 검사한 전체 유전자 중 비율. 오른쪽: 상위 20개 유전자 각각의 cluster 집중도, 빨간 선 = 중앙값. 위: cortex 병변 r14. 아래: colitis 사라진 상피. 요점: colitis에서 CODA, STcompare, DESpace2 목록은 사라진 상피에 몰려 있고 (중앙값 1.5~2.0) stORCA는 아니다 (0.4); cortex에서 CODA의 병변 marker는 거의 모두 shared (회색)이고, STcompare는 상위 20개에 cluster-only 유전자가 4개 있다 (stORCA 0개). 출처: [11-q1-unmatched-cells.ipynb](11-q1-unmatched-cells.ipynb) section 10b.*

![Colitis examples](fig/11-q1-unmatched-cells/q1-std-examples-colitisq1.png)

*1~4행: `Ptger3`, `Cldn15` (경쟁 방법 상위 20개), `Flnc`, `Grem2` (stORCA 1, 2위), 유전자마다 0일째 slice 셋과 9일째 slice 셋에 한 색 척도. 마지막 행: 상피 (파랑)와 나머지 세포 (회색). 요점: `Ptger3`과 `Cldn15`는 0일째 상피 고리에 있고 상피와 함께 사라진다; `Flnc`와 `Grem2`는 두 날 모두 있는 근육층에 있고 거기서 바뀐다. 출처: 노트북 section 10c.*

| Colitis 유전자 | stORCA 순위 | stORCA thinning 순위 | CODA | STcompare | DESpace2 | 분류 | 집중도 |
|---|---|---|---|---|---|---|---|
| `Ptger3` | 212 | 224 | 1 | 3 | 1 | cluster-only | 1.9 |
| `Cldn15` | 284 | 353 | 11 | >20 | 18 | cluster-only | 2.0 |
| `Flnc` | 1 | 2 | >20 | >20 | >20 | marker 아님 | 0.1 |
| `Grem2` | 2 | 5 | >20 | >20 | >20 | marker 아님 | 0.3 |

![Cortex examples](fig/11-q1-unmatched-cells/q1-std-examples-cortexor.png)

*행: `Cd52`, `Hmox1` (CODA 1위와 17위), `Sgk1` (stORCA 1위), `Ms4a6c` (stORCA thinning 17위), 유전자마다 방향을 맞춘 네 반구에 한 색 척도. 마지막 행: r14 (빨강). 요점: CODA 유전자는 병변에서 가장 높고 3 dpi cortex 전체에서도 올라 있다 (shared); `Sgk1`은 매칭된 조직의 띠 (뺀 r15)에서 오르고 병변에서는 아니다; `Ms4a6c`는 병변에만 있고 stORCA 목록에 있다. 출처: 노트북 section 10c.*

| Cortex 유전자 | stORCA 순위 | stORCA thinning 순위 | CODA 순위 | 분류 (r14) | 집중도 | r14 밖 log2FC |
|---|---|---|---|---|---|---|
| `Cd52` | 124 | 169 | 1 | shared | 3.05 | 1.49 |
| `Hmox1` | 119 | 212 | 17 | shared | 4.28 | 1.17 |
| `Sgk1` | 1 | 1 | 1291 | marker 아님 | 0.88 | 1.33 |
| `Ms4a6c` | 8 | 17 | 135 | 병변에만 있음, 25% 발현 규칙 미달 | 5.73 | -0.11 |

**읽기:**

- **Colitis는 표준 marker로도 유지된다.** CODA, STcompare, DESpace2는 상위 20개의 0.60~0.70을 사라진 상피의 marker에 두고, 그 절반이 cluster-only다 (기준 0.28과 0.12); stORCA는 0.35와 0.05~0.10. `Ptger3`이 이름 있는 예시다: 세 경쟁 방법 모두에서 3위 안, stORCA 212위, 지도에서 사라진 상피의 유전자다.
- **Cortex (r14만): CODA가 병변에 더 기대지만 shared 유전자를 통해서다.** CODA는 상위 20개 중 병변 marker가 0.45이고 stORCA는 0.30, 양쪽 thinning 후 0.20이다 (기준 0.11). `Cd52`와 `Hmox1`은 r14에서 가장 높다 (집중도 3.0과 4.3). 이 marker는 거의 모두 병변 밖에서도 오른다 (cluster-only: CODA와 thinning stORCA 0.05, stORCA 0.00). 그래서 CODA는 병변에서 가장 큰 진짜 변화를 올리는 것이고, 오류가 아니다. stORCA가 대신 올리는 것은 매칭된 조직의 변화다: 1위 `Sgk1`은 plan이 매칭하는 r15 띠에서 오르고 병변에서는 아니다. 두 목록을 통틀어 병변에만 있는 유전자 `Ms4a6c`는 stORCA 쪽에 있다 (집중도 5.7, 밖에서는 변화 없음).
- **Cortex, STcompare: colitis 패턴의 약한 형태.** STcompare는 상위 20개의 0.70을 병변 marker에 두고, 0.20이 cluster-only다 (기준 0.07): `Lgals1` (1위, 집중도 2.0, r14 밖 log2FC 0.47로 0.5 기준 바로 아래), `Ftl1` (11위), `Tpm4` (18위), `Tax1bp3` (19위). stORCA는 이들을 211~593위에 두고, 상위 20개에 cluster-only 유전자가 없다. 기대값 1.5개에 대해 4개이므로, 생기는 조직에 대한 claim의 방향은 뒷받침하지만 colitis만큼 강하지는 않다.
- **r15를 뺀 이유.** r14와 r15를 함께 쓰면 (이전 판) stORCA marker 0.55 대 CODA 0.50이었다. `Pou3f1`, `Sgk1` 같은 r15 유전자가 "새 조직" marker로 셌기 때문이다. plan은 r15를 매칭하므로 (retained mass 0.88) 이 유전자들은 짝이 있는 조직의 변화이고 세면 안 된다.
- **colitis에서 plan 기반 marker와 표준 marker가 일치한다** (section 5d와 5f). 표준 방식은 stORCA와 독립이므로 논문에서 쓸 정의다.

**판정: Q1의 경쟁 방법 부분은 colitis의 사라진 상피에서 plan과 무관한 표준 marker로 뒷받침되고, 예시는 `Ptger3`이다. 방향 맞춘 cortex에서 CODA는 강조점의 차이만 보이고 오류는 없다 (병변 유전자가 병변 밖에서도 바뀐다); STcompare는 약한 오류를 보인다 (상위 20개에 병변에만 있는 유전자 4개, `Lgals1` 1위, stORCA는 0개). Cortex는 생기는 조직에 대한 보조 예시로 쓸 수 있고, 주 예시는 colitis다.**

결과 파일: `5-Case-Study-Comparison/res/Comparison/q1-standard-markers-summary.csv`, `q1-standard-markers-<case>.csv` (유전자마다: 집중도, cluster 밖 변화, marker, cluster-only, 방법별 순위).

## 6. Q1의 현재 위치 (2026-11-18 갱신, section 7 이후)

**상태: 충분**, region 형태로 잃거나 생긴 조직 (구획, 병변)에 대해. section 7이 결론이다. plan 부분과 경쟁 방법 부분은 plan과 무관한 표준 marker로 두 실제 case 모두에서 성립하고, 기준선을 양쪽에서 솎은 stORCA는 기준 비율 근처에 머문다. section 7c는 경쟁 방법이 틀리는 기전을 보여주며, 이 기전에는 잃거나 생긴 region이 필요하다. section 5~5c의 semi-synthetic 검사는 쓰지 않는다 (2026-11-18 결정): 다른 세포 사이에 흩어진 class를 빼면 정렬이 메울 구멍이 생기지 않고 marker에 조직된 패턴도 남지 않으므로 실제 case를 재현하지 못한다 (section 7c). 이 상태는 2026-11-17의 상태 ("아직 아님")를 대신한다. 그 상태는 양쪽 thinning (section 5e)과 표준 marker (section 5f) 전에 쓴 것이다. 문제는 `CLAUDE.md`의 규칙 ("Level of Rigor: Fix or Defend")으로 나눈다.

| Claim | 뒷받침되는가? | 근거 |
|---|---|---|
| plan은 짝 없는 세포를 unmatched로 남긴다 | 예: AUROC 0.89 (cortex), 0.94 (colitis 0일째); within 쌍은 0.99 유지 | 1, 7a |
| stORCA는 구성 변화를 따로 보고한다 (얼마나, 어떤 집단) | 예, 출력으로 | 1, 7a |
| Registration과 domain 방법은 짝 없는 조직의 marker를 목록 위쪽에 올린다 | 표준 marker로 두 실제 case 모두에서 예: colitis 사라진 상피 CODA 0.70, STcompare 0.60, DESpace2 0.70 (기준 0.28); cortex 병변 CODA 0.45, STcompare 0.70 (기준 0.11) | 5f, 7b |
| stORCA의 상위 유전자는 그 조직에 끌려가지 않는다 | 두 실제 case에서 예: 양쪽 thinning으로 0.35와 0.20 | 7b |
| 경쟁 방법의 오류에 기전이 있다 | colitis 9개 pair 모두에서, CODA와 STcompare 모두 예: 정렬이 사라진 상피를 marker가 낮은 9일째 조직 위에 놓고, 이것이 음의 correlation 대부분을 만든다 (`Ptger3`: CODA 0.85, STcompare 0.59) | 7c |
| 이름 있는 유전자가 대비를 보여준다 | 예: colitis의 `Ptger3` (CODA, STcompare, DESpace2 3위 안; stORCA 212위); cortex의 `Lgals1` (STcompare 1위; stORCA는 200위 밖) | 5f |

**Fix.** 없음.

**Defend.**

| 리뷰어가 할 수 있는 말 | 답 |
|---|---|
| 실제 case가 둘뿐이다 | 기술, 조직, 방향이 다르고 (조직을 잃는 MERFISH 대장, 조직이 생기는 Visium cortex), 둘 다 모든 목록 길이에서 같은 쪽을 가리킨다 (section 7b, 상위 k). 통제된 검사는 synthetic rearrangement 세트다 (outline 그림 4g, 재실행 예정) |
| correlation 방법이 왜 틀려야 하는가? | section 7c: 정렬은 사라진 구획을 어딘가에 놓아야 하므로, 그 marker는 자신이 낮은 다른 조직과 비교된다. correlation이 음수가 되고, 이것이 유전자를 이 목록들의 맨 위에 올린다. 흩어진 class는 겹칠 것을 남기지 않는다 |
| Colitis 한 조건의 slice가 한 마우스에서 왔다 | colitis에서는 순위와 plan만 쓰고 call은 쓰지 않는다 |
| Cortex는 2 대 2이고 call이 하나다 | 순위와 plan만 쓰고 call 수는 쓰지 않는다 |
| River도 기준 비율 근처다 | claim은 위치마다 짝이 하나라고 가정하거나 domain을 고정하는 registration과 domain 방법에 대한 것이다. River는 있는 그대로 보고한다 |
| Pseudobulk DE도 병변 marker를 높게 매긴다 (cortex 0.60) | Pseudobulk DE는 새 조직의 수준 변화까지 포함해 수준 변화를 찾는 방법이다; 공간 경쟁 방법이 아니라 참고로 보인다 |
| "unmatched"의 0.5 기준은 관례다 | 지도와 AUROC는 연속값 retained mass를 쓴다 (section 7a) |
| Marker는 marker 검정에 좌우된다 | stORCA의 plan을 쓰지 않는 표준 cluster 대 나머지 marker다 (section 5f); plan 기반 marker도 colitis에서 같은 그림이다 (section 5d) |
| 병변에만 있는 유전자 하나 (`Ms4a6c`)가 여전히 stORCA cortex 상위 20개에 있다 | 20개 중 1개이고 보고한다; 목록에 남은 다른 병변 marker는 매칭된 조직에서도 오른다 (section 5e) |
| DESpace2를 cortex에서 돌리지 않았다 | colitis와 HPOA에서 돌렸다; 추가하면 표에 칸이 하나 늘 뿐이다 |

**결정할 것.**

1. 양쪽 thinning을 pipeline에 넣을지. 권장: 넣는다 (outline 6절, 0단계).
2. synthetic rearrangement 시나리오 08~11을 v3와 양쪽 thinning으로 다시 돌려 region에 대한 통제된 검사로 쓸지. 권장: 그렇게 하고, synthetic 재실행 중 가장 먼저 한다. 예전 pipeline 결과는 claim을 뒷받침하지 않으므로 그림 4가 여기에 달려 있다.
3. section 7c의 분해 (CODA와 STcompare, 9개 pair 전체에서 완료)를 outline 그림 4f의 기전 panel로 그릴지. 권장: 그린다.

## 7. 슬라이드용 그림 (노트북 section 11, 2026-11-18)

슬라이드 메시지 두 개를 위한 그림. stORCA는 기준선 양쪽 thinning 판만 보인다. 결과 파일: `5-Case-Study-Comparison/res/Comparison/q1-slide-retained-summary.csv`.

### 7a. 대응점 없는 세포는 retained mass가 낮다

**Retained mass.** 세포 $n$개가 각각 질량 $1/n$을 갖는 section 쌍에서, dead-zone plan $\pi$는 질량 일부를 매칭하지 않을 수 있다. 세포 $i$의 retained mass는

$$
m_i = n\sum_j \pi_{ij}\in[0,1],
$$

plan이 남기는 그 세포 질량의 비율이다 (1 = 완전히 매칭, 0 = 짝 없음; `interpret.retained_fraction`). section의 between 쌍으로 평균하고 (treated section은 target 쪽, control section은 source 쪽), within 쌍을 기준으로 둔다. $m_i<0.5$이면 unmatched.

**대응점 없음, annotation만으로** (section 5f 규칙: 한 조건에서 세포의 1% 미만, 다른 조건에서 2% 이상): cortex 3 dpi r14 (병변); colitis 9일째 9일째에만 있는 cell type 15개 (호중구, 단핵구, 염증성 fibroblast와 평활근 등); colitis 0일째 상피 (Colonocytes, TA, Stem cells).

| 패널 | 대응점 없는 세포 | Retained mass: 대응점 없음, between | 나머지 세포, between | 모든 세포, within | 낮은 retained mass의 AUROC | unmatched 세포 중 "대응점 없음" 비율 |
|---|---|---|---|---|---|---|
| Cortex 3 dpi | r14, spot 1738개 중 227개 | 0.43 | 0.97 | 0.99 | 0.89 | 0.86 |
| Colitis 0일째 | 상피, 세포 71,607개 중 28,315개 | 0.19 | 0.81 | 0.99 | 0.94 | 0.81 |
| Colitis 9일째 | cell type 15개, 세포 88,969개 중 68,867개 | 0.51 | 0.72 | 0.94 | 0.66 | 0.86 |

![Retained mass vs specificity](fig/11-q1-unmatched-cells/q1-slide-retained-vs-specificity.png)

*cluster마다 점 하나 (크기 = 세포 수). x: 이 조건의 세포 비율 / 다른 조건의 비율의 log2 (오른쪽 = 여기에만 있음). y: between 쌍 평균 retained mass. 색: 대응점 없는 cluster; 점선: within 쌍의 모든 세포. 요점: 한 조건에만 있는 cluster가 retained mass가 낮은 cluster다. 출처: [11-q1-unmatched-cells.ipynb](11-q1-unmatched-cells.ipynb) section 11a.*

![Retained mass violins](fig/11-q1-unmatched-cells/q1-slide-retained-violin.png)

*세포 하나하나의 retained mass: 대응점 없음 (between 쌍), 나머지 세포 (between 쌍), 모든 세포 (within 쌍). 점선: 0.5 기준. 요점: within 쌍은 거의 모두 남기고, between 쌍은 대응점 없는 세포를 뺀다. 출처: 노트북 section 11b.*

![Cortex maps](fig/11-q1-unmatched-cells/q1-slide-maps-cortex-3-dpi.png)

![Colitis day 0 maps](fig/11-q1-unmatched-cells/q1-slide-maps-colitis-day-0.png)

*위: 대응점 없는 세포는 색 (cortex r14 빨강, colitis 상피 파랑), 나머지 회색. 아래: 같은 section의 retained mass. 요점: 어두운 영역이 대응점 없는 영역이다. 9일째: `fig/11-q1-unmatched-cells/q1-slide-maps-colitis-day-9.png`; legend: `q1-slide-maps-legend.png`. 출처: 노트북 section 11c.*

**읽기:** plan의 낮은 retained mass는 cortex (AUROC 0.89)와 colitis 0일째 (0.94)에서 대응점 없는 세포를 찾는다. Colitis 9일째는 약하다 (0.66): annotation으로는 9일째 세포의 77%가 9일째에만 있는 type이고, 그중 상당수는 0일째에 있던 세포의 염증 상태 (염증성 fibroblast와 평활근, retained mass 0.5~0.95)라 plan이 매칭한다. 슬라이드에는 cortex와 colitis 0일째를 쓴다; 0일째는 메시지 2의 조직이기도 하다.

### 7b. 상위 유전자: 대응점 없는 조직의 marker 비율

Marker는 section 5f와 같다 (cluster마다 대 나머지, 모든 marker).

| 방법 | Cortex r14, 상위 20개 중 marker (기준 0.11) | Colitis 사라진 상피, 상위 20개 중 marker (기준 0.28) |
|---|---|---|
| stORCA (양쪽 thinning) | **0.20** | **0.35** |
| CODA | 0.45 | 0.70 |
| STcompare | 0.70 | 0.60 |
| DESpace2 | 실행 안 함 | 0.70 |
| River | 0.10 | 0.30 |
| Pseudobulk DE | 0.60 | 0.40 |

![Marker share top 20](fig/11-q1-unmatched-cells/q1-slide-marker-share-top20.png)

*각 방법 상위 20개 중 대응점 없는 조직의 marker 비율. 빨강: stORCA (thinning). 점선: 검사한 전체 유전자 중 비율. 출처: 노트북 section 11d.*

![Marker share top k](fig/11-q1-unmatched-cells/q1-slide-marker-share-topk.png)

*같은 비율을 상위 k개 (k = 5~100)에 대해 (legend: `fig/11-q1-unmatched-cells/q1-slide-method-legend.png`; 굵은 빨강 = stORCA thinning, 파랑 = CODA, 초록 = STcompare, 보라 = DESpace2, 주황 = River, 회색 = pseudobulk DE). 요점: CODA, STcompare, DESpace2는 모든 목록 길이에서 stORCA보다 위다; colitis에서 River는 상위 60개 이후 0.4를 넘는다. 출처: 노트북 section 11e.*

예시 유전자와 지도: section 5f (`Ptger3`, `Cldn15`, `Flnc`, `Grem2`; cortex `Cd52`, `Hmox1`, `Sgk1`, `Ms4a6c`).

### 7c. CODA와 STcompare가 사라진 조직의 marker를 1위에 두는 이유 (2026-11-18, 9개 pair 전체)

**질문.** 다른 세포 사이에 흩어진 세포 class를 빼면 (HPOA semi-synthetic, section 5) CODA와 STcompare는 속지 않는데, colitis 상피가 사라지면 속는다 (section 7b). 무엇이 다른가?

**쉽게 말하면.** 두 점수 모두 정렬 뒤에 계산하는 correlation이다. 상피가 사라지면 정렬은 0일째 상피를 어딘가에 놓아야 하고, 상피 marker를 발현하지 않는 9일째 조직 위에 놓는다. 그러면 각 marker는 자신이 높던 바로 그 자리에서 낮은 값과 비교되어 correlation이 음수가 되고, 음의 correlation이 유전자를 이 목록들의 맨 위에 올린다. 흩어진 class를 빼면 다른 조직 위에 놓이는 영역이 없다; marker의 correlation은 구조 없는 유전자 수준인 0 쪽으로 떨어질 뿐이고 유전자는 목록 중간에 머문다.

**구현.**

- CODA (`31-q1-coda-mechanism.py`, env_CODA). 점수는
$$
\mathrm{CCI}=\frac{n}{S}\,\frac{\sum_{ij}W_{ij}(x_i-\bar x)(y_j-\bar y)}{\sqrt{\sum_i(x_i-\bar x)^2\sum_j(y_j-\bar y)^2}},\qquad W_{ij}=e^{-d_{ij}^2},
$$
이고, source 세포는 LDDMM 뒤의 위치, target 세포는 제자리에 두고 CODA의 78 pixel 화면 위에서 계산한다 (`0-ExternalTool/CODA/icoda-2.0.0/CODA/Cross_correlation.py`). 우리 실행은 모든 세포를 채점한다; CODA의 공통 영역은 계산되지만 쓰이지 않는다 (`templates/03-coda-template.py`, `common_regions_used_in_scoring: False`). 저장된 정렬 상태 (`5-Case-Study-Colitis-Q1/res/CODA/*-align.pkl`)에서 CCI를 다시 계산하고, 분자를 사라진 상피 (Colonocytes, TA, Stem cells로 표시된 source 세포)에서 온 몫과 나머지로 나눴다.
- STcompare (`32-q1-stcompare-mechanism.py`). 점수는 두 section 모두에 세포가 있는 pixel 위에서 pixel 평균 count의 Pearson correlation이다 (STalign 뒤 80 단위 raster; `templates/stcompare-template.R`). STalign 출력에서 다시 계산하고 (`correlation.csv`와 차이 4e-16), 사라진 상피 pixel (0일째 세포의 절반 이상이 상피)에서 온 몫과 나머지로 나눴다.

**결과** (between pair 9개).

| | CODA | STcompare |
|---|---|---|
| 사라진 상피가 여전히 9일째 조직과 비교되는가 | 사라진 세포의 0.79가 9일째 세포 위에 놓임 (0.61~0.91), 주로 염증성 섬유모세포, 염증성 상피, 호중구 | 상피 pixel의 0.74~0.99가 공유 pixel로 남음 |
| pair별 `Ptger3` 점수 | 9개 중 9개에서 음수 (CCI -0.002~-0.014) | 9개 중 9개에서 음수 (r -0.12~-0.21) |
| 합한 음의 점수 중 사라진 상피에서 온 몫, `Ptger3` | 0.85 | 0.59, 공유 pixel의 0.31~0.37에서 |
| 같은 값, `Lrp6` | 0.91 | 0.61 |
| 같은 값, `Cldn15` | 전부 (1.06) | 0.43 (r은 0 근처) |
| 사라진 상피 아래의 9일째 세포, `Ptger3` | 9일째 평균 기준 -0.02~-0.08 SD (pair s1-s1은 +0.02) | |

비교를 위해, OD Mature를 뺀 HPOA (pair `naive-a5` vs `aggr-a34`): 제거된 class의 source 세포 중 0.45가 aggression 세포 위에 놓이고 (원래 데이터 0.64), `Gjc3`의 CCI는 0.18에서 0.04로 떨어지지만 여전히 양수이며 구조 없는 유전자 수준 (중앙값 0.02)이다; 160개 중 122위다.

`Ptger3` 신호의 위치: 0일째에는 평균 이상 신호의 0.76이 상피에 있고, 9일째에는 0.45가 근육층에 있다. 근육층 발현은 두 시점에서 바뀌지 않는다 (cluster-only, section 5f).

**읽기:**

- **사라진 조직이 다른 조직 위에 겹쳐 놓이는 것이 오류를 만든다.** 두 방법 모두 음의 점수 대부분이 9일째 평균보다 낮은 9일째 세포와 비교되는 사라진 상피에서 온다 (CODA 0.85; STcompare는 pixel의 1/3에서 0.59). 나머지 section은 남은 (근육층) 발현이 정하는 9일째 평균을 통해 더 작은 몫을 더한다. 이 section의 첫 판은 pair s1-s1만 보고 나머지 조직이 더 크다고 했는데, 이는 그 pair에서만 맞는다.
- **흩어진 class는 겹칠 것을 남기지 않는다.** 빼도 변하지 않은 조직 안에 구멍이 생길 뿐이고, marker의 correlation은 양수로 남는다.
- **그래서 이 오류에는 region 형태로 잃거나 생긴 구획이 필요하다.** claim의 범위와 같다. stORCA는 사라진 상피를 unmatched로 남기고 근육층을 근육층과 비교하며, 거기서 `Ptger3`는 바뀌지 않는다 (212위).

**판정: 9개 pair 모두에서, 두 방법 모두에 대해 기전을 찾음.** outline 그림 4f에 충분하다.

결과 파일: `5-Case-Study-Comparison/res/Comparison/q1-mechanism-coda.csv` (pair와 유전자마다: `cci`, `cci_group`, `cci_rest`, `group_on_target`, `targets_under_group`), `q1-mechanism-stcompare.csv` (pair와 유전자마다: `r`, `r_epi`, `r_rest`, `epi_pixels_kept`).
