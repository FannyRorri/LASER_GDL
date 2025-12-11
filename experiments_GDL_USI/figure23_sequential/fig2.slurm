#!/bin/bash
#SBATCH -J Fig2_Pep_ER_GD
#SBATCH --partition=gpu
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --time=16:00:00
#SBATCH --mem=16G
#SBATCH --output=Fig2_Pep_ER_GD_%j.out
#SBATCH --error=Fig2_Pep_ER_GD_%j.err

# Figure 2: Total effective resistance & graph distance
# Dataset: Peptides (functional)
# Rewirings:
#   - LASER: L in {2,3,4,5}, rho in {0.1, 1.0}
#   - FOSR: dynamic.num_iterations in {10,20,50,100}

source ~/miniconda/etc/profile.d/conda.sh
conda activate laser

cd /home/bosshf/LASER_GDL

CFG_LASER="configs/Peptides-laserglobal-ablation/peptides-func-GCN-laserglobal.yaml"
CFG_FOSR="configs/Peptides-baselines/FOSR/peptides-func-GCN.yaml"

OUT_BASE_LASER="results/fig2/Peptides/LASER"
OUT_BASE_FOSR="results/fig2/Peptides/FOSR"

SNAPS=(2 3 4 5)
RHOS=(0.1 1.0)
FOSR_ITERS=(10 20 50 100)

#########################
# LASER: sweep (L, rho) #
#########################

for RHO in "${RHOS[@]}"; do
  for L in "${SNAPS[@]}"; do
    OUT_DIR="${OUT_BASE_LASER}/rho${RHO}_L${L}"

    for SEED in 0 1 2 3; do
      echo "LASER (Fig2): rho=${RHO}, L=${L}, seed=${SEED}"
      python main.py --cfg "${CFG_LASER}" wandb.use False seed ${SEED} dynamic.num_snapshots ${L} dynamic.additions_factor ${RHO} out_dir "${OUT_DIR}"
    done
  done
done

############################
# FOSR: sweep num_iters    #
############################

for K in "${FOSR_ITERS[@]}"; do
  OUT_DIR="${OUT_BASE_FOSR}/iters${K}"

  for SEED in 0 1 2 3; do
    echo "FOSR (Fig2): num_iterations=${K}, seed=${SEED}"
    python main.py --cfg "${CFG_FOSR}" wandb.use False seed ${SEED} dynamic.num_iterations ${K} out_dir "${OUT_DIR}"
  done
done

############################
# Aggregate runs           #
############################

python - << 'EOF'
import os
from yacs.config import CfgNode
from torch_geometric.graphgym.utils.agg_runs import agg_runs

base_laser = "results/fig2/Peptides/LASER"
base_fosr  = "results/fig2/Peptides/FOSR"

rhos   = [0.1, 1.0]
snaps  = [2, 3, 4, 5]
iters  = [10, 20, 50, 100]

# LASER
for rho in rhos:
    for L in snaps:
        out_dir = os.path.join(base_laser, f"rho{rho}_L{L}")
        config_path = os.path.join(out_dir, "config.yaml")
        if not os.path.exists(config_path):
            print("Skipping", out_dir, "(no config.yaml)")
            continue
        cfg = CfgNode(new_allowed=True)
        cfg.merge_from_file(config_path)
        metric_best = cfg.metric_best
        print(f"Aggregating LASER Fig2: rho={rho}, L={L}, metric_best={metric_best}")
        agg_runs(out_dir, metric_best)

# FOSR
for k in iters:
    out_dir = os.path.join(base_fosr, f"iters{k}")
    config_path = os.path.join(out_dir, "config.yaml")
    if not os.path.exists(config_path):
        print("Skipping", out_dir, "(no config.yaml)")
        continue
    cfg = CfgNode(new_allowed=True)
    cfg.merge_from_file(config_path)
    metric_best = cfg.metric_best
    print(f"Aggregating FOSR Fig2: iters={k}, metric_best={metric_best}")
    agg_runs(out_dir, metric_best)
EOF
