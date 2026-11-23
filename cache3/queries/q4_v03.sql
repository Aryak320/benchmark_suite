select
    o_orderpriority 
from  
    orders,  
    lineitem  
where  
    o_orderdate >= date '1993-01-01'  
    and o_orderdate < date '1993-04-01'  
    and l_orderkey = o_orderkey  
    and l_commitdate < l_receiptdate  
group by  
    o_orderpriority LIMIT 100;
