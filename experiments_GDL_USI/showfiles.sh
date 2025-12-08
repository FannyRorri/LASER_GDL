for f in $1/*.slurm; do
  echo "===== $f ====="
  cat "$f"
  echo
done