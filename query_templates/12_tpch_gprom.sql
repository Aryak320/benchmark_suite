PROVENANCE OF (select
	l_shipmode,
	sum(case
		when o_orderpriority = '1-URGENT'
			or o_orderpriority = '2-HIGH'
			then 1
		else 0
	end) as high_line_count,
	sum(case
		when o_orderpriority <> '1-URGENT'
			and o_orderpriority <> '2-HIGH'
			then 1
		else 0
	end) as low_line_count
from
	orders,
	lineitem
where
	o_orderkey = l_orderkey
	and l_shipmode in ('TRUCK', 'AIR')
	and l_commitdate < l_receiptdate
	and l_shipdate < l_commitdate
	and l_receiptdate >= TO_DATE('1997-01-01', 'YYYY-MM-DD') 
	and l_receiptdate < TO_DATE('1997-01-01', 'YYYY-MM-DD')  +  '365' 
group by
	l_shipmode
order by
	l_shipmode
limit 1)
;
