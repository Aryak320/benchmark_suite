-- using 1472396759 as a seed to the RNG


SET search_path to public, provsql ;
SELECT *, probability_evaluate(provenance()) FROM (
select
	sum(l_extendedprice * l_discount) as revenue
from
	lineitem
where
	l_shipdate >= date '1995-01-01'
	and l_shipdate < date '1995-01-01' + interval '1' year
	and l_discount between 0.09 - 0.01 and 0.09 + 0.01
	and l_quantity < 24
) t;
