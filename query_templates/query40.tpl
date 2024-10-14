define DMIN = RANDOM(1,121,uniform);
define DMAX = RANDOM([DMIN],121,uniform);
define TAX_A = RANDOM(0,3,uniform);
define TAX_B = RANDOM(4,8,uniform);
PROVENANCE OF (
SELECT l.*, o.o_clerk, o.o_orderdate, o.o_totalprice
FROM lineitem l INNER JOIN orders o ON l.l_orderkey = o.o_orderkey
WHERE l.l_shipdate >= TO_DATE('1994-12-01', 'YYYY-MM-DD')- '[DMIN]'
AND l.l_shipdate < TO_DATE('1996-12-01', 'YYYY-MM-DD') -  '[DMAX]'
AND (
l.l_tax <= cast([TAX_A] as float)/100.0
 OR 
(l.l_tax > cast([TAX_B] as float)/100.0 AND o.o_orderstatus = 'O')
) );


