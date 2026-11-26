# Q5 해석: 각 call을 pattern 또는 amplitude로 어떻게 분류하는지, 데이터별로 유형이 어떻게 나오는지, NRDR activity 유전자와 ARTISTA 예시가 지도와 맞는지, 무엇이 아직 검증되지 않았는지

이 노트는 노트북 [15-q5-interpretation.ipynb](15-q5-interpretation.ipynb)를 section별로 설명한다. 하나의 흐름을 따른다: (1) ROS를 pattern 부분과 amplitude 부분으로 분해하고 call마다 유형을 주는 방법; (2) 데이터별 유형 비율; (3) 유형과 방향을 예측할 수 있는 NRDR activity 유전자에 대한 생물학적 확인; (4) ARTISTA 예시 두 개를 지도에서 확인한 결과; (5) 무엇을 주장할 수 있고 무엇을 먼저 고쳐야 하는지.

이 흐름은 outline의 claim 4, 해석을 뒷받침한다: "어떤 종류의 변화이고 (pattern 또는 amplitude) 어디서인가" ([0-paper-outline-natcomm.md](../0-Paper-Draft/0-paper-outline-natcomm.md)의 Figure 2b, 5c, 5d, 6e). outline에서 벗어난 점이 네 가지 있어서 여기서 밝힌다. 첫째, 기호가 다르다: 노트북의 `kappa`는 outline의 $C(\kappa)$이고, outline의 $\kappa$는 다른 양이다. 둘째, 유형은 replicate 대비 초과분이 아니라 between 쌍 점수 전체를 설명하므로, replicate 사이의 불일치를 설명하고 있을 수 있다. 셋째, claim의 "어디서" 절반은 유전자 두 개에 대해 쌍 하나의 residual 지도로만 보이고 숫자가 없다. 넷째, NRDR 확인은 방향이 예측과 반대로 나온다.

모든 그림은 노트북에서 그대로 가져왔다 (PDF는 `5-Case-Study-Comparison/fig/`, PNG 사본은 `5-Case-Study-Comparison/fig/15-q5-interpretation/`). 경로는 링크가 아니면 project root 기준이다. "이 보고서에서 계산"이라고 표시한 숫자는 저장된 결과 파일에서 구한 것으로 노트북에는 없다.

**데이터.** 세 데이터의 stORCA v3 call (one-sided unweighted limma, BH $<0.05$): ARTISTA 2 DPI vs 20 DPI (검정 782개 중 115 call, between 쌍 9개), NRDR V1 posterior 정상 사육 vs 암실 사육 (377개 중 32, between 쌍 4개), HPOA naive vs aggression (149개 중 11, between 쌍 9개).

**Score.** 한 쌍에서 $Q_x$, $Q_y$, $Q_r$을 source 발현, matching된 target 발현, 둘의 차이의 공간 quadratic form을 sampling한 matching에 대해 합한 것이라 하자. 그러면 $\mathrm{ROS}=Q_r/(Q_x+Q_y)$이고 (`storca/interpret.py`의 `pair_decomposition` 함수)

$$
1-\mathrm{ROS}=\rho\cdot\kappa,\qquad
\kappa=\frac{2\sqrt{Q_xQ_y}}{Q_x+Q_y},\qquad
\rho=\frac{Q_x+Q_y-Q_r}{2\sqrt{Q_xQ_y}} .
$$

$\kappa$는 두 section의 공간 구조 세기가 같으면 1이고, 세기가 다를수록 0으로 내려간다. $\rho$는 구조의 모양이 같으면 1이고 모양이 다를수록 내려간다. log를 취하면 손실이 더해지는 형태가 되어, $-\log(1-\mathrm{ROS})=-\log\rho-\log\kappa$, amplitude share와 방향이 나온다:

$$
s=\frac{-\log\kappa}{-\log\kappa-\log\rho},\qquad
\ell=\tfrac12\log\frac{Q_y}{Q_x} .
$$

$\ell>0$은 treated section의 구조가 더 강하다는 뜻이다. between 쌍은 항상 control section에서 treated section 방향이므로 (`storca/replicate_case_studies.py`), $\ell$의 부호는 모든 between 쌍에서 같은 뜻이다.

**쌍 하나의 유형 규칙.**

1. On/off: 한쪽이 상수다.
2. Undefined: $Q_x\le0$ 또는 $Q_y\le0$.
3. Pattern: $\rho\le0$ 또는 $s<1/3$.
4. Amplitude: $s>2/3$. 나머지는 모두 mixed.

노트북은 유전자마다 between 쌍에 대한 $\kappa$, $\rho$, $s$, $\ell$의 중앙값과, between 쌍 중 가장 자주 나온 유형을 취한다.

## 0. Summary

| Step | Finding |
|---|---|
| 1. 유형 | ARTISTA call 115개: pattern 63, mixed 42, amplitude 10. NRDR posterior call 32개: 14, 14, 4. HPOA call 11개: 2, 3, 6 |
| 2. 비율 | Pattern 비율은 ARTISTA 0.55, NRDR 0.44, HPOA 0.18. HPOA는 call 11개에 기댄다 |
| 3. NRDR 확인 | activity 유전자 11개 중 7개가 call이다. 예측: amplitude형, 암실 사육에서 더 약함. 관찰: mixed 5개와 pattern 2개, 모두 암실 사육에서 더 강함 ($\ell$ 0.63~1.38). Pseudobulk도 관찰된 방향과 일치하므로 ($\log_2$ fold change 1.6~3.1), 분해는 데이터와 일관되고 어긋난 것은 시료에 대한 기대다 |
| 4. 예시 | `CDKN1B` (amplitude, $s$ 0.82)와 `FABP7` (pattern, $s$ 0.12)은 둘 다 지도와 맞는다. 둘 다 전역 DE 유전자이기도 하고, River는 둘을 상위 40 안에 둔다 |
| 5. 검증되지 않은 것 | 유형을 replicate 기준선과 비교하지 않았고, 쌍 사이의 일치 정도가 없으며, 정답이 없다. 변화의 위치에는 숫자가 없다 |
| 6. Fix 또는 defend | 고칠 것 두 가지: 원 연구의 채취 조건을 한 번 확인한 뒤 NRDR 가설 문장을 다시 쓰기, 노트북의 `kappa`가 outline의 $C(\kappa)$임을 한 번 밝히기. 확인 하나: replicate 대비 초과분으로 유형을 붙이면 유형이 바뀌는지. 나머지 문제는 section 5에 방어 논리와 함께 기록했다 |

## 1. 각 call에 유형 붙이기 (노트북 section 1)

**질문.** call된 유전자에서 공간 concordance의 손실이 모양의 변화 때문인가, 세기의 변화 때문인가?

**쉽게 말하면.** 장난감 유전자 두 개. 유전자 A는 두 조건에서 지도가 같고 세기만 절반이다, $y=0.5\,x$. 그러면 $Q_y=0.25\,Q_x$이므로 $\kappa=2(0.5)/(1+0.25)=0.8$, $\rho=1$, $\mathrm{ROS}=1-0.8=0.2$, $s=1$: 손실 전부가 amplitude다. 유전자 B는 세기는 그대로인데 다른 곳으로 옮겨 간다: $\kappa=1$, $\rho<1$, $s=0$: 손실 전부가 pattern이다. 실제 유전자는 그 사이에 있고, $s$가 어디쯤인지 알려준다.

**"Amplitude"는 평균 수준이 아니라 공간 구조의 세기다.** $Q$는 공간 가중 분산이다. log 척도에서 모든 곳에서 같은 양만큼 오르는 유전자는 $Q$가 그대로이므로 $\kappa$는 1에 머문다. 그래서 $\kappa=0.96$으로 "pattern"형인 유전자가 pseudobulk DE 유전자일 수 있다 (`FABP7`, section 4).

**왜 중요한가.** CODA와 STcompare는 상관으로 점수를 매기므로 세기 변화를 구조상 무시한다. River와 DESpace2는 유전자마다 숫자 하나를 준다. call마다의 유형은 이들 중 누구도 내놓지 않는 출력이다.

**구현** (노트북 section 1. `interpret.case_decomposition`이 matching별 표 `<plan prefix>-issue-matching.csv`의 `q_x`, `q_y`, `q_r` column을 읽으므로, limma가 쓴 ROS와 숫자가 일치한다).

1. case의 모든 쌍을 위의 식으로 분해한다.
2. between 쌍만 남긴다. 유전자마다: $\kappa$, $\rho$, $s$, $\ell$의 중앙값과 가장 자주 나온 유형.
3. limma 표와 합쳐서 call만 남긴다.

**실제 숫자로 본 예 (ARTISTA, 유전자 중앙값).**

| 유전자 | $\kappa$ | $\rho$ | $-\log\kappa$ | $-\log\rho$ | $s$ | $\ell$ | 유형 |
|---|---|---|---|---|---|---|---|
| `CDKN1B` | 0.239 | 0.736 | 1.431 | 0.307 | $1.431/1.738=0.82$ | 2.11 | amplitude |
| `FABP7` | 0.961 | 0.746 | 0.040 | 0.293 | $0.040/0.333=0.12$ | 0.28 | pattern |

`CDKN1B`에서 $\ell=2.11$은 $Q_y/Q_x=e^{4.22}\approx68$이라는 뜻이다: 구조가 20 DPI에서 68배 강하다. 두 유전자의 $\rho$는 거의 같고, 다른 것은 $\kappa$다.

**결과.**

| 데이터 | Call | Pattern | Mixed | Amplitude |
|---|---|---|---|---|
| ARTISTA | 115 | 63 | 42 | 10 |
| NRDR posterior | 32 | 14 | 14 | 4 |
| HPOA | 11 | 2 | 3 | 6 |

**유형이 조건 효과를 설명하는가?** 정확히는 아니다. call은 between 쌍이 within 쌍을 넘는 초과분 $\Delta$에 대해 내리는데, 유형은 between 쌍만으로 계산한다. within ROS가 0.35이고 between ROS가 0.57인 call (ARTISTA의 `B2M`)은 0.57 전체에 대한 유형을 받는데, 그중 0.35는 replicate 사이에도 이미 있다. log 형태에서는 두 손실이 더해지므로 바로 고칠 수 있다:

$$
\text{excess amplitude loss}=\overline{-\log\kappa}_{\text{between}}-\overline{-\log\kappa}_{\text{within}},\qquad
\text{excess pattern loss}=\overline{-\log\rho}_{\text{between}}-\overline{-\log\rho}_{\text{within}} .
$$

이 두 초과분으로 계산한 share가, call이 대상으로 하는 변화 부분에 유형을 붙인다. within 분해는 `case_decomposition`이 돌려주는 표에 이미 있고 (column `within`), 쓰이지 않을 뿐이다.

**아직 잘못될 수 있는 곳.**

- 유형은 쌍 유형 9개 (NRDR은 4개) 중 최빈값이다. 몇 쌍이 일치하는지 보고하지 않아서, 4 대 3 대 2의 표결이 9 대 0과 똑같이 보인다.
- $\rho\le0$인 쌍은 규칙 3에 따라 "pattern"이 된다. $\rho\le0$은 $\mathrm{ROS}\ge1$을 뜻하며, [14-q4-effect-size.md](14-q4-effect-size.md) section 6의 범위 밖 점수가 여기에 들어간다. 이 세 데이터에서 검정 유전자의 쌍 점수 중 범위 밖은 ARTISTA 3.1% (call 115개 중 8개 관련), NRDR posterior 0.9% (32개 중 1개), HPOA 0.2% (11개 중 0개)다 (이 보고서에서 `limma-pair-scores.csv`로 계산).
- 경계값 1/3과 2/3는 관례다. 다른 경계값에서 개수가 어떻게 움직이는지는 노트북에 없다.

**판정: between 쌍에 대한 서술로는 작동, 조건 효과의 유형으로는 아직 아님.**

결과 파일: 각 case folder 아래의 쌍별 표 (`<plan prefix>-issue-gene.csv`, `-issue-matching.csv`). 노트북은 유전자별 유형 표를 저장하지 않는다.

## 2. rho-kappa 평면과 유형 비율 (노트북 section 2)

**질문.** 어떤 종류의 변화가 우세한지가 데이터마다 다른가?

**구현** (노트북 section 2). 검정된 모든 유전자를 중앙값 $(\kappa,\rho)$에 찍고, call은 유형별 색으로 칠한다. 점선은 ROS가 같은 선, $\rho\,\kappa=1-\mathrm{ROS}$로, ROS 0.2, 0.4, 0.6, 0.8에 해당한다.

![rho-kappa 평면](fig/15-q5-interpretation/q5-rho-kappa-plane.png)

*데이터마다 panel 하나. 가로: $\kappa$, 세기의 일치. 세로: $\rho$, 모양의 일치. 연한 회색: call이 아닌 검정 유전자. 파랑: amplitude call. 빨강: pattern call. 진한 회색: mixed call (legend: `fig/15-q5-interpretation/q5-change-type-legend.png`). 핵심: ARTISTA의 call은 오른쪽 가장자리를 따라 아래로 퍼지고 ($\kappa$가 1 근처, $\rho$가 낮음), HPOA의 call은 왼쪽, 높은 $\rho$에 있다. Source: [15-q5-interpretation.ipynb](15-q5-interpretation.ipynb) section 2.*

**결과.**

| 데이터 | Pattern | Mixed | Amplitude |
|---|---|---|---|
| ARTISTA | 0.55 (115개 중 63) | 0.37 (42) | 0.09 (10) |
| NRDR posterior | 0.44 (32개 중 14) | 0.44 (14) | 0.12 (4) |
| HPOA | 0.18 (11개 중 2) | 0.27 (3) | 0.55 (6) |

노트북은 ARTISTA를 "재생이 패턴을 재배치한다", HPOA를 "구조는 같고 세기가 다르다"로 읽는다. 둘 다 그럴듯하지만 어느 것도 검정되지 않았다. HPOA는 call이 11개라 유전자 하나에 비율이 0.09씩 움직인다. outline은 "colitis call의 대부분은 amplitude 변화"를 기대하는데, colitis는 이 노트북에 없으므로 그 문장은 여기서 근거가 없다.

**판정: 부분 성공. 비율은 측정되었고, 그 생물학적 해석은 측정되지 않았다.**

결과 파일: 그림 `fig/15-q5-interpretation/q5-rho-kappa-plane.png`, `q5-change-type-share.png`.

## 3. 생물학적 확인: NRDR의 activity 유전자 (노트북 section 3)

**질문.** 반응이 미리 알려진 유전자에서 유형이 기대대로 나오는가?

**노트북의 가설.** 암실 사육은 시각 활동을 줄인다. activity 의존 유전자 (`Arc`, `Fos`, `Egr4` 등)는 암실 사육 피질에서 층 패턴은 유지하고 세기를 잃을 것이다: amplitude형, $\ell<0$.

**구현** (노트북 section 3). NRDR posterior (2 vs 2, between 쌍 4개)의 activity 유전자 11개에 대한 section 1의 유전자별 요약.

**결과** (노트북의 표에, 이 보고서에서 `res/Comparison/nrdr-pos-gene-table.csv`로 계산한 pseudobulk column을 더함).

| 유전자 | Call (BH) | 유형 | $s$ | $\kappa$ | $\rho$ | $\ell$ | Pseudobulk $\log_2$ fold change, 암실 vs 정상 (FDR) |
|---|---|---|---|---|---|---|---|
| `Arc` | 예 (0.025) | mixed | 0.35 | 0.83 | 0.71 | 0.63 | 2.40 (0.001) |
| `Egr4` | 예 (0.025) | mixed | 0.55 | 0.69 | 0.70 | 0.93 | 2.36 (0.001) |
| `Fos` | 예 (0.038) | mixed | 0.58 | 0.47 | 0.56 | 1.38 | 3.08 (0.001) |
| `Fosb` | 예 (0.039) | mixed | 0.60 | 0.51 | 0.66 | 1.30 | 3.11 (0.001) |
| `Junb` | 예 (0.030) | mixed | 0.57 | 0.62 | 0.68 | 1.06 | 2.71 (0.001) |
| `Nr4a2` | 예 (0.020) | pattern | 0.14 | 0.83 | 0.37 | 0.64 | 2.69 (0.001) |
| `Npas4` | 예 (0.030) | pattern | 0.28 | 0.74 | 0.52 | 0.81 | 1.57 (0.048) |
| `Egr2` | 아니오 (0.082) | amplitude | 0.73 | 0.51 | 0.76 | 1.32 | 3.02 (0.008) |
| `Nr4a3` | 아니오 (0.067) | pattern | 0.21 | 0.87 | 0.61 | 0.53 | 2.31 (0.008) |
| `Nr4a1` | 아니오 (0.108) | pattern | 0.30 | 0.92 | 0.83 | 0.41 | 1.99 (0.003) |
| `Bdnf` | 아니오 (0.325) | pattern | 0.31 | 0.91 | 0.84 | -0.43 | -0.31 (0.72) |

**Reading:**

- **검출은 기대대로다.** activity 유전자 11개 중 7개가 call이고, 3개가 더 BH 0.11 미만이다.
- **유형은 예측과 다르다.** call 7개 중 amplitude형은 없고, 5개가 mixed, 2개가 pattern이다.
- **방향은 예측과 반대이고, 데이터는 stORCA와 일치한다.** $\ell$은 call 7개 모두에서 양수이고, pseudobulk 수준은 11개 중 10개에서 암실 사육 section이 3~9배 높다. 즉 분해는 count에 들어 있는 방향을 보고한다. 맞지 않는 것은 시료에 대한 기대다.

**예측이 틀릴 수 있는 이유.** "암실 사육" 그룹에서 immediate early gene 수준이 3~9배 높은 것은 두 가지로 설명된다: 동물이 채취 전에 빛에 노출되었거나 (암실 사육 뒤의 빛은 이 유전자들을 강하게 유도한다), 라벨이 상류에서 뒤바뀌었다. `5-Case-Study-NRDR-V1/01-data-preprocessing.py`의 대응은 직접적이어서 (`P28NR*`는 `nr`, `P28DR*`는 `dr`) 우리 코드에서 뒤바뀐 것은 아니다. 원 연구의 채취 조건을 한 번 확인하면 가설 문장이 정해진다.

**판정: 부분 성공.** 일관성 확인으로는 작동한다 ($\ell$의 방향이 11개 유전자 중 11개에서 pseudobulk와 일치). 유형의 검증으로는 실패한다. 기대되는 정답이 확립되어 있지 않기 때문이다.

결과 파일: `5-Case-Study-Comparison/res/Comparison/nrdr-pos-gene-table.csv` (column `de_global_logfc`, `de_global_fdr`).

## 4. ARTISTA의 예시: amplitude call 하나와 pattern call 하나 (노트북 section 4)

**질문.** amplitude형 call과 pattern형 call의 지도가 유형이 말하는 대로 보이는가?

**선택 규칙.** 유형마다 stORCA $t$가 가장 큰 call. 각각에 대해 section 6개의 지도와, between 쌍 하나 (`dpi2-r1` 대 `dpi20-r1`)의 source 발현, matching된 target 발현, 평활한 residual.

**결과 (이 보고서에서 지도를 직접 확인).**

| 유전자 | 유형 | $t$ | $s$ | $\kappa$ | $\rho$ | $\ell$ | 지도에서 보이는 것 | 성립? |
|---|---|---|---|---|---|---|---|---|
| `CDKN1B` (`XICL`) | amplitude | 17.1 | 0.82 | 0.24 | 0.74 | 2.11 | 2 DPI에서는 거의 없음. 20 DPI section 세 개 모두에서 ventricle을 둘러싼 강한 띠 | 예 |
| `FABP7` | pattern | 10.1 | 0.12 | 0.96 | 0.75 | 0.28 | 2 DPI: 두 반구에서 ventricle을 따라가는 띠. 20 DPI: 세 section 모두에서 손상 반구의 배쪽에 몰림 | 예 |

같은 유전자의 다른 방법 결과 (3000개 중 between 평균의 순위, 그리고 pseudobulk. pseudobulk column은 이 보고서에서 계산):

| 유전자 | CODA 순위 | River 순위 | SpaceExpress 순위 | DESpace2 FDR | Pseudobulk $\log_2$ fold change (FDR) |
|---|---|---|---|---|---|
| `CDKN1B` | 2799 | 37 | 1298 | 0.65 | 3.30 (0.001 미만) |
| `FABP7` | 2961 | 7 | 1312 | 0.001 미만 | 1.86 (0.001 미만) |

![CDKN1B 지도](fig/15-q5-interpretation/q5-artista-amplitude-xiclnr-cdkn1bhs-maps.png)

*위 행: 2 DPI. 아래 행: 20 DPI. 색 scale 공통. 핵심: ventricle의 띠는 2 DPI에서 세포 몇 개가 양성인 바로 그 자리에 있고, 20 DPI에서 훨씬 강하다. Source: [15-q5-interpretation.ipynb](15-q5-interpretation.ipynb) section 4.*

![FABP7 지도](fig/15-q5-interpretation/q5-artista-pattern-fabp7nr-maps.png)

*위 행: 2 DPI. 아래 행: 20 DPI. 핵심: 20 DPI에서는 밝은 부위가 모든 section에서 오른쪽 (손상) 반구의 아래쪽에 있는데, 2 DPI에서는 거기에 없다. Source: [15-q5-interpretation.ipynb](15-q5-interpretation.ipynb) section 4.*

![FABP7 residual](fig/15-q5-interpretation/q5-artista-pattern-fabp7nr-residual.png)

*왼쪽: `dpi2-r1`. 가운데: matching된 `dpi20-r1` 세포를 source 위치에 그린 것. 오른쪽: 평활한 차이, 파랑은 20 DPI에서 더 높다는 뜻이다. 핵심: 파란 부위가 손상 반구의 배쪽으로, 지도에서 보이는 곳과 같다. Source: [15-q5-interpretation.ipynb](15-q5-interpretation.ipynb) section 4.*

**Reading:**

- **두 유형은 지도와 맞는다.** `CDKN1B`는 자리를 지키고 세기가 커진다. `FABP7`은 새 자리를 얻는다.
- **`CDKN1B`는 on/off 유전자에 가깝다.** 2 DPI에 신호가 거의 없으므로 여기서 "amplitude"는 출현을 뜻한다. outline은 on/off를 $\kappa\to0$의 극한으로 다루므로 일관되지만, 본문은 "같은 패턴이 더 강해진다"가 아니라 "ventricle에 나타난다"고 써야 한다.
- **어느 예시도, 유형으로 설명되는 경쟁 방법의 실패를 보여주지 않는다.** River는 둘 다 상위 40 안에 둔다. CODA는 구조가 있는 모든 유전자에 그러듯 둘 다 맨 아래 근처에 두므로 ([13-q3-beyond-de.md](13-q3-beyond-de.md) section 2 참고), 그 순위로는 amplitude와 pattern을 가를 수 없다. 노트북도 같은 말을 하고 outline Figure 2a의 설계 유전자 실험을 가리킨다.
- **Q4와의 교차 확인에서 볼 것이 하나 있다.** `DDIT4`는 pattern 목록의 2위인데 ($\rho$ 0.24, $\kappa$ 0.70), [14-q4-effect-size.md](14-q4-effect-size.md)의 지도는 section 전체의 상승을 보인다. 넓은 수준 상승이 "pattern"으로 분류되는 이유를 유형을 보고하기 전에 이해해야 한다.

**위치 claim은 보였는가?** 유전자 두 개, 쌍 하나씩에 대해 눈으로만. "어디서"에 대한 숫자가 없다: domain이나 세포 유형별 residual의 enrichment도 없고, 그 위치가 나머지 between 쌍 여덟 개에서 반복되는지의 확인도 없다.

**판정: 이 두 유전자의 유형에 대해서는 작동. 정량화된 위치에 대해서는 no evidence yet.**

결과 파일: 그림 `fig/15-q5-interpretation/q5-artista-amplitude-xiclnr-cdkn1bhs-maps.png`, `-residual.png`, `q5-artista-pattern-fabp7nr-maps.png`, `-residual.png`.

## 5. Q5의 현재 위치

| Claim | 뒷받침되는가? | 근거 |
|---|---|---|
| 모든 call이 pattern 성분과 amplitude 성분을 받는다 | 예, 계산으로서는 | 1 |
| 유형이 조건 효과를 설명한다 | 보이지 않음. between 쌍을 설명하며 replicate 부분이 포함됨 | 1 |
| 유형이 쌍 사이에 안정적이다 | no evidence yet | 1 |
| 데이터마다 유형 비율이 다르다 | 측정됨 (pattern 0.55, 0.44, 0.18). HPOA는 call 11개 | 2 |
| 유형이 생물학적으로 맞다 | 보이지 않음: NRDR의 방향이 예측과 반대, 설계 미확인 | 3 |
| 방향 $\ell$이 데이터와 일치한다 | 예: NRDR activity 유전자 11개 중 11개에서 pseudobulk와 같은 부호 | 3 |
| 이름을 댄 예시가 지도에서 유형과 맞는다 | 예: `CDKN1B`, `FABP7` | 4 |
| 경쟁 방법이 amplitude 변화를 놓친다 | 실제 데이터에서는 no evidence. 설계 유전자가 필요 | 4 |
| 각 call의 위치가 특정된다 | 눈으로만, 유전자 두 개, 쌍 하나씩 | 4 |
| 유형이 정답에 대해 검증되었다 | no evidence yet (outline Figure 4d 미실행) | 5 |

**상태: 아래 수정 뒤 충분, 이 노트북이 보이는 범위에서** (call마다의 유형과 지도에 맞는 예시). claim 4 전체에는 outline Figure 4d의 설계 유전자 검증이 추가로 필요하고, 그것은 별도 실험이다. 문제는 `CLAUDE.md`의 규칙 ("Level of Rigor: Fix or Defend")에 따라 나눈다.

**Fix.**

1. NRDR 가설. "암실 사육에서 더 약하다"는 데이터와 반대이므로 (immediate early gene이 암실 사육 section에서 3~9배 높음), 쓰인 그대로는 이 section이 스스로를 반박한다. `5-Case-Study-NRDR-V1/01-data-preprocessing.py`의 라벨 대응은 직접적이어서 (`P28NR*`는 `nr`, `P28DR*`는 `dr`) 우리 코드에서 라벨이 뒤바뀐 것은 아니다. 가장 단순한 수정: 원 연구의 채취 조건을 한 번 찾아보고 가설 문장을 거기에 맞게 다시 쓴다. 그것이 확정되지 않으면 이 section을 일관성 확인으로만 제시한다 (방향 $\ell$이 유전자 11개 중 11개에서 pseudobulk와 같음).
2. 기호. 노트북 머리말에 한 문장을 더한다: 노트북의 `kappa`는 outline의 $C(\kappa)=2/(\kappa+1/\kappa)$이고, outline의 $\kappa=\sqrt{Q_x/Q_y}$는 $e^{-\ell}$과 같다. 코드 변경은 없다.

**Fix와 defend를 가르는 확인 하나.** 유형은 replicate 대비 초과분이 아니라 between 쌍으로 계산한다. 초과분 기반 share를 한 번 계산해서 (section 1의 식. within 분해는 이미 표에 있다) 유형이 유지되는 call이 몇 개인지 센다. 대부분 유지되면 현재의 단순한 정의를 두고 그 숫자를 방어 논리로 보고한다. 많은 call이 바뀔 때만 정의를 바꾼다.

**Defend.**

| 리뷰어가 할 수 있는 말 | 답 |
|---|---|
| 유형이 쌍 유형 중 최빈값이다 | $\kappa$, $\rho$, $s$의 중앙값을 함께 보고하고 모든 call을 평면에 보이므로, 독자가 연속값을 본다 |
| 경계값 1/3과 2/3는 관례다 | $s$를 보고한다. 라벨은 읽기를 돕는 장치다 |
| HPOA는 call이 11개다 | 비율을 개수와 함께 보인다 |
| "Amplitude"는 평균 수준이 아니다 (`FABP7`은 pattern형이면서 DE) | Methods에서 공간 구조의 세기로 정의한다. log 척도의 균일한 shift는 이것을 바꾸지 않는다 |
| `CDKN1B`는 on/off 유전자에 가깝다 | On/off는 outline에서 $\kappa\to0$의 극한이다. 본문은 "ventricle에 나타난다"고 쓴다 |
| River가 두 예시를 모두 상위에 두고, CODA 순위는 둘을 가르지 못한다 | 주장은 검출이 아니라 출력, 즉 call마다의 유형에 대한 것이다. amplitude를 보지 못한다는 것은 설계 유전자로 보인다 (outline Figure 2a) |
| 위치는 눈으로만 보였고, 유형의 정답이 없다 | 이들은 계획된 panel Figure 5d와 Figure 4d이고 이 노트북의 일이 아니다 |
| $\rho\le0$인 쌍이 범위 밖 점수를 포함해 pattern이 된다 | [14-q4-effect-size.md](14-q4-effect-size.md)에서 제안한 자르기로 없어진다 |
| colitis가 노트북에 없다 | colitis replicate 실행이 확정되면 넣는다 |
| `DDIT4`가 section 전체에서 수준이 오르는데 pattern형이다 | 여기에 기대는 claim이 없다 |

**사용자가 결정할 것.**

1. 본문에서 amplitude 성분의 이름. 권장: "amplitude"를 유지하고 공간 구조의 세기라고 한 번 정의한다.
2. NRDR을 생물학적 확인으로 남길지. 권장: 남긴다. 가설 문장을 다시 쓰고 일관성 확인으로 쓴다.
