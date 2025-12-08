#!/bin/bash
# LASER Peptides-func ablation (num_snapshots x density) with W&B logging

set -e

CONFIG="configs/Peptides-laserglobal-ablation/peptides-func-GCN-laserglobal.yaml"

# (num_snapshots, hidden_dim) pairs from the paper
SNAP_HID_PAIRS=(
    "2 270"
    "3 250"
    "4 235"
    "5 225"
)

DENSITIES=(0.1 0.25 0.5 1.0)

# Optional: cheap pre-processing warmup with very few epochs (no W&B)
for pair in "${SNAP_HID_PAIRS[@]}"; do
    set -- ${pair}
    SNAP=$1
    HID=$2
    for density in "${DENSITIES[@]}"; do
        python main.py --cfg "${CONFIG}" \
            wandb.use False \
            optim.max_epoch 1 \
            dynamic.num_snapshots ${SNAP} \
            dynamic.additions_factor ${density} \
            gnn.dim_inner ${HID}
    done
done

# Full runs with W&B for each setting and seed
for pair in "${SNAP_HID_PAIRS[@]}"; do
    set -- ${pair}
    SNAP=$1
    HID=$2
    for density in "${DENSITIES[@]}"; do
        for SEED in {0..3}; do
            python main.py --cfg "${CONFIG}" \
                wandb.use True \
                wandb.project "laser-paper" \
                wandb.entity "fabianlucasbosshard-zhaw" \
                seed ${SEED} \
                dynamic.num_snapshots ${SNAP} \
                dynamic.additions_factor ${density} \
                gnn.dim_inner ${HID}
        done
    done
done
