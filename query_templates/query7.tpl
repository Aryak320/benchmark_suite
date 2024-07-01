-- Query7: Retrieve line items that were shipped in a certain mode and have a quantity less than a certain value
DEFINE SHIPMODE = TEXT({"REG AIR",1},{"AIR",1},{"RAIL",1},{"SHIP",1},{"TRUCK",1},{"MAIL",1},{"FOB",1});
DEFINE QUANTITY = RANDOM(1,50,uniform);
SELECT *
FROM lineitem
WHERE l_shipmode = '[SHIPMODE]'
AND l_quantity < [QUANTITY];

