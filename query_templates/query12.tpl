define NATION = RANDOM(0,24,uniform);
define P_MIN = RANDOM(10000,100000,uniform);
define P_MAX = RANDOM([P_MIN],200000,uniform);
SELECT c.c_name, o.o_orderstatus, c.c_nationkey, c.c_phone
FROM customer c, orders o
WHERE c.c_custkey = o.o_custkey
AND c.c_nationkey = [NATION]
AND o.o_totalprice >= [P_MIN]
AND o.o_totalprice <= [P_MAX];

