#!/usr/bin/env python3
from common import arguments, exp2_summary, qname, speedup_picture, write


def picture(queries, data):
    queries = [q for q in queries if (q, "off") in data and (q, "cachefold") in data]
    labels = [(qname(q), data[(q, "off")]["seconds"] / data[(q, "cachefold")]["seconds"]) for q in queries]
    total = lambda mode: sum(data[(q, mode)]["seconds"] for q in queries)
    labels.append((f"All {len(queries)}", total("off") / total("cachefold")))
    return speedup_picture(labels, 0.47 * (len(labels) + 0.25), "speed-up: \\texttt{Qi*}$_{\\text{off}}$/\\texttt{Qi*}$_{\\text{optimized}}$")


def main():
    args = arguments("exp2.csv", "exp2_speedup.tex")
    write(args.out, picture(*exp2_summary(args.csv)))


if __name__ == "__main__":
    main()
