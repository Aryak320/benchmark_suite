 select  
    l_returnflag,  
    l_linestatus,  
    conf()  
from  
    lineitem_s 
where  
    l_shipdate <= date '1998-09-01'  
group by  
    l_returnflag,  
    l_linestatus; 