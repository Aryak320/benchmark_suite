SET search_path to public, provsql ;
SELECT *, probability_evaluate(provenance()) FROM (
select DISTINCT
    s_suppkey,  
    s_name,  
    s_address,  
    s_phone
from  
    supplier,  
    lineitem 
where  
    s_suppkey = l_suppkey  
    and l_shipdate >= date '1991-10-10'  
    and l_shipdate < date '1992-01-10'  
group by  
    s_suppkey,  
    s_name,  
    s_address,  
    s_phone)t; 