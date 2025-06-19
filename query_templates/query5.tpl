-- Query5: Retrieve suppliers who have supplied parts with a supply cost greater than a certain value
define COST=RANDOM(100,1000,uniform);
define AVAIL=RANDOM(1,8888,uniform);
SELECT s.s_name, s.s_address, s.s_phone
FROM supplier s INNER JOIN partsupp ps ON s.s_suppkey = ps.ps_suppkey
WHERE ps.ps_supplycost > [COST]
OR (ps.ps_availqty > [AVAIL] AND ps.ps_supplycost > cast([COST] as float)/2);

