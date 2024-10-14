-- using 1472396759 as a seed to the RNG


SET search_path to public, provsql ;
SELECT *, probability_evaluate(provenance()) FROM (
select
	*
from
	lineitem,
	part
where
	l_partkey = p_partkey
	and l_shipdate >= date '1995-09-01'
	and l_shipdate < date '1995-09-01' + interval '1' month
	and l_partkey%512=0
limit 1) t;
