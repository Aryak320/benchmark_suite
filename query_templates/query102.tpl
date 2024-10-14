-- Query3: Retrieve parts supplied by suppliers in a specific region and have a supply cost less than a certain value
DEFINE REGIONKEY = RANDOM(0,4,uniform);
DEFINE SUPPLYCOST = RANDOM(1,1000,uniform);
SELECT p.*, tconf()
FROM part_s p, partsupp_s ps, supplier_s s, nation_s n, region_s r
WHERE p.p_partkey = ps.ps_partkey
AND ps.ps_suppkey = s.s_suppkey
AND s.s_nationkey = n.n_nationkey
AND n.n_regionkey = r.r_regionkey
AND r.r_regionkey = [REGIONKEY]
AND ps.ps_supplycost < [SUPPLYCOST];
