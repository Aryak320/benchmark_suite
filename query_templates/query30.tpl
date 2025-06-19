 define QUANT=RANDOM(1,50,uniform);
 define MODE=TEXT({"REG AIR",1},{"AIR",1},{"RAIL",1},{"SHIP",1},{"TRUCK",1},{"MAIL",1},{"FOB",1});
 define DISC=RANDOM(0,10,uniform);
 PROVENANCE OF (
 SELECT l_orderkey, l_partkey, l_suppkey, l_linenumber, l_linestatus
 FROM lineitem
 WHERE l_shipmode = '[MODE]'
 AND l_quantity > [QUANT]
 OR l_discount >= cast([DISC] as float)/100.0);


