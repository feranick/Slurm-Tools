#!/bin/bash
#============================================================
# Template SLURM submit script for small GPU jobs on "carbonio"
# 1x GTX 1080 Ti (11 GB, Pascal), GPU shared via MPS.
#
# Sizing rationale (small jobs, ~2% sm, ~444 MiB VRAM each):
#   - mps:8  => 100/8 ~= 12 jobs on the single GPU
#   - 12 jobs matches the 12 CPUs and stays under Pascal's 16-client MPS cap
#   - VRAM check: 12 x ~0.45 GB ~= 5.4 GB < 11 GB  (OK)
#   - Real ceiling is CPUs (12) and host RAM (~38 GB): tune the two below.
#============================================================

#SBATCH --job-name=DAE
#SBATCH --partition=long
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1          # raise only if your code is multithreaded
#SBATCH --gres=mps:8              # ~8% of the GPU; ~12 jobs share it
#SBATCH --mem=1500M               # host RAM; set from measured MaxRSS + margin
#SBATCH --time=4-04:00:00
#SBATCH --output=log_%x.o%j
#SBATCH --error=log_%x.e%j

set -euo pipefail

echo "Job $SLURM_JOB_ID on $(hostname)"
echo "Assigned GPU/MPS: CUDA_VISIBLE_DEVICES=${CUDA_VISIBLE_DEVICES:-unset}"
nvidia-smi --query-gpu=index,memory.used,utilization.gpu --format=csv || true

# ---- your workload below ----
# e.g.:
# python train.py --config myconfig.yaml
# ------------------------------

echo "Done."
