-- start query 1 in stream 0 using template query41.tpl
PROVENANCE OF (
SELECT c.c_name, o.o_orderstatus, c.c_nationkey, c.c_phone
FROM customer c, orders o
WHERE c.c_custkey = o.o_custkey
AND c.c_nationkey = 4
AND o.o_totalprice >= 52353
AND o.o_totalprice <= 141505
);

-- end query 1 in stream 0 using template query41.tpl

