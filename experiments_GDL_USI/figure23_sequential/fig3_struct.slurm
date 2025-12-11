#!/bin/bash
#SBATCH -J Fig3_PepStruct
#SBATCH --partition=gpu
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --time=16:00:00
#SBATCH --mem=20G
#SBATCH --output=Fig3_PepStruct_%j.out
#SBATCH --error=Fig3_PepStruct_%j.err

# Figure 3 (right): Peptides-struct MAE vs rho and #snapshots
# LASER: L in {2,3,4,5}, rho in {0.1, 0.25, 0.5, 1.0}
# Baseline: plain GCN (no rewiring)

source ~/miniconda/etc/profile.d/conda.sh
conda activate laser

cd /home/bosshf/LASER_GDL

CFG_LASER="configs/Peptides-laserglobal-ablation/peptides-struct-GCN-laserglobal.yaml"
CFG_BASELINE="configs/GCN/peptides-struct-GCN.yaml"

OUT_BASE_LASER="results/fig3/Peptides_struct/LASER"
OUT_BASE_BASELINE="results/fig3/Peptides_struct/GCN_baseline"

SNAPS=(2 3 4 5)
RHOS=(0.1 0.25 0.5 1.0)

#########################
# LASER: sweep (L, rho) #
#########################

for RHO in "${RHOS[@]}"; do
  for L in "${SNAPS[@]}"; do
    OUT_DIR="${OUT_BASE_LASER}/rho${RHO}_L${L}"

    for SEED in 0 1 2 3; do
      echo "LASER Pept-struct (Fig3): rho=${RHO}, L=${L}, seed=${SEED}"
      python main.py --cfg "${CFG_LASER}" wandb.use False seed ${SEED} dynamic.num_snapshots ${L} dynamic.additions_factor ${RHO} out_dir "${OUT_DIR}"
    done
  done
done

#########################
# Baseline GCN          #
#########################

for SEED in 0 1 2 3; do
  echo "Baseline GCN Pept-struct (Fig3): seed=${SEED}"
  python main.py --cfg "${CFG_BASELINE}" wandb.use False seed ${SEED} out_dir "${OUT_BASE_BASELINE}"
done

############################
# Aggregate runs           #
############################

python - << 'EOF'
import os
from yacs.config import CfgNode
from torch_geometric.graphgym.utils.agg_runs import agg_runs

base_laser = "results/fig3/Peptides_struct/LASER"
base_gcn   = "results/fig3/Peptides_struct/GCN_baseline"

snaps = [2, 3, 4, 5]
rhos  = [0.1, 0.25, 0.5, 1.0]

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
        print(f"Aggregating LASER Pept-struct Fig3: rho={rho}, L={L}, metric_best={metric_best}")
        agg_runs(out_dir, metric_best)

# Baseline GCN
config_path = os.path.join(base_gcn, "config.yaml")
if os.path.exists(config_path):
    cfg = CfgNode(new_allowed=True)
    cfg.merge_from_file(config_path)
    metric_best = cfg.metric_best
    print(f"Aggregating baseline GCN Pept-struct Fig3: metric_best={metric_best}")
    agg_runs(base_gcn, metric_best)
else:
    print("Skipping baseline GCN aggregation (no config.yaml).")
EOF
