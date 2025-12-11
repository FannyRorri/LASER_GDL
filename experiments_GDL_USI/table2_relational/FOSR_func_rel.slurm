#!/bin/bash
#SBATCH -J FOSR_func_rel
#SBATCH --partition=gpu
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --time=10:00:00
#SBATCH --mem=16G
#SBATCH --output=FOSR_func_rel_%j.out
#SBATCH --error=FOSR_func_rel_%j.err

# NOTE: main.py must NOT call agg_runs() internally; aggregation is done below.

source ~/miniconda/etc/profile.d/conda.sh
conda activate laser

cd /home/bosshf/LASER_GDL

CFG="configs/Peptides-baselines/FOSR/peptides-func-GCN-relational.yaml"
OUT_BASE="results/table2/FOSR_func_rel"

for SEED in 0 1 2 3; do
    echo "Running FOSR: Peptides-func-relational, seed=${SEED}"
    python main.py --cfg "${CFG}" wandb.use False seed ${SEED}          out_dir "${OUT_BASE}"
done

python - << 'EOF'
import os
from yacs.config import CfgNode
from torch_geometric.graphgym.utils.agg_runs import agg_runs

out_dir = "results/table2/FOSR_func_rel"
config_path = os.path.join(out_dir, "config.yaml")

cfg = CfgNode(new_allowed=True)
cfg.merge_from_file(config_path)

metric_best = cfg.metric_best
print(f"Aggregating runs in {out_dir} with metric_best={metric_best}")
agg_runs(out_dir, metric_best)
EOF
