
 define QUANTITY = RANDOM(1,50,uniform);
 SELECT *, tconf()
 FROM lineitem_s
 WHERE l_shipmode = 'AIR'
 AND l_quantity > [QUANTITY];


