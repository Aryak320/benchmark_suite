
-- Query13: Retrieve suppliers, parts they supply, and their corresponding parts for a given region and supply cost range
DEFINE REGIONKEY = RANDOM(0,4,uniform);
DEFINE SUPPLYCOST_MIN = RANDOM(1,1000,uniform);
DEFINE SUPPLYCOST_MAX = RANDOM([SUPPLYCOST_MIN],2000,uniform);
SELECT s.*, ps.*, p.*, tconf()
FROM supplier_s s, partsupp_s ps, part_s p, nation_s n, region_s r
WHERE s.s_suppkey = ps.ps_suppkey
AND ps.ps_partkey = p.p_partkey
AND s.s_nationkey = n.n_nationkey
AND n.n_regionkey = r.r_regionkey
AND r.r_regionkey = [REGIONKEY]
AND ps.ps_supplycost >= [SUPPLYCOST_MIN]
AND ps.ps_supplycost <= [SUPPLYCOST_MAX];
