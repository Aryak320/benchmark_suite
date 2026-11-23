#!/usr/bin/env python3
from common import arguments, exp1_summary, qname, speedup_picture, write


def picture(queries, data):
    labels = [(qname(q), data[(q, "off")]["seconds"] / data[(q, "cachefold")]["seconds"]) for q in queries]
    total = lambda mode: sum(data[(q, mode)]["seconds"] for q in queries)
    labels.append((f"All {len(queries)}", total("off") / total("cachefold")))
    return speedup_picture(labels, 0.47 * (10 + 0.25), "speed-up: $t_{\\text{off}}/t_{\\text{optimized}}$")


def main():
    args = arguments("exp1.csv", "exp1_speedup.tex")
    write(args.out, picture(*exp1_summary(args.csv)))


if __name__ == "__main__":
    main()
