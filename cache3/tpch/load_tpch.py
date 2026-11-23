import os
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
DDL = os.path.join(HERE, "tpch-kit", "dbgen", "dss.ddl")
PSQL = "/opt/homebrew/opt/postgresql@18/bin/psql"
KEYS = {"part": "p_partkey", "supplier": "s_suppkey", "partsupp": "ps_partkey,ps_suppkey", "customer": "c_custkey",
        "orders": "o_orderkey", "lineitem": "l_orderkey,l_linenumber", "nation": "n_nationkey", "region": "r_regionkey"}


def psql(database, sql):
    r = subprocess.run([PSQL, "-X", "-q", "-A", "-t", "-v", "ON_ERROR_STOP=1", "-d", database], input=sql,
                       capture_output=True, text=True)
    if r.returncode:
        raise RuntimeError(r.stderr[-800:] + "\nwhile running: " + sql[:200])
    return r.stdout.strip()


STEPS = 33
done_steps = 0


def step(label, database, sql):
    global done_steps
    started = time.time()
    filled = 30 * done_steps // STEPS
    print(f"[{'#' * filled}{'-' * (30 - filled)}] {done_steps}/{STEPS}  {label:<28}", end="", flush=True)
    psql(database, sql)
    done_steps += 1
    print(f"{time.time() - started:9.1f} s", flush=True)


def main(tbl_dir, database):
    psql("postgres", f"CREATE DATABASE {database};")
    psql(database, "SET client_min_messages = warning; CREATE EXTENSION provsql CASCADE;")
    psql(database, open(DDL).read())
    for table in KEYS:
        path = os.path.abspath(os.path.join(tbl_dir, table + ".tbl"))
        step(f"copy {table}", database,
             f"\\copy {table} FROM PROGRAM '/usr/bin/sed \"s/|$//\" {path}' CSV DELIMITER '|'\n")
    for table in KEYS:
        step(f"add_provenance {table}", database,
             f"SET client_min_messages = warning; SET search_path TO public, provsql; SELECT add_provenance('{table}');")
    for table, key in KEYS.items():
        step(f"primary key {table}", database, f"ALTER TABLE {table} ADD PRIMARY KEY ({key});")
    for number, table in enumerate(KEYS):
        step(f"set_prob {table}", database,
             f"SET search_path TO public, provsql; SELECT setseed({(number + 1) / 100});\n"
             f"DO $$ BEGIN PERFORM set_prob(provenance(), 0.1 + 0.8 * random()) FROM {table}; END $$;")
    step("analyze", database, "ANALYZE;")
    print(psql(database, "SELECT string_agg(c.relname || ' ' || c.reltuples::bigint, ', ') FROM pg_class c "
                         "WHERE c.relkind = 'r' AND c.relnamespace = 'public'::regnamespace;"))
    print("database size", psql("postgres", f"SELECT pg_size_pretty(pg_database_size('{database}'));"))


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
