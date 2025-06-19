PROVENANCE OF(select
	*
from
	lineitem,
	part
where
	l_partkey = p_partkey
	and l_shipdate >= TO_DATE('1995-09-01', 'YYYY-MM-DD')
	and l_shipdate < TO_DATE('1995-09-01', 'YYYY-MM-DD') + '30' 
	and l_partkey%512=0
limit 1)
;
