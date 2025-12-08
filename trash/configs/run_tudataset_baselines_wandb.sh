#!/bin/bash
# TUDataset baselines with W&B logging

set -e

# Adjust this list to the exact baseline config files present in configs/TUDatasets-baselines/
CONFIGS=(
    "configs/TUDatasets-baselines/PROTEINS-GCN.yaml"
    "configs/TUDatasets-baselines/ENZYMES-GCN.yaml"
    "configs/TUDatasets-baselines/DD-GCN.yaml"
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
