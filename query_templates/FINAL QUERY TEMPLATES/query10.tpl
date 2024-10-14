define REGION=RANDOM(0,4,uniform);
define BAL=RANDOM(1,10000,uniform);
SELECT s.*
FROM supplier s 
INNER JOIN nation n ON  s.s_nationkey = n.n_nationkey 
INNER JOIN region r ON  n.n_regionkey = r.r_regionkey
WHERE r.r_regionkey = [REGION]
AND s.s_acctbal < [BAL];

