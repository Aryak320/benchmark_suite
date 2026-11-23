#!/usr/bin/env python3
from common import arguments, exp1_summary, qname, write

MODES = ["off", "on", "fold", "cachefold"]


def times(values):
    best = min(values)
    return " & ".join(("\\textbf{%.3f}" if v == best else "%.3f") % v for v in values)


def table(queries, data):
    out = ["\\begin{tabular}{lrrrrrr}", "\\toprule",
           "& \\multicolumn{4}{c}{time (s)} & \\multicolumn{2}{c}{hits/misses} \\\\",
           "\\cmidrule(lr){2-5}\\cmidrule(lr){6-7}", "& off & on & fold & optimized & on & optimized \\\\", "\\midrule"]
    hits = {"on": 0, "cachefold": 0}
    misses = {"on": 0, "cachefold": 0}
    for q in queries:
        lookups = []
        for mode in ("on", "cachefold"):
            h, m = round(data[(q, mode)]["hits"]), round(data[(q, mode)]["misses"])
            hits[mode] += h
            misses[mode] += m
            lookups.append(f"{h}/{m}")
        out.append(f"{qname(q)} & {times([data[(q, m)]['seconds'] for m in MODES])} & {lookups[0]} & {lookups[1]} \\\\")
    out.append("\\midrule")
    totals = [round(sum(data[(q, m)]["seconds"] for q in queries), 3) for m in MODES]
    out.append(f"All {len(queries)} & {times(totals)} & {hits['on']}/{misses['on']} & "
               f"{hits['cachefold']}/{misses['cachefold']} \\\\")
    out += ["\\bottomrule", "\\end{tabular}",
            "\\par\\vspace{2mm}{\\small off: cache and folding off; on: cache only; fold: folding only; optimized: cache and folding. "
            "Bold: the smallest time of the row.\\par}"]
    return "\n".join(out)


def main():
    args = arguments("exp1.csv", "exp1_table.tex")
    write(args.out, table(*exp1_summary(args.csv)))


if __name__ == "__main__":
    main()
