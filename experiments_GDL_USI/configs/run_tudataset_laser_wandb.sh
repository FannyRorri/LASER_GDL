#!/bin/bash
# TUDataset LASER runs with W&B logging

set -e

# Adjust this list to the exact LASER config files present in configs/TUDatasets-laserglobal/
CONFIGS=(
    "configs/TUDatasets-laserglobal/PROTEINS-GCN-laserglobal.yaml"
    "configs/TUDatasets-laserglobal/ENZYMES-GCN-laserglobal.yaml"
    "configs/TUDatasets-laserglobal/DD-GCN-laserglobal.yaml"
)

for CFG in "${CONFIGS[@]}"; do
    for SEED in {0..3}; do
        python main.py --cfg "${CFG}" \
            wandb.use True \
            wandb.project "laser-paper" \
            wandb.entity "fabianlucasbosshard-zhaw" \
            seed ${SEED}
    done
done
