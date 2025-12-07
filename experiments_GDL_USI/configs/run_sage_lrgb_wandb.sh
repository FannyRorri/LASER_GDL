#!/bin/bash
# SAGE baselines on LRGB Peptides with W&B logging

set -e

FUN_CONFIG="configs/Peptides-baselines/peptides-func-SAGE.yaml"
STR_CONFIG="configs/Peptides-baselines/peptides-struct-SAGE.yaml"

for CFG in "${FUN_CONFIG}" "${STR_CONFIG}"; do
    for SEED in {0..3}; do
        python main.py --cfg "${CFG}" \
            wandb.use True \
            wandb.project "laser-paper" \
            wandb.entity "fabianlucasbosshard-zhaw" \
            seed ${SEED}
    done
done
