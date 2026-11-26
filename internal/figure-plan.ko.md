# stORCA Nature Communications Figure 구성안: 5개 Main Figure, 패널 설계, 보충 필요 결과 (2026-11-23)

**논문 제목(가제):** *Calibrated detection and decomposition of differential spatial gene expression across replicate tissue sections with stORCA*

이 문서는 `0-Paper-Draft/0-paper-outline-natcomm.ko.md`와 `0-Paper-Draft/0-audit-natcomm-nov23.ko.md`를 바탕으로 Nature Communications 타겟 stORCA 원고의 수정 Figure 구성안을 정의한다. 한 줄의 논지를 따른다: (1) Results 1절 = Figure 1개 구조의 타당성과 세 가지 구조 조정; (2) Main Figures 1~5의 패널별 구성과 보충 필요 결과; (3) Supplementary Figures S1~S5 구성; (4) 실행 우선순위. 경로는 프로젝트 루트 기준이다.

**기본 구조 판정.** Results 1절당 Main Figure 1개, Figure당 핵심 Claim 1개를 배치하는 구조는 Nature Communications 방법론 논문에서 가장 이상적이다. 다만 2026-11-20 아웃라인 대비 세 가지 구조 조정이 필요하다.

1. **Main 5 Figures 체제 확정 (Claim 5 / Figure 6 본문 제외).** ARTISTA 시간축 분석은 시점 간 2~3배 시퀀싱 깊이 교란, 15 DPI 거짓 라벨 최대 41개 호출, 비진폭 시나리오에서의 비단조 $\Delta$(Fix 4) 문제가 있다. 본문을 Main Figures 1~5(문제/방법, 벤치마크, 가짜 1 Replicate, 가짜 2 Unmatched Tissue, 유형/생물학)로 완결하는 편이 공격면이 적고 훨씬 단단하다.
2. **Main Figure당 패널 수를 5~6개로 압축.** 현재 Figures 2~5는 각각 7~8개 패널로 과밀하며 강한 증거와 약하거나 깨진 패널(`2d`, `3d Colitis D0 vs D3`, `4g`)이 섞여 있다. 보조·한계 항목을 Supplementary로 옮겨 가로 18인치 제한 안에서 가독성과 설득력을 높인다.
3. **특정 패널 재배치 및 삭제:**
   - `Fig 2e`(synthetic ground-truth $\rho\kappa$ 유형 검증)를 **`Fig 5a`**로 이동해 Claim 4가 ground-truth 유형 정확도 검증으로 시작해 실데이터 해석으로 이어지게 한다.
   - `Fig 2d`(`3-BM-DSE-Scores`, ROS v4가 3/20 vs 20/20으로 패배)는 본문에서 삭제하고, `Fig 2f2`(`HPOA swap`)와 `Fig 4g`(경쟁사가 `strength = 0`부터 30.5등에 고정되는 synthetic rearrangement `08~12`)는 Supplementary로 이동한다.

## 0. 요약

| Figure (= Results 절) | 핵심 주장 | 패널 수 | 핵심 데이터 | 필수 보충 사항 |
|---|---|---|---|---|
| Figure 1 (Results 1) | 공간 변화는 진짜일 수도, 착시(개체 변이·대응 조직 부재)일 수도 있으며 stORCA가 이를 분리한다 | `1a`~`1e` (5) | Toy + HPOA/Colitis/Cortex thumbnail + 모식도 | 스코어링($\mathrm{ROS}_\lambda^{\text{sym}}$) 동결 후 통일 스타일로 `1a`~`1e` 작도 |
| Figure 2 (Results 2) | stORCA는 패턴·진폭·국소 공간 변화를 모두 잡고 전역 이동은 무시하며, 경쟁 방법은 각기 맹점이 있다 | `2a`~`2e` (5) | Synthetic v2 (`02~07`), LIBD 3 vs 3 semi-synthetic (+ decoy), Runtime | Synthetic v2 1,000배 스케일 및 `01F~01K` bin 수정; Fix 1·대칭 ROS 적용; 공정 gated LIBD + SpaceExpress `FDR=0` 수정 + STcompare `spatialSimilarity`; `8-BM-Runtime` 경쟁사 추가 |
| Figure 3 (Results 3) | 단일 쌍 검정은 replicate 변이를 변화로 오검출하며, stORCA의 replicate 설계는 위양성을 보정한다 | `3a`~`3f` (6) | 실데이터 (LIBD, HPOA, NRDR, ARTISTA) + LIBD implant 확장 | 대칭 ROS 적용(HPOA 1/30 해결); LIBD 3 vs 3 donor 페어링 교란 해소; STcompare $H_0: r=0$ 역전 오용 제거; ARTISTA STcompare = 40 calls 정정 |
| Figure 4 (Results 4) | 대응 조직이 없는 영역이 registration·domain 상위 목록을 채우지만, partial OT + thinning은 이를 차단한다 | `4a`~`4f` (6) | 실데이터 (Cortex 3 dpi, Colitis D0 vs D9, HPOA) | 저장된 `common_cells`로 `colitisq1`/`cortexor` CODA 재스코어링; Balanced vs Partial OT ablation 추가; `4e`, `4f` 작도 |
| Figure 5 (Results 5) | stORCA는 변화 유형을 정확히 분류하고 residual 위치를 지목하며, DE·domain 검정이 놓치는 생물학적 변화를 찾는다 | `5a`~`5f` (6) | 수정된 Synthetic v2 (`5a`) + 실데이터 (ARTISTA, NRDR, HPOA) | `interpret.py` `rho > 1` 버그 수정; ground-truth 유형 검증(`5a`); Q3xQ5 교차표(`5c`) 및 정량 국소화(`5d`); NRDR L2/3-L4 이동 및 Xie et al. Dataset S1 검증(`5e`, `5f`) |

---

## 1. Main Figure 패널별 설계안

상태 표기: `[유지]` = 그대로 사용 가능; `[수정/재실행]` = 기존 분석 수정 또는 확정 스코어링으로 재계산; `[신규 보충]` = Nature Communications를 위해 새로 추가해야 할 분석 또는 패널.

### Figure 1 (Results 1): 문제 정의와 stORCA 개요

- **주장:** 조건 간 공간 발현 차이는 진짜 변화일 수도, 착시(개체 변이·대응 조직 부재)일 수도 있으며, stORCA는 이를 분리한다.

| 패널 | 내용 | 데이터 / 출처 | 상태 |
|---|---|---|---|
| `1a` | Toy 유전자 3종: global shift ($\mathrm{ROS} = 0$), amplitude 변화, pattern 변화 | Toy | `[신규 보충]` |
| `1b` | 두 가지 가짜 변화 thumbnail: (좌) 같은 조건 replicate 간 hotspot(HPOA `Oxt`); (우) 대응 없는 조직(Colitis D0 상피 소실 또는 Cortex 병변) | 실데이터 thumbnail | `[신규 보충]` |
| `1c` | stORCA 파이프라인 모식도: SysVI 임베딩, niche+cell cost 및 density-ratio partial OT, 대칭·안정화 공간 일치도($\mathrm{ROS}_\lambda^{\text{sym}}$ 채택 시 50회 랜덤 매칭과 다단계 `z_den` 필터 제거), thinning된 within vs between replicate `limma` | 모식도 (`01-storca-figure1-nov19.py`) | `[수정/재실행]` |
| `1d` | 유전자 1개 출력 요약: 효과 크기 $\Delta$와 call, $(\rho, \kappa)$ 분해 평면, 공간 residual map | 모식도 | `[유지]` / `[수정/재실행]` |
| `1e` | 기존 방법(CODA, STcompare, DESpace2, River, SpaceExpress) 대비 기능 비교 격자표 (STcompare `spatialSimilarity` 및 실제 1-vs-1 vs replicate 실행 여부 정확히 반영) | 방법 비교표 | `[신규 보충]` |

### Figure 2 (Results 2): 통제된 벤치마크 (Synthetic, Semi-Synthetic, Runtime)

- **주장:** stORCA는 패턴·진폭·국소 공간 변화를 모두 검출하고 전역 이동은 무시하는 반면, registration·domain·분류기 방법은 각기 다른 맹점을 가진다.
- **본문 제외:** `2d` (`3-BM-DSE-Scores`, 삭제), `2f2` (`HPOA swap`, Supplementary), `2e` (유형 검증, `Fig 5a`로 이동).

| 패널 | 내용 | 데이터 / 출처 | 상태 |
|---|---|---|---|
| `2a` | 동물 효과가 포함된 6개 설계 변화 유형 모식도 (`domain-de`, `domain-ct-de`, `within-shift`, `boundary-band`, `amplitude/svg-increase`, `ring-domain`) | Synthetic v2 (`3-BM-DSE-Scenario-v2`) | `[유지]` / `[수정/재실행]` |
| `2b` | 맹점 히트맵: 방법 × 6개 변화 유형 AUROC (3 vs 3, `strength = 1`), STcompare `correlation`과 `spatialSimilarity` 병기 | 수정된 Synthetic v2 | `[수정/재실행]` |
| `2c` | `strength = 0` null 보정: 방법별 FDR 0.05 위양성 호출 비율 | 수정된 Synthetic v2 | `[수정/재실행]` |
| `2d` | 실제 조직 기반 semi-synthetic (`LIBD DLPFC 3 vs 3` implant, **공정한 shared gene universe**): (좌) 5개 유형별 AUROC (`domain_de`, `within_shift`, `amplitude`, `relocation`, `pure_shift`); (우) global-shift decoy 분리도 (River는 decoy에 무너지고 stORCA는 분리함) | `1-BM-DSE-Semi-LIBD` (재평가) | `[수정/재실행]` |
| `2e` | 섹션당 2.5k~20k 세포 수에 따른 실행 시간 및 피크 RAM/GPU 비교 (**stORCA와 모든 경쟁 방법 함께 표시**) | `8-BM-Runtime` | `[신규 보충]` |

**Figure 2 필수 보충 사항:** (1) Synthetic v2 생성기 수정(배경/focal count 스케일 일치 + `01F~01K` Moran bin 수정) 및 Fix 1 / $\mathrm{ROS}_\lambda^{\text{sym}}$ 재실행; (2) LIBD 공정 shared gene universe 재평가 + SpaceExpress `FDR = 0` sentinel 수정 + STcompare `spatialSimilarity` 병기 + `same_donor` 처리; (3) `8-BM-Runtime`에 경쟁 방법 실행 시간·메모리 추가.

### Figure 3 (Results 3): 가짜 변화 1, 개체 간 Replicate 변이

- **주장:** 단일 쌍 검정은 replicate 변이를 조건 변화로 보고하지만, stORCA의 replicate 설계는 위양성을 보정한다.
- **Supplementary 이동:** Colitis D0 vs D3 (`29` true vs `26` false calls, 하위군집 이질성 진단 사례로 Supplementary 배치).

| 패널 | 내용 | 데이터 / 출처 | 상태 |
|---|---|---|---|
| `3a` | 단일 쌍 검정의 within-condition replicate 쌍 위양성 호출 비율 (실데이터 5~6종, 잘못된 STcompare $H_0: r=0$ 기각 실패 역전 제거) | 실데이터 (Q2) | `[수정/재실행]` |
| `3b` | 단일 쌍 순위의 replicate 오염: between 상위 20과 within 상위 20의 겹침 비율 (stORCA 공유 유전자 집합 기준) | 실데이터 (Q2) | `[수정/재실행]` |
| `3c` | Replicate 설계의 참 라벨 vs 모든 거짓 라벨(label-swap) 호출 수: LIBD null(donor 보정), HPOA, NRDR(pos/ant), ARTISTA | 실데이터 (대칭 ROS) | `[수정/재실행]` |
| `3d` | 2 × 2 ablation (단일 쌍 vs replicate 설계; 점수 vs 검정) 경쟁 방법 비교 (ARTISTA STcompare = 40 calls, River = 46 calls 정직하게 표기) | 실데이터 (`q2-four-comparisons.csv`) | `[수정/재실행]` |
| `3e` | 원인과 확장성: (좌) matching 분산 대비 replicate 분산 비 (5개 데이터셋, 26~155배); (우) replicate 수(2 vs 2, 3 vs 3)에 따른 LIBD implant 경험적 FDR 및 검정력 | 실데이터 + LIBD implant | `[유지]` / `[수정/재실행]` |
| `3f` | HPOA 대표 사례 지도: 경쟁사 위양성(`Blank_2`, `Oxt`) vs stORCA 진양성(`Cpne5`, 대칭 ROS에서도 안정적; River `Sema4d` 제거, `Gbx2` 문장 수정) | 실데이터 (HPOA) | `[수정/재실행]` |

**Figure 3 필수 보충 사항:** (1) 대칭 ROS($\mathrm{ROS}_\lambda^{\text{sym}}$)로 HPOA·NRDR·ARTISTA·LIBD 재실행해 HPOA 1/30 비대칭 해소; (2) LIBD 3 vs 3 donor 페어링 교란 해결(`same_donor` 공변량 또는 비페어링 null)로 nominal $p$ 분포 중심화; (3) STcompare `3a`·`3d` 서술 및 수치 정정.

### Figure 4 (Results 4): 가짜 변화 2, 대응 조직이 없는 영역

- **주장:** 대응 조직이 없는 영역이 registration과 domain 방법의 상위 목록을 채우지만, stORCA의 partial OT와 대칭 within-pair thinning은 이를 차단한다.
- **Supplementary 이동:** `4g` (synthetic rearrangement `08~12`, `10-domain-expansion` Fix 2를 $\mathrm{ROS}_\lambda^{\text{sym}}$ + `limma::treat`로 해결 후 Supplementary 수록).

| 패널 | 내용 | 데이터 / 출처 | 상태 |
|---|---|---|---|
| `4a` | 공간 retained-mass 지도: Cortex 3 dpi 병변(`r14`)과 Colitis D0 소실 상피가 어둡게 표시됨 | 실데이터 (Cortex, Colitis, Q1) | `[유지]` |
| `4b` | Cluster별 retained mass vs 조건 특이성 (`AUROC 0.89` Cortex, `0.94` Colitis D0; within pair `0.99`) | 실데이터 (Q1) | `[유지]` |
| `4c` | 각 방법 상위 20(및 상위 $k$) 중 대응 없는 조직 마커 비율: stORCA vs **CODA (`common_cells` 적용 포함)**, STcompare, DESpace2, pseudobulk DE, River | 실데이터 (Q1) | `[신규 보충]` |
| `4d` | Colitis 대표 사례: `Ptger3`(사라진 D0 상피, 경쟁사 상위 3위, stORCA 212위) vs `Flnc`, `Grem2`(양 시점 보존 근육층 변화) | 실데이터 (Colitis) | `[유지]` |
| `4e` | 2종 Ablation: (좌) Partial OT vs Balanced OT (강제 매칭); (우) thinning 없음 vs control만 vs 양쪽 thinning (Cortex, Colitis, HPOA) | 실데이터 (Q1) | `[신규 보충]` |
| `4f` | Registration 실패 메커니즘: Colitis D0 vs D9 9개 쌍에서 CODA/STcompare가 사라진 상피를 다른 D9 조직 위에 겹쳐 `Ptger3` 음의 상관을 만드는 과정 | 실데이터 (Colitis, Q1 7c) | `[수정/재실행]` (작도) |

**Figure 4 필수 보충 사항:** (1) `*-align.pkl`에 이미 저장된 `common_cells`로 `colitisq1`·`cortexor`에서 CODA 재스코어링; (2) Balanced OT vs Partial OT ablation 추가; (3) `4e`, `4f` 작도.

### Figure 5 (Results 5): 변화 유형 분해와 DE 너머의 생물학적 발견

- **주장:** stORCA는 변화를 pattern·amplitude·mixed로 정확히 분해하고 변화 위치를 지목하며, pseudobulk DE와 domain 검정이 놓치는 생물학적 공간 변화를 찾아낸다.

| 패널 | 내용 | 데이터 / 출처 | 상태 |
|---|---|---|---|
| `5a` | Ground-truth 유형 검증 (기존 Fig 2e 이동): $(\rho, \kappa)$ 평면 위의 pattern·amplitude 설계 유전자 배치 및 confusion matrix (`interpret.py` `rho > 1` 버그 수정 후) | 수정된 Synthetic v2 | `[신규 보충]` |
| `5b` | 실데이터(ARTISTA, NRDR, HPOA) 전체 호출의 $(\rho, \kappa)$ 평면과 유형 비율 (`rho > 1` 수정 및 대칭 ROS 반영) | 실데이터 (Q5) | `[수정/재실행]` |
| `5c` | DESpace2 및 global/domain pseudobulk DE와의 벤다이어그램 (ARTISTA 모두 미검출 29개, NRDR layer 19개) + non-DE 호출의 pattern/amplitude 유형 분할 (Q3 x Q5 join) | 실데이터 (ARTISTA, NRDR) | `[신규 보충]` |
| `5d` | 유형 대표 사례 및 residual map (ARTISTA `CDKN1B` amplitude, `FABP7` pattern) + **정량적 국소화("where") 지표** (도메인/니치 residual 농축도 및 pair 간 일관성) | 실데이터 (ARTISTA) | `[신규 보충]` |
| `5e` | 시각적으로 검증되는 non-DE 공간 재구성 사례: NRDR 4 vs 4에서 이동한 L2/3-L4 경계 유전자 또는 ARTISTA/HPOA에서 지도상 명확한 non-DE 패턴 유전자 (`Prkca`/`Trpc3`는 4 vs 4에서 layer DE이므로 과장 금지) | 실데이터 (NRDR / ARTISTA) | `[신규 보충]` |
| `5f` | 외부 생물학적 검증: NRDR dark-reared V1 activity 유전자 방향 일치 (`7/7` $\ell > 0$, `11/11` pseudobulk 부호 일치) + Xie et al. 2025 Dataset S1(`L2/3B/C`) 교차 대조 | 실데이터 (NRDR) | `[신규 보충]` |

**Figure 5 필수 보충 사항:** (1) `storca/interpret.py:66-70` (`rho > 1` 및 `one_side_constant` 버그) 수정; (2) ground-truth 유형 검증 (`5a`); (3) Q3 x Q5 join (`5c`) 및 정량적 국소화 지표 (`5d`); (4) NRDR L2/3-L4 경계 이동 및 Xie et al. Dataset S1 검증 (`5e`, `5f`).

---

## 2. Supplementary Figures 구성안

| Supp Fig | 내용 | 현재 상태 |
|---|---|---|
| **S1** | 민감도 및 안정성: `9-BM-Sensitivity` (HPOA 12종 파라미터 변형), 5-seed SysVI 안정성 (`Q-E5`), SysVI loss 수렴 곡선, forward vs reverse 대칭화 검증 (`Q-S7`) | 12종 민감도 완료; 5-seed·loss·대칭화 보충 |
| **S2** | 강건성 대조군: gene-holdout embedding circularity 검증 (`Q-E6`, HPOA/NRDR 및 `04-within-domain-shift`) + blind per-labeling thinning 체크 (`Q-I4`, HPOA/LIBD) | `[신규 보충]` |
| **S3** | Synthetic rearrangement `08~12` ($\mathrm{ROS}_\lambda^{\text{sym}}$ + `limma::treat`로 `10-domain-expansion` Fix 2 해결 포함) + 하위군집 이질성 진단 사례 (LIBD 6 vs 6, Colitis D0 vs D3) | `[수정/재실행]` |
| **S4** | 1 vs 1 탐색 모드 (gene-bulk / split-half 순위 보정), `limma` 보정 시뮬레이션, Python vs R `limma` 수치 일치 검증 | 대부분 완료 |
| **S5** | *(선택)* ARTISTA 재생 시간축 탐색 분석 (기존 Fig 6, depth-matched downsampling 포함 시에만 수록) + NRDR 4 vs 4 재현 | 선택; depth downsampling 필요 |

---

## 3. 권장 실행 순서

1. **스코어링 동결 및 핵심 코드 버그 수정 우선:** HPOA, NRDR, LIBD, ARTISTA, Colitis Q1에서 $\mathrm{ROS}_\lambda^{\text{sym}}$ (`lam = 0.03, 0.05`) + 균형 3-column `limma::treat`를 검증하고 `storca/` 버그 6건(`interpret.py` `rho > 1` 포함)을 수정한다. 이 단계가 끝나면 Figures 1~5가 동시에 열린다.
2. **벤치마크 수리 및 공정 경쟁사 비교:** Synthetic v2 수정(`2a~c`, `5a`, `S3`), LIBD 공정 재평가(`2d`, `3c`, `3e`), CODA `common_cells` 재스코어링(`4c`), `8-BM-Runtime` 경쟁사 추가(`2e`).
3. **Claim 4 생물학 및 Supplementary 대조군 완료:** Q3 x Q5 join, 정량적 국소화, NRDR L2/3-L4 / Xie et al. Dataset S1 (`5c~f`) 및 `Q-E5`, `Q-E6`, `Q-I4` (`S1`, `S2`).
4. **최종 그림 일괄 작도 및 `storca/` 패키지화:** `1a~e`, `4e`, `4f` 작도 후 `0-paper-outline-natcomm.md`, `0-method-v1.md`, Q1~Q5 리포트를 최종 확정 수치로 동기화한다.
