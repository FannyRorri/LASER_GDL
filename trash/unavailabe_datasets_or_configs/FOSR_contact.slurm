#!/bin/bash
#SBATCH -J FOSR_contact
#SBATCH --partition=gpu
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --time=08:00:00
#SBATCH --mem=32G
#SBATCH --array=0-3
#SBATCH --output=FOSR_contact_%A_%a.out
#SBATCH --error=FOSR_contact_%A_%a.err

source ~/miniconda/etc/profile.d/conda.sh
conda activate laser

cd /home/bosshf/LASER_GDL

SEED=$SLURM_ARRAY_TASK_ID

echo "Running FOSR: PCQM-Contact, seed=$SEED"
python main.py --cfg configs/Contact-baselines/pcqm-contact-GCN-fosr.yaml wandb.use False seed $SEED
