import csv
import json
import os
import re
import subprocess
import tempfile
import time

CACHE3 = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
QUERIES = os.path.join(CACHE3, "queries")
RESULTS = os.path.join(CACHE3, "results")
RESTART = os.path.join(CACHE3, "lib", "restart_server.sh")
PG = "/opt/homebrew/opt/postgresql@18/bin"
D4_DIR = os.path.expanduser("~/d4_arm64/bin")
PROVSQL_SOURCE = os.path.expanduser("~/provsql")
DATABASE = "provsql_tpch_005"
SCALE = "0.05"
TIMEOUT = 300
CALL = "probability_evaluate(provenance(), 'compilation', 'd4')"
END = "__experiment_end__"
SETTINGS = {"on": ("on", "off"), "off": ("off", "off"), "fold": ("off", "on"), "cachefold": ("on", "on")}
MESSAGES = ("WARNING", "DETAIL", "HINT", "NOTICE", "CONTEXT")
FIELDS = ["experiment", "repetition", "mode", "phase", "position", "query", "variant", "file", "status", "seconds", "tuples",
          "hits", "misses", "inserts", "evictions", "rejections", "entries", "bytes", "swap_mib", "swapins", "swapouts",
          "load1", "methods", "finished_at", "probabilities", "database", "scale", "timeout_s", "d4", "provsql_version",
          "provsql_commit", "server_version", "shared_buffers", "seed"]


class Session:
    def __init__(self, database):
        self.process = subprocess.Popen([os.path.join(PG, "psql"), "-X", "-q", "-A", "-t", "-d", database],
                                        stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                        text=True, bufsize=1)
        self.run("SET client_min_messages = warning;\nSET search_path TO public, provsql;\n"
                 f"SET provsql.tool_search_path = '{D4_DIR}';")

    def run(self, sql):
        self.process.stdin.write(sql.rstrip() + f"\nSELECT '{END}';\n")
        self.process.stdin.flush()
        lines = []
        while True:
            line = self.process.stdout.readline()
            if line == "":
                raise RuntimeError("psql ended: " + "".join(lines)[-500:])
            line = line.rstrip("\n")
            if line == END:
                return lines
            lines.append(line)

    def close(self):
        self.process.stdin.close()
        self.process.wait()


class Output:
    def __init__(self, path, force, constants, append=False):
        if append and not os.path.exists(path):
            raise SystemExit(f"{path} does not exist: there is nothing to append to")
        if os.path.exists(path) and not force and not append:
            raise SystemExit(f"{path} exists: pass --force to overwrite it")
        os.makedirs(os.path.dirname(os.path.abspath(path)), exist_ok=True)
        self.file = open(path, "a" if append else "w", newline="")
        self.writer = csv.DictWriter(self.file, FIELDS)
        if not append:
            self.writer.writeheader()
        self.file.flush()
        self.constants = constants

    def write(self, **row):
        self.writer.writerow({**self.constants, **row})
        self.file.flush()

    def close(self):
        self.file.close()


def file_of(query, variant):
    return f"q{query}_v{variant:02d}.sql"


def query_text(query, variant):
    with open(os.path.join(QUERIES, file_of(query, variant))) as f:
        return f.read().rstrip().rstrip(";")


def statement(query, variant):
    return f"SELECT *, {CALL} FROM ({query_text(query, variant)}) t;"


def provenance_statement(query, variant):
    return f"SELECT *, provenance() FROM ({query_text(query, variant)}) t;"


def preflight(database, statements):
    d4 = os.path.join(D4_DIR, "d4")
    kind = subprocess.run(["file", "-L", d4], capture_output=True, text=True).stdout
    if "arm64" not in kind:
        raise SystemExit(f"{d4} is not an arm64 binary: {kind.strip()}")
    missing = [file_of(q, v) for q, v in statements if not os.path.exists(os.path.join(QUERIES, file_of(q, v)))]
    if missing:
        raise SystemExit("missing query files: " + " ".join(missing))
    if subprocess.run([os.path.join(PG, "pg_isready"), "-q"]).returncode:
        raise SystemExit("the PostgreSQL server does not accept connections")
    found = subprocess.run([os.path.join(PG, "psql"), "-X", "-A", "-t", "-d", "postgres", "-c",
                            f"SELECT count(*) FROM pg_database WHERE datname = '{database}';"],
                           capture_output=True, text=True).stdout.strip()
    if found != "1":
        raise SystemExit(f"database {database} does not exist")


def environment(database, timeout, seed):
    session = Session(database)
    value = lambda sql: session.run(sql)[-1]
    commit = subprocess.run(["git", "-C", PROVSQL_SOURCE, "rev-parse", "--short", "HEAD"],
                            capture_output=True, text=True).stdout.strip()
    info = dict(database=database, scale=SCALE, timeout_s=timeout, d4=os.path.realpath(os.path.join(D4_DIR, "d4")),
                provsql_version=value("SELECT extversion FROM pg_extension WHERE extname = 'provsql';"),
                provsql_commit=commit, server_version=value("SHOW server_version;"),
                shared_buffers=value("SHOW shared_buffers;"), seed=seed)
    session.close()
    return info


def open_session(database, mode, timeout):
    use_cache, use_fold = SETTINGS[mode]
    session = Session(database)
    session.run(f"SET statement_timeout = '{timeout}s';\nSET provsql.prob_cache = {use_cache};\n"
                f"SET provsql.idp_fold = {use_fold};")
    return session


def restart_server():
    started = time.time()
    done = subprocess.run([RESTART], capture_output=True, text=True)
    if done.returncode:
        raise SystemExit("server restart failed: " + done.stderr[-300:])
    time.sleep(1)
    print(f"  server restarted in {time.time() - started:.1f} s", flush=True)


def warm_up_d4():
    with tempfile.TemporaryDirectory() as folder:
        path = os.path.join(folder, "tiny.cnf")
        with open(path, "w") as f:
            f.write("p cnf 2 1\n1 2 0\n")
        subprocess.run([os.path.join(D4_DIR, "d4"), "-dDNNF", path, f"-out={path}.nnf"], capture_output=True)


def swap_used():
    out = subprocess.run(["/usr/sbin/sysctl", "-n", "vm.swapusage"], capture_output=True, text=True).stdout
    match = re.search(r"used = ([0-9.]+)M", out)
    return float(match.group(1)) if match else -1.0


def swap_activity():
    out = subprocess.run(["/usr/bin/vm_stat"], capture_output=True, text=True).stdout
    return tuple(int(re.search(rf"{label}:\s+(\d+)", out).group(1)) for label in ("Swapins", "Swapouts"))


def cache_stats(session):
    return json.loads(session.run("SELECT prob_cache_stats();")[0])


def measure(session, query, variant, provenance_only=False):
    sql = provenance_statement(query, variant) if provenance_only else statement(query, variant)
    session.run("SET provsql.last_eval_method = '';")
    before = cache_stats(session)
    swap_before = swap_activity()
    started = time.perf_counter()
    lines = session.run(sql)
    elapsed = time.perf_counter() - started
    swap_after = swap_activity()
    methods = session.run("SELECT current_setting('provsql.last_eval_method');")[0]
    after = cache_stats(session)
    errors = [l for l in lines if l.startswith(("ERROR", "psql:", "FATAL"))]
    status = "ok" if not errors else "timeout" if "statement timeout" in errors[0] else errors[0][:200]
    rows = [] if errors else [l.split("|") for l in lines if "|" in l and not l.startswith(MESSAGES)]
    pairs = [] if provenance_only else [[r[-1], r[-2]] for r in rows]
    return dict(query=f"q{query}", variant=variant, file=file_of(query, variant), status=status, seconds=round(elapsed, 3),
                tuples=len(rows), entries=after["entries"], bytes=after["bytes"], swap_mib=swap_used(),
                swapins=swap_after[0] - swap_before[0], swapouts=swap_after[1] - swap_before[1],
                load1=round(os.getloadavg()[0], 2), methods=methods.replace(",", " "),
                finished_at=time.strftime("%Y-%m-%d %H:%M:%S"), probabilities=json.dumps(pairs, separators=(",", ":")),
                **{k: after[k] - before[k] for k in ("hits", "misses", "inserts", "evictions", "rejections")})


def report(label, position, total, row):
    print(f"  {label} {position}/{total} {row['query']} v{row['variant']}: {row['status']}, {row['tuples']} tuples, "
          f"{row['seconds']:.3f} s, hits {row['hits']}, misses {row['misses']}, evictions {row['evictions']}", flush=True)
    if row["status"] not in ("ok", "timeout"):
        raise SystemExit(f"stopped: {row['query']} variant {row['variant']}: {row['status']}")
