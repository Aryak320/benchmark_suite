-- start query 1 in stream 0 using template query13.tpl
SELECT s.s_name, p.p_brand, p.p_name
FROM supplier s, partsupp ps, part p, nation n, region r
WHERE s.s_suppkey = ps.ps_suppkey
AND ps.ps_partkey = p.p_partkey
AND s.s_nationkey = n.n_nationkey
AND n.n_regionkey = r.r_regionkey
AND r.r_regionkey = 4
AND ps.ps_supplycost >= 678
AND ps.ps_supplycost <= 1396
GROUP BY p.p_brand, p.p_name, s.s_name;

-- end query 1 in stream 0 using template query13.tpl
-- start query 2 in stream 0 using template query3.tpl
SELECT p.p_name, p.p_mfgr, p.p_partkey, p.p_retailprice
FROM part p
INNER JOIN partsupp ps ON p.p_partkey = ps.ps_partkey
INNER JOIN supplier s  ON ps.ps_suppkey = s.s_suppkey
INNER JOIN nation n    ON s.s_nationkey = n.n_nationkey
INNER JOIN region r    ON n.n_regionkey = r.r_regionkey
WHERE r.r_regionkey = 0
AND ps.ps_supplycost < 975;

-- end query 2 in stream 0 using template query3.tpl
-- start query 3 in stream 0 using template query17.tpl
SELECT c.c_name AS name, 'Customer' AS type
FROM customer c
WHERE c.c_nationkey = 4
UNION
SELECT s.s_name AS name, 'Supplier' AS type
FROM supplier s
WHERE s.s_nationkey = 4;

-- end query 3 in stream 0 using template query17.tpl
-- start query 4 in stream 0 using template query10.tpl
SELECT s.*
FROM supplier s 
INNER JOIN nation n ON  s.s_nationkey = n.n_nationkey 
INNER JOIN region r ON  n.n_regionkey = r.r_regionkey
WHERE r.r_regionkey = 1
AND s.s_acctbal < 9488;

-- end query 4 in stream 0 using template query10.tpl
-- start query 5 in stream 0 using template query7.tpl
SELECT *
FROM lineitem
WHERE l_shipmode = 'AIR'
AND l_quantity < 38
AND l_linestatus = 'F';

-- end query 5 in stream 0 using template query7.tpl
-- start query 6 in stream 0 using template query14.tpl
SELECT DISTINCT c.c_name, o.o_orderkey, l.l_linenumber
FROM customer c, orders o, lineitem l
WHERE c.c_custkey = o.o_custkey
AND o.o_orderkey = l.l_orderkey
AND o.o_totalprice >= 70144
AND o.o_totalprice <= 118748;

-- end query 6 in stream 0 using template query14.tpl
-- start query 7 in stream 0 using template query12.tpl
SELECT c.c_name, o.o_orderstatus, c.c_nationkey, c.c_phone
FROM customer c, orders o
WHERE c.c_custkey = o.o_custkey
AND c.c_nationkey = 22
AND o.o_totalprice >= 70184
AND o.o_totalprice <= 86773;

-- end query 7 in stream 0 using template query12.tpl
-- start query 8 in stream 0 using template query9a.tpl
SELECT c.c_name, o.o_orderstatus
FROM customer c, orders o, partsupp ps, lineitem l
WHERE c.c_custkey = o.o_custkey
AND o.o_orderkey = l.l_orderkey
AND l.l_partkey = ps.ps_partkey
AND c.c_nationkey = 18
AND c_acctbal > 2672 
GROUP BY o.o_orderstatus, c.c_name;

-- end query 8 in stream 0 using template query9a.tpl
-- start query 9 in stream 0 using template query8.tpl
SELECT c.c_name, o.o_orderdate
FROM orders o INNER JOIN customer c ON o_custkey= c_custkey
WHERE o_orderpriority = '2-HIGH'
AND o_clerk like 'Clerk#000000009%';

-- end query 9 in stream 0 using template query8.tpl
-- start query 10 in stream 0 using template query16.tpl
SELECT p.p_type, p.p_name, s.s_name, ps.ps_supplycost
FROM part p, partsupp ps, supplier s
WHERE p.p_partkey = ps.ps_partkey
AND ps.ps_suppkey = s.s_suppkey
AND p.p_size >= 48
AND p.p_size <= 49
GROUP BY p.p_type, p.p_name, s.s_name, ps.ps_supplycost ;

-- end query 10 in stream 0 using template query16.tpl
-- start query 11 in stream 0 using template query6.tpl
SELECT part.p_name, part.p_brand
FROM part
WHERE p_type = 'MEDIUM POLISHED TIN'
AND p_size = 1
GROUP BY part.p_brand, part.p_name;

-- end query 11 in stream 0 using template query6.tpl
-- start query 12 in stream 0 using template query11.tpl
SELECT l.*, o.o_clerk, o.o_orderdate, o.o_totalprice
FROM lineitem l INNER JOIN orders o ON l.l_orderkey = o.o_orderkey
WHERE l.l_shipdate >= date '1994-12-01' - interval '63' day
AND l.l_shipdate < date '1996-12-01' - interval '94' day
AND (
l.l_tax <= cast(2 as float)/100.0
 OR 
(l.l_tax > cast(5 as float)/100.0 AND o.o_orderstatus = 'O')
);

-- end query 12 in stream 0 using template query11.tpl
-- start query 13 in stream 0 using template query1.tpl
SELECT l_orderkey, l_partkey, l_suppkey, l_linenumber, l_linestatus
 FROM lineitem
 WHERE l_shipmode = 'RAIL'
 AND l_quantity > 50
 OR l_discount >= cast(3 as float)/100.0;

-- end query 13 in stream 0 using template query1.tpl
-- start query 14 in stream 0 using template query15.tpl
SELECT c.c_name AS name, 'Customer' AS type
FROM customer c, orders o, lineitem l, part p
WHERE c.c_custkey = o.o_custkey
AND o.o_orderkey = l.l_orderkey
AND l.l_partkey = p.p_partkey
AND p.p_size = 13
EXCEPT
SELECT c.c_name AS name, 'Customer' AS type
FROM customer c, orders o, lineitem l, part p
WHERE c.c_custkey = o.o_custkey
AND o.o_orderkey = l.l_orderkey
AND l.l_partkey = p.p_partkey
AND p.p_brand = 'BRAND#53';

-- end query 14 in stream 0 using template query15.tpl
-- start query 15 in stream 0 using template query2.tpl
SELECT DISTINCT o.o_orderdate, o.o_custkey
FROM orders o, customer c
WHERE o.o_custkey = c.c_custkey
AND o.o_totalprice > 89874
AND c.c_nationkey = 20
AND o.o_orderstatus IN ('P','F');

-- end query 15 in stream 0 using template query2.tpl
-- start query 16 in stream 0 using template query5.tpl
SELECT s.s_name, s.s_address, s.s_phone
FROM supplier s INNER JOIN partsupp ps ON s.s_suppkey = ps.ps_suppkey
WHERE ps.ps_supplycost > 294
OR (ps.ps_availqty > 4579 AND ps.ps_supplycost > cast(294 as float)/2);

-- end query 16 in stream 0 using template query5.tpl
-- start query 17 in stream 0 using template query4.tpl
SELECT DISTINCT c.c_name, c.c_nationkey
FROM customer c, orders o
WHERE c.c_custkey = o.o_custkey
AND o.o_totalprice > 30083
GROUP BY c.c_nationkey,c.c_name;

-- end query 17 in stream 0 using template query4.tpl