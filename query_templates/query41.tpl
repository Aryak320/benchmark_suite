-- Query12: Retrieve customers and their orders for a given nation and total price range
DEFINE NATIONKEY = RANDOM(0,24,uniform);
DEFINE TOTALPRICE_MIN = RANDOM(10000,100000,uniform);
DEFINE TOTALPRICE_MAX = RANDOM([TOTALPRICE_MIN],200000,uniform);
PROVENANCE OF (
SELECT c.*, o.*
FROM customer c, orders o
WHERE c.c_custkey = o.o_custkey
AND c.c_nationkey = [NATIONKEY]
AND o.o_totalprice >= [TOTALPRICE_MIN]
AND o.o_totalprice <= [TOTALPRICE_MAX]);

