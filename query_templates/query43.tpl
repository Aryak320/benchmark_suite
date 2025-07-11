define P_MIN = RANDOM(10000,100000,uniform);
define P_MAX = RANDOM([P_MIN],200000,uniform);
PROVENANCE OF (
SELECT DISTINCT c.c_name, o.o_orderkey, l.l_linenumber
FROM customer  has provenance(prov) c, orders has provenance(prov) o, lineitem  has provenance(prov) l
WHERE c.c_custkey = o.o_custkey
AND o.o_orderkey = l.l_orderkey
AND o.o_totalprice >= [P_MIN]
AND o.o_totalprice <= [P_MAX]);

