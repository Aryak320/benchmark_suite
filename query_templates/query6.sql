-- start query 6 in stream 0 using template query31.tpl
PROVENANCE OF ( 
SELECT DISTINCT o.o_orderdate, o.o_custkey
FROM orders o, customer c
WHERE o.o_custkey = c.c_custkey
AND o.o_totalprice > 70144
AND c.c_nationkey = 24
AND o.o_orderstatus IN ('P','F'));

-- end query 6 in stream 0 using template query31.tpl

