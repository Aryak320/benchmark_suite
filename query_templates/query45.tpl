define MIN = RANDOM(1,50,uniform);
define MAX = RANDOM([MIN],50,uniform);
PROVENANCE OF (
SELECT p.p_type, p.p_name, s.s_name, ps.ps_supplycost
FROM part has provenance(prov) p, partsupp has provenance(prov) ps, supplier has provenance(prov) s
WHERE p.p_partkey = ps.ps_partkey
AND ps.ps_suppkey = s.s_suppkey
AND p.p_size >= [MIN]
AND p.p_size <= [MAX]
GROUP BY p.p_type, p.p_name, s.s_name, ps.ps_supplycost);
