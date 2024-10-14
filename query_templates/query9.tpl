-- Query9: Retrieve customers who are from a certain nation and have an account balance greater than a certain value
DEFINE NATIONKEY = RANDOM(0,24,uniform);
DEFINE ACCTBAL = RANDOM(1,10000,uniform);
SELECT *
FROM customer
WHERE c_nationkey = [NATIONKEY]
AND c_acctbal > [ACCTBAL];

