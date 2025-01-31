-- start query 1 in stream 0 using template query9a.tpl
SELECT c.c_name, o.o_orderstatus
FROM customer c, orders o, partsupp ps, lineitem l
WHERE c.c_custkey = o.o_custkey
AND o.o_orderkey = l.l_orderkey
AND l.l_partkey = ps.ps_partkey
AND c.c_nationkey = 12
AND c_acctbal > 5678 
GROUP BY o.o_orderstatus, c.c_name;

-- end query 1 in stream 0 using template query9a.tpl
