#!/usr/bin/env python3
from common import CACHE_QUERIES, arguments, exp2_summary, qname, write


def ratio(value):
    return f"{value:.1f}$\\times$"


def line(name, tuples, alone, both, off):
    return (f"{name} & {round(tuples):,} & {round(alone['hits']):,} & {round(alone['misses']):,} & "
            f"{ratio(off / alone['seconds'])} & {round(both['hits']):,} & {round(both['misses']):,} & "
            f"{ratio(off / both['seconds'])} \\\\")


def table(data):
    queries = CACHE_QUERIES
    out = ["\\begin{tabular}{lrrrrrrr}", "\\toprule",
           " & & \\multicolumn{3}{c}{on} & \\multicolumn{3}{c}{optimized} \\\\",
           "\\cmidrule(lr){3-5}\\cmidrule(lr){6-8}",
           "Query & tuples & hits & misses & speed-up & hits & misses & speed-up \\\\", "\\midrule"]
    for q in queries:
        out.append(line(qname(q), data[(q, "cachefold")]["tuples"], data[(q, "on")], data[(q, "cachefold")],
                        data[(q, "off")]["seconds"]))
    out.append("\\midrule")
    total = lambda mode: {k: sum(data[(q, mode)][k] for q in queries) for k in ("hits", "misses", "seconds", "tuples")}
    out.append(line(f"All {len(queries)}", total("cachefold")["tuples"], total("on"), total("cachefold"),
                    total("off")["seconds"]))
    out += ["\\bottomrule", "\\end{tabular}",
            "\\par\\vspace{2mm}{\\small tuples: result tuples of the 20 variants of the query; hits and misses: "
            "average of 10 streams; speed-up: \\texttt{Qi*}$_{\\text{off}}$ divided by \\texttt{Qi*} in the "
            "mode of the column.\\par}"]
    return "\n".join(out)


def main():
    args = arguments("exp2.csv", "exp2_table.tex")
    _, data = exp2_summary(args.csv)
    write(args.out, table(data))


if __name__ == "__main__":
    main()
