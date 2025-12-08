#!/bin/bash
#SBATCH -J SDRF_func
#SBATCH --partition=gpu
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --time=10:00:00
#SBATCH --mem=16G
#SBATCH --output=SDRF_func_%j.out
#SBATCH --error=SDRF_func_%j.err

# NOTE: main.py must NOT call agg_runs() internally; aggregation is done below.

source ~/miniconda/etc/profile.d/conda.sh
conda activate laser

cd /home/bosshf/LASER_GDL

CFG="configs/Peptides-baselines/SDRF/peptides-func-GCN.yaml"
OUT_BASE="results/table2/SDRF_func"

for SEED in 0 1 2 3; do
    echo "Running SDRF: Peptides-func, seed=${SEED}"
    python main.py --cfg "${CFG}" wandb.use False seed ${SEED}          out_dir "${OUT_BASE}"
done

python - << 'EOF'
import os
from yacs.config import CfgNode
from torch_geometric.graphgym.utils.agg_runs import agg_runs

out_dir = "results/table2/SDRF_func"
config_path = os.path.join(out_dir, "config.yaml")

cfg = CfgNode(new_allowed=True)
cfg.merge_from_file(config_path)

metric_best = cfg.metric_best
print(f"Aggregating runs in {out_dir} with metric_best={metric_best}")
agg_runs(out_dir, metric_best)
EOF
