-- Query11: Retrieve line items and their corresponding orders for a given ship date range
DEFINE SHIPDATE_MIN = RANDOM(1,121,uniform);
DEFINE SHIPDATE_MAX = RANDOM([SHIPDATE_MIN],121,uniform);
SELECT l.*, o.*, tconf()
FROM lineitem_s l, orders_s o
WHERE l.l_orderkey = o.o_orderkey
AND l.l_shipdate >= date '1994-12-01' - interval '[SHIPDATE_MIN]' day
AND l.l_shipdate < date '1995-12-01' - interval '[SHIPDATE_MAX]' day;


