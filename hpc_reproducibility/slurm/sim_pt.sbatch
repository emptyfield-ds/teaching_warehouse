#!/bin/bash
#SBATCH --job-name=_______
#SBATCH --partition=_______
#SBATCH --output=_______
#SBATCH --error=_______
#SBATCH --nodes=_______
#SBATCH --ntasks=_______
#SBATCH --cpus-per-task=_______
#SBATCH --mem=_______
#SBATCH --time=_______
#SBATCH --array=_______

echo "Job started on $(hostname) at $(date)"
echo "Processing Task ID: $SLURM_ARRAY_TASK_ID"

# load the most recent version of python or R available

# run the script, passing the Task ID (Dose) and CPU count

echo "Job finished at $(date)"
