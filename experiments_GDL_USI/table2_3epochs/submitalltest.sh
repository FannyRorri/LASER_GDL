#!/bin/bash
# Go to the directory where this script lives
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

for f in *.slurm; do
    echo "Submitting $f"
    sbatch "$f"
done
