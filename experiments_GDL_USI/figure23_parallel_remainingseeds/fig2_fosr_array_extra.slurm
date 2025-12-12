#!/bin/bash
#SBATCH -J Fig2_Pep_FOSR_extra
#SBATCH --partition=gpu
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --time=16:00:00
#SBATCH --mem=16G
#SBATCH --array=0-11
#SBATCH --output=Fig2_Pep_FOSR_extra_%A_%a.out
#SBATCH --error=Fig2_Pep_FOSR_extra_%A_%a.err

source ~/miniconda/etc/profile.d/conda.sh
conda activate laser

cd /home/bosshf/LASER_GDL

CFG_FOSR="configs/Peptides-baselines/FOSR/peptides-func-GCN.yaml"
OUT_BASE_FOSR="results/fig2/Peptides/FOSR"

FOSR_ITERS=(10 20 50 100)
SEEDS=(1 2 3)

NUM_ITERS=${#FOSR_ITERS[@]}   # 4
NUM_SEED=${#SEEDS[@]}         # 3

TASK_ID=${SLURM_ARRAY_TASK_ID}

# TASK_ID -> (iter_idx, seed_idx)  (4 * 3 = 12)
iter_idx=$((TASK_ID / NUM_SEED))
seed_idx=$((TASK_ID % NUM_SEED))

K=${FOSR_ITERS[$iter_idx]}
SEED=${SEEDS[$seed_idx]}

OUT_DIR="${OUT_BASE_FOSR}/iters${K}"

echo "FOSR Fig2 (extra seeds): num_iterations=${K}, seed=${SEED}"
python main.py --cfg "${CFG_FOSR}"       wandb.use False       seed ${SEED}       dynamic.num_iterations ${K}       out_dir "${OUT_DIR}"
