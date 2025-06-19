-- Query10: Retrieve suppliers who are from a certain region and have an account balance less than a certain value
DEFINE REGIONKEY = RANDOM(0,4,uniform);
DEFINE ACCTBAL = RANDOM(1,10000,uniform);
SELECT s.*, tconf()
FROM supplier_s s, nation_s n, region_s r
WHERE s.s_nationkey = n.n_nationkey
AND n.n_regionkey = r.r_regionkey
AND r.r_regionkey = [REGIONKEY]
AND s.s_acctbal < [ACCTBAL];

