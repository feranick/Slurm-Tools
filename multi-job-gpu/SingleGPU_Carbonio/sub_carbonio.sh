#!/bin/bash
#============================================================
# SLURM submit script for DataML_DAE jobs on "carbonio"
# 12 CPUs, ~38 GB RAM, 1x GTX 1080 Ti (11 GB, Pascal), GPU shared via MPS.
#
# Sizing from a measured job (~1.7 GB RES, ~1.2 cores active, multi-worker):
#   --cpus-per-task=2  -> covers the active cores, no core contention
#   --mem=2500M        -> above peak RES so cgroup won't OOM-kill it
#   Concurrency: 12 CPUs / 2 = ~6 jobs at once (CPU-limited)
#   --gres=mps:16      -> 100/16 ~= 6 GPU slices; GPU is not the bottleneck
#============================================================

#SBATCH --job-name=DAE
#SBATCH --partition=long
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --gres=mps:16
#SBATCH --mem=2500M
#SBATCH --time=100:00:00
#SBATCH --output=log_%x.o%j
#SBATCH --error=log_%x.e%j
#SBATCH --export=ALL

set -euo pipefail

# Keep math/DL libraries within the allocated cores.
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export MKL_NUM_THREADS=$SLURM_CPUS_PER_TASK

echo "Job $SLURM_JOB_ID on $(hostname)"
echo "CUDA_VISIBLE_DEVICES=${CUDA_VISIBLE_DEVICES:-unset}"
nvidia-smi --query-gpu=index,memory.used,utilization.gpu --format=csv || true

echo "DataML_DAE -a $1"
DataML_DAE -a "$1"

echo "Done."
