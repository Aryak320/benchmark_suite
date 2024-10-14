-- Query18: Retrieve all customers who have placed orders for a specific part and all suppliers who supply that part, except those suppliers who supply another specific part
DEFINE PARTKEY_A = RANDOM(1,200000,uniform);
DEFINE PARTKEY_B = RANDOM(1,200000,uniform);

PROVENANCE OF (
SELECT combined.name, combined.type
FROM (
    SELECT c.c_name AS name, 'Customer' AS type, l.l_partkey AS partkey
    FROM customer c, orders o, lineitem l
    WHERE c.c_custkey = o.o_custkey
    AND o.o_orderkey = l.l_orderkey
    UNION ALL
    SELECT s.s_name AS name, 'Supplier' AS type, ps.ps_partkey AS partkey
    FROM supplier s, partsupp ps
    WHERE s.s_suppkey = ps.ps_suppkey
) AS combined
LEFT JOIN (
    SELECT s.s_name AS name
    FROM supplier s, partsupp ps
    WHERE s.s_suppkey = ps.ps_suppkey
    AND ps.ps_partkey = [PARTKEY_B]
) AS excluded ON combined.name = excluded.name
WHERE combined.partkey = [PARTKEY_A]
AND excluded.name IS NULL);
