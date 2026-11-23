#!/usr/bin/env python3
import argparse
import json

from common import read_rows


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("csv")
    args = ap.parse_args()
    seen, values, compared, worst = {}, 0, 0, 0.0
    for row in read_rows(args.csv):
        for token, p in json.loads(row["probabilities"]):
            key = (row["query"], row["variant"], token)
            values += 1
            if key in seen:
                compared += 1
                worst = max(worst, abs(float(p) - seen[key]))
            seen.setdefault(key, float(p))
    print(f"{values} values over {len(seen)} tuples, {compared} compared, largest difference {worst:.3g}")


if __name__ == "__main__":
    main()
