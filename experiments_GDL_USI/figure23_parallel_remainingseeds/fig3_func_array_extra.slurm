#!/bin/bash
#SBATCH -J Fig3_PepFunc_LASER_extra
#SBATCH --partition=gpu
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --time=16:00:00
#SBATCH --mem=16G
#SBATCH --array=0-47           # 4 rhos * 4 L * 3 seeds = 48 jobs
#SBATCH --output=Fig3_PepFunc_LASER_extra_%A_%a.out
#SBATCH --error=Fig3_PepFunc_LASER_extra_%A_%a.err

source ~/miniconda/etc/profile.d/conda.sh
conda activate laser

cd /home/bosshf/LASER_GDL

CFG_LASER="configs/Peptides-laserglobal-ablation/peptides-func-GCN-laserglobal.yaml"
OUT_BASE_LASER="results/fig3/Peptides_func/LASER"

SNAPS=(2 3 4 5)
RHOS=(0.1 0.25 0.5 1.0)
SEEDS=(1 2 3)

NUM_L=${#SNAPS[@]}      # 4
NUM_RHO=${#RHOS[@]}     # 4
NUM_SEED=${#SEEDS[@]}   # 3

TASK_ID=${SLURM_ARRAY_TASK_ID}

# map TASK_ID -> (rho_idx, L_idx, seed_idx)
PER_RHO=$((NUM_L * NUM_SEED))        # 12
rho_idx=$((TASK_ID / PER_RHO))
rem=$((TASK_ID % PER_RHO))
L_idx=$((rem / NUM_SEED))
seed_idx=$((rem % NUM_SEED))

RHO=${RHOS[$rho_idx]}
L=${SNAPS[$L_idx]}
SEED=${SEEDS[$seed_idx]}

OUT_DIR="${OUT_BASE_LASER}/rho${RHO}_L${L}"

echo "LASER Pept-func (Fig3 extra seeds): rho=${RHO}, L=${L}, seed=${SEED}"
python main.py --cfg "${CFG_LASER}"       wandb.use False       seed ${SEED}       dynamic.num_snapshots ${L}       dynamic.additions_factor ${RHO}       out_dir "${OUT_DIR}"
