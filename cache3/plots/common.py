import argparse
import csv
import math
import os
import statistics
import sys

CACHE3 = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RESULTS = os.path.join(CACHE3, "results")
FIGURES = os.path.join(CACHE3, "figures")
GRID = "black!18"
INK = "black!80"
CACHE_ONLY = "red!80!black"
FOLD_ONLY = "isB"
CACHE_QUERIES = ["q3", "q4", "q10", "q12"]
FOLD_QUERIES = ["q6", "q14", "q19"]
NOGAIN_QUERIES = ["q5", "q7", "q9"]


def arguments(csv_name, figure_name):
    ap = argparse.ArgumentParser()
    ap.add_argument("--csv", default=os.path.join(RESULTS, csv_name))
    ap.add_argument("--out", default=os.path.join(FIGURES, figure_name))
    return ap.parse_args()


def write(path, text):
    os.makedirs(os.path.dirname(os.path.abspath(path)), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write(text.rstrip("\n") + "\n")
    print("wrote", path)


def read_rows(path):
    if not os.path.exists(path):
        raise SystemExit(f"{path} does not exist: run the experiment first")
    csv.field_size_limit(sys.maxsize)
    with open(path, newline="") as f:
        return list(csv.DictReader(f))


def seconds_of(row):
    if row["status"] == "ok":
        return float(row["seconds"])
    if row["status"] == "timeout":
        return float(row["timeout_s"])
    raise SystemExit(f"{row['query']} variant {row['variant']} in mode {row['mode']} has status {row['status']}")


def mean(values):
    return math.fsum(values) / len(values)


def by_number(names):
    return sorted(names, key=lambda q: int(q[1:]))


def exp1_summary(path):
    groups = {}
    for row in read_rows(path):
        if row["phase"] == "measured":
            groups.setdefault((row["query"], row["mode"]), []).append(row)
    data = {}
    for key, rows in groups.items():
        times = [seconds_of(row) for row in rows]
        reached = any(row["status"] == "timeout" for row in rows)
        data[key] = dict(seconds=float(rows[0]["timeout_s"]) if reached else round(mean(times), 4),
                         hits=mean([int(row["hits"]) for row in rows]), misses=mean([int(row["misses"]) for row in rows]),
                         tuples=mean([int(row["tuples"]) for row in rows]))
    return by_number({q for q, _ in data}), data


def exp2_summary(path):
    sessions = {}
    for row in read_rows(path):
        if row["phase"] == "measured":
            cell = sessions.setdefault((row["query"], row["mode"], row["repetition"]),
                                       dict(seconds=[], hits=[], misses=[], tuples=[]))
            cell["seconds"].append(seconds_of(row))
            for name in ("hits", "misses", "tuples"):
                cell[name].append(int(row[name]))
    groups = {}
    for (query, mode, _), cell in sessions.items():
        group = groups.setdefault((query, mode), dict(seconds=[], hits=[], misses=[], tuples=[]))
        group["seconds"].append(math.fsum(cell["seconds"]))
        for name in ("hits", "misses", "tuples"):
            group[name].append(sum(cell[name]))
    average = lambda key: statistics.median if key[1] == "fold" else mean
    data = {key: {name: average(key)(values) for name, values in group.items()} for key, group in groups.items()}
    return by_number({q for q, _ in data}), data


def qname(query):
    return "\\texttt{" + query.upper() + "}"


def star(query):
    return "\\texttt{" + query.upper() + "*}"


def num(x):
    return f"{x:.3f}"


def marker(shape, colour, x, y, size):
    style = f"fill={colour}, draw=white, line width=0.2pt"
    if shape == "square":
        return f"\\filldraw[{style}] ({num(x - size)},{num(y - size)}) rectangle ({num(x + size)},{num(y + size)});"
    t = size * 1.35
    return (f"\\filldraw[{style}] ({num(x)},{num(y + t)}) -- ({num(x + t)},{num(y)}) "
            f"-- ({num(x)},{num(y - t)}) -- ({num(x - t)},{num(y)}) -- cycle;")


def ratio_range(ratios):
    return (min(-0.3, math.floor(math.log10(min(ratios)) * 10) / 10),
            max(2.3, math.ceil(math.log10(max(ratios)) * 10) / 10))


def power_ticks(lo, hi):
    return [10.0 ** e for e in range(math.ceil(lo), math.floor(hi) + 1)]


def ratio_text(ratio):
    return f"{ratio:.1f}$\\times$" if ratio >= 1 else f"{ratio:.2f}$\\times$"


def speedup_picture(labels, height, axis):
    lo, hi = ratio_range([ratio for _, ratio in labels])
    width = 4.9
    unit = width / (hi - lo)
    pos = lambda ratio: (math.log10(ratio) - lo) * unit
    base = pos(1.0)
    row_height = height / (len(labels) + 0.25)
    bar = 0.15 * row_height / 0.47
    out = ["\\begin{tikzpicture}[font=\\scriptsize]"]
    for value in power_ticks(lo, hi):
        x = pos(value)
        out.append(f"\\draw[{GRID}] ({num(x)},0) -- ({num(x)},{num(height)});")
        out.append(f"\\node[below, text={INK}] at ({num(x)},0) {{{value:g}$\\times$}};")
    for k, (name, ratio) in enumerate(labels):
        y = height - row_height * (k + 0.6)
        if k == len(labels) - 1:
            sep = y + row_height * 0.52
            out.append(f"\\draw[{INK}] (0,{num(sep)}) -- ({num(width)},{num(sep)});")
        x = pos(ratio)
        out.append(f"\\fill[isD!75] ({num(min(x, base))},{num(y - bar)}) rectangle ({num(max(x, base))},{num(y + bar)});")
        out.append(f"\\node[left, text={INK}] at (0,{num(y)}) {{{name}}};")
        out.append(f"\\node[right, text={INK}, inner sep=1.5pt] at ({num(max(x, base))},{num(y)}) {{{ratio_text(ratio)}}};")
    out.append(f"\\draw[{INK}] ({num(base)},0) -- ({num(base)},{num(height)});")
    out.append(f"\\draw[{INK}] (0,0) -- ({num(width)},0);")
    out.append(f"\\node at ({num(width / 2)},-0.62) {{{axis}}};")
    out.append("\\end{tikzpicture}")
    return "\n".join(out)


def speedup_pair(queries, data, mode, colour, name):
    rows = [(qname(q), data[(q, "off")]["seconds"], data[(q, mode)]["seconds"], data[(q, "cachefold")]["seconds"])
            for q in queries]
    rows.append((f"All {len(queries)}", sum(r[1] for r in rows), sum(r[2] for r in rows), sum(r[3] for r in rows)))
    lo, hi = ratio_range([r[1] / r[i] for r in rows for i in (2, 3)])
    width = 4.9
    unit = width / (hi - lo)
    pos = lambda ratio: (math.log10(ratio) - lo) * unit
    base = pos(1.0)
    row = 0.84
    height = row * len(rows) + 0.08
    bar = 0.14
    out = ["\\begin{tikzpicture}[font=\\scriptsize]"]
    for value in power_ticks(lo, hi):
        x = pos(value)
        out.append(f"\\draw[{GRID}] ({num(x)},0) -- ({num(x)},{num(height)});")
        out.append(f"\\node[below, text={INK}] at ({num(x)},0) {{{value:g}$\\times$}};")
    for k, (label, off, alone, both) in enumerate(rows):
        y = height - row * (k + 0.5)
        if k == len(rows) - 1:
            sep = height - row * k
            out.append(f"\\draw[{INK}] (0,{num(sep)}) -- ({num(width)},{num(sep)});")
        for ratio, fill, text, yy in ((off / alone, colour, colour, y + 0.14), (off / both, "isD!85", INK, y - 0.14)):
            x = pos(ratio)
            out.append(f"\\fill[{fill}] ({num(min(x, base))},{num(yy - bar / 2)}) rectangle ({num(max(x, base))},{num(yy + bar / 2)});")
            out.append(f"\\node[right, text={text}, inner sep=1.5pt] at ({num(max(x, base))},{num(yy)}) {{{ratio_text(ratio)}}};")
        out.append(f"\\node[left, text={INK}] at (0,{num(y)}) {{{label}}};")
    out.append(f"\\draw[{INK}] ({num(base)},0) -- ({num(base)},{num(height)});")
    out.append(f"\\draw[{INK}] (0,0) -- ({num(width)},0);")
    ratio = lambda m: "\\texttt{Qi*}$_{\\text{off}}$/\\texttt{Qi*}$_{\\text{" + m + "}}$"
    out.append(f"\\node at ({num(width / 2)},-0.62) {{speed-up:}};")
    y = -1.0
    for x, (fill, legend) in zip((0.2, 2.4), ((colour, ratio(mode)), ("isD!85", ratio("optimized")))):
        out.append(f"\\fill[{fill}] ({num(x)},{num(y - 0.06)}) rectangle ({num(x + 0.2)},{num(y + 0.06)});")
        out.append(f"\\node[anchor=west, text={INK}] at ({num(x + 0.22)},{num(y)}) {{{legend}}};")
    out.append("\\end{tikzpicture}")
    return "\n".join(out)
