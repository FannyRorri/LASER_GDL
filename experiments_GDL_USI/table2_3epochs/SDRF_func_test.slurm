#!/bin/bash
#SBATCH -J SDRF_func
#SBATCH --partition=gpu
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --time=02:00:00
#SBATCH --mem=16G
#SBATCH --array=0-3
#SBATCH --output=SDRF_func_%A_%a.out
#SBATCH --error=SDRF_func_%A_%a.err

source ~/miniconda/etc/profile.d/conda.sh
conda activate laser

cd /home/bosshf/LASER_GDL

SEED=$SLURM_ARRAY_TASK_ID

echo "Running SDRF: Peptides-func, seed=$SEED"
python main.py --cfg configs/Peptides-baselines/SDRF/peptides-func-GCN.yaml wandb.use False seed $SEED optim.max_epoch 3 \
    out_dir results/table2/SDRF_func
