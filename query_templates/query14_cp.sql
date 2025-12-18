SET search_path to public, provsql ;

SELECT *, probability_evaluate(provenance()) FROM 
(  SELECT DISTINCT c.c_name, o.o_orderkey, l.l_linenumber FROM customer c, orders o, lineitem l 
WHERE c.c_custkey = o.o_custkey AND o.o_orderkey = l.l_orderkey AND o.o_totalprice >= 91123 AND o.o_totalprice <= 110058 )t;