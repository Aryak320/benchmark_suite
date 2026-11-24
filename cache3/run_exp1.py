#!/usr/bin/env python3
"""Experiment 1: variant 1 of the eleven queries, ten times in each of the four modes.

One provenance pass first runs each query with provenance() in place of the call to probability_evaluate.
The four modes then run one after the other: cache only (on), unoptimized (off), optimized (cachefold) and folding only
(fold). Each mode makes ten runs. A run executes all the queries once, in a database session of its own. The server
restarts before each run, which empties the cache, and d4 is launched once on a two-variable formula. A query that
reaches the timeout is not run again in that mode.
Every statement gives one row of the output CSV.
"""
import argparse
import os

from lib import experiment
from lib.experiment import (DATABASE, RESULTS, TIMEOUT, Output, environment, measure, open_session, preflight, report,
                            warm_up_d4)

QUERIES = [3, 5, 6, 7, 9, 10, 14, 19, 12, 4, 1]
MODES = ["on", "off", "cachefold", "fold"]
VARIANT = 1
RUNS = 10


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--database", default=DATABASE)
    ap.add_argument("--out", default=os.path.join(RESULTS, "exp1.csv"))
    ap.add_argument("--runs", type=int, default=RUNS, help="runs of each mode")
    ap.add_argument("--timeout", type=int, default=TIMEOUT, help="seconds allowed per statement")
    ap.add_argument("--queries", default=",".join(map(str, QUERIES)))
    ap.add_argument("--modes", default=",".join(MODES))
    ap.add_argument("--force", action="store_true", help="overwrite the output CSV")
    ap.add_argument("--dry-run", action="store_true", help="print the plan and touch nothing")
    args = ap.parse_args(argv)
    queries = [int(x) for x in args.queries.split(",")]
    modes = args.modes.split(",")

    if args.dry_run:
        print(f"provenance pass: {len(queries)} statements")
        for mode in modes:
            print(f"mode {mode}: {args.runs} runs of {len(queries)} queries, a server restart before each")
        print("order:", " ".join(f"q{q}v{VARIANT}" for q in queries))
        return

    preflight(args.database, [(q, VARIANT) for q in queries])
    output = Output(args.out, args.force, environment(args.database, args.timeout, ""))
    print(f"\n== provenance pass over {len(queries)} statements", flush=True)
    experiment.restart_server()
    session = open_session(args.database, "off", args.timeout)
    for position, query in enumerate(queries, 1):
        row = measure(session, query, VARIANT, provenance_only=True)
        output.write(experiment="exp1", repetition=0, mode="provenance", phase="provenance", position=position, **row)
        report("provenance", position, len(queries), row)
    session.close()
    for mode in modes:
        reached = set()
        for number in range(1, args.runs + 1):
            order = [q for q in queries if q not in reached]
            print(f"\n== mode {mode}, run {number} of {args.runs}: {len(order)} statements", flush=True)
            experiment.restart_server()
            session = open_session(args.database, mode, args.timeout)
            session.run("SELECT prob_cache_reset();")
            warm_up_d4()
            for position, query in enumerate(order, 1):
                row = measure(session, query, VARIANT)
                output.write(experiment="exp1", repetition=number, mode=mode, phase="measured", position=position, **row)
                report(f"{mode} r{number}", position, len(order), row)
                if row["status"] == "timeout":
                    reached.add(query)
            session.close()
    output.close()
    print(f"\nwrote {args.out}", flush=True)


if __name__ == "__main__":
    main()
