#!/bin/bash
#SBATCH -J FoSR_func
#SBATCH --partition=gpu
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --time=02:00:00
#SBATCH --mem=16G
#SBATCH --output=fosr_func_%j.out
#SBATCH --error=fosr_func_%j.err

source ~/miniconda3/etc/profile.d/conda.sh
conda activate laser

echo "Running FoSR: Peptides-func"
python main.py --cfg configs/Peptides-baselines/FOSR/peptides-func-GCN.yaml wandb.use False
