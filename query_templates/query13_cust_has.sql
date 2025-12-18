PROVENANCE OF (
SELECT s.s_name, p.p_brand, p.p_name
FROM supplier has provenance(prov) s, partsupp has provenance(prov) ps, part has provenance(prov) p, nation has provenance(prov) n, region has provenance(prov) r
WHERE s.s_suppkey = ps.ps_suppkey
AND ps.ps_partkey = p.p_partkey
AND s.s_nationkey = n.n_nationkey
AND n.n_regionkey = r.r_regionkey
AND r.r_regionkey = 0
AND ps.ps_supplycost >= 330
AND ps.ps_supplycost <= 1324
GROUP BY p.p_brand, p.p_name, s.s_name);

