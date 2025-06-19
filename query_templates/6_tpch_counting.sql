SET search_path to public, provsql ;
select
	sum(l_extendedprice * l_discount) as revenue
 , sr_counting(provenance(), 'counting_map') from 
	lineitem
where
	l_shipdate >= date '1995-01-01'
	and l_shipdate < date '1995-01-01' + interval '1' year
	and l_discount between 0.09 - 0.01 and 0.09 + 0.01
	and l_quantity < 24
;
