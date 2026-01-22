#!/bin/bash
#SBATCH --job-name=positivity_py
#SBATCH --partition=sherrir,normal
#SBATCH --output=logs/%x_%a.out
#SBATCH --error=logs/%x_%a.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=4G
#SBATCH --time=00:10:00
#SBATCH --array=____

GAMMAS=(0.5 2.0 5.0)
CURRENT_GAMMA=${GAMMAS[$SLURM_ARRAY_TASK_ID]}

echo "Job started on $(hostname) at $(date)"
echo "Task: $SLURM_ARRAY_TASK_ID | Gamma: $CURRENT_GAMMA"

ml python/3.14
ml py-numpy/2.3.5_py314

python3 python/sim_positivity.py \
    --sims 10000 \
    --subjects 1000 \
    --gamma $CURRENT_GAMMA \
    --out "results/sim_positivity_py_${SLURM_ARRAY_TASK_ID}.csv"

echo "Task $SLURM_ARRAY_TASK_ID complete at $(date)"
