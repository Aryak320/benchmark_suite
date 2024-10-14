--Query15: This query retrieves the names of customers who have placed orders for parts of a specific size, excluding those customers who have also placed orders for parts of a specific brand.
DEFINE SIZE = RANDOM(1,50,uniform);
DEFINE M = RANDOM(1,5,uniform);
DEFINE N = RANDOM(1,5,uniform);
SELECT c.c_name AS name, 'Customer' AS type
FROM customer c, orders o, lineitem l, part p
WHERE c.c_custkey = o.o_custkey
AND o.o_orderkey = l.l_orderkey
AND l.l_partkey = p.p_partkey
AND p.p_size = [SIZE]
EXCEPT
SELECT c.c_name AS name, 'Customer' AS type
FROM customer c, orders o, lineitem l, part p
WHERE c.c_custkey = o.o_custkey
AND o.o_orderkey = l.l_orderkey
AND l.l_partkey = p.p_partkey
AND p.p_brand = 'BRAND#[M][N]';
