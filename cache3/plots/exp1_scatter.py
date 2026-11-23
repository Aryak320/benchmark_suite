#!/usr/bin/env python3
import math

from common import GRID, INK, arguments, exp1_summary, marker, num, qname, write

LABELS = {"q1": "left", "q3": "left", "q4": "above", "q5": "below right", "q6": "above", "q7": "right", "q9": "left",
          "q10": "right", "q12": "left", "q14": "right", "q19": "below"}


def picture(queries, data):
    values = [data[(q, m)]["seconds"] for q in queries for m in ("off", "cachefold")]
    lo = min(-2, math.floor(math.log10(min(values))))
    hi = max(3, math.ceil(math.log10(max(values))))
    side = 5.2
    unit = side / (hi - lo)
    pos = lambda t: (math.log10(t) - lo) * unit
    out = ["\\begin{tikzpicture}[font=\\scriptsize]"]
    for e in range(lo, hi + 1):
        v = (e - lo) * unit
        out.append(f"\\draw[{GRID}] ({num(v)},0) -- ({num(v)},{num(side)});")
        out.append(f"\\draw[{GRID}] (0,{num(v)}) -- ({num(side)},{num(v)});")
        out.append(f"\\node[below, text={INK}] at ({num(v)},0) {{{10.0 ** e:g}}};")
        out.append(f"\\node[left, text={INK}] at (0,{num(v)}) {{{10.0 ** e:g}}};")
    out.append(f"\\draw[{INK}] (0,0) rectangle ({num(side)},{num(side)});")
    out.append(f"\\draw[{INK}, dashed] (0,0) -- ({num(side)},{num(side)});")
    for q in queries:
        x, y = pos(data[(q, "off")]["seconds"]), pos(data[(q, "cachefold")]["seconds"])
        out.append(marker("diamond", "isD", x, y, 0.075))
        out.append(f"\\node[{LABELS[q]}=0.5mm, inner sep=0.5pt] at ({num(x)},{num(y)}) {{{qname(q)}}};")
    out.append(f"\\node at ({num(side / 2)},-0.62) {{$t_{{\\text{{off}}}}$ (s)}};")
    out.append(f"\\node[rotate=90] at (-0.82,{num(side / 2)}) {{$t_{{\\text{{optimized}}}}$ (s)}};")
    out.append("\\end{tikzpicture}")
    return "\n".join(out)


def main():
    args = arguments("exp1.csv", "exp1_scatter.tex")
    write(args.out, picture(*exp1_summary(args.csv)))


if __name__ == "__main__":
    main()
