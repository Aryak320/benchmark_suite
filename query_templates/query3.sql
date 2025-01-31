-- start query 3 in stream 0 using template query43.tpl
PROVENANCE OF (
SELECT DISTINCT c.c_name, o.o_orderkey, l.l_linenumber
FROM customer c, orders o, lineitem l
WHERE c.c_custkey = o.o_custkey
AND o.o_orderkey = l.l_orderkey
AND o.o_totalprice >= 13156
AND o.o_totalprice <= 165958);

-- end query 3 in stream 0 using template query43.tpl

