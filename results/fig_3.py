#!/usr/bin/env python3
import os, json
import numpy as np
import matplotlib.pyplot as plt
import matplotlib as mpl
mpl.rcParams.update({
    "text.usetex": True,
    "font.family": "serif",
    "font.serif": ["Computer Modern Roman"],
    "mathtext.fontset": "cm",   # math also in Computer Modern
})

BASE = "fig3"

# metric keys inside stats.json
TASKS = {
    "Peptides_func":  ("ap",  "Peptides-func ↑",  "AP"),
    "Peptides_struct":("mae", "Peptides-struct ↓","MAE"),
}

# for now: only seed 0 is guaranteed; you can later change to [0,1,2,3]
SEEDS = [0, 1, 2, 3]

def last_json(path):
    with open(path) as f:
        lines = [ln.strip() for ln in f if ln.strip()]
    return json.loads(lines[-1])

def discover_rhos_Ls(task):
    """Look at fig3/<task>/LASER and infer all (rho, L) dirs that exist."""
    root = os.path.join(BASE, task, "LASER")
    if not os.path.isdir(root):
        return [], []
    rhos, Ls = set(), set()
    for name in os.listdir(root):
        if not name.startswith("rho"):
            continue
        try:
            rho_part, L_part = name.split("_L")
            rho_str = rho_part[3:]   # strip 'rho'
            L = int(L_part)
            rhos.add(float(rho_str))
            Ls.add(L)
        except ValueError:
            continue
    return sorted(rhos), sorted(Ls)

def laser_metrics(task, metric_key, rhos, Ls):
    """
    Return:
      means[L][rho], stds[L][rho]
      (only filled when at least one seed file exists)
    """
    means = {L: {} for L in Ls}
    stds  = {L: {} for L in Ls}

    for L in Ls:
        for rho in rhos:
            vals = []
            for seed in SEEDS:
                path = os.path.join(
                    BASE,
                    task,
                    "LASER",
                    f"rho{rho}_L{L}",
                    str(seed),
                    "test",
                    "stats.json",
                )
                if not os.path.exists(path):
                    continue
                d = last_json(path)
                vals.append(d[metric_key])
            if vals:
                vals = np.array(vals, float)
                means[L][rho] = vals.mean()
                stds[L][rho]  = vals.std()
    return means, stds

def baseline_metric(task, metric_key):
    base = os.path.join(BASE, task, "GCN_baseline")
    if not os.path.isdir(base):
        return None
    vals = []
    for seed in SEEDS:
        path = os.path.join(base, str(seed), "test", "stats.json")
        if not os.path.exists(path):
            continue
        d = last_json(path)
        vals.append(d[metric_key])
    if not vals:
        return None
    vals = np.array(vals, float)
    return vals.mean(), vals.std()

# discover grid from Peptides_func LASER dir
rhos, Ls = discover_rhos_Ls("Peptides_func")
print("Found rhos:", rhos)
print("Found Ls:", Ls)

if not rhos or not Ls:
    raise SystemExit("No LASER results found yet under fig3/...")

fig, axes = plt.subplots(1, 2, figsize=(5, 3))

for ax, (task, (metric_key, title, ylabel)) in zip(axes, TASKS.items()):
    means, stds = laser_metrics(task, metric_key, rhos, Ls)
    base = baseline_metric(task, metric_key)

    # LASER lines: one per L
    for L in Ls:
        xs, ys, es = [], [], []
        for rho in rhos:
            if rho in means[L]:
                xs.append(rho)
                ys.append(means[L][rho])
                es.append(stds[L][rho])
        if not xs:
            continue
        xs = np.array(xs, float)
        ys = np.array(ys, float)
        es = np.array(es, float)
        ax.errorbar(xs, ys, yerr=es, marker="o", capsize=0, label=f"$L={L}$", linewidth=1.0, markersize=4)

    # baseline
    if base is not None:
        base_mean, base_std = base
        ax.axhline(base_mean, linestyle="--", label="Baseline", color="black", linewidth=1.0)

    ax.set_xlabel(r"Density $\rho$")
    ax.set_ylabel(ylabel)
    ax.set_title(title)
    ax.grid(True, alpha=0.3)
    ax.set_xticks(rhos)
    ax.set_yticks([0.29, 0.3, 0.31, 0.32, 0.33, 0.34, 0.35] if "struct" in task else [0.58, 0.6, 0.62, 0.64, 0.66, 0.68, 0.7])
    ax.set_xticklabels([str(r) for r in rhos])

# combined legend
handles, labels = axes[0].get_legend_handles_labels()
fig.legend(handles, labels, loc="lower center", ncol=max(2, len(Ls)+1), frameon=True)

plt.tight_layout(rect=[0, 0.1, 1, 1])
plt.savefig("fig3_peptides.pdf", bbox_inches="tight", pad_inches=0.02)
print("✅ Saved fig3_peptides.pdf")