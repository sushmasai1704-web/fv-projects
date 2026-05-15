#!/usr/bin/env python3
"""
run_fv.py — run all SymbiYosys FV projects and report results.
Usage: python3 run_fv.py
"""

import subprocess
import time
import os

PROJECTS = [
    {"name": "FIFO",          "dir": "project1-fifo",         "sby": "fifo.sby"},
    {"name": "FIFO (buggy)",  "dir": "project1-fifo",         "sby": "fifo_buggy.sby"},
    {"name": "Arbiter",       "dir": "project2-arbiter",      "sby": "arbiter.sby"},
    {"name": "AXI4-Lite",     "dir": "project3-axi4lite",     "sby": "axi4lite.sby"},
    {"name": "AXI4-Lite cov", "dir": "project3-axi4lite",     "sby": "cover.sby"},
    {"name": "Counter (fix)", "dir": "project4-buggy-designs/bug1_counter", "sby": "counter.sby"},
]

BASE = os.path.dirname(os.path.abspath(__file__))
COL  = {"PASS": "\033[32m", "FAIL": "\033[31m", "ERROR": "\033[33m", "RESET": "\033[0m"}

def run(project):
    d   = os.path.join(BASE, project["dir"])
    sby = project["sby"]
    t0  = time.time()
    try:
        r = subprocess.run(
            ["sby", "-f", sby],
            cwd=d, capture_output=True, text=True, timeout=120
        )
        elapsed = time.time() - t0
        if r.returncode == 0:
            return "PASS", elapsed
        else:
            return "FAIL", elapsed
    except subprocess.TimeoutExpired:
        return "ERROR", 120.0
    except FileNotFoundError:
        return "ERROR", 0.0

def main():
    print(f"\n{'Project':<22} {'Config':<20} {'Result':<8} {'Time':>6}")
    print("─" * 60)
    passed = failed = errors = 0
    for p in PROJECTS:
        status, elapsed = run(p)
        color = COL.get(status, "")
        reset = COL["RESET"]
        print(f"{p['name']:<22} {p['sby']:<20} "
              f"{color}{status:<8}{reset} {elapsed:>5.1f}s")
        if status == "PASS":   passed  += 1
        elif status == "FAIL": failed  += 1
        else:                  errors  += 1
    print("─" * 60)
    print(f"{'TOTAL':<22} {'':<20} "
          f"{passed} pass  {failed} fail  {errors} error\n")

if __name__ == "__main__":
    main()
