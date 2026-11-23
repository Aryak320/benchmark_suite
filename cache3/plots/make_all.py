#!/usr/bin/env python3
import argparse
import os
import subprocess
import sys

from common import FIGURES, RESULTS, write

HERE = os.path.dirname(os.path.abspath(__file__))
PLOTS = {"exp1.csv": ["exp1_scatter", "exp1_speedup", "exp1_table"],
         "exp2.csv": ["exp2_polygon", "exp2_speedup", "exp2_cache_speedup", "exp2_fold_speedup", "exp2_nogain", "exp2_table"]}


def panel(body, caption, height):
    return (f"\\begin{{minipage}}[c][{height}][s]{{7.7cm}}\\centering\n\\vspace{{1mm}}\\vfill\n{body}\n"
            f"\\par\\vfill{{\\small {caption}}}\\par\\vspace{{1.5mm}}\n\\end{{minipage}}")


def grid(rows):
    lines = ["{\\setlength{\\tabcolsep}{1pt}", "\\begin{tabular}{cc}"]
    for left, right in rows:
        lines += [left, "&", right, "\\\\"]
    lines.append("\\end{tabular}}")
    return "\n".join(lines)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--results", default=RESULTS)
    ap.add_argument("--figures", default=FIGURES)
    args = ap.parse_args()
    present = set()
    for csv_name, names in PLOTS.items():
        path = os.path.join(args.results, csv_name)
        if not os.path.exists(path):
            print("skipped:", path, "does not exist")
            continue
        present.add(csv_name)
        for name in names:
            subprocess.run([sys.executable, "-B", os.path.join(HERE, f"{name}.py"), "--csv", path,
                            "--out", os.path.join(args.figures, f"{name}.tex")], check=True)
    body = lambda name: open(os.path.join(args.figures, f"{name}.tex"), encoding="utf-8").read().rstrip("\n")
    if "exp1.csv" in present:
        write(os.path.join(args.figures, "exp1_figure.tex"), grid([
            (panel(body("exp1_scatter"), "(a) running times in the off and optimized modes", "7.25cm"),
             panel(body("exp1_speedup"), "(b) speed-up of the optimized mode", "7.25cm"))]))
    if "exp2.csv" in present:
        write(os.path.join(args.figures, "exp2_figure.tex"), grid([
            (panel(body("exp2_polygon"), "(a) \\texttt{Qi*} in the off and optimized modes", "7.6cm"),
             panel(body("exp2_speedup"), "(b) the speed-up of the optimized mode", "7.6cm")),
            (panel(body("exp2_cache_speedup"), "(c) speed-ups of the on and optimized modes", "6.6cm"),
             panel(body("exp2_nogain"), "(d) the speed-up of the optimized mode for \\texttt{Q5}, \\texttt{Q7} and \\texttt{Q9}", "6.6cm"))]))


if __name__ == "__main__":
    main()
