#!/bin/bash
#SBATCH -J NONE_func
#SBATCH --partition=gpu
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --time=01:30:00
#SBATCH --mem=12G
#SBATCH --output=none_func_%j.out
#SBATCH --error=none_func_%j.err

source ~/miniconda/etc/profile.d/conda.sh
conda activate laser

cd /home/bosshf/LASER_GDL

echo "Running NONE baseline: Peptides-func"
python main.py --cfg configs/GCN/peptides-func-GCN.yaml wandb.use False optim.max_epoch 3
