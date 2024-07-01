-- Query8: Retrieve orders that were placed at a certain order priority and have a clerk with a certain pattern in their name
DEFINE ORDERPRIORITY = TEXT({"1-URGENT",1},{"2-HIGH",1},{"3-MEDIUM",1},{"4-NOT SPECIFIED",1},{"5-LOW",1});
DEFINE CLERK = RANDOM(1,9,uniform);
SELECT *
FROM orders
WHERE o_orderpriority = '[ORDERPRIORITY]'
AND o_clerk like 'Clerk#00000000[CLERK]%';

