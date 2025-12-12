#!/bin/bash
#SBATCH -J Fig3_PepStruct_Base_extra
#SBATCH --partition=gpu
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --time=16:00:00
#SBATCH --mem=8G
#SBATCH --array=1-3
#SBATCH --output=Fig3_PepStruct_Base_extra_%A_%a.out
#SBATCH --error=Fig3_PepStruct_Base_extra_%A_%a.err

source ~/miniconda/etc/profile.d/conda.sh
conda activate laser

cd /home/bosshf/LASER_GDL

CFG_BASELINE="configs/GCN/peptides-struct-GCN.yaml"
OUT_BASE_BASELINE="results/fig3/Peptides_struct/GCN_baseline"

SEED=${SLURM_ARRAY_TASK_ID}

echo "Baseline GCN Pept-struct (Fig3 extra seeds): seed=${SEED}"
python main.py --cfg "${CFG_BASELINE}"       wandb.use False       seed ${SEED}       out_dir "${OUT_BASE_BASELINE}"
