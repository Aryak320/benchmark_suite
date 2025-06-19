SET search_path to public, provsql ;

SELECT *, probability_evaluate(provenance()) FROM ( 
     SELECT p.p_type, p.p_name, s.s_name, ps.ps_supplycost FROM part p, partsupp ps, supplier s 
     WHERE p.p_partkey = ps.ps_partkey AND ps.ps_suppkey = s.s_suppkey AND p.p_size >= 4 AND p.p_size <= 36 
     GROUP BY p.p_type, p.p_name, s.s_name, ps.ps_supplycost )t;


