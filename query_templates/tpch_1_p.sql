SET search_path to public, provsql ;
SELECT *, probability_evaluate(provenance()) FROM (
select
    l_returnflag,  
    l_linestatus
from  
    lineitem 
where  
    l_shipdate <= date '1998-09-01'  
group by  
    l_returnflag,  
    l_linestatus)t; 