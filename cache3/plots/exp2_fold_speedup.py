#!/usr/bin/env python3
from common import FOLD_ONLY, FOLD_QUERIES, arguments, exp2_summary, speedup_pair, write


def main():
    args = arguments("exp2.csv", "exp2_fold_speedup.tex")
    _, data = exp2_summary(args.csv)
    write(args.out, speedup_pair(FOLD_QUERIES, data, "fold", FOLD_ONLY, "folding only"))


if __name__ == "__main__":
    main()
