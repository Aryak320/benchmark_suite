
PROVENANCE OF (
select
    o_orderpriority 
from  
    orders has provenance(prov),  
    lineitem has provenance(prov) 
where  
    o_orderdate >= TO_DATE('1993-07-01', 'YYYY-MM-DD')  
    and o_orderdate < TO_DATE('1993-10-01', 'YYYY-MM-DD')   
    and l_orderkey = o_orderkey  
    and l_commitdate < l_receiptdate  
group by  
    o_orderpriority);


