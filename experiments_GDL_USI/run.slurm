#!/bin/bash
#SBATCH -J peptides_laser
#SBATCH --partition=debug-gpu
#SBATCH --gres=gpu:1
#SBATCH --ntasks=1
#SBATCH --mem=16G
#SBATCH --time=4:00:00
#SBATCH --output=peptides_laser_%j.out
#SBATCH --error=peptides_laser_%j.err

source ~/miniconda/etc/profile.d/conda.sh
conda activate laser

cd /home/bosshf/LASER_GDL

# Main LASER experiments on Peptides (functional + structural),
# matching the Peptides LASER rows in Table 2 of the paper.
bash experiments_GDL_USI/configs/run_peptides_laser_wandb.sh
