#!/bin/bash
#SBATCH -J Fig3_PepFunc_Base
#SBATCH --partition=gpu
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --time=16:00:00
#SBATCH --mem=8G
#SBATCH --array=0
#SBATCH --output=Fig3_PepFunc_Base_%A_%a.out
#SBATCH --error=Fig3_PepFunc_Base_%A_%a.err

source ~/miniconda/etc/profile.d/conda.sh
conda activate laser

cd /home/bosshf/LASER_GDL

CFG_BASELINE="configs/GCN/peptides-func-GCN.yaml"
OUT_BASE_BASELINE="results/fig3/Peptides_func/GCN_baseline"

SEED=${SLURM_ARRAY_TASK_ID}

OUT_DIR="${OUT_BASE_BASELINE}"

echo "Baseline GCN Pept-func (Fig3): seed=${SEED}"
python main.py --cfg "${CFG_BASELINE}" \
  wandb.use False \
  seed ${SEED} \
  out_dir "${OUT_DIR}"
  