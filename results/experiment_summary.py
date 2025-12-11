#!/usr/bin/env python3
import subprocess
import re
import os
import datetime
from collections import defaultdict


def run(cmd):
    return subprocess.check_output(cmd, text=True)


# ---------- results_summary.py ----------

def parse_results_summary():
    out = run(["python", "results_summary.py"])
    info = {}
    dataset = None

    line_re = re.compile(
        r'^(?P<name>\S+)\s*:\s*[0-9.]+\s±\s*[0-9.]+\s+'
        r'\(seeds:\s*(?P<seeds>[^;]+); epochs:\s*(?P<epochs>[^)]+)\)'
    )

    for line in out.splitlines():
        m_head = re.match(r"=== Peptides-(func|struct)", line)
        if m_head:
            dataset = m_head.group(1)  # "func" or "struct"
            continue

        m = line_re.match(line)
        if not m or dataset is None:
            continue

        raw = m.group("name")
        seeds = [float(x.strip()) for x in m.group("seeds").split(",")]
        epochs = [int(x.strip()) for x in m.group("epochs").split(",")]

        if raw.endswith("-R"):
            base = raw[:-2]
            suffix = "_rel"
        else:
            base = raw
            suffix = ""

        key = f"{base}_{dataset}{suffix}"
        info[key] = {
            "num_seeds": len(seeds),
            "seeds_values": seeds,
            "epochs_per_seed": epochs,
        }

    return info


# ---------- time_summary.py ----------

def parse_time_summary():
    out = run(["python", "time_summary.py"])
    info = {}

    time_re = re.compile(
        r'^(?P<name>\S+)\s+\(GPU\s+\[(?P<gpu>\d+)\]\):\s*'
        r'(?P<mean>[0-9.]+)h\s±\s*[0-9.]+h\s+'
        r'\(seeds:\s*(?P<seeds>[^)]+)\)'
    )

    for line in out.splitlines():
        m = time_re.match(line)
        if not m:
            continue

        name = m.group("name")
        gpu = int(m.group("gpu"))
        mean = float(m.group("mean"))
        seed_times = [float(x.replace("h", "").strip())
                      for x in m.group("seeds").split(",")]

        info[name] = {
            "gpu_index": gpu,
            "mean_hours": mean,
            "seed_hours": seed_times,
        }

    return info


# ---------- sacct helpers ----------

def parse_mem(alloc_tres):
    for part in alloc_tres.split(","):
        part = part.strip()
        if part.startswith("mem="):
            return part.split("=", 1)[1]
    return "?"


def get_gpu_type(node, cache):
    if node in cache:
        return cache[node]
    out = run(["scontrol", "show", "node", node])
    m = re.search(r"Gres=([^\s]+)", out)
    cache[node] = m.group(1) if m else "none"
    return cache[node]


def load_sacct(lookback_days=7):
    user = os.environ.get("USER", "")
    start = (datetime.date.today() - datetime.timedelta(days=lookback_days)).strftime("%Y-%m-%d")

    out = run([
        "sacct", "-n", "-P",
        "-u", user,
        "-S", start,
        "--format=JobID,JobName,AllocTRES,Elapsed,MaxRSS,NodeList",
    ])

    records = []
    for line in out.splitlines():
        if not line.strip():
            continue
        parts = line.split("|")
        if len(parts) != 6:
            continue
        jid, jname, alloc, elapsed, maxrss, nodelist = parts
        records.append({
            "jobid": jid,
            "jobname": jname,
            "alloc_tres": alloc,
            "elapsed": elapsed,
            "maxrss": maxrss,
            "nodelist": nodelist,
        })

    roots_by_id = {}
    steps_by_root = defaultdict(list)

    for r in records:
        jid = r["jobid"]
        if "." in jid:
            root = jid.split(".", 1)[0]
            steps_by_root[root].append(r)
        else:
            roots_by_id[jid] = r

    return roots_by_id, steps_by_root


# ---------- HARD-CODED mapping: experiment -> Slurm JobID ----------

# From your sacct output:
# 59554 FOSR_func
# 59555 FOSR_struct
# 59556 LASER_func
# 59557 LASER_struct
# 59558 NONE_func
# 59559 NONE_struct
# 59560 SDRF_func
# 59561 SDRF_struct
# 59611 FOSR_func  (rel)
# 59612 FOSR_struct (rel)
# 59613 SDRF_func   (rel)
# 59614 SDRF_struct (rel)

EXP_JOBID = {
    "FOSR_func":       "59554",
    "FOSR_func_rel":   "59611",
    "FOSR_struct":     "59555",
    "FOSR_struct_rel": "59612",

    "LASER_func":      "59556",
    "LASER_struct":    "59557",

    "NONE_func":       "59558",
    "NONE_struct":     "59559",

    "SDRF_func":       "59560",
    "SDRF_func_rel":   "59613",
    "SDRF_struct":     "59561",
    "SDRF_struct_rel": "59614",
}


# ---------- main ----------

def main():
    results = parse_results_summary()
    times = parse_time_summary()
    roots_by_id, steps_by_root = load_sacct()

    gpu_cache = {}

    for exp_name in sorted(times.keys()):
        tinfo = times[exp_name]
        rinfo = results.get(exp_name)

        total_time = sum(tinfo["seed_hours"])

        jobid = EXP_JOBID.get(exp_name)
        root = roots_by_id.get(jobid) if jobid is not None else None

        mem_alloc = "?"
        maxrss = "?"
        gpu_type = "?"

        if root is not None:
            mem_alloc = parse_mem(root["alloc_tres"])
            root_id = root["jobid"]

            node = root["nodelist"].split(",")[0].strip("[]")
            if node:
                gpu_type = get_gpu_type(node, gpu_cache)

            steps = steps_by_root.get(root_id, [])
            batch_steps = [s for s in steps if s["jobname"] == "batch"]
            if batch_steps:
                maxrss = batch_steps[-1]["maxrss"]
            else:
                maxrss = root["maxrss"] or "?"
        else:
            root_id = "no job"

        print(f"{exp_name} ({root_id}):")
        print(f"  GPU type (from node):  {gpu_type}")
        # print(f"  Allocated RAM:         {mem_alloc}")
        print(f"  MaxRSS:                {maxrss}")
        print(f"  Time (h):              {total_time:.2f}   {tinfo['seed_hours']}")

        # if rinfo is not None:
        #     print(f"  #seeds:                {rinfo['num_seeds']}")
        #     print(f"  Best epoch per seed:   {rinfo['epochs_per_seed']}")

        print()


if __name__ == "__main__":
    main()
    