SET search_path to public, provsql ;

SELECT *, probability_evaluate(provenance()) FROM (  
    SELECT s.* FROM supplier s INNER JOIN nation n ON  s.s_nationkey = n.n_nationkey INNER JOIN region r ON  
    n.n_regionkey = r.r_regionkey WHERE r.r_regionkey = 0 AND s.s_acctbal < 4975 )t;


