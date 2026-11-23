#!/usr/bin/env python3
import math

from common import GRID, INK, NOGAIN_QUERIES, arguments, exp2_summary, num, qname, write


def picture(data):
    queries = NOGAIN_QUERIES
    total = lambda mode: sum(data[(q, mode)]["seconds"] for q in queries)
    rows = [(qname(q), data[(q, "off")]["seconds"] / data[(q, "cachefold")]["seconds"]) for q in queries]
    rows.append((f"All {len(queries)}", total("off") / total("cachefold")))
    low, high = 0.5, 2.0
    while min(r for _, r in rows) < low:
        low /= 2
    while max(r for _, r in rows) > high:
        high *= 2
    width = 5.4
    unit = width / (math.log10(high) - math.log10(low))
    pos = lambda ratio: (math.log10(ratio) - math.log10(low)) * unit
    base = pos(1.0)
    row = 0.56
    height = row * len(rows) + 0.06
    bar = 0.2
    out = ["\\begin{tikzpicture}[font=\\scriptsize]"]
    value = low
    while value <= high:
        x = pos(value)
        out.append(f"\\draw[{GRID}] ({num(x)},0) -- ({num(x)},{num(height)});")
        out.append(f"\\node[below, text={INK}] at ({num(x)},0) {{{value:g}$\\times$}};")
        value *= 2
    for k, (name, ratio) in enumerate(rows):
        y = height - row * (k + 0.5)
        if k == len(rows) - 1:
            sep = height - row * k
            out.append(f"\\draw[{INK}] (0,{num(sep)}) -- ({num(width)},{num(sep)});")
        x = pos(ratio)
        out.append(f"\\fill[isD!85] ({num(min(x, base))},{num(y - bar / 2)}) rectangle ({num(max(x, base))},{num(y + bar / 2)});")
        out.append(f"\\node[left, text={INK}] at (0,{num(y)}) {{{name}}};")
        out.append(f"\\node[right, text={INK}, inner sep=1.5pt] at ({num(max(x, base))},{num(y)}) {{{ratio:.2f}$\\times$}};")
    out.append(f"\\draw[{INK}] ({num(base)},0) -- ({num(base)},{num(height)});")
    out.append(f"\\draw[{INK}] (0,0) -- ({num(width)},0);")
    out.append(f"\\node at ({num(width / 2)},-0.62) {{speed-up: \\texttt{{Qi*}}$_{{\\text{{off}}}}$/\\texttt{{Qi*}}$_{{\\text{{optimized}}}}$}};")
    out.append("\\end{tikzpicture}")
    return "\n".join(out)


def main():
    args = arguments("exp2.csv", "exp2_nogain.tex")
    _, data = exp2_summary(args.csv)
    write(args.out, picture(data))


if __name__ == "__main__":
    main()
