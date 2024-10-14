PROVENANCE OF (select
	c_custkey,
	c_name,
	c_acctbal,
	n_name,
	c_address,
	c_phone,
	c_comment
from
	customer,
	orders,
	lineitem,
	nation
where
	c_custkey = o_custkey
	and l_orderkey = o_orderkey
	and o_orderdate >= TO_DATE('1993-10-01', 'YYYY-MM-DD') 
	and o_orderdate < TO_DATE('1993-10-01' , 'YYYY-MM-DD')  + '90'
	and l_returnflag = 'R'
	and c_nationkey = n_nationkey
	and l_partkey % 64 = 0
group by
	c_custkey,
	c_name,
	c_acctbal,
	c_phone,
	n_name,
	c_address,
	c_comment

limit 1)

;
