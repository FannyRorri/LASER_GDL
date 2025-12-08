#!/bin/bash
#SBATCH -J LASER_all
#SBATCH --partition=debug-gpu
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --time=03:00:00
#SBATCH --mem=15G
#SBATCH --output=laser_func_%j.out
#SBATCH --error=laser_func_%j.err

# Load conda
source ~/miniconda3/etc/profile.d/conda.sh
conda activate laser

echo "===================="
echo "Running LASER: Peptides-func"
echo "===================="

python main.py --cfg configs/Peptides-laserglobal/peptides-func-GCN-laserglobal.yaml wandb.use False

