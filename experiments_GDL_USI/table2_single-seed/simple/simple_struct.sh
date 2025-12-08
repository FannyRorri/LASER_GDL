#!/bin/bash
#SBATCH -J NONE_struct
#SBATCH --partition=gpu
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --time=02:30:00
#SBATCH --mem=16G
#SBATCH --output=none_struct_%j.out
#SBATCH --error=none_struct_%j.err

source ~/miniconda3/etc/profile.d/conda.sh
conda activate laser

echo "Running NONE baseline: Peptides-struct"
python main.py --cfg configs/GCN/peptides-struct-GCN.yaml wandb.use False
