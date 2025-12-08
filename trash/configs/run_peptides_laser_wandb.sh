#!/bin/bash
# LASER on Peptides (functional + structural) with W&B logging

set -e

# Use the ACTUAL config file names you have in configs/Peptides-laserglobal
FUN_CONFIG_NOSH="configs/Peptides-laserglobal/peptides-func-GCN-laserglobal-noshuffle.yaml"
FUN_CONFIG_SHUF="configs/Peptides-laserglobal/peptides-func-GCN-laserglobal-shuffle.yaml"
STR_CONFIG_NOSH="configs/Peptides-laserglobal/peptides-struct-GCN-laserglobal-noshuffle.yaml"
STR_CONFIG_SHUF="configs/Peptides-laserglobal/peptides-struct-GCN-laserglobal-shuffle.yaml"

# Run all 4 (func/struct × shuffle/noshuffle) with seeds 0..3
for CFG in "$FUN_CONFIG_NOSH" "$FUN_CONFIG_SHUF" "$STR_CONFIG_NOSH" "$STR_CONFIG_SHUF"; do
    for SEED in {0..3}; do
        python main.py --cfg "${CFG}" \
            wandb.use True \
            wandb.project "laser-paper" \
            wandb.entity "fabianlucasbosshard-zhaw" \
            seed ${SEED}
    done
done
