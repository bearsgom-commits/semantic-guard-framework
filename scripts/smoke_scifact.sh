#!/usr/bin/env bash
set -euo pipefail

#############################################
# Stage: 2단계 – scifact smoke test (고정판)
# 목적:
#   1) end-to-end 파이프라인 검증
#   2) eps 변화에도 동일하게 완주하는지 확인
# 정책:
#   - smoke는 안정성 우선: CPU 강제
#   - eps별 결과 덮어쓰기 방지(별도 파일로 보관)
#############################################

# ====== 로컬 루트 경로 ======
LOCAL_ROOT="/Users/kimdoyeon/Downloads/research/semantic-guard"
REPO_DIR="${LOCAL_ROOT}/repo"
BEIR_ROOT="${LOCAL_ROOT}/private_data/beir"
ARTIFACTS_ROOT="${LOCAL_ROOT}/artifacts"
RUNS_ROOT="${LOCAL_ROOT}/runs"

DATASET="scifact"
SEED=7

# ✅ smoke eps 2개로 고정(최소 검증 세트)
EPS_LIST=(0 16)

# ✅ smoke는 CPU 고정 (MPS segfault 회피)
DEVICE="cpu"

# ✅ 스모크 샘플 크기 (빠르게)
DOC_LIMIT=5000
QUERY_LIMIT=200

echo "========================================="
echo "[SMOKE TEST START]"
echo "Dataset : ${DATASET}"
echo "Seed    : ${SEED}"
echo "EpsList : ${EPS_LIST[*]}"
echo "Device  : ${DEVICE}"
echo "========================================="

cd "${REPO_DIR}"

# ====== 의존성 간단 체크 ======
echo "[1] Dependency check..."
python - <<'PY'
import torch, numpy, transformers
print("✓ Core deps OK")
PY

# ====== 실행 ======
echo "[2] Running smoke pipeline..."

# 스레드/BLAS 이슈 예방(선택이지만 안정적)
export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1
export VECLIB_MAXIMUM_THREADS=1

for EPS in "${EPS_LIST[@]}"; do
  echo "-----------------------------------------"
  echo "[RUN] dataset=${DATASET} seed=${SEED} eps=${EPS} device=${DEVICE}"
  echo "-----------------------------------------"

  python -X faulthandler -m src.smoke_scifact \
      --beir_root "${BEIR_ROOT}" \
      --artifacts_root "${ARTIFACTS_ROOT}" \
      --runs_root "${RUNS_ROOT}" \
      --seed "${SEED}" \
      --eps "${EPS}" \
      --doc_limit "${DOC_LIMIT}" \
      --query_limit "${QUERY_LIMIT}" \
      --device "${DEVICE}"

  # ✅ metrics_smoke.csv 덮어쓰기 방지: eps별로 보관
  METRIC_DIR="${RUNS_ROOT}/scifact/seed${SEED}/retrieval"
  if [[ -f "${METRIC_DIR}/metrics_smoke.csv" ]]; then
    cp "${METRIC_DIR}/metrics_smoke.csv" "${METRIC_DIR}/metrics_smoke_eps${EPS}.csv"
    echo "[OK] copied -> ${METRIC_DIR}/metrics_smoke_eps${EPS}.csv"
  fi
done

echo "========================================="
echo "[SMOKE TEST DONE]"
echo "Check metrics at:"
echo "${RUNS_ROOT}/scifact/seed${SEED}/retrieval/metrics_smoke_eps0.csv"
echo "${RUNS_ROOT}/scifact/seed${SEED}/retrieval/metrics_smoke_eps16.csv"
echo "========================================="