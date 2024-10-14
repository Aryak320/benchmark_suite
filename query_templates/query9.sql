-- start query 9 in stream 0 using template query45.tpl
PROVENANCE OF (
SELECT p.p_type, p.p_name, s.s_name, ps.ps_supplycost
FROM part p, partsupp ps, supplier s
WHERE p.p_partkey = ps.ps_partkey
AND ps.ps_suppkey = s.s_suppkey
AND p.p_size >= 45
AND p.p_size <= 49
GROUP BY p.p_type, p.p_name, s.s_name, ps.ps_supplycost);

-- end query 9 in stream 0 using template query45.tpl

