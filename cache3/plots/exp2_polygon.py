#!/usr/bin/env python3
import math

from common import GRID, INK, arguments, exp2_summary, marker, num, star, write

MODES = [("off", "off", "isA", "square"), ("cachefold", "optimized", "isD", "diamond")]


def picture(queries, data):
    queries = [q for q in queries if (q, "off") in data and (q, "cachefold") in data]
    seconds = {(q, m): data[(q, m)]["seconds"] for q in queries for m, *_ in MODES}
    low = math.floor(math.log10(min(seconds.values())))
    high = math.ceil(math.log10(max(seconds.values())))
    radius = 2.4
    n = len(queries)
    angle = lambda i: math.radians(90 - i * 360 / n)
    point = lambda r, i: (r * math.cos(angle(i)), r * math.sin(angle(i)))
    scale = lambda t: (math.log10(t) - low) / (high - low) * radius
    rings = [10.0 ** e for e in range(low + 1, high + 1)]
    out = ["\\begin{tikzpicture}[font=\\scriptsize]"]
    for ring in rings:
        path = " -- ".join(f"({num(x)},{num(y)})" for x, y in (point(scale(ring), i) for i in range(n)))
        out.append(f"\\draw[{GRID}] {path} -- cycle;")
    for i, q in enumerate(queries):
        x, y = point(radius, i)
        lx, ly = point(radius + 0.32, i)
        out.append(f"\\draw[{GRID}] (0,0) -- ({num(x)},{num(y)});")
        out.append(f"\\node[text={INK}] at ({num(lx)},{num(ly)}) {{{star(q)}}};")
    for mode, _, colour, _ in MODES:
        path = " -- ".join(f"({num(x)},{num(y)})" for x, y in (point(scale(seconds[(q, mode)]), i) for i, q in enumerate(queries)))
        out.append(f"\\draw[{colour}, line width=0.7pt, fill={colour}, fill opacity=0.07] {path} -- cycle;")
    for mode, _, colour, shape in MODES:
        for i, q in enumerate(queries):
            x, y = point(scale(seconds[(q, mode)]), i)
            out.append(marker(shape, colour, x, y, 0.055))
    label_angle = math.radians(90 - 360 / n / 2)
    for ring in rings:
        r = scale(ring)
        out.append(f"\\node[font=\\tiny, text={INK}, fill=white, fill opacity=0.8, text opacity=1, inner sep=0.4pt] "
                   f"at ({num(r * math.cos(label_angle))},{num(r * math.sin(label_angle))}) {{{ring:g} s}};")
    y = -radius - 0.6
    for k, (_, name, colour, shape) in enumerate(MODES):
        x = -2.7 + k * 2.8
        out.append(marker(shape, colour, x, y, 0.06))
        out.append(f"\\node[anchor=west, text={INK}] at ({num(x + 0.1)},{num(y)}) {{{name}}};")
    out.append("\\end{tikzpicture}")
    return "\n".join(out)


def main():
    args = arguments("exp2.csv", "exp2_polygon.tex")
    write(args.out, picture(*exp2_summary(args.csv)))


if __name__ == "__main__":
    main()
