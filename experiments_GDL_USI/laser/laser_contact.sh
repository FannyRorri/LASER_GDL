#!/bin/bash
#SBATCH -J LASER_all
#SBATCH --partition=gpu
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --time=04:00:00
#SBATCH --mem=24G
#SBATCH --output=laser_contact_%j.out
#SBATCH --error=laser_contact_%j.err

# Load conda
source ~/miniconda3/etc/profile.d/conda.sh
conda activate laser

echo "===================="
echo "Running LASER: PCQM-Contact"
echo "===================="

python main.py --cfg configs/Contact-laser/pcqm-contact-GCN-laserglobal.yaml wandb.use False

