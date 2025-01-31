-- start query 10 in stream 0 using template query41.tpl
PROVENANCE OF (
SELECT c.c_name, o.o_orderstatus, c.c_nationkey, c.c_phone
FROM customer c, orders o
WHERE c.c_custkey = o.o_custkey
AND c.c_nationkey = 2
AND o.o_totalprice >= 20501
AND o.o_totalprice <= 60748
);

-- end query 10 in stream 0 using template query41.tpl

