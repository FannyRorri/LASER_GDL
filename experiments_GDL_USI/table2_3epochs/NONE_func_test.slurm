#!/bin/bash
#SBATCH -J NONE_func
#SBATCH --partition=gpu
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --time=01:30:00
#SBATCH --mem=12G
#SBATCH --array=0-3
#SBATCH --output=NONE_func_%A_%a.out
#SBATCH --error=NONE_func_%A_%a.err

source ~/miniconda/etc/profile.d/conda.sh
conda activate laser

cd /home/bosshf/LASER_GDL

SEED=$SLURM_ARRAY_TASK_ID

echo "Running NONE baseline: Peptides-func, seed=$SEED"
python main.py --cfg configs/GCN/peptides-func-GCN.yaml wandb.use False seed $SEED optim.max_epoch 3
