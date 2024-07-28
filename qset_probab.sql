--3467678
SET search_path to public, provsql ;
SELECT *, probability_evaluate(provenance()) FROM ( SELECT s.*, ps.*, p.* FROM supplier s, partsupp ps, part p, nation n, region r WHERE s.s_suppkey = ps.ps_suppkey AND ps.ps_partkey = p.p_partkey AND s.s_nationkey = n.n_nationkey AND n.n_regionkey = r.r_regionkey AND r.r_regionkey = 4 AND ps.ps_supplycost >= 678 AND ps.ps_supplycost <= 1396 )t;
SELECT *, probability_evaluate(provenance()) FROM (  SELECT p.* FROM part p, partsupp ps, supplier s, nation n, region r WHERE p.p_partkey = ps.ps_partkey AND ps.ps_suppkey = s.s_suppkey AND s.s_nationkey = n.n_nationkey AND n.n_regionkey = r.r_regionkey AND r.r_regionkey = 0 AND ps.ps_supplycost < 975 )t;
SELECT *, probability_evaluate(provenance()) FROM (  SELECT c.c_name AS name, 'Customer' AS type FROM customer c WHERE c.c_nationkey = 4 UNION SELECT s.s_name AS name, 'Supplier' AS type FROM supplier s WHERE s.s_nationkey = 4 )t;
SELECT *, probability_evaluate(provenance()) FROM (  SELECT s.* FROM supplier s, nation n, region r WHERE s.s_nationkey = n.n_nationkey AND n.n_regionkey = r.r_regionkey AND r.r_regionkey = 1 AND s.s_acctbal < 9488 )t;
SELECT *, probability_evaluate(provenance()) FROM (  SELECT * FROM lineitem WHERE l_shipmode = 'AIR' AND l_quantity < 38 )t;
SELECT *, probability_evaluate(provenance()) FROM (  SELECT c.*, o.*, l.* FROM customer c, orders o, lineitem l WHERE c.c_custkey = o.o_custkey AND o.o_orderkey = l.l_orderkey AND o.o_totalprice >= 70144 AND o.o_totalprice <= 118748 )t;
SELECT *, probability_evaluate(provenance()) FROM (  SELECT c.*, o.* FROM customer c, orders o WHERE c.c_custkey = o.o_custkey AND c.c_nationkey = 22 AND o.o_totalprice >= 70184 AND o.o_totalprice <= 86773 )t;
SELECT *, probability_evaluate(provenance()) FROM (  SELECT * FROM customer WHERE c_nationkey = 18 AND c_acctbal > 2672 )t;
SELECT *, probability_evaluate(provenance()) FROM (  SELECT * FROM orders WHERE o_orderpriority = '2-HIGH' AND o_clerk like 'Clerk#000000009%' )t;
SELECT *, probability_evaluate(provenance()) FROM (  SELECT p.*, s.*, ps.* FROM part p, partsupp ps, supplier s WHERE p.p_partkey = ps.ps_partkey AND ps.ps_suppkey = s.s_suppkey AND p.p_size >= 48 AND p.p_size <= 49 )t;
SELECT *, probability_evaluate(provenance()) FROM (  SELECT * FROM part WHERE p_type = 'MEDIUM POLISHED TIN' AND p_size = 1 )t;
SELECT *, probability_evaluate(provenance()) FROM (  SELECT l.*, o.* FROM lineitem l, orders o WHERE l.l_orderkey = o.o_orderkey AND l.l_shipdate >= date '1994-12-01' - interval '4' day AND l.l_shipdate < date '1995-12-01' - interval '104' day )t;
SELECT *, probability_evaluate(provenance()) FROM (  SELECT * FROM lineitem WHERE l_shipmode = 'AIR' AND l_quantity > 25 )t;
SELECT *, probability_evaluate(provenance()) FROM (  SELECT c.c_name AS name, 'Customer' AS type FROM customer c, orders o, lineitem l, part p WHERE c.c_custkey = o.o_custkey AND o.o_orderkey = l.l_orderkey AND l.l_partkey = p.p_partkey AND p.p_size = 14 EXCEPT SELECT c.c_name AS name, 'Customer' AS type FROM customer c, orders o, lineitem l, part p WHERE c.c_custkey = o.o_custkey AND o.o_orderkey = l.l_orderkey AND l.l_partkey = p.p_partkey AND p.p_brand = 'BRAND#52' )t;
SELECT *, probability_evaluate(provenance()) FROM (  SELECT o.* FROM orders o, customer c WHERE o.o_custkey = c.c_custkey AND c.c_nationkey = 17 AND o.o_totalprice > 60229 )t;
SELECT *, probability_evaluate(provenance()) FROM (  SELECT s.* FROM supplier s, partsupp ps WHERE s.s_suppkey = ps.ps_suppkey AND ps.ps_supplycost > 995 )t;
SELECT *, probability_evaluate(provenance()) FROM (  SELECT c.* FROM customer c, orders o WHERE c.c_custkey = o.o_custkey AND o.o_totalprice > 64719 )t;
