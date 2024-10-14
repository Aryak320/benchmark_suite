define PRICE=RANDOM(10000,100000,uniform);
SELECT DISTINCT c.c_name, c.c_nationkey
FROM customer c, orders o
WHERE c.c_custkey = o.o_custkey
AND o.o_totalprice > [PRICE]
GROUP BY c.c_nationkey,c.c_name;
