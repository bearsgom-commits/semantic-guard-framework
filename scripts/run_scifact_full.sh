#!/usr/bin/env bash
set -euo pipefail

#############################################
# Stage: 3단계 – scifact 정식 실험 (고정판)
# matrix:
#   seeds = {7,13,42}
#   eps   = {0,2,4,8,16,32,64}
# policy:
#   - 안정성 우선: CPU 고정(필요 시 나중에 mps/cuda로 확장)
#   - per-run 결과 덮어쓰기 방지
# outputs:
#   runs/scifact/seed{seed}/retrieval/metrics_eps{eps}.csv
#############################################

LOCAL_ROOT="/Users/kimdoyeon/Downloads/research/semantic-guard"
REPO_DIR="${LOCAL_ROOT}/repo"
BEIR_ROOT="${LOCAL_ROOT}/private_data/beir"
ARTIFACTS_ROOT="${LOCAL_ROOT}/artifacts"
RUNS_ROOT="${LOCAL_ROOT}/runs"

DATASET="scifact"
DEVICE="cpu"

DOC_LIMIT=5000
QUERY_LIMIT=200

SEEDS=(7 13 42)
EPS_LIST=(0 2 4 8 16 32 64)

echo "========================================="
echo "[SCIFACT FULL RUN START]"
echo "Dataset : ${DATASET}"
echo "Seeds   : ${SEEDS[*]}"
echo "EpsList : ${EPS_LIST[*]}"
echo "Device  : ${DEVICE}"
echo "========================================="

cd "${REPO_DIR}"

# 안정성(스레드/BLAS)
export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1
export VECLIB_MAXIMUM_THREADS=1

# 의존성 체크
python - <<'PY'
import torch, numpy, transformers
print("✓ Core deps OK")
PY

for SEED in "${SEEDS[@]}"; do
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

    METRIC_DIR="${RUNS_ROOT}/scifact/seed${SEED}/retrieval"
    # smoke_scifact는 metrics_smoke.csv로 저장하므로, eps별로 복사해서 보관
    if [[ -f "${METRIC_DIR}/metrics_smoke.csv" ]]; then
      cp "${METRIC_DIR}/metrics_smoke.csv" "${METRIC_DIR}/metrics_eps${EPS}.csv"
      echo "[OK] saved -> ${METRIC_DIR}/metrics_eps${EPS}.csv"
    else
      echo "[ERR] missing metrics_smoke.csv at ${METRIC_DIR}"
      exit 1
    fi
  done
done

echo "========================================="
echo "[SCIFACT FULL RUN DONE]"
echo "Check results under:"
echo "${RUNS_ROOT}/scifact/"
echo "========================================="