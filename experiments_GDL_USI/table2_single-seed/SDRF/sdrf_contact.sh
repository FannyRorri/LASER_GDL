#!/bin/bash
#SBATCH -J SDRF_contact
#SBATCH --partition=gpu
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --time=08:00:00
#SBATCH --mem=32G
#SBATCH --output=sdrf_contact_%j.out
#SBATCH --error=sdrf_contact_%j.err

source ~/miniconda3/etc/profile.d/conda.sh
conda activate laser

echo "Running SDRF: PCQM-Contact"
python main.py --cfg configs/Contact-baselines/pcqm-contact-GCN-sdrf.yaml wandb.use False
