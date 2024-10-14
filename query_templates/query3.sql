-- start query 3 in stream 0 using template query42.tpl
PROVENANCE OF (
SELECT s.s_name, p.p_brand, p.p_name
FROM supplier s, partsupp ps, part p, nation n, region r
WHERE s.s_suppkey = ps.ps_suppkey
AND ps.ps_partkey = p.p_partkey
AND s.s_nationkey = n.n_nationkey
AND n.n_regionkey = r.r_regionkey
AND r.r_regionkey = 1
AND ps.ps_supplycost >= 904
AND ps.ps_supplycost <= 1715
GROUP BY p.p_brand, p.p_name, s.s_name);

-- end query 3 in stream 0 using template query42.tpl

