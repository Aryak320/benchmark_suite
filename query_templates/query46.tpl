define NATION = RANDOM(1,25,uniform);
PROVENANCE OF (
SELECT c.c_name AS name, 'Customer' AS class
FROM customer c
WHERE c.c_nationkey = [NATION]
UNION
SELECT s.s_name AS name, 'Supplier' AS class
FROM supplier s
WHERE s.s_nationkey = [NATION]);
