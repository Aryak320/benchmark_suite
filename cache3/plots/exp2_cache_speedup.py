#!/usr/bin/env python3
from common import CACHE_ONLY, CACHE_QUERIES, arguments, exp2_summary, speedup_pair, write


def main():
    args = arguments("exp2.csv", "exp2_cache_speedup.tex")
    _, data = exp2_summary(args.csv)
    write(args.out, speedup_pair(CACHE_QUERIES, data, "on", CACHE_ONLY, "on"))


if __name__ == "__main__":
    main()
