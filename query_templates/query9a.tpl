define NATION=RANDOM(0,24,uniform);
define BAL=RANDOM(1,10000,uniform);
SELECT c.c_name, o.o_orderstatus
FROM customer c, orders o, partsupp ps, lineitem l
WHERE c.c_custkey = o.o_custkey
AND o.o_orderkey = l.l_orderkey
AND l.l_partkey = ps.ps_partkey
AND c.c_nationkey = [NATION]
AND c_acctbal > [BAL] 
GROUP BY o.o_orderstatus, c.c_name;

