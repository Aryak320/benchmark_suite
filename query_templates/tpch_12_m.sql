select  
    l_shipmode,  
    conf()  
from  
    orders_s,  
    lineitem_s  
where  
       o_orderkey = l_orderkey  
       and (l_shipmode = 'MAIL'   or l_shipmode = 'SHIP')  
       and l_commitdate < l_receiptdate  
       and l_shipdate < l_commitdate  
       and l_receiptdate >= '1992-01-01'  
       and l_receiptdate < '1999-01-01'  
group by  
    l_shipmode;  