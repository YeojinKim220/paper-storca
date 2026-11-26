# Q3 DE 너머: pseudobulk DE도 DESpace2도 검출하지 못하는 stORCA call은 무엇인지, ARTISTA와 NRDR V1에서, 그리고 예시는 어떻게 보이는지

이 노트는 노트북 [13-q3-beyond-de.ipynb](13-q3-beyond-de.ipynb)를 section 순서대로 설명한다. 흐름은 하나다. (1) ARTISTA에서 stORCA call이 DESpace2, pseudobulk DE와 어떻게 겹치는지; (2) 둘 다 검출하지 못하는 ARTISTA call과, 그것이 예시가 되지 못하는 이유; (3) 피질 층을 domain으로 쓴 NRDR V1에서의 같은 겹침; (4) 지도에서 변화가 보이는 NRDR 유전자 두 개와 표본 매칭 하나; (5) 앞쪽 section을 더한 4 vs 4 시험과, 예시가 2 vs 2에서 층 DE가 아닌 이유; (6) 4 vs 4 call의 층 marker와 움직인 L2/3~L4 경계; (7) 무엇을 주장할 수 있는지.

이 흐름은 outline의 "DSE는 DE가 못 찾는 유전자를 찾는다" 행 ([0-paper-outline-natcomm.md](../0-Paper-Draft/0-paper-outline-natcomm.md) section 9)과 Figure 5f, Figure 6e panel을 뒷받침한다. 노트북은 2026-11-16에 다시 썼다:
- DE 유형 막대 그림을 stORCA, DESpace2, pseudobulk DE의 Venn diagram으로 바꿨다.
- ARTISTA 예시 유전자는 뺐다. 지도에서 두 그룹 차이가 눈에 보이지 않았다.
- "matched" panel은 매칭 평균 대신 표본 hard matching 하나를 보인다.
- STARmap PLUS AD section은 뺐다. claim을 뒷받침하지 않았다 (call 1개, 가짜 라벨에서 call이 더 많음, stORCA 출력 없이 계산한 profile).
- 층 domain을 쓴 NRDR V1이 새 예시 데이터다.

outline은 유형별 분할 (pattern call 대 amplitude call)도 요구한다. 노트북은 아직 이 분할을 하지 않는다. Defend 표를 보라.

모든 그림은 노트북 그림을 그대로 복사했다 (PDF는 `5-Case-Study-Comparison/fig/`, PNG 사본은 `5-Case-Study-Comparison/fig/13-q3-beyond-de/`). 링크가 아닌 경로는 프로젝트 루트 기준이다.

**데이터.**

- ARTISTA (axolotl 뇌 재생, Stereo-seq): 2 DPI 3 section 대 20 DPI 3 section. panel 유전자 3000개, stORCA v3가 782개 검정, 115 call. Domain: 손상 또는 비손상 반구 x 등쪽 또는 배쪽 (`compartment`), DESpace2가 쓰는 annotation.
- NRDR V1 posterior (마우스 시각 피질 MERFISH, Xie, Jain, Xu et al. 2025, PNAS): 정상 사육 (NR) 동물 a, b 대 암 사육 (DR) 동물 a, b, P28. 유전자 500개, 377개 검정, 32 call. Domain: 이 비교를 위해 만든 피질 층 (section 3).

**비교한 방법.**

1. stORCA call: 쌍 ROS에 대한 one-sided unweighted limma, BH $<0.05$, [12-q2-replicate-calibration.md](12-q2-replicate-calibration.md)와 같다.
2. Pseudobulk DE (`02-compare-methods.py`, 함수 `pseudobulk_de`): 합한 count의 $\log_2(\mathrm{CPM}+1)$에 limma, section마다 pseudobulk 하나 (전역) 또는 section x domain마다 하나 (세포 20개 이상). 전역 DE이거나 domain 하나 이상에서 DE이면 pseudobulk DE다, BH $<0.05$.
3. DESpace2: 고유 FDR $<0.05$. DESpace2는 조건이 domain마다 발현을 다르게 바꾸는지 검정한다 (pseudobulk count에서 조건 x domain 상호작용). 모든 domain에서 같은 변화는 검정 대상이 아니다.

세 방법 모두 stORCA가 검정한 유전자에서 비교하므로, 모든 방법을 같은 유전자로 판단한다.

## 0. Summary

| 단계 | 결과 |
|---|---|
| 1. ARTISTA 겹침 | stORCA call 115개 중 DESpace2는 25개를 call하고 90개를 놓친다. 90개 중 62개는 pseudobulk DE (대부분 균일한 변화로, DESpace2의 검정 대상 밖)이고 28개는 둘 다 검출하지 못한다. DESpace2는 stORCA가 call하지 않는 29개를 call한다 (7개는 ribosomal) |
| 2. ARTISTA 예시 | 28개는 희소하고, 지도에서 눈에 보이는 차이가 없다. ARTISTA는 개수를 뒷받침하지만 예시는 주지 못한다 |
| 3. NRDR 겹침 | stORCA 32 call; 층 domain DESpace2 0 call; 32개 중 13개는 전역 또는 층 pseudobulk DE; 19개는 둘 다 검출하지 못한다 |
| 4. NRDR 예시 | `Prkca`: NR의 높은 L2/3, L4 발현이 DR에서 L5 수준으로 떨어져 깊이 기울기가 평평해진다. `Trpc3`: NR의 L4 띠가 DR에서 흐려진다. 둘 다 각 그룹의 두 동물 모두에서 보이고, 표본 매칭 하나에서 residual이 L2/3~L4 띠에 놓인다. 두 유전자 모두 pseudobulk DE가 아니고 (최소 층 FDR 0.10, 0.11), DESpace2 FDR은 1.00이다. 둘 다 층 DE를 아깝게 놓친 경우다: L4에서 NR section 둘 다 DR section 둘보다 위에 있지만 (log2 fold change 약 -0.9, p 0.006, 0.008), 층 검정 2000개에 걸친 BH는 p < 0.0019를 요구한다 |
| 5. NRDR 4 vs 4 | 앞쪽 section과 same-animal 공변량을 넣으면: 82 call, 가짜 라벨 최대 17개 중 1, 뒤쪽 call 32개 중 23개 유지 (빠진 것은 동물 하나가 끈 약한 call). 4 vs 4 pseudobulk는 뒤쪽 예시 대부분 (19개 중 15)을 찾고 `Prkca`, `Trpc3`도 여기에 든다. 재현이지 새 주 결과는 아니다 |
| 6. L2/3~L4 경계 | 보정한 4 vs 4 call 중 21개는 DE가 아니고 대부분 층 marker다. DR에서 L2/3~L4 경계가 더 깊고 (정규화 L4 폭 0.26 대 0.32, L5는 그대로), L4 띠 안 뉴런의 14~16%가 L2/3 label을 가진다 (NR 5~7%, 겹침 없음). domain label이 흡수하는 층 구조 변화; 후보이고 아직 주장하지 않는다 |
| 7. 상태 | 충분. claim은 잰 그대로 쓴다: "같은 replicate 설계에서 pseudobulk DE와 DESpace2가 검출하지 못한다". 예시는 층 검정이 볼 수 없다는 것이 아니라 stORCA가 더 적은 replicate로 찾는다는 것을 보인다 |

## 1. ARTISTA: stORCA, DESpace2, pseudobulk DE의 겹침 (노트북 section 1)

**질문.** DESpace2는 어떤 stORCA call을 놓치고, 그것들은 단순히 DE 유전자인가?

**쉽게 말하면.** DESpace2는 "조건이 이 유전자를 한 domain에서 다른 domain보다 더 바꾸는가?"를 묻는다. Pseudobulk DE는 "이 유전자의 합이 section 전체나 한 domain에서 바뀌는가?"를 묻는다. stORCA는 "이 유전자의 공간 패턴이 replicate 사이 차이를 넘어 바뀌는가?"를 묻는다. 세 call 집합의 Venn diagram은 어떤 stORCA call이 새롭고 어떤 것이 더 단순한 검정으로 이미 찾아지는지 보여 준다.

**구현** (노트북 section 1, `res/Comparison/artista-gene-table.csv`, 열 `storca_call`, `despace2_fdr`, `de_global`, `de_domain`). 전체 집합: stORCA가 검정한 유전자 782개. DESpace2 call 59개 중 5개는 그 밖에 있어 그리지 않는다.

![ARTISTA Venn diagram](fig/13-q3-beyond-de/q3-artista-venn.png)

*빨강: stORCA call. 파랑: DESpace2 call. 회색: pseudobulk DE (전역 또는 domain). 테두리를 친 빨간 영역이 다른 두 검정이 검출하지 못하는 stORCA call이다. 요점: 28개는 둘 다에게 새롭다. 출처: [13-q3-beyond-de.ipynb](13-q3-beyond-de.ipynb) section 1.*

**결과.**

| 영역 | 유전자 |
|---|---|
| stORCA만 | 28 |
| stORCA와 pseudobulk DE, DESpace2 아님 | 62 |
| stORCA와 DESpace2, pseudobulk DE 아님 | 2 |
| 셋 모두 | 23 |
| DESpace2와 pseudobulk DE, stORCA 아님 | 24 |
| DESpace2만 | 5 |
| Pseudobulk DE만 | 165 |

**읽기.**

- **DESpace2는 stORCA call 115개 중 90개를 놓친다.** 대부분 (62개)은 pseudobulk DE다. DESpace2가 설계상 검정하지 않는 수준 변화이고, 여기서는 "DE 너머"로 세지 않는다.
- **28개는 둘 다 검출하지 못한다.** ARTISTA에서 claim이 기대는 개수다.
- **DESpace2는 stORCA가 call하지 않는 검정 유전자 29개를 call한다** (24 + 5), 그중 7개는 ribosomal이다. claim은 stORCA가 DESpace2를 포함한다는 것이 아니다. 둘은 다른 질문에 답한다.

**판정: 성립.** Venn diagram이 개수를 바로 주고, 두 검정 외에 "둘 다 아님"의 정의에 기대지 않는다.

## 2. ARTISTA: 둘 다 검출하지 못하는 call (노트북 section 2)

**질문.** 28개 중 하나를 예시로 쓸 수 있는가?

**구현.** 표는 28개 유전자의 stORCA $t$와 BH, within과 between 평균 ROS, 각 baseline의 FDR, 3000개 중 CODA, River, SpaceExpress의 between 순위를 보인다.

**결과.** 이전 노트북은 이 중 다섯 개 (`B2M`, `ARL4D`, `ANXA2`, `VIM`, `GFAP`)를 보였다. 다시 보고, 이 보고서를 위해 열 개를 더 그렸다 (`TLCD1`, `CTF1`, `ARRDC2` 두 개, `XBP1`, `RAPGEF6`, `PCDH7`, `PTGR1`, 이름 없는 locus 두 개). 모두 희소해서, 2 DPI와 20 DPI 지도에 독자가 볼 수 있는 차이가 없다. `B2M`과 `ANXA2`는 domain 평균도 눈에 띄게 달랐다.

**판정: ARTISTA는 개수를 뒷받침하고, 예시는 주지 못한다.** 예시는 변화가 보이는 NRDR V1에서 가져온다 (section 4).

## 3. NRDR V1 posterior: 층 domain과 같은 겹침 (노트북 section 3)

**질문.** domain이 뚜렷한 조직에서, 같은 설계의 domain 검정이 찾지 못하는 유전자를 stORCA가 call하는가?

**쉽게 말하면.** 시각 피질은 층으로 되어 있어서, 여기가 domain 방법에게 가장 유리한 경우다. 층별 검정이 놓치는 변화를 stORCA가 찾는다면, claim은 약한 domain annotation에 기대지 않는다.

**구현** (`5-Case-Study-Comparison/18-nrdr-layer-domains.py`).

1. 준비된 section에는 원 연구의 세포 class와 뉴런 subclass가 있고, 공간 domain은 없다. 각 세포에 가장 가까운 흥분성 뉴런 30개 중 가장 흔한 층을 붙인다. subclass는 L2/3; L4; L5 (L5 IT, PT, NP); L6 (L6 CT, IT, L6b)로 묶는다.
2. 이 층을 domain으로 한 pseudobulk DE (`res/Comparison/nrdr-pos-layer-de.csv`).
3. 층을 domain으로 네 section에 DESpace2, 2 vs 2 (`5-Case-Study-NRDR-V1/res/DESpace2/despace2-v1-rep1-nrdr-pos-layer-scores.csv`). 이 실행을 위해 DESpace2 template을 "정확히 3 vs 3"에서 "조건마다 같은 수, 2 이상"으로 완화했다. 3 vs 3 benchmark 실행은 바뀌지 않는다.

![NRDR 층 domain](fig/13-q3-beyond-de/q3-nrdr-layer-domains.png)

*section마다 panel 하나 (legend: `fig/13-q3-beyond-de/q3-nrdr-layer-legend.png`; 초록 L2/3, 주황 L4, 보라 L5, 분홍 L6). 요점: 모든 section에 네 층이 올바른 순서로 있으므로, 자른 각도는 달라도 같은 깊이의 피질을 담는다. 출처: [13-q3-beyond-de.ipynb](13-q3-beyond-de.ipynb) section 3.*

| 층 | nr-a | nr-b | dr-a | dr-b |
|---|---|---|---|---|
| L2/3 | 1640 | 3061 | 1546 | 2033 |
| L4 | 1530 | 1821 | 852 | 1009 |
| L5 | 937 | 1438 | 901 | 1192 |
| L6 | 2336 | 2448 | 2364 | 1987 |

![NRDR Venn diagram](fig/13-q3-beyond-de/q3-nrdr-venn.png)

*section 1과 같고, stORCA가 검정한 유전자 377개에서. DESpace2는 call이 없어 원이 비어 있다. 출처: [13-q3-beyond-de.ipynb](13-q3-beyond-de.ipynb) section 3.*

**결과.**

| 방법 | 검정 유전자 | Call (FDR 또는 BH $<0.05$) | stORCA 검정 377개 중 call | 최소 FDR 또는 BH | 명목 $p<0.05$ |
|---|---|---|---|---|---|
| stORCA (replicate limma, 단측) | 377 | 32 | 32 | 0.020 | 100 |
| DESpace2, 층 domain | 500 | 0 | 0 | 0.372 | 34 (우연 기대값 25) |
| Pseudobulk DE, 전역 | 500 | 17 | 16 | 0.0007 | 88 |
| Pseudobulk DE, 층 하나 이상 | 500 | 36 | 32 | 0.0001 | 계산 안 함 |
| Pseudobulk DE, 전역 또는 층 | 500 | 36 | 32 | | |

| stORCA call 32개 안의 겹침 | 유전자 |
|---|---|
| Pseudobulk DE이기도 함 (전역 또는 층) | 13 |
| Pseudobulk DE도 DESpace2도 아님 | 19 |
| DESpace2 명목 $p<0.05$ (call은 아님) | 6: `Egr4`, `Nr4a2`, `Ptchd4`, `Shisa6`, `Slc24a3`, `Stard8` |

**DESpace2 결과.** 실행은 정상 완료되었다 (`despace2-v1-rep1-nrdr-pos-layer-provenance.json`, status complete; DESpace 2.2.2, edgeR quasi-likelihood F 검정). 설계는 pseudobulk sample 16개 (조건 2 x 동물 2 x 층 4)와 계수 8개 (조건, 층, 조건 x 층)라서 잔차 자유도가 8이다. stORCA의 377개만이 아니라 panel 유전자 500개를 모두 검정했다. 최소 FDR은 0.372 (`Stac`, `Cacna1h`, `Rspo1`)이고, 명목 $p<0.05$인 유전자는 34개로 우연 기대값 25개와 비슷하다. 즉 2 vs 2에서 DESpace2는 우연을 넘는 층 특이 변화를 찾지 못한다. FDR을 377개로 한정해도 결론은 같다 (최소 $p$가 같다). 출처: `5-Case-Study-NRDR-V1/res/DESpace2/despace2-v1-rep1-nrdr-pos-layer-native-gene-scores.csv` (열 `PValue`, `FDR`).

전에 쓴 세포 class domain에서는 32개 중 22개가 DE가 아니었다. 층으로는 19개라서, 3개 (`Stard8`, `Scube1`, `Ptchd4`)는 층 DE로 드러난다. 이들의 L2/3 띠는 DR에서 사라지고, 층 검정이 그것을 본다.

**판정: 성립.** domain 검정이 가장 유리한 경우인데도 32개 중 19개를 놓친다.

## 4. NRDR V1 예시 (노트북 section 4)

**질문.** pseudobulk DE도 DESpace2도 검출하지 못하면서, 독자가 변화를 볼 수 있는 stORCA call이 있는가?

**선택.** section 3의 19개 중 14개의 지도를 이 보고서를 위해 그렸다. 변화가 가장 뚜렷한 `Prkca`와 `Trpc3`를 보인다. 예시마다 그림 세 개:

1. **지도.** 각 세포를 가장 가까운 30개 세포의 평균 log1p 발현으로 칠한다. 단일 세포 MERFISH count는 희소하고, 평활은 표시용일 뿐이며, 점수는 평활하지 않은 발현을 쓴다.
2. **층 profile.** 층별 평균 log1p 발현, section마다 선 하나.
3. **표본 매칭 하나** (between 쌍 nr-a 대 dr-a). 점수는 transport plan에서 뽑은 hard matching들을 평균한다. 각 매칭에서 남은 nr-a 세포는 dr-a 세포를 정확히 하나 받는다. panel은 nr-a 발현, 첫 번째 표본 매칭에서 각 nr-a 세포에 매칭된 dr-a 세포의 발현, 그 차이를 보인다. 회색 세포는 이 매칭에서 버려진 세포다 (3%).

이전 노트북은 "matched"로, 매칭된 target 발현을 모든 매칭에 대해 평균한 값을 그렸다. 이것은 plan 곱하기 $Y$에 가까워서 target을 평활하고, 매칭 하나의 모습이 아니다. `storca.interpret.residual_maps`의 새 출력 `y_sample`, `residual_sample`로 표본 매칭 하나로 바꿨다.

**`Prkca`** (stORCA BH 0.039; ROS within 0.07, between 0.27; 전역 $\log_2$ fold change -0.66, FDR 0.17; 최소 층 FDR 0.10; DESpace2 FDR 1.00).

![Prkca 지도](fig/13-q3-beyond-de/q3-nrdr-prkca-maps.png)

*nr-a, nr-b (NR), dr-a, dr-b (DR), 공통 색 척도. 요점: 두 NR section 모두 위쪽 층에 밝은 띠가 있고, 두 DR section은 평평하다. 출처: [13-q3-beyond-de.ipynb](13-q3-beyond-de.ipynb) section 4.*

![Prkca 층 profile](fig/13-q3-beyond-de/q3-nrdr-prkca-layer-profile.png)

*파랑: NR section. 주황: DR section. 요점: NR에서 L2/3과 L4는 0.57~0.73이고 L6로 갈수록 떨어진다; DR에서 L2/3과 L4는 0.38~0.53으로 떨어져 L5에 가깝다. L5와 L6은 거의 그대로다. 출처: [13-q3-beyond-de.ipynb](13-q3-beyond-de.ipynb) section 4.*

![Prkca 표본 매칭 하나](fig/13-q3-beyond-de/q3-nrdr-prkca-sampled-matching.png)

*왼쪽: nr-a 발현. 가운데: 표본 매칭 하나에서 각 nr-a 세포에 매칭된 dr-a 세포의 발현, nr-a 위치에 그림. 오른쪽: 차이; 빨강은 NR에서 높음. 요점: residual은 L2/3~L4 띠를 따라 양수이고 깊은 층에서는 0 근처다. 출처: [13-q3-beyond-de.ipynb](13-q3-beyond-de.ipynb) section 4.*

**`Trpc3`** (stORCA BH 0.038; ROS within 0.12, between 0.27; 전역 $\log_2$ fold change -0.49, FDR 0.40; 최소 층 FDR 0.11; DESpace2 FDR 1.00).

![Trpc3 지도](fig/13-q3-beyond-de/q3-nrdr-trpc3-maps.png)

*요점: 두 NR section의 좁은 가운데 띠 (L4)가 두 DR section 모두에서 흐려진다. 출처: [13-q3-beyond-de.ipynb](13-q3-beyond-de.ipynb) section 4. 층 profile과 표본 매칭은 `fig/13-q3-beyond-de/q3-nrdr-trpc3-layer-profile.png`와 `-sampled-matching.png`에 있다: L4는 0.37~0.46에서 0.24~0.26으로 떨어지고, L2/3과 L6은 움직이지 않는다.*

**어떤 종류의 변화인가?** 한두 층에 국한된 변화다. 층 평균은 움직이지만, 그룹당 동물 2마리로는 전역 검정도 층 검정도 FDR 0.05에 닿지 않는다 (아깝게 놓침; 이유는 section 5). DESpace2는 이 설계에서 아무것도 call하지 않는다. stORCA는 같은 네 section에서 두 유전자를 모두 call한다. 변화에 ROS가 재는 공간 형태가 있고, replicate끼리는 그 형태를 공유하지 않기 때문이다.

**판정: 성립.** 두 유전자 모두 각 그룹의 두 동물에서 독자가 볼 수 있는 변화를 보이고, domain 기반 검정은 같은 설계에서 이를 검출하지 못한다.

결과 파일: `res/Comparison/nrdr-pos-gene-table.csv`, `res/Comparison/nrdr-pos-layer-de.csv`, `5-Case-Study-NRDR-V1/data/layer/nrdr-pos-<label>-layer.h5ad`, 위의 DESpace2 파일; 그림 `fig/q3-nrdr-*.pdf`.

## 5. NRDR V1, 4 vs 4: 앞쪽과 뒤쪽 section을 함께 (노트북 section 5, 시험 실행)

**질문.** 앞쪽 section을 더하면 뒤쪽 결과가 유지되는가, 그리고 그때 pseudobulk가 같은 유전자를 찾는가?

**쉽게 말하면.** NRDR의 각 동물에는 앞쪽과 뒤쪽 V1 section이 하나씩 있다. 둘 다 쓰면 section은 두 배가 되지만 동물은 그대로다: 한 동물의 두 section은 그 동물 고유의 차이를 공유한다. 이 실행은 데이터를 늘렸을 때 2 vs 2 call이 재현되는지, 그리고 "DE 아님" 예시가 단지 검정력의 문제였는지를 확인한다.

**구현.**

1. 여덟 section 전체에 stORCA (`5-Case-Study-NRDR-V1/03-run-storca-both.py`): pair 28개 (between 16, within 12), pair 공변량 `cross_position` (두 section의 위치가 다름), 가짜 라벨은 위치로 층화 (17개).
2. 두 번째 pair 공변량 `same_animal`을 넣어 다시 fit (`5-Case-Study-NRDR-V1/04-refit-both-same-animal.py`, 저장된 pair score 사용, 새 매칭 없음). 이유는 아래.
3. 4 vs 4 pseudobulk (`27-q3-nrdr-4v4-pseudobulk.py`): 설계 condition + position, 전역과 층별. 한 동물의 두 section을 독립으로 다루므로 DE에 유리하다.

**결과.**

| 설계 | 검정 유전자 | Call | 가짜 라벨 최대 call | 유지된 2 vs 2 call | 4 vs 4에서도 pseudobulk DE가 아닌 call |
|---|---|---|---|---|---|
| 2 vs 2 뒤쪽 (주 결과) | 377 | 32 | 0 (2개 중) | 32개 중 32 | 4 |
| 4 vs 4, `cross_position` | 375 | 103 | 5 (17개 중) | 32개 중 27 | 30 |
| 4 vs 4, `cross_position` + `same_animal` | 296 | 82 | 1 (17개 중) | 32개 중 23 | 21 |

**same-animal 공변량이 필요한 이유.** within pair 12개 중 4개는 한 동물의 두 section을 묶는다. 위치가 다른 pair에서 이들의 ROS는 다른 동물끼리의 within pair보다 낮고 (유전자 중앙값 0.194 대 0.239; 유전자의 81%에서 낮음), 이런 pair는 between pair에는 없다. 그래서 within 평균을 낮추고 condition 효과를 부풀린다: 공변량을 넣으면 call이 103개에서 82개로 준다. 공변량을 넣으면 pair가 하나라도 빠진 유전자가 제외되어 296개가 남는다 (`Axin2`, `Dcbld2`가 여기서 빠진다).

**뒤쪽 유전자들.** `Prkca`, `Trpc3`, `Slc24a3`, `Nptx2`는 강해지고 (BH < 0.001), `Kcnk2`는 0.042에 머문다. 동물 하나가 끌던 약한 2 vs 2 call은 떨어진다 (`Nrxn1` 0.12, `Sorcs2` 0.15). 4 vs 4 pseudobulk는 124개를 call하고, 2 vs 2에서 DE가 아니던 뒤쪽 call 19개 중 15개가 DE 또는 층 DE가 된다. `Prkca`, `Trpc3`, `Slc24a3`도 여기에 든다 ([28-q3-nrdr-finer-than-layer.ipynb](28-q3-nrdr-finer-than-layer.ipynb) section 2).

**`Prkca`와 `Trpc3`가 2 vs 2에서 층 DE가 아닌 이유** ([28-q3-nrdr-finer-than-layer.ipynb](28-q3-nrdr-finer-than-layer.ipynb) section 4).

![Prkca depth and layers](fig/28-q3-nrdr-finer-than-layer/q3-nrdr-prkca-depth-layer-box.png)

*왼쪽: 피질 깊이를 따라 세포당 평균 log1p count (0.125 층 간격 bin), section마다 선 하나와 표준오차 띠; 파랑 NR a, b, 빨강 DR a, b. 가운데: 각 층에 속한 세포의 kNN-30 평활 발현 (마름모: 평균). 오른쪽: 층 검정이 보는 것, section과 층마다 pseudobulk log2 CPM 하나와 층 FDR. 요점: L2/3과 L4에서 NR section 둘 다 DR section 둘보다 위에 있다. 출처: [28-q3-nrdr-finer-than-layer.ipynb](28-q3-nrdr-finer-than-layer.ipynb) section 4.*

![Trpc3 depth and layers](fig/28-q3-nrdr-finer-than-layer/q3-nrdr-trpc3-depth-layer-box.png)

*같은 배치. 요점: NR의 봉우리는 L4와 L5 위쪽에 있고, L4에서 NR section 둘 다 DR section 둘보다 위에 있다. 출처: 위와 같다.*

| 유전자 | 층 | log2 fold change (DR 대 NR) | p | FDR |
|---|---|---|---|---|
| `Prkca` | L2/3 | -0.86 | 0.014 | 0.16 |
| `Prkca` | L4 | -0.92 | 0.006 | 0.10 |
| `Trpc3` | L4 | -0.93 | 0.008 | 0.11 |

층 검정은 L4에서 두 그룹을 가르지만, 그룹당 section이 둘이라 (잔차 자유도 2) BH가 2000개 검정 (유전자 500 x 층 4)에 걸쳐 돌므로 통과하려면 p < 0.0019가 필요하다. 전역 검정은 한두 층의 변화를 section 전체로 희석한다 (FDR 0.17, 0.40). 따라서 이 예시들은 층 요약이 볼 수 없는 변화가 아니라, 검정력이 모자라 층 DE를 아깝게 놓친 경우다. 깊이 bin이 더하는 정보는 크지 않다: bin 해상도에서 가장 큰 변화는 그 층 변화의 1.16~1.33배다 (유전자 30개 중앙값 1.15).

**판정: 재현으로는 성립, 예시의 해석은 바뀐다.** 4 vs 4 실행은 뒤쪽 call을 재현하고 (32개 중 23, 빠진 것은 동물 하나가 끈 약한 call) 가짜 라벨 call을 0 가까이로 유지한다. 동시에 section을 더 넣으면 층 pseudobulk도 뒤쪽 예시를 찾는다는 것을 보인다. 4 vs 4는 동물이 아니라 section을 더하므로, 2 vs 2 뒤쪽 실행이 주 결과로 남는다.

결과 파일: `5-Case-Study-NRDR-V1/res/stORCA/storca-v3-rep1-nrdr-both-limma-{genes,splits}{,-animal}.csv`, `res/Comparison/q3-nrdr-4v4-pseudobulk.csv`.

## 6. 4 vs 4 call의 층 marker: L2/3~L4 경계가 움직인다 (노트북 section 6)

**질문.** 보정한 4 vs 4 call 중 21개는 4 vs 4에서도 pseudobulk DE가 아니고, 대부분이 층 marker다 (`Cux1`, `Scnn1a`, `Otof`, `Whrn`, `Tle4`, `Pou3f2`, `Syt2`, `Nefm`, `Kirrel3`, `Cntn5`). 모든 DR section에서 L4 뉴런 비율도 작다. L4가 얇아진 것인가, L4 뉴런이 L2/3로 label된 것인가, 아니면 절단 각도 때문인가?

**쉽게 말하면.** 층 경계 자체가 움직이면, 층 marker의 총량은 그대로인데 그 띠가 옮겨 가거나 좁아질 수 있다. 층 domain 검정은 층 label을 주어진 것으로 받으므로 바로 이 변화를 흡수한다.

**구현** (`29-q3-nrdr-l4-thickness.py`). section마다 깊이 축은 흥분성 뉴런의 층 index가 커지는 방향이다 (L2/3 = 1 ~ L6 = 4). 접선 축을 250 um 띠로 자르고, 각 띠에서 층 경계는 그 위아래 뉴런을 가장 잘 가르는 깊이, pia 가장자리는 전체 세포의 1번째 백분위수다. 폭은 pia 가장자리에서 L5 바닥까지의 거리로 나누므로, 모든 층을 같이 늘리는 비스듬한 절단은 상쇄된다. L4 띠 안에서 각 label을 가진 흥분성 뉴런의 비율을 센다. section마다 띠의 중앙값.

| Section | L4 뉴런 비율 | L2/3 폭 | L4 폭 | L5 폭 | L4 띠: L4 label | L4 띠: L2/3 label |
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

*정규화한 깊이 (0 = pia 가장자리, 1 = L5 바닥)를 따른 층 label별 뉴런 수, section마다 panel 하나; 보라 L2/3, 파랑 L4, 초록 L5, 노랑 L6; 점선: L4 띠 (띠 중앙값). 요점: DR에서 L2/3 분포가 L4 띠 깊숙이 들어오고, L4 봉우리가 낮다. 출처: [13-q3-beyond-de.ipynb](13-q3-beyond-de.ipynb) section 6.*

**결과.**

1. 절단 때문이 아니다: L5 폭은 그대로이고 (0.24 대 0.26), L4는 좁아지며 (0.26 대 0.32) 그만큼 L2/3가 넓어진다 (0.50 대 0.44). L2/3~L4 경계만 움직인다.
2. 가장 깨끗한 신호는 섞임이다: L4 띠 안에서 L2/3 label을 가진 흥분성 뉴런이 DR section 넷 모두에서 14~16%, NR section 넷 모두에서 5~7%다. 두 범위는 겹치지 않는다.
3. L4가 얇아진 것인지 identity가 바뀐 것인지는 가릴 수 없다. 경계를 같은 전사체 label로 정했기 때문이다. 섞임 양상 (L4 깊이에 있는 L2/3형 뉴런)은 identity 변화에 더 잘 맞는다. 어느 쪽이든 condition이 만든 층 구조 변화이고, marker의 총 발현은 그대로다.

**판정: 후보, 아직 claim에 넣지 않는다.** domain label이 변화와 함께 움직이므로 domain 검정이 볼 수 없는 종류의 변화다. 그러나 그룹당 동물 2마리와 4 vs 4 실행에 기대고, 뒤쪽 2 vs 2 call에는 이 marker들이 없다. section 7의 결정이 필요하다.

결과 파일: `res/Comparison/q3-nrdr-l4-thickness.csv`, `res/Comparison/q3-nrdr-l4-thickness-strips.csv`; 그림 `fig/q3-nrdr-l4-thickness.pdf` (범례 `fig/q3-nrdr-l4-thickness-legend.pdf`).

## 7. Q3의 현재 위치

| 주장 | 뒷받침되는가? | 근거 |
|---|---|---|
| stORCA는 DESpace2가 놓치는 유전자를 call한다 | 예: ARTISTA 115개 중 90, NRDR 32개 중 32 | 1, 3 |
| 그중 일부는 pseudobulk DE도 아니다 | 예: 115개 중 28 (ARTISTA), 32개 중 19 (NRDR, 층 domain) | 1, 3 |
| 이름을 댈 수 있는 유전자가 지도에서 그런 변화를 보인다 | 예: `Prkca`, `Trpc3` (NRDR) | 4 |
| section을 더하면 call이 재현된다 | 예: same-animal 공변량을 넣은 4 vs 4에서 32개 중 23개 유지; 빠진 것은 동물 하나가 끈 약한 call | 5 |
| 예시는 층 검정에 보이지 않는다 | 아니다. 2 vs 2에서 층 DE를 아깝게 놓치고 4 vs 4에서는 층 DE가 된다. 주장은 표본 크기이지 사각지대가 아니다 | 5 |
| stORCA는 domain label이 흡수하는 변화를 찾는다 | 후보: DR에서 L2/3~L4 경계가 움직인다 (층 marker, 4 vs 4). 아직 주장하지 않는다 | 6 |
| 변화의 domain 평균이 같다 | 주장하지 않는다. 예시는 이 설계에서 domain 검정이 닿지 못하는 층 국한 변화다 | 4 |
| outline이 요구하는 유형별 분할 (pattern 대 amplitude) | 아직 증거 없음 | |

**상태: 충분.** 다시 쓴 노트북은 제기된 네 가지에 답한다: Venn diagram이 막대 그림을 대신하고, 예시는 지도에서 보이며, matched panel은 표본 매칭 하나를 보이고, claim을 뒷받침하지 않던 section (AD)은 빠졌다. 쓴 그대로의 claim과 상충하는 항목은 없다. 문제는 `CLAUDE.md`의 규칙 ("Level of Rigor: Fix or Defend")에 따라 나눈다.

**Fix.** 없음.

**Defend.**

| 리뷰어가 할 수 있는 말 | 답 |
|---|---|
| "검출 안 됨"은 "차이 없음"이 아니다; `Prkca`는 L2/3과 L4에서 약 3분의 1 떨어진다 | claim은 "같은 replicate 설계에서 pseudobulk DE와 DESpace2가 검출하지 못한다"이고, 예시는 층 국한 변화로 설명한다. 모든 방법이 같은 네 section을 보므로 비교는 공정하다 |
| 예시는 검정력 문제일 뿐이다: 4 vs 4에서는 pseudobulk가 찾는다 | 맞고, 그것이 주장이다: stORCA는 그룹당 동물 2마리로 call하고, 층 검정은 section이 두 배 필요하다 (section 5). DESpace2는 section 여덟 개에서도 놓친다 |
| 4 vs 4 실행은 한 동물의 두 section을 replicate로 다룬다 | 재현으로만 보고한다. same-animal 공변량이 부풀림을 없애고 (103에서 82 call), 주 결과는 2 vs 2 뒤쪽 실행으로 남는다 |
| NRDR는 그룹당 동물 2마리라 모든 검정이 약하다 | 비교는 바로 그 조건에서 한다. 이 설계에서 stORCA의 보정은 Q2에 기댄다 (가짜 라벨에서 0 call, 주 null은 LIBD와 HPOA) |
| 층 domain은 우리가 만들었다 | 원 연구의 subclass label에서 이웃 30개의 다수결로 만들었다. 모든 section이 네 층을 올바른 순서로 보인다. DESpace2는 domain 없이 돌 수 없고, 피질 층은 DESpace2에게 가장 유리한 경우다 |
| DESpace2가 아무것도 call하지 않으니 2 vs 2에서 공정한 경쟁자가 아니다 | 같은 데이터에 고유 설정으로 돌렸다. 작은 설계에서 domain 검정은 pseudobulk 관측치가 적다; 그것은 접근법의 성질이다 |
| ARTISTA에서 DESpace2는 stORCA가 call하지 않는 29개를 call한다 | claim은 stORCA가 DESpace2를 포함한다는 것이 아니다. DESpace2는 수준의 조건 x domain 상호작용을 검정한다; 29개 중 7개는 ribosomal이다 |
| 둘 다 검출하지 못하는 ARTISTA call은 눈에 보이는 예시가 없다 | 그 개수는 보정된 replicate 검정 (Q2)에 기댄다. 눈에 보이는 예시는 NRDR에서 가져온다 |
| DR에서 L4 domain의 세포가 적다 (852, 1009 대 1530, 1821), 그래서 `Trpc3`는 구성 변화일 수 있다 | DSE에서는 구성 변화와 세포당 변화 모두 공간 변화다. 본문은 "세포당 낮아짐"이 아니라 "L4 띠가 흐려짐"이라고 쓴다. section 6은 세포가 어디로 갔는지 보인다: DR에서 L2/3~L4 경계가 더 깊고, 절단 각도 때문이 아니다 |
| 지도가 평활되었다 | 표시용일 뿐이다; 점수는 평활하지 않은 발현을 쓴다. 층 profile은 세포별 원래 값을 쓴다 |
| 많은 매칭 중 표본 하나만 보인다 | 점수가 평균하는 매칭 중 하나의 예시다; call은 이 panel이 아니라 평균과 replicate 검정에서 나온다 |
| call이 pattern과 amplitude 유형으로 나뉘지 않았다 | 분할은 Q5 분해 표와의 join이고 Figure 5f를 그릴 때 한다. 개수는 그것에 기대지 않는다 |
| 겉모양: 예전 ARTISTA와 AD 그림 파일이 `fig/`에 남아 있다 | 한 줄; 그림 폴더를 정리할 때 지운다 |

**결정할 것.**

1. NRDR 예시를 본문에서 원 연구와 연결할지. 2026-11-17에 확인했다 (`0-Data/Mouse-NRDR-2024/pnas.202421022.pdf`): 원 연구는 암 사육 V1에서 L2/3 type-identity 유전자가 sublayer 순서를 유지하고, L2/3A 특이 유전자는 비교적 그대로이며, L2/3B와 L2/3C 특이 유전자는 내려간다고 보고한다 (그 Fig. 3G). 암 사육 section에서 `Prkca`와 `Trpc3`의 위층 띠가 사라지는 것은 같은 방향이다. 두 유전자가 B 또는 C형 유전자인지는 원 연구의 Dataset S1이 필요한데 디스크에 없다. 권장: Dataset S1로 두 유전자를 확인한 뒤 "보고된 L2/3B, C 유전자의 감소와 맞다"는 문장 하나. 그 전에는 생물학적 문장을 쓰지 않는다.
2. Q5 ([15-q5-interpretation.ipynb](15-q5-interpretation.ipynb))도 같은 평균 "matched" panel을 그린다. 권장: 같은 방식으로 `y_sample`로 바꾼다, 한 줄 변경이다.
3. 움직인 L2/3~L4 경계 (section 6)를 "domain label이 흡수하는 변화"의 예로 쓸지. 지금까지 이런 종류로는 가장 강한 예지만, 4 vs 4 실행에서 나왔고 그룹당 동물 2마리에 기대며, 생물학 (L4가 얇아짐 또는 identity 변화)은 열려 있다. 권장: 보충 관찰로 두고, 원 연구 (Dataset S1 또는 L4 결과)와 대조하기 전에는 Q3 claim을 이것 위에 세우지 않는다.
