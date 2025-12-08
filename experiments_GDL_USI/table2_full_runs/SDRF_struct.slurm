#!/bin/bash
#SBATCH -J SDRF_struct
#SBATCH --partition=gpu
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --time=03:00:00
#SBATCH --mem=20G
#SBATCH --array=0-3
#SBATCH --output=SDRF_struct_%A_%a.out
#SBATCH --error=SDRF_struct_%A_%a.err

source ~/miniconda/etc/profile.d/conda.sh
conda activate laser

cd /home/bosshf/LASER_GDL

SEED=$SLURM_ARRAY_TASK_ID

echo "Running SDRF: Peptides-struct, seed=$SEED"
python main.py --cfg configs/Peptides-baselines/SDRF/peptides-struct-GCN.yaml wandb.use False seed $SEED
