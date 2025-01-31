-- start query 1 in stream 0 using template query39.tpl
PROVENANCE OF (
SELECT s.*
FROM supplier s 
INNER JOIN nation n ON  s.s_nationkey = n.n_nationkey 
INNER JOIN region r ON  n.n_regionkey = r.r_regionkey
WHERE r.r_regionkey = 2
AND s.s_acctbal < 5678);

-- end query 1 in stream 0 using template query39.tpl

