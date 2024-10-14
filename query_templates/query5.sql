-- start query 5 in stream 0 using template query33.tpl
PROVENANCE OF(
SELECT DISTINCT c.c_name, c.c_nationkey
FROM customer c, orders o
WHERE c.c_custkey = o.o_custkey
AND o.o_totalprice > 70144
GROUP BY c.c_nationkey,c.c_name );

-- end query 5 in stream 0 using template query33.tpl

