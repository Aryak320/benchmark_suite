#!/usr/bin/env python3
import argparse
import csv
import datetime
import os
import random
import re

HERE = os.path.dirname(os.path.abspath(__file__))
TEMPLATES = os.path.join(HERE, "..", "query_templates")
QUERIES = [1, 3, 4, 5, 6, 7, 9, 10, 12, 14, 19]
VARIANTS = 20
LIMIT = 100
DRAWS = 50
DISTINCT_DRAWS = 24
DISTINCT = {1, 5, 7}
REPLACED = {7: {8: 21}}

SEGMENTS = ["AUTOMOBILE", "BUILDING", "FURNITURE", "HOUSEHOLD", "MACHINERY"]
SHIPMODES = ["REG AIR", "AIR", "RAIL", "TRUCK", "MAIL", "FOB", "SHIP"]
REGIONS = ["AFRICA", "AMERICA", "ASIA", "EUROPE", "MIDDLE EAST"]
NATIONS = ["ALGERIA", "ARGENTINA", "BRAZIL", "CANADA", "EGYPT", "ETHIOPIA", "FRANCE", "GERMANY", "INDIA", "INDONESIA", "IRAN",
           "IRAQ", "JAPAN", "JORDAN", "KENYA", "MOROCCO", "MOZAMBIQUE", "PERU", "CHINA", "ROMANIA", "SAUDI ARABIA", "VIETNAM",
           "RUSSIA", "UNITED KINGDOM", "UNITED STATES"]
COLORS = """almond antique aquamarine azure beige bisque black blanched blue blush brown burlywood burnished
chartreuse chiffon chocolate coral cornflower cornsilk cream cyan dark deep dim dodger drab firebrick floral forest
frosted gainsboro ghost goldenrod green grey honeydew hot indian ivory khaki lace lavender lawn lemon light lime linen
magenta maroon medium metallic midnight mint misty moccasin navajo navy olive orange orchid pale papaya peach peru pink
plum powder puff purple red rose rosy royal saddle salmon sandy seashell sienna sky slate smoke snow spring steel tan
thistle tomato turquoise violet wheat white yellow""".split()
assert len(COLORS) == 92

TARGETS = {1: {"interval '117' day": 1},
           3: {"'BUILDING'": 1, "TO_DATE('1995-03-15', 'YYYY-MM-DD')": 1, "TO_DATE('1995-05-15', 'YYYY-MM-DD')": 1},
           4: {"date '1993-07-01'": 1, "date '1993-10-01'": 1},
           5: {"'AMERICA'": 1, "date '1995-01-01'": 2},
           6: {"date '1995-01-01'": 2, "0.09 - 0.01 and 0.09 + 0.01": 1, "l_quantity < 24": 1},
           7: {"'RUSSIA'": 2, "'INDIA'": 2},
           9: {"'%orchid%'": 1},
           10: {"date '1993-10-01'": 2},
           12: {"('TRUCK', 'AIR')": 1, "date '1997-01-01'": 2},
           14: {"date '1995-09-01'": 2},
           19: {"'Brand#54'": 1, "'Brand#51'": 1, "'Brand#21'": 1,
                "l_quantity >= 4 and l_quantity <= 4 + 10": 1, "l_quantity >= 11 and l_quantity <= 11 + 10": 1,
                "l_quantity >= 28 and l_quantity <= 28 + 10": 1}}


def add_months(d, months):
    m = d.month - 1 + months
    return datetime.date(d.year + m // 12, m % 12 + 1, 1)


def month_between(rng, first, last):
    count = (last.year - first.year) * 12 + last.month - first.month + 1
    return add_months(first, rng.randrange(count))


def brand(rng):
    return f"Brand#{rng.randint(1, 5)}{rng.randint(1, 5)}"


def parameters(q, rng):
    if q == 1:
        return {"interval '117' day": f"interval '{rng.randint(60, 120)}' day"}
    if q == 3:
        d = datetime.date(1995, 3, 1) + datetime.timedelta(days=rng.randrange(31))
        return {"'BUILDING'": f"'{rng.choice(SEGMENTS)}'",
                "TO_DATE('1995-03-15', 'YYYY-MM-DD')": f"TO_DATE('{d}', 'YYYY-MM-DD')",
                "TO_DATE('1995-05-15', 'YYYY-MM-DD')": f"TO_DATE('{d + datetime.timedelta(days=61)}', 'YYYY-MM-DD')"}
    if q == 4:
        d = month_between(rng, datetime.date(1993, 1, 1), datetime.date(1997, 10, 1))
        return {"date '1993-07-01'": f"date '{d}'", "date '1993-10-01'": f"date '{add_months(d, 3)}'"}
    if q == 5:
        return {"'AMERICA'": f"'{rng.choice(REGIONS)}'", "date '1995-01-01'": f"date '{rng.randint(1993, 1997)}-01-01'"}
    if q == 6:
        disc = rng.randint(2, 9) / 100
        return {"date '1995-01-01'": f"date '{rng.randint(1993, 1997)}-01-01'",
                "0.09 - 0.01 and 0.09 + 0.01": f"{disc:.2f} - 0.01 and {disc:.2f} + 0.01",
                "l_quantity < 24": f"l_quantity < {rng.randint(24, 25)}"}
    if q == 7:
        first, second = rng.sample(NATIONS, 2)
        return {"'RUSSIA'": f"'{first}'", "'INDIA'": f"'{second}'"}
    if q == 9:
        return {"'%orchid%'": f"'%{rng.choice(COLORS)}%'"}
    if q == 10:
        d = month_between(rng, datetime.date(1993, 2, 1), datetime.date(1995, 1, 1))
        return {"date '1993-10-01'": f"date '{d}'"}
    if q == 12:
        m1, m2 = rng.sample(SHIPMODES, 2)
        return {"('TRUCK', 'AIR')": f"('{m1}', '{m2}')",
                "date '1997-01-01'": f"date '{rng.randint(1993, 1997)}-01-01'"}
    if q == 14:
        d = month_between(rng, datetime.date(1993, 1, 1), datetime.date(1997, 12, 1))
        return {"date '1995-09-01'": f"date '{d}'"}
    if q == 19:
        q1, q2, q3 = rng.randint(1, 10), rng.randint(10, 20), rng.randint(20, 30)
        return {"'Brand#54'": f"'{brand(rng)}'", "'Brand#51'": f"'{brand(rng)}'", "'Brand#21'": f"'{brand(rng)}'",
                "l_quantity >= 4 and l_quantity <= 4 + 10": f"l_quantity >= {q1} and l_quantity <= {q1} + 10",
                "l_quantity >= 11 and l_quantity <= 11 + 10": f"l_quantity >= {q2} and l_quantity <= {q2} + 10",
                "l_quantity >= 28 and l_quantity <= 28 + 10": f"l_quantity >= {q3} and l_quantity <= {q3} + 10"}
    raise ValueError(q)


def draw(q, number):
    return parameters(q, random.Random(f"tpch-stream-{q}-{number}"))


def replace_in_turn(template, subs):
    sql = template
    for target, value in subs.items():
        sql = sql.replace(target, value)
    return sql


def replace_at_once(template, subs):
    pattern = re.compile("|".join(re.escape(t) for t in subs))
    return pattern.sub(lambda m: subs[m.group(0)], template)


def streams(q, template):
    found = {}
    if q not in DISTINCT:
        for s in range(1, DRAWS + 1):
            subs = draw(q, s)
            found[s] = (subs, replace_in_turn(template, subs))
        return found
    seen, number = set(), 0
    for s in range(1, DISTINCT_DRAWS + 1):
        while True:
            number += 1
            subs = draw(q, number)
            if tuple(subs.values()) not in seen:
                break
        seen.add(tuple(subs.values()))
        found[s] = (subs, replace_at_once(template, subs))
    return found


def choose(q, template, found):
    swap = REPLACED.get(q, {})
    order = [swap.get(s, s) for s in sorted(found) if s not in swap.values()]
    chosen, seen = [], set()
    for s in order:
        subs, text = found[s]
        if replace_at_once(template, subs) != text or text in seen:
            continue
        seen.add(text)
        chosen.append(s)
        if len(chosen) == VARIANTS:
            break
    assert len(chosen) == VARIANTS, q
    return chosen


def select_of(text):
    kept = "\n".join(line for line in text.split("\n") if not line.strip().startswith("--"))
    selects = [s.strip() for s in kept.split(";") if s.strip().lower().startswith("select")]
    assert len(selects) == 1
    return selects[0]


def strip_limit(sql):
    return re.sub(r"\blimit\s+\d+\s*$", "", sql, flags=re.I).rstrip()


def original_text(q, template):
    sql = select_of(template)
    if q == 5:
        sql = re.sub(r"\border\s+by\b.*$", "", sql, flags=re.I | re.S).rstrip()
    return f"{strip_limit(sql)} LIMIT {LIMIT}"


def variant_text(q, text):
    sql = f"{strip_limit(select_of(text))} LIMIT {LIMIT}"
    if q == 5:
        sql = re.sub(r"\border\s+by\b.*?(LIMIT \d+)$", r"\1", sql, flags=re.S)
    return sql


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default=os.path.join(HERE, "queries"), help="folder that receives the files")
    args = ap.parse_args()
    os.makedirs(args.out, exist_ok=True)
    rows = []
    for q in QUERIES:
        with open(os.path.join(TEMPLATES, f"{q}_tpch.sql")) as f:
            template = f.read()
        for target, count in TARGETS[q].items():
            assert template.count(target) == count, (q, target, template.count(target))
        found = streams(q, template)
        chosen = choose(q, template, found)
        texts = {1: original_text(q, template)}
        sources = {1: ("original", "")}
        for variant, s in zip(range(2, VARIANTS + 1), chosen[1:]):
            subs, text = found[s]
            texts[variant] = variant_text(q, text)
            sources[variant] = (f"stream {s}", " ; ".join(f"{a} -> {b}" for a, b in subs.items()))
        assert len(set(" ".join(t.split()) for t in texts.values())) == VARIANTS, q
        for variant in sorted(texts):
            file = f"q{q}_v{variant:02d}.sql"
            with open(os.path.join(args.out, file), "w") as f:
                f.write(texts[variant] + ";\n")
            rows.append(dict(query=f"q{q}", variant=variant, file=file, source=sources[variant][0],
                             constants=sources[variant][1]))
    with open(os.path.join(args.out, "variants.csv"), "w", newline="") as f:
        w = csv.DictWriter(f, ["query", "variant", "file", "source", "constants"])
        w.writeheader()
        w.writerows(rows)
    print("wrote", len(rows), "query files and variants.csv in", args.out)


if __name__ == "__main__":
    main()
