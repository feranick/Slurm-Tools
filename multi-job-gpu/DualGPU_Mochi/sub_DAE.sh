#!/bin/bash
#============================================================
# Template SLURM submit script for small GPU jobs on "mochi"
# 2x Quadro RTX 6000, GPU shared via MPS.
#
# Sizing rationale (from measured usage):
#   - GPU compute per job : ~2%  -> request mps:5 (5% slice, generous)
#   - GPU memory per job   : ~444 MiB on a 24 GB card -> not a limit
#   - mps:5  => 100/5 = 20 jobs per GPU, 40 across both cards
#   - The real ceiling is CPUs (40) and host RAM (60 GB), so tune
#     --cpus-per-task and --mem to control how many jobs pack in.
#============================================================

#SBATCH --job-name=DAE
#SBATCH --partition=long
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1          # raise only if your code is multithreaded
#SBATCH --gres=mps:5              # 5% of one GPU; ~20 jobs share a card
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
