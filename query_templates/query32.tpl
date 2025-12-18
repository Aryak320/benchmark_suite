define REGION=RANDOM(0,4,uniform);
define COST=RANDOM(1,1000,uniform);
PROVENANCE OF (
SELECT p.p_name, p.p_mfgr, p.p_partkey, p.p_retailprice
FROM part  has provenance(prov) p, partsupp  has provenance(prov) ps, supplier has provenance(prov)  s, nation has provenance(prov)  n, region  has provenance(prov) r
WHERE p.p_partkey = ps.ps_partkey
AND ps.ps_suppkey = s.s_suppkey
AND s.s_nationkey = n.n_nationkey
AND n.n_regionkey = r.r_regionkey
AND r.r_regionkey = [REGION]
AND ps.ps_supplycost < [COST] );
