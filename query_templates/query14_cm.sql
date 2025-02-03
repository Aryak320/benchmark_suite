SELECT s.s_name, p.p_brand, p.p_name, conf() FROM supplier_s s, partsupp_s ps, part_s p, nation_s n, region_s r 
    WHERE s.s_suppkey = ps.ps_suppkey AND ps.ps_partkey = p.p_partkey AND s.s_nationkey = n.n_nationkey 
    AND n.n_regionkey = r.r_regionkey AND r.r_regionkey = 4 AND ps.ps_supplycost >= 678 AND ps.ps_supplycost <= 1396 
    GROUP BY p.p_brand, p.p_name, s.s_name;