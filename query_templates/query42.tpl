define REGION=RANDOM(0,4,uniform);
define S_MIN=RANDOM(1,1000,uniform);
define S_MAX=RANDOM([S_MIN],2000,uniform);
PROVENANCE OF (
SELECT s.s_name, p.p_brand, p.p_name
FROM supplier has provenance(prov) s, partsupp has provenance(prov) ps, part has provenance(prov) p, nation has provenance(prov) n, region has provenance(prov) r
WHERE s.s_suppkey = ps.ps_suppkey
AND ps.ps_partkey = p.p_partkey
AND s.s_nationkey = n.n_nationkey
AND n.n_regionkey = r.r_regionkey
AND r.r_regionkey = [REGION]
AND ps.ps_supplycost >= [S_MIN]
AND ps.ps_supplycost <= [S_MAX]
GROUP BY p.p_brand, p.p_name, s.s_name);
