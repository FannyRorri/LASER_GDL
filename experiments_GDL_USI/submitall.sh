#!/bin/bash

# Directory where this script lives
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# If an argument is given, use it as subdirectory; otherwise use SCRIPT_DIR itself
if [ -n "$1" ]; then
    TARGET_DIR="$SCRIPT_DIR/$1"
else
    TARGET_DIR="$SCRIPT_DIR"
fi

cd "$TARGET_DIR" || exit 1

for f in *.slurm; do
    [ -e "$f" ] || continue
    echo "Submitting $f"
    sbatch "$f"
done
