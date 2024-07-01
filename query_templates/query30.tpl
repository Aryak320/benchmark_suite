
 define QUANTITY = RANDOM(1,50,uniform);
 PROVENANCE OF (
 SELECT *
 FROM lineitem
 WHERE l_shipmode = 'AIR'
 AND l_quantity > [QUANTITY] );


