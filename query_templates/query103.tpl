-- Query4: Retrieve customers who have placed orders with a total price greater than a certain value
DEFINE TOTALPRICE = RANDOM(10000,100000,uniform);
SELECT c.*, tconf()
FROM customer_s c, orders_s o
WHERE c.c_custkey = o.o_custkey
AND o.o_totalprice > [TOTALPRICE];

