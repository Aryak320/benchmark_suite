-- Query11: Retrieve line items and their corresponding orders for a given ship date range
DEFINE SHIPDATE_MIN = RANDOM(1,121,uniform);
DEFINE SHIPDATE_MAX = RANDOM([SHIPDATE_MIN],121,uniform);
PROVENANCE OF (
SELECT l.*, o.*
FROM lineitem l, orders o
WHERE l.l_orderkey = o.o_orderkey
AND l.l_shipdate >= TO_DATE('1994-12-01', 'YYYY-MM-DD') - [SHIPDATE_MIN]
AND l.l_shipdate < TO_DATE('1995-12-01', 'YYYY-MM-DD') - [SHIPDATE_MAX]);


