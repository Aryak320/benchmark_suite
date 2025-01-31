SELECT p.p_type, p.p_name, s.s_name, ps.ps_supplycost, conf() FROM part_s p, partsupp_s ps, supplier_s s 
     WHERE p.p_partkey = ps.ps_partkey AND ps.ps_suppkey = s.s_suppkey AND p.p_size >= 4 AND p.p_size <= 36 
     GROUP BY p.p_type, p.p_name, s.s_name, ps.ps_supplycost;