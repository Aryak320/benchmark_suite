#!/usr/bin/env python3
"""Experiment 1: variant 1 of the eleven queries, ten times in each of the four modes.

Each mode runs in its own database session: a warm-up over the queries, then ten rounds of all the queries, with the
cache reset before each round. The server is not restarted. A query that reaches the timeout is not run again in
that mode. Query 1 is left out of the warm-up of the modes in which it is known to reach the timeout.
Every statement gives one row of the output CSV.
"""
import argparse
import os

from lib.experiment import (DATABASE, RESULTS, TIMEOUT, Output, environment, measure, open_session, preflight, report,
                            warm_up_d4)

QUERIES = [3, 5, 6, 7, 9, 10, 14, 19, 12, 4, 1]
MODES = ["on", "off", "cachefold", "fold"]
VARIANT = 1
ROUNDS = 10
KNOWN_TIMEOUTS = {("on", 1), ("off", 1)}


def run_round(session, output, mode, phase, repetition, queries):
    reached = set()
    for position, query in enumerate(queries, 1):
        row = measure(session, query, VARIANT)
        output.write(experiment="exp1", repetition=repetition, mode=mode, phase=phase, position=position, **row)
        report(f"{mode} {phase} {repetition}", position, len(queries), row)
        if row["status"] == "timeout":
            reached.add(query)
    return reached


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--database", default=DATABASE)
    ap.add_argument("--out", default=os.path.join(RESULTS, "exp1.csv"))
    ap.add_argument("--rounds", type=int, default=ROUNDS)
    ap.add_argument("--timeout", type=int, default=TIMEOUT, help="seconds allowed per statement")
    ap.add_argument("--queries", default=",".join(map(str, QUERIES)))
    ap.add_argument("--modes", default=",".join(MODES))
    ap.add_argument("--force", action="store_true", help="overwrite the output CSV")
    ap.add_argument("--dry-run", action="store_true", help="print the plan and touch nothing")
    args = ap.parse_args(argv)
    queries = [int(x) for x in args.queries.split(",")]
    modes = args.modes.split(",")

    if args.dry_run:
        for mode in modes:
            warm = [q for q in queries if (mode, q) not in KNOWN_TIMEOUTS]
            print(f"mode {mode}: warm-up over {len(warm)} queries, then {args.rounds} rounds of {len(queries)} queries")
        print("order:", " ".join(f"q{q}v{VARIANT}" for q in queries))
        return

    preflight(args.database, [(q, VARIANT) for q in queries])
    output = Output(args.out, args.force, environment(args.database, args.timeout, ""))
    for mode in modes:
        session = open_session(args.database, mode, args.timeout)
        warm_up_d4()
        print(f"\n== mode {mode}: warm-up", flush=True)
        session.run("SELECT prob_cache_reset();")
        run_round(session, output, mode, "warmup", 0, [q for q in queries if (mode, q) not in KNOWN_TIMEOUTS])
        reached = set()
        for number in range(1, args.rounds + 1):
            print(f"\n== mode {mode}: round {number} of {args.rounds}", flush=True)
            session.run("SELECT prob_cache_reset();")
            reached |= run_round(session, output, mode, "measured", number, [q for q in queries if q not in reached])
        session.close()
    output.close()
    print(f"\nwrote {args.out}", flush=True)


if __name__ == "__main__":
    main()
