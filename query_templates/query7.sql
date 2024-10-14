-- start query 7 in stream 0 using template query31.tpl
PROVENANCE OF ( 
SELECT DISTINCT o.o_orderdate, o.o_custkey
FROM orders o, customer c
WHERE o.o_custkey = c.c_custkey
AND o.o_totalprice > 26930
AND c.c_nationkey = 22
AND o.o_orderstatus IN ('P','F'));

-- end query 7 in stream 0 using template query31.tpl

