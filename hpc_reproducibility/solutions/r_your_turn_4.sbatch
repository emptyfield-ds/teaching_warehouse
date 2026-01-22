#!/bin/bash
#SBATCH --job-name=positivity_r_container
#SBATCH --partition=sherrir,normal
#SBATCH --output=logs/%x_%a.out
#SBATCH --error=logs/%x_%a.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=4G
#SBATCH --time=00:10:00
#SBATCH --array=0-2

# ==============================================================================
# Run once before submitting the job
# ==============================================================================
# 1. Build the Container
#    $ apptainer build container_r.sif container_r.def
# ==============================================================================

GAMMAS=(0.5 2.0 5.0)
CURRENT_GAMMA=${GAMMAS[$SLURM_ARRAY_TASK_ID]}

echo "Job started on $(hostname) at $(date)"
echo "Task: $SLURM_ARRAY_TASK_ID | Gamma: $CURRENT_GAMMA"

apptainer exec container_r.sif \
    Rscript R/sim_positivity.R \
    --sims 10000 \
    --subjects 1000 \
    --gamma $CURRENT_GAMMA \
    --out "results/container_r_${SLURM_ARRAY_TASK_ID}.csv"

echo "Task $SLURM_ARRAY_TASK_ID complete at $(date)"
