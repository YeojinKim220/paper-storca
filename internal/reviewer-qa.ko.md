# Reviewer Q&A

## Figure 2: cortex implant (DLPFC)

| 리뷰어가 말할 수 있는 것 | 답 | 근거 |
|---|---|---|
| 이식한 유전자 40개 중 7개(MAN1A2, GLUL, NCL, HLA-C, NCOR1, H3F3B, FTL)는 layer enrichment가 q < 0.05여서, layer 구조가 없다고 할 수 없다. | 선택 규칙은 효과 크기, 즉 모든 layer에서 log2 fold change 절댓값 0.5 미만이고, 이 7개는 모두 0.49 이하입니다. 이식한 기본 패턴은 log2로 1.44, 가장 약한 변화(s = 0.5)는 0.72이므로, 기존 차이는 이식한 크기에 비해 작습니다. | DLPFC 이식 정답 표 (`max_abs_log2fc`, `min_q`); 보충 방법 S2.5 |
| DESpace2는 이식 영역을 정의한 바로 그 수동 layer label을 받는다. | DESpace2는 domain label이 필요하고, 실제로 받게 될 label로 발표된 방식대로 돌렸습니다. 이것은 DESpace2에 유리하므로, layer DE와 amplitude 결과는 domain 검정의 상한입니다. within shift는 layer 5 안에 머물고 layer 평균을 유지하므로, 정답 label이 거기서는 도움이 되지 않습니다. | 보충 방법 S2.6, S2.8 |
| DESpace2 로그에 일부 유전자의 BiocParallel 오류(`NA/NaN/Inf in foreign function call`)가 있다. | 이 section들에서 DESpace2를 기본 설정으로 돌리면 생기는 오류이며, 이전 cortex 실행에서도 동일하게 나타납니다. fit이 실패한 유전자는 점수가 없어 DESpace2 지표에서 빠지고, 모든 실행은 끝까지 완료됐습니다. | Implant 실행 워커 로그 |
| within shift 유전자 IGKC는 plasma cell 때문에 발현이 패치 모양이라, 지도가 깨끗한 layer 띠로 보이지 않는다. | IGKC는 눈으로 고른 것이 아니라 정한 규칙(평균 count가 가장 높은 패턴 없는 유전자 10개 중 하나)으로 뽑혔습니다. 패치는 두 조건 모두에 있고, implant는 layer 5 count를 얕은 절반에서 깊은 절반으로 옮길 뿐이라 패치를 바꾸지 않습니다. | DLPFC 이식 유전자 사례 지도 점검 |
| STcompare가 이전 버전 benchmark에서 계산한 STalign 변환을 재사용한다. | STalign 단계는 좌표만 쓰고, implant는 count만 바꾸고 spot은 바꾸지 않습니다. 여섯 section 모두에서 spot 이름, 좌표, spot 수가 그 변환의 입력과 같은지 확인했습니다. | 절편 기하 정합 점검; 보충 방법 S2.6 |
| decoy(global shift)를 패턴 없는 유전자에서만 뽑았다. layer 패턴이 있는 유전자에서는 균일한 배수 변화가 stORCA의 log1p centering으로 정확히 지워지지 않아 cortex benchmark가 약점을 가릴 수 있다. | global shift가 순수한 수준 변화가 되고 layer 구조는 이식한 것뿐이도록 패턴 없는 유전자를 썼습니다. 패턴이 있는 decoy는 모든 decoy가 domain marker인 simulated benchmark에서 직접 검정했으며, s = 1일 때 stORCA는 decoy 대비 AUROC 0.94(상위 15위 내 미끼 0.5개)를 기록한 반면 River와 STcompare percent similarity는 0.00이었습니다. | 시뮬레이션 벤치마크 요약; 보충 방법 S2.2, S2.4 |

## 통계 설계와 ROS 성질

| 리뷰어가 말할 수 있는 것 | 답 | 근거 |
|---|---|---|
| ROS의 `[0, 2]` 클리핑과 `Moran > 0.03` 사전 필터링은 임의적이지 않은가. | 대각선 0인 Moran 연산자는 세포 수준 산탄 잡음을 제거하는 대신 비정부호이므로 경계 클리핑이 필요합니다. 자연 유계인 양의 준정부호 연산자($W^\top W$)를 직접 비교하면 산탄 잡음이 유입되어 HPOA(`11 -> 0`)와 NRDR(`32 -> 0`) 호출이 모두 소실됩니다. `Moran > 0.03`은 조건 라벨을 쓰지 않는 표준 독립 필터링(Bourgon et al. 2010)이며, 클리핑은 기존 호출의 94~100%를 보존합니다. | 대각 0 연산자 vs $W^\top W$ 비교 검증 (Methods) |
| 정방향(`A -> B`)과 역방향(`B -> A`)의 호출 유전자가 왜 다른가 (예: HPOA). | 비정합 연성 수송에서 타겟 발현을 참조 그래프에 투영하면 내재적 감쇠($\alpha^2 < 1$)가 발생하므로, `A -> B`는 $A$ 패턴의 소실(`naive > aggr`, 11/11개)을, `B -> A`는 $B$에서 새로 생기는 패턴(`aggr > naive`, 17/20개)을 각각 검정합니다. 양방향 모두 귀무 보정(`null_max = 0`)이 유지되며 양방향 결합 옵션도 제공됩니다. | HPOA 방향별 호출 분석 (Methods) |
| 3 vs 3 반복 설계는 치환 경우의 수가 적고 쌍들이 서로 독립이 아니다. | 3 vs 3은 공간 전사체 코호트 표준 설계이며, 2 vs 2 · 3 vs 3 · 6 vs 6 확장 곡선과 4~6개 독립 데이터셋의 일관된 결과로 보완합니다. 주 유의성 판정은 경험적 베이즈 limma로 수행하고, 전체 절편 라벨 치환에서 쌍 간 비독립성으로 인한 위양성 팽창이 없음을 확인했습니다(LIBD, HPOA, NRDR 모두 0건). | 전 코호트 라벨 치환 진단 (Methods) |
| Cortex 3 dpi에서는 CODA와 stORCA의 lesion-only 마커 비율 차이가 작다. | Cortex에서는 반응성 교세포 유전자가 병변 밖 공유 조직에서도 실제로 상승하기 때문이며(`shared` 마커), 상피 구획 전체가 소실되는 Colitis D0 vs D9에서는 등록/도메인 경쟁 방법들의 상위 목록이 미대응 상피 마커로 채워지는 메커니즘이 9개 모든 쌍에서 확인됩니다. | 교차 연구 마커 비교 (Fig. 4) |

## 코호트 설정과 강건성

| 리뷰어가 말할 수 있는 것 | 답 | 근거 |
|---|---|---|
| Partial OT의 dummy cell이 타겟에 새 조직이 생길 때 정상 소스 세포를 일부 제외할 수 있다. | 강제 왜곡 없이 공유 질량 $\min(\sum a_i, \sum b_j)$을 맞추는 partial OT의 성질입니다. stORCA는 세포별 유지 비율 $r_i$와 공간 지도를 함께 보고해 제외 영역을 투명하게 확인할 수 있게 합니다. | Partial OT 유지 비율 진단 (Fig. 4; Methods) |
| SysVI 하이퍼파라미터(`vamp` prior, `kl_weight = 1`, `z_distance_cycle_weight = 5`)가 데이터셋에 튜닝된 것 아닌가. | `prior = "vamp"`는 scvi-tools 기본값이고 `kl_weight = 1, z_distance_cycle_weight = 5`는 공식 scvi-tools SysVI 튜토리얼 설정 그대로이며 모든 데이터셋에 동일하게 적용했습니다. | 공통 SysVI 설정 (Methods) |
| 동일한 thinning 시드와 50회 확률적 매칭이 몬테카를로 변동을 만들지 않는가. | 매칭 시드 간 재표본 분산은 생물학적 반복 변이보다 26~155배 작아(Fig. 3), 샘플링 시드가 최종 limma 호출에 미치는 영향은 무시할 수준입니다. | 매칭 시드 안정성 벤치마크 (Fig. 3) |
| 시간축 분석 코호트가 본문 두 조건 비교 주장에서 빠져 있다. | 시간축에서는 시퀀싱 깊이가 2~3배 변동하고 형태 변화에서 효과 크기가 비단조적일 수 있어, 본문은 잘 정의된 두 조건 비교에 집중했습니다. | 시간축 코호트 범위 평가 |
