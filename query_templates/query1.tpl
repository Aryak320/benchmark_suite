
 define QUANTITY = RANDOM(1,50,uniform);
 SELECT *
 FROM lineitem
 WHERE l_shipmode = 'AIR'
 AND l_quantity > [QUANTITY];


