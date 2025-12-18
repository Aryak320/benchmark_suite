SELECT *,tconf() 
FROM supplier_s,nation_s,region_s 
WHERE supplier_s.s_nationkey = nation_s.n_nationkey AND 
nation_s.n_regionkey = region_s.r_regionkey AND 
region_s.r_regionkey = 0 AND supplier_s.s_acctbal < 4975
;
