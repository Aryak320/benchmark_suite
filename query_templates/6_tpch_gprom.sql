PROVENANCE OF(select
	sum(l_extendedprice * l_discount) as revenue
from
	lineitem
where
	l_shipdate >= TO_DATE('1995-01-01', 'YYYY-MM-DD')
	and l_shipdate < TO_DATE('1995-01-01', 'YYYY-MM-DD') + '365' 
	and l_discount between 0.09 - 0.01 and 0.09 + 0.01
	and l_quantity < 24
limit 1)


;
