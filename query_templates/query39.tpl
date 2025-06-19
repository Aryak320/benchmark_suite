define REGION=RANDOM(0,4,uniform);
define BAL=RANDOM(1,10000,uniform);
PROVENANCE OF (
SELECT s.*
FROM supplier has provenance(prov) s, nation has provenance(prov) n, region has provenance(prov) r
WHERE s.s_nationkey = n.n_nationkey 
AND n.n_regionkey = r.r_regionkey
AND r.r_regionkey = [REGION]
AND s.s_acctbal < [BAL]);

