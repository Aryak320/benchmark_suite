-- Query14: Retrieve customers, their orders, and corresponding line items for a given total price range
DEFINE TOTALPRICE_MIN = RANDOM(10000,100000,uniform);
DEFINE TOTALPRICE_MAX = RANDOM([TOTALPRICE_MIN],200000,uniform);
SELECT c.*, o.*, l.*
FROM customer c, orders o, lineitem l
WHERE c.c_custkey = o.o_custkey
AND o.o_orderkey = l.l_orderkey
AND o.o_totalprice >= [TOTALPRICE_MIN]
AND o.o_totalprice <= [TOTALPRICE_MAX];

