-- start query 1 in stream 0 using template query39.tpl
PROVENANCE OF (
SELECT s.*
FROM supplier s 
INNER JOIN nation n ON  s.s_nationkey = n.n_nationkey 
INNER JOIN region r ON  n.n_regionkey = r.r_regionkey
WHERE r.r_regionkey = 2
AND s.s_acctbal < 5678);

-- end query 1 in stream 0 using template query39.tpl
-- start query 2 in stream 0 using template query42.tpl
PROVENANCE OF (
SELECT s.s_name, p.p_brand, p.p_name
FROM supplier s, partsupp ps, part p, nation n, region r
WHERE s.s_suppkey = ps.ps_suppkey
AND ps.ps_partkey = p.p_partkey
AND s.s_nationkey = n.n_nationkey
AND n.n_regionkey = r.r_regionkey
AND r.r_regionkey = 0
AND ps.ps_supplycost >= 330
AND ps.ps_supplycost <= 1324
GROUP BY p.p_brand, p.p_name, s.s_name);

-- end query 2 in stream 0 using template query42.tpl
-- start query 3 in stream 0 using template query43.tpl
PROVENANCE OF (
SELECT DISTINCT c.c_name, o.o_orderkey, l.l_linenumber
FROM customer c, orders o, lineitem l
WHERE c.c_custkey = o.o_custkey
AND o.o_orderkey = l.l_orderkey
AND o.o_totalprice >= 13156
AND o.o_totalprice <= 165958);

-- end query 3 in stream 0 using template query43.tpl
-- start query 4 in stream 0 using template query33.tpl
PROVENANCE OF(
SELECT DISTINCT c.c_name, c.c_nationkey
FROM customer c, orders o
WHERE c.c_custkey = o.o_custkey
AND o.o_totalprice > 91123
GROUP BY c.c_nationkey,c.c_name );

-- end query 4 in stream 0 using template query33.tpl
-- start query 5 in stream 0 using template query38a.tpl
PROVENANCE OF ( 
SELECT c.c_name, o.o_orderstatus
FROM customer c, orders o, partsupp ps, lineitem l
WHERE c.c_custkey = o.o_custkey
AND o.o_orderkey = l.l_orderkey
AND l.l_partkey = ps.ps_partkey
AND c.c_nationkey = 16
AND c_acctbal > 8888 
GROUP BY o.o_orderstatus, c.c_name);

-- end query 5 in stream 0 using template query38a.tpl
-- start query 6 in stream 0 using template query31.tpl
PROVENANCE OF ( 
SELECT DISTINCT o.o_orderdate, o.o_custkey
FROM orders o, customer c
WHERE o.o_custkey = c.c_custkey
AND o.o_totalprice > 70144
AND c.c_nationkey = 24
AND o.o_orderstatus IN ('P','F'));

-- end query 6 in stream 0 using template query31.tpl
-- start query 7 in stream 0 using template query45.tpl
PROVENANCE OF (
SELECT p.p_type, p.p_name, s.s_name, ps.ps_supplycost
FROM part p, partsupp ps, supplier s
WHERE p.p_partkey = ps.ps_partkey
AND ps.ps_suppkey = s.s_suppkey
AND p.p_size >= 37
AND p.p_size <= 45
GROUP BY p.p_type, p.p_name, s.s_name, ps.ps_supplycost);

-- end query 7 in stream 0 using template query45.tpl
-- start query 8 in stream 0 using template query36.tpl
PROVENANCE OF (
SELECT *
FROM lineitem
WHERE l_shipmode = 'MAIL'
AND l_quantity < 48
AND l_linestatus = 'F');

-- end query 8 in stream 0 using template query36.tpl
-- start query 9 in stream 0 using template query32.tpl
PROVENANCE OF (
SELECT p.p_name, p.p_mfgr, p.p_partkey, p.p_retailprice
FROM part p
INNER JOIN partsupp ps ON p.p_partkey = ps.ps_partkey
INNER JOIN supplier s  ON ps.ps_suppkey = s.s_suppkey
INNER JOIN nation n    ON s.s_nationkey = n.n_nationkey
INNER JOIN region r    ON n.n_regionkey = r.r_regionkey
WHERE r.r_regionkey = 4
AND ps.ps_supplycost < 844);

-- end query 9 in stream 0 using template query32.tpl
-- start query 10 in stream 0 using template query41.tpl
PROVENANCE OF (
SELECT c.c_name, o.o_orderstatus, c.c_nationkey, c.c_phone
FROM customer c, orders o
WHERE c.c_custkey = o.o_custkey
AND c.c_nationkey = 2
AND o.o_totalprice >= 20501
AND o.o_totalprice <= 60748
);

-- end query 10 in stream 0 using template query41.tpl
