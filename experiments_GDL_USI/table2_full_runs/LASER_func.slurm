#!/bin/bash
#SBATCH -J LASER_func
#SBATCH --partition=debug-gpu
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --time=03:00:00
#SBATCH --mem=15G
#SBATCH --array=0-3
#SBATCH --output=LASER_func_%A_%a.out
#SBATCH --error=LASER_func_%A_%a.err

source ~/miniconda/etc/profile.d/conda.sh
conda activate laser

cd /home/bosshf/LASER_GDL

SEED=$SLURM_ARRAY_TASK_ID

echo "Running LASER: Peptides-func, seed=$SEED"
python main.py --cfg configs/Peptides-laserglobal/peptides-func-GCN-laserglobal-shuffle.yaml wandb.use False seed $SEED
