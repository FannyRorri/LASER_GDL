#!/bin/bash
# LASER on PCQM-Contact with Weights & Biases logging enabled

set -e

CONFIG="configs/Contact-laser/pcqm-contact-GCN-laserglobal.yaml"

python main.py --cfg "${CONFIG}" \
    wandb.use True \
    wandb.project "laser-paper" \
    wandb.entity "fabianlucasbosshard-zhaw"
