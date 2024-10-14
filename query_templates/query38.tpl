define NATION=RANDOM(0,24,uniform);
define BAL=RANDOM(1,10000,uniform);
PROVENANCE OF ( 
SELECT c.c_name, o.o_orderstatus
FROM customer c, orders o, nation n, region r, part p, supplier s, partsupp ps, lineitem l
WHERE c.c_custkey = o.o_custkey
AND o.o_orderkey = l.l_orderkey
AND l.l_partkey = ps.ps_partkey
AND ps.ps_suppkey= s.s_suppkey
AND ps.ps_partkey = p.p_partkey
AND s.s_nationkey = n.n_nationkey
AND n.n_regionkey = r.r_regionkey
AND c.c_nationkey = [NATION]
AND c_acctbal > [BAL] 
GROUP BY o.o_orderstatus, c.c_name);

