define MODE=TEXT({"REG AIR",1},{"AIR",1},{"RAIL",1},{"SHIP",1},{"TRUCK",1},{"MAIL",1},{"FOB",1});
define QUANT=RANDOM(1,50,uniform);
PROVENANCE OF (
SELECT *
FROM lineitem
WHERE l_shipmode = '[MODE]'
AND l_quantity < [QUANT]
AND l_linestatus = 'F');

