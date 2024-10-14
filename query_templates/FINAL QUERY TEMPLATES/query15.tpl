define SIZE=RANDOM(1,50,uniform);
define M=RANDOM(1,5,uniform);
define N=RANDOM(1,5,uniform);
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
