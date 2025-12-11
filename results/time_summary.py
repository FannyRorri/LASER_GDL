import os, math, subprocess

ROOT = "table2"  # we are in LASER_GDL/results

methods = [
    "NONE_func",  "SDRF_func",  "SDRF_func_rel",
    "FOSR_func",  "FOSR_func_rel", "LASER_func",
    "NONE_struct","SDRF_struct","SDRF_struct_rel",
    "FOSR_struct","FOSR_struct_rel","LASER_struct",
]

def parse_time(t):
    t = t.strip()        # e.g. "1.14h" or "45.3m" or "500s"
    x = float(t[:-1])
    u = t[-1]
    return x*3600 if u == "h" else x*60 if u == "m" else x

def mean_std(xs):
    m = sum(xs) / len(xs)
    v = sum((x - m)**2 for x in xs) / len(xs)
    return m, math.sqrt(v)

def fmt_hours(sec):
    return f"{sec/3600:.2f}h"

for mdir in methods:
    times = []
    gpu_mem = None
    for seed in range(4):
        log = os.path.join(ROOT, mdir, str(seed), "logging.log")
        with open(log) as f:
            lines = f.readlines()

        # GPU mem (same for all seeds of this method, just grab once)
        if gpu_mem is None:
            gline = [l for l in lines if "GPU Mem:" in l][0]
            gpu_mem = gline.split("GPU Mem:")[1].strip()

        # total train loop time
        tline = [l for l in lines if "Total train loop time:" in l][-1]
        tstr  = tline.split("Total train loop time:")[1].strip()
        times.append(parse_time(tstr))

    mu, sigma = mean_std(times)
    times_str = ", ".join(fmt_hours(t) for t in times)
    print(f"{mdir:16s} (GPU {gpu_mem:>6s}): {fmt_hours(mu)} ± {fmt_hours(sigma)}"
          f"   (seeds: {times_str})")


# sacct -u $USER -S 2025-12-09 -E 2025-12-10 -o JobID,JobName,AllocTRES%40,Elapsed,MaxRSS,NodeList
subprocess.run([
    "sacct", "-u", os.getenv("USER"),
    "-S", "2025-12-09", "-E", "2025-12-10",
    "-o", "JobID,JobName,AllocTRES%40,Elapsed,MaxRSS,NodeList"
])

