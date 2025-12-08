#!/bin/bash
#SBATCH -J NONE_contact
#SBATCH --partition=gpu
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --time=06:00:00
#SBATCH --mem=28G
#SBATCH --output=none_contact_%j.out
#SBATCH --error=none_contact_%j.err

source ~/miniconda3/etc/profile.d/conda.sh
conda activate laser

echo "Running NONE baseline: PCQM-Contact"
python main.py --cfg configs/GCN/pcqm-contact-GCN.yaml wandb.use False
