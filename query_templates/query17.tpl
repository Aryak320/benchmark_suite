define NATION = RANDOM(1,25,uniform);
SELECT c.c_name AS name, 'Customer' AS type
FROM customer c
WHERE c.c_nationkey = [NATION]
UNION
SELECT s.s_name AS name, 'Supplier' AS type
FROM supplier s
WHERE s.s_nationkey = [NATION];
