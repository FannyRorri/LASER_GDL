import os
import json
import math

ROOT = os.path.join('..', 'results', 'table2')

# Per task: (pretty name, metric key, maximize?, list of (subdir, label))
TASKS = [
    (
        "Peptides-func",
        "ap",
        True,  # maximize AP
        [
            ("NONE_func",        "NONE"),
            ("SDRF_func",        "SDRF"),
            ("SDRF_func_rel",    "SDRF-R"),
            ("FOSR_func",        "FOSR"),
            ("FOSR_func_rel",    "FOSR-R"),
            ("LASER_func",       "LASER"),
        ],
    ),
    (
        "Peptides-struct",
        "mae",
        False,  # minimize MAE
        [
            ("NONE_struct",      "NONE"),
            ("SDRF_struct",      "SDRF"),
            ("SDRF_struct_rel",  "SDRF-R"),
            ("FOSR_struct",      "FOSR"),
            ("FOSR_struct_rel",  "FOSR-R"),
            ("LASER_struct",     "LASER"),
        ],
    ),
]


def load_stats(path):
    with open(path) as f:
        content = f.read().strip()

    # Try normal JSON first
    try:
        data = json.loads(content)
    except json.JSONDecodeError:
        # Fallback: JSON Lines
        rows = []
        for line in content.splitlines():
            line = line.strip()
            if not line:
                continue
            rows.append(json.loads(line))
        data = rows

    if isinstance(data, list):
        return data
    elif isinstance(data, dict):
        # dict of lists -> list of dicts
        keys = list(data.keys())
        n = len(data[keys[0]])
        rows = []
        for i in range(n):
            row = {k: data[k][i] for k in keys}
            rows.append(row)
        return rows
    else:
        raise ValueError(f"Unknown stats format in {path}")


def best_epoch(stats, metric, maximize):
    if maximize:
        best = max(stats, key=lambda r: r[metric])
    else:
        best = min(stats, key=lambda r: r[metric])
    return best["epoch"]


def mean_std(xs):
    n = len(xs)
    m = sum(xs) / n
    var = sum((x - m) ** 2 for x in xs) / n
    return m, math.sqrt(var)


def get_method_results(method_dir, metric, maximize, seeds=(0, 1, 2, 3)):
    vals = []
    best_epochs = []
    for seed in seeds:
        base = os.path.join(ROOT, method_dir, str(seed))

        val_path = os.path.join(base, 'val',  'stats.json')
        test_path = os.path.join(base, 'test', 'stats.json')

        val_stats = load_stats(val_path)
        test_stats = load_stats(test_path)

        be = best_epoch(val_stats, metric, maximize)
        best_epochs.append(be)

        test_row = next(r for r in test_stats if r['epoch'] == be)
        vals.append(test_row[metric])

    return mean_std(vals), vals, best_epochs


for task_name, metric, maximize, methods in TASKS:
    print(f"=== {task_name} ({metric}) ===")
    for method_dir, label in methods:
        (m, s), per_seed, best_epochs = get_method_results(
            method_dir, metric, maximize
        )
        seeds_str  = ", ".join(f"{v:.4f}" for v in per_seed)
        epochs_str = ", ".join(str(e) for e in best_epochs)
        print(f"{label:10s}: {m:.4f} ± {s:.4f}   "
              f"(seeds: {seeds_str}; epochs: {epochs_str})")
    print()
