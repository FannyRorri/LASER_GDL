#!/bin/bash
#SBATCH -J FoSR_struct
#SBATCH --partition=gpu
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --time=03:00:00
#SBATCH --mem=20G
#SBATCH --output=fosr_struct_%j.out
#SBATCH --error=fosr_struct_%j.err

source ~/miniconda3/etc/profile.d/conda.sh
conda activate laser

echo "Running FoSR: Peptides-struct"
python main.py --cfg configs/Peptides-baselines/FOSR/peptides-struct-GCN.yaml wandb.use False
