#!/bin/bash
#SBATCH -J NONE_contact
#SBATCH --partition=gpu
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --time=06:00:00
#SBATCH --mem=28G
#SBATCH --array=0-3
#SBATCH --output=NONE_contact_%A_%a.out
#SBATCH --error=NONE_contact_%A_%a.err

source ~/miniconda/etc/profile.d/conda.sh
conda activate laser

cd /home/bosshf/LASER_GDL

SEED=$SLURM_ARRAY_TASK_ID

echo "Running NONE baseline: PCQM-Contact, seed=$SEED"
python main.py --cfg configs/GCN/pcqm-contact-GCN.yaml wandb.use False seed $SEED
