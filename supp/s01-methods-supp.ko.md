# 보충 방법 (Figure 2 to 5)

이 문서는 Figure 2 to 5 뒤의 모든 설정을 프로젝트 원고 문체(`.claude/skills/manuscript-style/SKILL.md`)로 모읍니다. S2 섹션(Figure 2)은 완성되었고, Figure 3 to 5 섹션은 추가될 예정입니다. `0-method-v3-supplementary.md`의 보충 섹션을 대체합니다. 알고리즘은 본문 Methods([English](0-method-v4.md) · [한국어](0-method-v4.ko.md))에, Figure 2 결과 문단과 legend는 현재 초안([English](0-results-fig2-v4.md) · [한국어](0-results-fig2-v4.ko.md))에 있습니다.

## S2. 통제된 benchmark (Figure 2)

### S2.1. 두 benchmark와 각각이 검정하는 것

Figure 2는 각 방법이 어떤 종류의 공간 변화를 검출할 수 있는지를 묻습니다. 바뀐 유전자를 알고 있는 benchmark 두 개를 사용했습니다. simulated benchmark(Figure 2a to c)는 알려진 기하 구조 위에서 공간 패턴의 한 가지 특성만 바꾸므로, 방법의 실패를 변화의 종류로 추적할 수 있습니다. cortex benchmark(Figure 2d,e)는 세 donor의 측정된 Visium section에 변화를 넣으므로, section과 donor 사이의 실제 변동을 배경으로 변화를 찾아야 하고, stORCA는 replicate design을 쓸 수 있습니다. 두 benchmark 모두 global shift decoy, 즉 모든 세포에서 같은 평균 발현 변화를 가진 유전자를 포함해, 방법이 공간 변화와 수준 변화를 구분하는지 검정합니다.

### S2.2. Simulated tissue

**기하 구조.** 다섯 시나리오는 열 15개 너비의 세로 domain A to D 네 개로 나눈 $60\times60$ 격자를 사용했습니다. 고리 시나리오는 $68\times68$ 격자 중심에서 반지름 34 안의 site를 남기고, 반지름 8.5, 17, 25.5에서 동심원 domain 네 개로 나눴습니다. domain A, B, C, D는 cell type (0, 1), (1, 2), (2, 3), (3, 0)을 같은 비율로 섞었고, cell type은 section마다 독립적으로 뽑았습니다.

**유전자.** 각 시나리오는 네 class의 유전자 120개를 가졌고, 모두 두 조건에서 공간 패턴을 가집니다. 그래서 방법이 패턴의 유무만으로 바뀐 유전자를 가려낼 수 없습니다.

| Class | 수 | 기본 패턴 | 조건 2 |
|---|---|---|---|
| Domain marker (불변) | 80 | domain 하나씩, domain당 20개 | 불변 |
| Cell type marker (불변) | 20 | cell type 하나씩, type당 5개 | 불변 |
| Decoy | 10 | domain 하나씩 | 모든 세포에서 log mean $+s$ |
| Focal 유전자 | 10 | 바뀌는 영역이 아닌 domain 하나(B, C, D; 고리는 첫째, 셋째, 넷째 고리; amplitude 변화는 네 domain 모두) | 설계된 변화 하나(아래 표) |

**발현 모형.** 세포 $i$와 유전자 $g$의 count는 평균 $\mu_{ig}$, 분산 $\mu_{ig}+\mu_{ig}^2/\theta_g$인 negative binomial이며

$$
\log\mu_{ig}=\beta_g+\alpha_g S_{ig}+\epsilon_{ig}+d_{ig},
$$

$S_{ig}$는 section 안에서 centering한 유전자의 domain 또는 cell type 지시자, $\beta_g\sim N(1.5,0.25^2)$, $\theta_g=|N(3,0.5^2)|$, $\epsilon_{ig}\sim N(0,0.3^2)$는 section마다 따로 뽑은 세포 수준 noise, $d_{ig}$는 설계된 변화입니다. 패턴 amplitude $\alpha_g$는 domain marker(값당 8개), decoy, focal 유전자에서 1.0부터 2.4까지 고르게 놓인 10개 값을, cell type marker에서는 1.2부터 2.2까지 5개 값을 가졌습니다. decoy와 focal 유전자에 배경과 같은 amplitude를 주면, 방법이 기본 패턴의 세기로 바뀐 유전자를 찾을 수 없습니다.

**설계된 변화.** 효과 강도 $s\in\{0,0.5,1,1.5,2\}$에서 focal 유전자는 다음 변화 $d_{ig}$를 받았습니다(열 번호는 0부터).

| 시나리오(패널 label) | Focal 유전자 log mean의 변화 |
|---|---|
| Domain DE | 조건 2, domain A에서 $+s$ |
| Domain 안 cell type DE | 조건 2, domain A의 cell type 0에서 $+s$ |
| Domain 내부 shift | 조건 1에서 domain A의 열 0 to 6에, 조건 2에서 열 8 to 14에 $+s$ |
| 경계 띠 | 조건 2, 열 14와 15(A와 B 경계)에서 $+s$ |
| Amplitude 증가 | 조건 2에서 $+s\,S_{ig}$, 기존 패턴의 강화 |
| 고리 domain | 조건 2, 두 번째 동심원 domain에서 $+s$ |

domain 내부 shift는 domain 평균을 거의 바꾸지 않은 채 발현을 domain A의 한쪽에서 다른 쪽으로 옮기고, 경계 띠는 60개 열 중 2개만 바꿉니다. 그래서 이 두 시나리오는 domain 평균 검정이 볼 수 없는 변화를 검정합니다. $s=0$에서는 어떤 유전자도 바뀌지 않으며, 지정된 focal 유전자는 변화가 없을 때 어떤 방법도 그것들을 맨 위에 두지 않는지 확인하는 용도로만 남겨 두었습니다.

**Replicate과 seed.** 시나리오와 강도마다 조건당 section 세 장을 생성했습니다. 유전자 파라미터는 강도, 조건, replicate에 걸쳐 공유했습니다(기본 seed 20261124, 시나리오별 offset). cell type 배정, 세포 수준 noise, count sampling은 시나리오, replicate, 조건마다 각자의 seed를 가졌고, 이 seed를 강도에 걸쳐 재사용해 강도 계열이 $s$에서만 다르도록 했습니다. 생성기: [01-make-v3.py](../3-BM-DSE-Scenario-v3/01-data-generation/01-make-v3.py).

### S2.3. Simulated tissue에서 방법 실행

비교 방법 여섯 개 중 네 개(CODA, STcompare, River, paired mode의 SpaceExpress)는 section 하나를 section 하나와 비교합니다. 그래서 조건 1의 replicate $r$을 조건 2의 replicate $r$과 짝지어 세 쌍에서 각 single-pair 방법을 돌리고 지표를 평균했습니다. 비교가 점수만을 분리하도록 stORCA도 같은 single-pair 방식으로 돌렸습니다.

| 방법 | 입력 | 설정 | 사용한 점수(클수록 변화 큼) |
|---|---|---|---|
| stORCA | section 쌍 하나 | SysVI 400 epoch, batch 128, seed 42; $\delta=0$인 partial transport; matching 50개(seed 42); Moran과 분모 filter 없이 유전자 120개 전부 점수 | clip된 ROS; 합산 분모가 $10^{-12}$ 이하이면 0 |
| CODA | section 쌍 하나 | 발표된 template, seed $41+r$ | 음의 spatial cross-correlation index(CCI) |
| STcompare | section 쌍 하나 | 좌표에 STalign($dx=1$, blur 1.5, 10,000 반복, seed 42; 같은 기하에는 변환 재사용); 해상도 2의 정사각 raster | 음의 spatial correlation; 별도로 음의 percent similarity |
| River | section 쌍 하나 | 100 epoch, seed $41+r$ | 최종 순위 목록에서의 음의 위치 |
| SpaceExpress | section 쌍 하나 | paired 모형, embedding 4차원, 100 epoch, spline 자유도 300, seed $41+r$; outlier filter 후 zero-variance 검사에서 표시된 유전자 제거 | 음의 FDR |
| DESpace2 | 조건당 section 세 장 전부 | simulated domain label을 domain key로, seed 42 | Quasi-likelihood $F$ 통계량 |

DESpace2는 domain label이 필요하고 replicate section을 쓰므로, 정답 domain과 section 여섯 장 전부를 받았으며 시나리오와 강도마다 순위 하나를 냅니다. stORCA의 균일 marginal transport plan은 민감도 확인으로 계산했고 Figure 2에는 보이지 않습니다(강도 1에서 partial plan과 AUROC 차이 0.03 이내). 실행기: [03-run-methods.py](../3-BM-DSE-Scenario-v3/03-run-methods.py); stORCA: [02-run-storca-1v1.py](../3-BM-DSE-Scenario-v3/02-run-storca-1v1.py).

### S2.4. Simulated tissue 지표

**검출(Figure 2b 왼쪽, 2c).** 양성은 focal 유전자 10개, 음성은 변하지 않은 유전자 100개(domain과 cell type marker)이며 decoy는 제외했습니다. 동점에 절반 점수를 주는 AUROC와, 서로 다른 threshold에 걸친 average precision $\mathrm{AP}=\sum_j(R_j-R_{j-1})P_j$를 계산했고 AP를 AUPRC로 보고했습니다(양성 비율 $10/110$).

**Global shift 특이도(Figure 2b 오른쪽).** focal 유전자 10개 대 decoy 10개의 AUROC를 계산했고, 유전자 120개 전체 중 상위 15개 안의 decoy와 focal 유전자 수를 셌습니다.

각 지표는 section 쌍마다 계산한 뒤 세 쌍에 걸쳐 평균했고, DESpace2는 하나의 값을 냅니다. heatmap은 $s=1$, 곡선은 다섯 강도 전부를 사용합니다. 수집기: [06-collect-v3.py](../3-BM-DSE-Scenario-v3/06-collect-v3.py); 값: [v3-summary-by-strength.csv](../3-BM-DSE-Scenario-v3/res/v3-summary-by-strength.csv); 패널: [02b-fig2-v3-synthetic-panels.py](02b-fig2-v3-synthetic-panels.py).

### S2.5. 인간 cortex에 이식한 변화

**Section과 설계.** donor 세 명에게서 두 장씩 얻은 LIBD DLPFC Visium section 여섯 장을 사용했습니다. donor 순서를 맞춰 151507, 151669, 151673을 control, 151509, 151671, 151675를 treated로 두었습니다. 측정된 좌표, 수동 layer label, 공통 3,000-유전자 panel을 유지했고, treated section 세 장에서만 count를 바꿨습니다. 그래서 각 donor가 control과 treated section을 하나씩 내고, 조건 사이 비교에는 한 donor의 section 사이와 donor 사이의 실제 변동이 포함됩니다.

**유전자.** 바뀌지 않은 section에서 stORCA Moran filter를 통과하고 평균 count가 0.2 이상인 유전자 중에서, 변화마다 유전자 10개와 decoy 20개를 뽑았습니다(seed 20261118). treated section 세 장에 걸쳐 평균한, 유전자의 가장 큰 layer 평균 대 section 평균 비율을 사용했습니다. 비율이 2 이상인 유전자(강한 층 패턴)는 작용할 층 패턴이 필요한 amplitude와 relocation 변화를 받았고, 1.5 미만인 유전자는 기존 layer 3 패턴에 변화가 가려지지 않도록 layer 3 증가, 절반 layer 증가, 재분배를 받았습니다. decoy는 두 계층(비율 2 이상, 1.5 미만)에서 10개씩입니다. 세 수준 모두 같은 유전자를 사용했습니다. 정답 표: [implant-truth-v2.csv](../1-BM-DSE-Semi-LIBD/res/implant-truth-v2.csv).

**변화.** 각 treated section에서 $m_l$을 layer $l$의 유전자 평균, $\bar m$을 모든 spot의 평균, A와 B를 layer 3의 두 절반이라 합니다. 수준 1, 2, 3은 $(s,a,t)=(0.5,0.25,1/3)$, $(1,0.5,2/3)$, $(1.5,0.75,1)$을 사용했습니다.

| 변화(패널 label) | Treated section의 목표 평균 |
|---|---|
| Layer 3 증가(Domain DE) | $m_3\,e^{s}$ |
| 절반 layer 증가(Within shift) | layer 3 절반 A의 평균에 $e^{s}$를 곱함 |
| 약해진 층 패턴(Amplitude) | 각 layer: $\bar m+(1-a)(m_l-\bar m)$ |
| 이동(Relocation) | 모든 donor에 있는 layer(3, 4, 5, 6, white matter)에서 layer $i$가 $(1-t)\,m_i+t\,m_{(i+2)\bmod 5}$를 받음 |
| Layer 3 안 재분배(Pure shift) | $m'_B=(1-t)\,m_B$, $m'_A=m_A+t\,m_B\,n_B/n_A$; layer 총량의 기댓값 유지 |
| Global shift(decoy) | 모든 layer: $m_l\,e^{s}$ |

절반 layer 증가는 layer 3 평균도 올리지만, 재분배는 그것을 유지합니다. 따라서 재분배가 layer 평균 검정이 볼 수 없는 변화입니다.

**모든 donor에서 같은 해부 위치.** layer 3의 두 절반은 layer 3 spot 좌표의 첫 번째 주축을 중앙값에서 나눠 정의했습니다. 세 donor 모두에서 절반 A가 같은 해부학적 절반이 되도록, white matter 중심에서 layer 3 중심으로 가는 벡터를 90도 회전하고 주축이 이 접선 방향을 향하도록 맞췄습니다. relocation은 모든 donor에 있는 다섯 layer에 대한 하나의 순환 순열을 사용해, 모든 donor에서 각 layer가 같은 출처 layer의 발현을 받도록 했습니다. 이전 버전(imp3v2)은 한 donor에서 절반 A가 뒤집혔고 donor마다 다른 layer 집합을 순열했습니다. Figure 2는 수정된 버전(imp3v3)을 사용합니다.

**Count 조작.** 그룹 평균을 $m$에서 $m'$로 올릴 때는 각 spot에 평균 $m'-m$인 독립 Poisson count를 더했고, 내릴 때는 각 count를 확률 $m'/m$로 binomial thinning했습니다. 바뀐 그룹 밖의 spot과 모든 control section은 건드리지 않았습니다. 난수 생성기 seed는 (20261121, section, 수준)이었습니다. 생성기: [06-make-implant-v3.py](../1-BM-DSE-Semi-LIBD/06-make-implant-v3.py); 목표와 실제 평균: [implant-targets-v3.csv](../1-BM-DSE-Semi-LIBD/res/implant-targets-v3.csv).

### S2.6. Cortex implant에서 방법 실행

**stORCA.** stORCA는 본문 Methods의 replicate design을 조건 사이 쌍 9개와 조건 안 쌍 6개에 적용했습니다(SysVI 400 epoch, batch 128; ROS를 $[0,2]$로 clip; Moran과 분모 filter; source 세포 availability에 의한 조건 안 thinning; 분산 trend를 둔 limma; one-sided 검정). 유전자는 조건 사이 효과의 moderated $t$ 통계량으로 순위 매겼고, one-sided BH 보정 $P<0.05$에서 call했습니다. 실제 그룹과 다른 section 전체 재배정 9가지에 대해서도 대비를 다시 맞췄습니다.

**비교 방법.** 각 방법은 발표된 기본 설정으로 돌렸습니다. CODA(seed 42), River(100 epoch, seed 42), SpaceExpress(embedding 4차원, 100 epoch, spline 자유도 300, seed 42), STcompare(해상도 310의 정사각 raster, seed 42)는 조건 사이 쌍 9개 각각에서 돌렸고, 방향을 맞춘 점수를 쌍에 걸쳐 평균했습니다. implant는 count만 바꾸고 좌표는 바꾸지 않으므로, STcompare는 쌍마다 좌표만 쓰는 STalign 변환 하나를 수준에 걸쳐 재사용했습니다. DESpace2(seed 42)는 수준마다 section 여섯 장 전부에서 수동 layer label을 domain key로 한 번 돌렸습니다. 이 label은 이식 영역을 정의한 바로 그 label이므로, DESpace2는 다섯 변화 중 네 개의 정확한 domain을 받습니다. 실행기: [07-run-imp3v3.py](../1-BM-DSE-Semi-LIBD/07-run-imp3v3.py).

### S2.7. Cortex implant 지표

모든 방법을 같은 유전자, 즉 각 수준에서 stORCA가 검정한 유전자(수준 1, 2, 3에서 664, 642, 588개)에서 평가했습니다. Moran filter는 조건 label을 쓰지 않으며, 평가 집합은 수준 1과 2에서 이식 유전자 50개 전부, 수준 3에서 49개를 포함했고, 모든 수준에서 decoy 20개 전부를 포함했습니다. 방법은 그 수준에서 50개 이상의 유전자에 유한한 점수가 있을 때 보고했습니다. SpaceExpress의 zero-variance 검사에서 표시된 fit과, 구현이 그런 fit의 sentinel로 반환하는 정확히 0인 FDR 값은 결측으로 두었습니다.

| 지표 | 양성 | 음성 | 패널 |
|---|---|---|---|
| 변화 type별 AUROC와 AP | 그 type의 유전자 10개 | 변하지 않은 유전자(이식 아님, decoy 아님) | 2d 왼쪽, 2e |
| 전체 AUROC와 AP | 모든 이식 유전자 | decoy를 포함한 나머지 모든 유전자 | 2d 오른쪽 |
| Decoy 대비 AUROC | 모든 이식 유전자 | decoy 20개 | 2d 오른쪽 |
| 상위 50 구성 | 상위 50개 유전자 안의 이식 유전자와 decoy 수 | | Supplementary Fig. S2 |

stORCA에 대해서는 이식 유전자, 변하지 않은 유전자, decoy 중의 call 수와, 재배정 9가지에 걸친 최대 call 수도 셌습니다. 수집기: [08-collect-imp3v3.py](../1-BM-DSE-Semi-LIBD/08-collect-imp3v3.py); 값: [imp3v3-summary-metrics.csv](../1-BM-DSE-Semi-LIBD/res/imp3v3-summary-metrics.csv); 패널: [02d-fig2-dlpfc-imp3v3-panels.py](02d-fig2-dlpfc-imp3v3-panels.py).

### S2.8. 두 benchmark의 범위

simulated benchmark는 stORCA를 single-pair 방법과 단일 section 쌍에서 비교하므로, replicate design이 아니라 점수를 검정합니다. cortex benchmark는 조건당 section 세 장에서 replicate design 전체를 검정합니다. 이식 유전자는 측정 가능한 공간 구조를 가진 유전자에서 뽑았고, 성능은 그런 유전자 사이에서의 회수를 나타냅니다. DESpace2는 두 benchmark 모두에서 정답 domain을 받았습니다. 실제 데이터에서는 domain을 추정해야 하므로, 여기서의 결과는 domain test의 상한입니다. implant 수준 1과 2에서 stORCA는 call하지 않았습니다. 조건당 section 세 장에서 이 변화들이 서로 다른 donor에서 온 같은 조건 section 사이의 차이를 넘지 못했기 때문입니다.
