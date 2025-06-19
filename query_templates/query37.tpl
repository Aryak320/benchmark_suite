define OP=TEXT({"1-URGENT",1},{"2-HIGH",1},{"3-MEDIUM",1},{"4-NOT SPECIFIED",1},{"5-LOW",1});
define CLERK=RANDOM(1,9,uniform);
PROVENANCE OF (
SELECT c.c_name, o.o_orderdate
FROM orders has provenance(prov) o, customer has provenance(prov) c
WHERE  o_custkey= c_custkey
AND o_orderpriority = '[OP]'
AND o_clerk like 'Clerk#00000000[CLERK]%');

