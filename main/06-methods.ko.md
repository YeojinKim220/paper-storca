# Methods

## 개요

stORCA는 한 유전자의 공간 패턴이 두 조건 사이에서, 같은 조건의 section 사이에서보다 더 크게 다른지를 검정합니다. section 쌍마다 공유된 cell state를 학습하고, 다른 section에 대응 세포가 있는 세포를 matching하며, 두 section이 공유하지 않는 유전자의 공간 구조가 얼마인지를 측정합니다. 이 측정값을 residual-to-original spatial ratio(ROS)라고 부릅니다. replicate section이 있으면 stORCA는 조건 사이 쌍의 ROS를 조건 안 쌍의 ROS와 비교하고, 그 초과분을 유전자마다 검정합니다. 본문 전체에서 세포라고 쓰며, Visium에서는 spot이 세포의 자리를 대신합니다.

## 발현 입력

각 section의 원래 좌표와 측정된 유전자 panel을 유지했고, sequencing 기반 assay에서는 section을 batch로 두고 고른 highly variable gene 3,000개를 사용했습니다(Methods, Datasets). 두 가지 변환이 서로 다른 목적에 쓰입니다. cell state를 학습할 때는 쌍이 공유하는 유전자에 대해 각 세포를 총 $10^4$ count로 정규화하고 $\log(1+\cdot)$를 적용했습니다. 유전자를 점수 매길 때는 원래 측정값 $Y_{ig}$로 돌아가 section마다 $\log(1+Y_{ig})$를 적용하고, 양수 값을 95번째 백분위수에서 잘랐으며 0은 유지했습니다. 이 cap은 소수의 매우 높은 측정값이 공간 이차형식에 미치는 영향을 제한합니다. 두 변환을 분리해 두면, 점수 매기는 유전자는 자기 측정 척도에서 비교되고, 그 조직 맥락은 panel 전체에서 추론됩니다.

## 쌍마다 공유된 cell state 학습

순서가 있는 source와 target 쌍마다, 두 section의 정규화된 발현에 cross-system variational inference 모델(SysVI)을 맞췄고, section 출처를 system covariate로 두었습니다. section covariate를 두면 decoder가 section 사이의 측정 차이를 흡수하므로, 15차원 latent state가 두 section이 공유하는 척도에서 cell state를 나타냅니다. encoder와 decoder는 각각 batch normalization, ReLU, dropout 0.1을 쓴 256-unit hidden layer 두 개를 가졌고, 모든 hidden layer에서 section label을 받았습니다. 학습은 Gaussian 재구성 손실, 다섯 성분 VampPrior에 대한 Kullback–Leibler 항, 그리고 section label을 바꿨을 때 encoding된 상태가 변하는 것을 벌하는 가중치 5의 cycle-consistency 항을 최소화했습니다.<!-- link: reviewer-qa#q12-shared-sysvi-hyperparameters-across-datasets --> 400 epoch, 128 세포 batch, Adam(learning rate $10^{-3}$, weight decay $10^{-6}$), seed 42로 학습했고, 모든 세포의 posterior mean $\mu_i$를 사용했습니다. 공간 좌표는 학습에 쓰이지 않으며, 아래에서 neighborhood를 만들 때만 들어갑니다.

## Partial optimal transport로 조직 matching

두 세포는 세포 자체와 그 주변 조직이 모두 일치할 때만 matching되어야 합니다. 각 세포에 대해 같은 section에서 가장 가까운 20개 세포(자기 포함)의 latent mean을 평균해 neighborhood vector $\nu_i$를 만들었습니다. $\mu_i$와 $\nu_i$를 단위 길이로 맞춘 뒤, cosine 비유사도 $d(v,w)=[1-\cos(v,w)]/2$를 하나의 cost로 결합했습니다.

$$
C_{ij}=1-\bigl(1-d(\mu_i,\mu_j)\bigr)\bigl(1-d(\nu_i,\nu_j)\bigr),
$$

이 cost는 중심 상태와 그 neighborhood가 모두 비슷할 때만 낮습니다. 모든 물리적 거리는 section 안에서 계산하므로, 두 section은 각자의 원점과 방향을 유지하고 registration이 필요 없습니다.

어떤 세포는 대응 세포가 없습니다. 예를 들어 조건 사이에서 사라지거나 생긴 조직입니다. 이런 위치를 cost와 독립적으로, latent space에서 두 section의 국소 균형으로 추정했습니다. pooled latent space에서 각 세포의 가장 가까운 50개 세포 중 source와 target 세포 수 $(c_s,c_t)$를 세고, section 크기 $n_s,n_t$로 $\ell=\log[(c_t+0.5)/n_t]-\log[(c_s+0.5)/n_s]$를 만든 뒤, 그 세포와 같은 50개 이웃에 걸쳐 평균해 $\bar\ell$을 얻었습니다. 같은 조건의 section도 어느 정도 불균형하므로, 한 연구의 모든 조건 안 쌍 세포에 대한 $|\bar\ell|$의 95번째 백분위수를 허용치 $\delta$로 정했고, $\delta$를 넘는 불균형만 세포의 capacity를 줄입니다.

$$
a_i=\frac{\min\bigl(1,e^{\bar\ell_i+\delta}\bigr)}{n_s},\qquad
b_j=\frac{\min\bigl(1,e^{-\bar\ell_j+\delta}\bigr)}{n_t}.
$$

두 총 capacity 중 작은 쪽을 운송했고, capacity가 작은 쪽에 cost 0인 dummy node를 두어 entropy 정규화 문제를 Sinkhorn scaling으로 풀었습니다($\varepsilon=0.02$). dummy coupling을 제거하면 plan $\Pi$는 각 source 세포에 유지 비율 $r_i=n_s\sum_j\Pi_{ij}$와 partner 분포 $\Pi_{ij}/\sum_k\Pi_{ik}$를 주고, target 세포는 같은 방식의 비율 $r'_j=n_t\sum_i\Pi_{ij}$를 가집니다. replicate section 없는 single-pair 분석에서는 $\delta=0$으로 두었습니다.

## 대응 sampling과 source graph

transport plan은 하나의 matching이 아니라 matching에 대한 분포입니다. 그래서 plan마다 matching 50개를 뽑았습니다. 각 matching에서 source 세포 $i$는 확률 $r_i$로 유지되고, plan의 자기 행에서 뽑은 target partner 하나를 받습니다. 모든 유전자에 같은 matching을 사용했습니다. source section에 공간 graph 하나를 만들어, 각 세포를 가장 가까운 10개 세포와 가중치 $\exp[-d_{ij}^2/(2\sigma^2)]$로 연결했습니다. $\sigma$는 이웃 거리의 중앙값입니다. 가중치를 대칭화하고 대각을 0으로 두었으며 각 행의 합을 1로 정규화했습니다. matching $m$에서 $W_m$은 유지된 source 세포로 제한한 이 graph이며, 원래 가중치를 그대로 씁니다. matching된 target 발현을 같은 source 세포 위에 놓으므로, 두 발현 field가 하나의 neighborhood 체계에서 비교됩니다.

## Residual-to-original spatial ratio(ROS)

한 유전자와 matching $m$에 대해, $x_m$을 유지된 세포의 변환된 source 발현, $y_m$을 sampling된 partner의 변환된 발현이라고 합니다. $\tilde v$를 유지된 세포에서 centering한 벡터 $v$라 하고, 공간 이차형식 $q_m(v)=\tilde v^\top W_m\tilde v$를 정의합니다. 이 값은 이웃 세포들이 평균에서 같은 방향으로 벗어날 때 큽니다. matching에 걸쳐 합치면

$$
\mathrm{ROS}=\frac{\sum_m q_m(x_m-y_m)}{\sum_m\bigl[q_m(x_m)+q_m(y_m)\bigr]} .
$$

분자는 matching된 차이의 공간 구조이고, 분모는 두 발현 field 자체의 공간 구조입니다. 두 field의 패턴과 세기가 같으면 ROS는 0, 공간 구조를 전혀 공유하지 않으면 1, 패턴이 반대면 2입니다. 이 형태에서 세 가지 성질이 나옵니다. 첫째, centering이 점수 척도에서 모든 세포에 같은 변화를 제거하므로 global shift는 ROS를 올리지 않습니다. 둘째, ROS는 amplitude에 반응합니다. $y=ax$이면 두 field의 공간 correlation은 1이지만 $\mathrm{ROS}=(1-a)^2/(1+a^2)$이고, 두 배가 되면 0.2입니다. 셋째, ROS는 residual을 residual 자신의 분산이 아니라(residual의 Moran's $I$가 하는 방식) 원래 field의 구조로 나눕니다. 그래서 모양이 같은 약한 residual과 강한 residual이 다른 점수를 받습니다. $W_m$은 대각이 0이고 음의 고윳값을 가질 수 있으므로 유한한 raw ROS가 $[0,2]$를 약간 벗어날 수 있으며, replicate 추론에서는 이 구간으로 clip했습니다.<!-- link: reviewer-qa#q7-clipping-ros-to-0-2-and-moran-filtering -->

## 패턴과 amplitude 분리

ROS는 패턴 항과 amplitude 항으로 인수분해됩니다. $A=\sum_m q_m(x_m)$, $B=\sum_m q_m(y_m)$, $C=\sum_m\tilde x_m^\top\tfrac12(W_m+W_m^\top)\tilde y_m$이라 쓰면 분자는 $A+B-2C$이고, $A,B>0$일 때

$$
1-\mathrm{ROS}=\rho_W\,\kappa,\qquad
\rho_W=\frac{C}{\sqrt{AB}},\qquad
\kappa=\frac{2\sqrt{AB}}{A+B}.
$$

$\rho_W$는 두 패턴의 공간 가중 correlation이고, $\kappa$는 두 패턴의 공간 세기가 같을 때 1이며 세기가 벌어질수록 작아집니다. $h=\tfrac12\log(B/A)$가 방향을 줍니다. identity 가중치에서 이 곱은 centering한 두 profile의 Lin concordance correlation이고, $\rho_W$는 Pearson correlation입니다. 이 인수분해는 변화의 type을 기술하는 데 쓰며(Figure 5), 검정에는 들어가지 않습니다.

## Replicate section에서 조건 효과 검정

다른 조건의 두 section 사이 차이에는 임의의 두 section 사이 차이가 포함되며, 같은 조건의 replicate section도 이미 이런 차이를 보입니다. replicate design은 이 기준선을 직접 측정합니다. 모든 조건 사이 쌍을 control에서 treated 방향으로, 모든 조건 안 쌍을 한 번씩 점수 매겼으므로, 조건당 section 세 장이면 조건 사이 쌍 9개와 조건 안 쌍 6개가 나옵니다.

조건 안 쌍은 다른 조건에 대응이 없는 조직을 공유할 수 있고, 그러면 기준선이 실제보다 더 비슷해 보입니다. 같은 것끼리 비교하기 위해, 각 세포의 유지 비율을 모든 조건 사이 partner에 걸쳐 평균했고, 이 availability를 조건 안 matching에서 세포를 유지할 확률로 썼습니다. 그다음 제한된 graph와 이차형식을 다시 계산했습니다. Figure 2, 3, 5의 분석에서는 source 세포의 availability를 사용했고, Figure 4의 injury 비교에서는 source 세포와 sampling된 partner의 availability 중 작은 값을 사용했습니다.

pair들이 측정할 수 있는 공간 구조를 가진 유전자를 검정했습니다. 유전자는 먼저 적어도 한 section graph에서 Moran's $I>0.03$이어야 했으며, 이 filter는 조건 label을 쓰지 않습니다. 각 쌍과 matching에 대해 분모 $D_m=q_m(x_m)+q_m(y_m)$을 centering된 값의 독립 무작위 부호 아래 표준편차로 표준화했습니다.

$$
V_m(v)=\sum_{i<j}\bigl(w^{(m)}_{ij}+w^{(m)}_{ji}\bigr)^2\tilde v_i^2\tilde v_j^2,\qquad
z_m=\frac{D_m}{\sqrt{V_m(x_m)+V_m(y_m)}} ,
$$

두 section 모두 상수가 아니고 matching 50개에 걸친 최소 $z_m$이 1 이상일 때 그 쌍에서 유전자를 평가 가능하다고 보았습니다. 쌍의 60% 이상에서 평가 가능한 유전자를 검정했고, 모든 쌍의 유한한 점수를 사용했습니다.

유전자 $g$와 쌍 $p$에 대해 clip된 ROS $T_{gp}$를 다음 모형으로 맞췄습니다.

$$
T_{gp}=\alpha_g+\beta_g B_p+\gamma_g H_p+\epsilon_{gp},
$$

조건 사이 쌍에서 $B_p=1$입니다. 그룹 크기가 다르면 $H_p$를 추가해(첫 그룹 안 $-\tfrac12$, 두 번째 그룹 안 $+\tfrac12$, 조건 사이 0), $\beta_g$가 조건 사이 쌍을 두 조건 안 그룹의 동일 가중 평균과 비교하도록 했습니다. 유전자당 쌍이 몇 개뿐이라 유전자별 분산이 불안정하고, 그 크기는 유전자가 가진 공간 구조의 양에 따라 달라집니다. 그래서 평균 log 중앙값 $z_m$에 대한 분산 trend를 둔 limma empirical Bayes 절차로 분산을 조정했습니다. 조건 사이 차이가 replicate 차이를 넘는 것만이 조건 효과의 증거이므로 $\beta_g>0$을 one-sided로 검정했고, 검정한 유전자 전체에 Benjamini–Hochberg 보정을 적용해 보정 $P<0.05$에서 call했습니다. 각 쌍의 가중치는 같습니다.

section 쌍들은 section을 공유하므로 독립이 아닙니다. call이 특정 section이 아니라 조건 label에 의존하는지 확인하기 위해, section 전체를 원래 크기의 두 그룹으로 다시 배정하는 모든 경우(3 대 3에서 실제 배정을 포함해 서로 다른 분할 10개)에 대해 대비를 다시 맞췄고, plan, thinning, 유전자 적격성은 고정했습니다.<!-- link: reviewer-qa#q9-non-independence-of-section-pairs-in-3-vs-3-replicate-designs -->

## Single-pair 점수

Figure 2의 simulated benchmark처럼 조건당 section 하나만 비교할 때는 조건 안 기준선이 없습니다. 이 경우 $\delta=0$, matching 50개, gene filter 없이 그 쌍의 clip된 ROS로 모든 유전자를 순위 매겨, 모든 방법을 모든 유전자에서 평가했습니다.

## Benchmark와 비교 방법

Figure 2를 위해 여섯 가지 설계된 변화를 가진 simulated tissue를 생성했고, 인간 DLPFC section에 설계된 변화 다섯 가지를 이식했습니다. 생성기, 파라미터, 정답 집합, 지표는 보충 방법 S2에 있습니다. 각 비교 방법은 발표된 그대로 기본 설정으로 돌렸습니다. CODA는 자체 registration 뒤 음의 spatial cross-correlation index로 유전자를 순위 매겼습니다. STcompare는 STalign으로 좌표를 registration하고 공통 격자에 발현을 rasterize한 뒤 spatial correlation과 percent similarity 두 순위를 냈습니다. River는 발현과 위치로 조건을 예측하는 network에서의 attribution으로 유전자를 순위 매겼습니다. SpaceExpress는 natural spline으로 조건과 embedding의 상호작용을 검정했습니다. DESpace2는 주어진 domain label, replicate 식별자, 조건으로 domain 패턴의 차이를 검정했습니다. 모든 점수는 값이 클수록 변화가 크도록 방향을 맞췄습니다. replicate design에서 pairwise 방법은 방향을 맞춘 점수를 조건 사이 쌍에 걸쳐 평균했습니다.

## 소프트웨어

stORCA는 Python 3.11, scvi-tools 1.4.2, PyTorch 2.8.0, Scanpy 1.11.5, AnnData 0.12.6을 사용했고, transport scaling은 double precision으로, limma empirical Bayes 절차는 Python 구현으로 계산했습니다. 코드는 transport marginal, sampling된 matching, matching별 이차형식을 저장하므로, 모든 쌍 점수와 그 분해를 모델을 다시 맞추지 않고 재계산할 수 있습니다.
