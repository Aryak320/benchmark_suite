-- Query16: Retrieve parts, their suppliers, and corresponding parts for a given part size range
DEFINE PARTSIZE_MIN = RANDOM(1,50,uniform);
DEFINE PARTSIZE_MAX = RANDOM([PARTSIZE_MIN],50,uniform);
SELECT p.*, s.*, ps.*, tconf()
FROM part_s p, partsupp_s ps, supplier_s s
WHERE p.p_partkey = ps.ps_partkey
AND ps.ps_suppkey = s.s_suppkey
AND p.p_size >= [PARTSIZE_MIN]
AND p.p_size <= [PARTSIZE_MAX];
