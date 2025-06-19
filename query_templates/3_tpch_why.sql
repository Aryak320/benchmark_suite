SET search_path to public, provsql ;
select
	l_orderkey, sr_why(provenance(), 'why_map')
from
	customer,
	orders,
	lineitem
where
	c_mktsegment = 'BUILDING'
	and c_custkey = o_custkey
	and l_orderkey = o_orderkey
	and o_orderdate < TO_DATE('1995-03-15', 'YYYY-MM-DD')
	and l_shipdate > TO_DATE('1995-05-15', 'YYYY-MM-DD')
group by
	l_orderkey,
	o_orderdate,
	o_shippriority
limit 20;
