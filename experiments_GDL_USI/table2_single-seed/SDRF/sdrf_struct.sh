#!/bin/bash
#SBATCH -J SDRF_struct
#SBATCH --partition=debug-gpu
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --time=03:00:00
#SBATCH --mem=20G
#SBATCH --output=sdrf_struct_%j.out
#SBATCH --error=sdrf_struct_%j.err

source ~/miniconda3/etc/profile.d/conda.sh
conda activate laser

echo "Running SDRF: Peptides-struct"
python main.py --cfg configs/Peptides-baselines/SDRF/peptides-struct-GCN.yaml wandb.use False
