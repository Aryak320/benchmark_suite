-- Query4: Retrieve customers who have placed orders with a total price greater than a certain value
DEFINE TOTALPRICE = RANDOM(10000,100000,uniform);
SELECT c.*
FROM customer c, orders o
WHERE c.c_custkey = o.o_custkey
AND o.o_totalprice > [TOTALPRICE];

