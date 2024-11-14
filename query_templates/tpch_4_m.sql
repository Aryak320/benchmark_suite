select  
    o_orderpriority,  
    conf()  
from  
    orders_s,  
    lineitem_s  
where  
    o_orderdate >= date '1993-07-01'  
    and o_orderdate < date '1993-10-01'  
    and l_orderkey = o_orderkey  
    and l_commitdate < l_receiptdate  
group by  
    o_orderpriority; 