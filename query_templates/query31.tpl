define NATION=RANDOM(0,24,uniform);
define PRICE=RANDOM(10000,100000,uniform);
PROVENANCE OF ( 
SELECT DISTINCT o.o_orderdate, o.o_custkey
FROM orders has provenance(prov) o, customer  has provenance(prov) c
WHERE o.o_custkey = c.c_custkey
AND o.o_totalprice > [PRICE]
AND c.c_nationkey = [NATION]
AND o.o_orderstatus IN ('P','F') );

