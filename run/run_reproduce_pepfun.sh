#!/usr/bin/env bash
set -e

CONFIG_DIR="configs/SAGE-lrgb"

# 1) Baseline SAGE on peptides-func
python main.py --cfg ${CONFIG_DIR}/peptides-func-SAGE.yaml \
    wandb.use True optim.max_epoch 1

for SEED in 0 1 2 3; do
    python main.py --cfg ${CONFIG_DIR}/peptides-func-SAGE.yaml \
        wandb.use True optim.max_epoch 5 device mps seed ${SEED}
done

# 2) SAGE + LASER (global, shuffled) on peptides-func
python main.py --cfg ${CONFIG_DIR}/peptides-func-SAGE-laserglobal-shuffle.yaml \
    wandb.use True optim.max_epoch 1

for SEED in 0 1 2 3; do
    python main.py --cfg ${CONFIG_DIR}/peptides-func-SAGE-laserglobal-shuffle.yaml \
        wandb.use True optim.max_epoch 5 device mps seed ${SEED}
done
