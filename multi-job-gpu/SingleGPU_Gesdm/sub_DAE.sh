#!/bin/bash
#============================================================
# Template SLURM submit script for small GPU jobs on "GridEdgeDM" (gesdm)
# 1x RTX 3050 (Ampere), GPU shared via MPS.
#
# Sizing rationale (small jobs, ~2% sm, ~444 MiB VRAM each):
#   - mps:12 => 100/12 ~= 8 jobs on the single GPU, matching the 8 CPUs
#   - Ampere MPS isolates client memory (up to 48 clients) - no low cap
#   - VRAM check: 8 x ~0.45 GB ~= 3.6 GB  (fits an 8 GB card; even a 4 GB
#     mobile 3050 has margin) -- verify your card's size with nvidia-smi
#   - Real ceiling is CPUs (8) and host RAM (~22 GB): tune the two below.
#============================================================

#SBATCH --job-name=DAE
#SBATCH --partition=long
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1          # raise only if your code is multithreaded
#SBATCH --gres=mps:12             # ~12% of the GPU; ~8 jobs share it
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
