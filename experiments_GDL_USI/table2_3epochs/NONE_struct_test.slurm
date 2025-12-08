#!/bin/bash
#SBATCH -J NONE_struct
#SBATCH --partition=gpu
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --time=02:30:00
#SBATCH --mem=16G
#SBATCH --array=0-3
#SBATCH --output=NONE_struct_%A_%a.out
#SBATCH --error=NONE_struct_%A_%a.err

source ~/miniconda/etc/profile.d/conda.sh
conda activate laser

cd /home/bosshf/LASER_GDL

SEED=$SLURM_ARRAY_TASK_ID

echo "Running NONE baseline: Peptides-struct, seed=$SEED"
python main.py --cfg configs/GCN/peptides-struct-GCN.yaml wandb.use False seed $SEED optim.max_epoch 3 \
    out_dir results/table2/NONE_struct
