#!/bin/bash
#SBATCH -J FOSR_func
#SBATCH --partition=gpu
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --time=02:00:00
#SBATCH --mem=16G
#SBATCH --array=0-3
#SBATCH --output=FOSR_func_%A_%a.out
#SBATCH --error=FOSR_func_%A_%a.err

source ~/miniconda/etc/profile.d/conda.sh
conda activate laser

cd /home/bosshf/LASER_GDL

SEED=$SLURM_ARRAY_TASK_ID

echo "Running FOSR: Peptides-func, seed=$SEED"
python main.py --cfg configs/Peptides-baselines/FOSR/peptides-func-GCN.yaml wandb.use False seed $SEED
