-- Query 17: Retrieve all customers and suppliers from the same nation
DEFINE NATIONKEY = RANDOM(1,25,uniform);
PROVENANCE OF (
SELECT c.c_name AS name, 'Customer' AS class
FROM customer c
WHERE c.c_nationkey = [NATIONKEY]
UNION
SELECT s.s_name AS name, 'Supplier' AS class
FROM supplier s
WHERE s.s_nationkey = [NATIONKEY]);
