#!/usr/bin/env python3
"""Experiment 2: the twenty variants of ten queries, in ten sessions per mode with arbitrary sequences of the statements.

One provenance pass first runs each statement with provenance() in place of the call to probability_evaluate.
The four modes then run one after the other: optimized (cachefold), unoptimized (off), cache only (on) and folding only
(fold). Each mode runs ten sessions. A session runs all the statements once, in a random order in which the variants of
different queries mix, for example q7v3 q19v11 q7v14 q4v1. The server restarts and the cache is reset before each
session, and never between the statements of a session. Session k has the same order in every mode, and the
order depends only on the seed and k.
Every statement gives one row of the output CSV.
"""
import argparse
import os
import random

from lib import experiment
from lib.experiment import (DATABASE, RESULTS, TIMEOUT, Output, environment, measure, open_session, preflight, report,
                            warm_up_d4)

QUERIES = [3, 4, 5, 6, 7, 9, 10, 12, 14, 19]
VARIANTS = 20
SESSIONS = 10
SEED = 1
MODES = ["cachefold", "off", "on", "fold"]


def sequence(seed, number, queries, variants):
    statements = [(q, v) for q in queries for v in range(1, variants + 1)]
    random.Random(f"exp2-seed-{seed}-repetition-{number}").shuffle(statements)
    return statements


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--database", default=DATABASE)
    ap.add_argument("--out", default=os.path.join(RESULTS, "exp2.csv"))
    ap.add_argument("--sessions", type=int, default=SESSIONS, help="last session of each mode")
    ap.add_argument("--first-session", type=int, default=1, help="first session of each mode")
    ap.add_argument("--append", action="store_true", help="add to the output CSV and skip the provenance pass")
    ap.add_argument("--variants", type=int, default=VARIANTS)
    ap.add_argument("--seed", type=int, default=SEED)
    ap.add_argument("--timeout", type=int, default=TIMEOUT, help="seconds allowed per statement")
    ap.add_argument("--queries", default=",".join(map(str, QUERIES)))
    ap.add_argument("--modes", default=",".join(MODES))
    ap.add_argument("--force", action="store_true", help="overwrite the output CSV")
    ap.add_argument("--dry-run", action="store_true", help="print the plan and touch nothing")
    args = ap.parse_args(argv)
    queries = [int(x) for x in args.queries.split(",")]
    modes = args.modes.split(",")
    statements = [(q, v) for q in queries for v in range(1, args.variants + 1)]
    numbers = range(args.first_session, args.sessions + 1)

    if args.dry_run:
        if not args.append:
            print(f"provenance pass: {len(statements)} statements")
        for mode in modes:
            print(f"mode {mode}: sessions {numbers[0]} to {numbers[-1]} of {len(statements)} statements, a server restart before each")
        for number in numbers:
            order = sequence(args.seed, number, queries, args.variants)
            print(f"session {number} in every mode starts " + " ".join(f"q{q}v{v}" for q, v in order[:8]))
        return

    preflight(args.database, statements)
    output = Output(args.out, args.force, environment(args.database, args.timeout, args.seed), args.append)
    if not args.append:
        print(f"\n== provenance pass over {len(statements)} statements", flush=True)
        experiment.restart_server()
        session = open_session(args.database, "off", args.timeout)
        for position, (query, variant) in enumerate(statements, 1):
            row = measure(session, query, variant, provenance_only=True)
            output.write(experiment="exp2", repetition=0, mode="provenance", phase="provenance", position=position, **row)
            report("provenance", position, len(statements), row)
        session.close()
    for mode in modes:
        for number in numbers:
            order = sequence(args.seed, number, queries, args.variants)
            print(f"\n== mode {mode}, session {number} of {args.sessions}: {len(order)} statements", flush=True)
            experiment.restart_server()
            session = open_session(args.database, mode, args.timeout)
            session.run("SELECT prob_cache_reset();")
            warm_up_d4()
            for position, (query, variant) in enumerate(order, 1):
                row = measure(session, query, variant)
                output.write(experiment="exp2", repetition=number, mode=mode, phase="measured", position=position, **row)
                report(f"{mode} s{number}", position, len(order), row)
            session.close()
    output.close()
    print(f"\nwrote {args.out}", flush=True)


if __name__ == "__main__":
    main()
