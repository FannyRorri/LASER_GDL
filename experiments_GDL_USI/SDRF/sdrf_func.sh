#!/bin/bash
#SBATCH -J SDRF_func
#SBATCH --partition=gpu
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --time=02:00:00
#SBATCH --mem=16G
#SBATCH --output=sdrf_func_%j.out
#SBATCH --error=sdrf_func_%j.err

source ~/miniconda3/etc/profile.d/conda.sh
conda activate laser

echo "Running SDRF: Peptides-func"
python main.py --cfg configs/Peptides-baselines/SDRF/peptides-func-GCN.yaml wandb.use False
