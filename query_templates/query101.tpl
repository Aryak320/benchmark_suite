-- Query2: Retrieve orders from customers in a specific nation and have total price greater than a certain value
DEFINE NATIONKEY = RANDOM(0,24,uniform);
DEFINE TOTALPRICE = RANDOM(10000,100000,uniform);
SELECT o.*, tconf()
FROM orders_s o, customer_s c
WHERE o.o_custkey = c.c_custkey
AND c.c_nationkey = [NATIONKEY]
AND o.o_totalprice > [TOTALPRICE];

