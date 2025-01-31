-- start query 9 in stream 0 using template query32.tpl
PROVENANCE OF (
SELECT p.p_name, p.p_mfgr, p.p_partkey, p.p_retailprice
FROM part p
INNER JOIN partsupp ps ON p.p_partkey = ps.ps_partkey
INNER JOIN supplier s  ON ps.ps_suppkey = s.s_suppkey
INNER JOIN nation n    ON s.s_nationkey = n.n_nationkey
INNER JOIN region r    ON n.n_regionkey = r.r_regionkey
WHERE r.r_regionkey = 4
AND ps.ps_supplycost < 844);

-- end query 9 in stream 0 using template query32.tpl

