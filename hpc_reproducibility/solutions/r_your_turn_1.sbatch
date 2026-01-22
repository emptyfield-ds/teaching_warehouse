#!/bin/bash
#SBATCH --job-name=sim_pt_r
#SBATCH --partition=sherrir,normal
#SBATCH --output=logs/%x_%a.out
#SBATCH --error=logs/%x_%a.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=4G
#SBATCH --time=00:10:00
#SBATCH --array=0-5

echo "Job started on $(hostname) at $(date)"
echo "Processing Task ID: $SLURM_ARRAY_TASK_ID"

# load the most recent version of R available
ml R

# Run the script, passing the Task ID (Dose) and CPU count
Rscript R/sim_pt.R $SLURM_ARRAY_TASK_ID $SLURM_CPUS_PER_TASK

echo "Job finished at $(date)"
