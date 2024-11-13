select  
    s_suppkey,  
    s_name,  
    s_address,  
    s_phone,  
    conf()  
from  
    supplier_s,  
    lineitem_s 
where  
    s_suppkey = l_suppkey  
    and l_shipdate >= date '1991-10-10'  
    and l_shipdate < date '1992-01-10'  
group by  
    s_suppkey,  
    s_name,  
    s_address,  
    s_phone; 