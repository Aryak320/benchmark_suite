CREATE TABLE why_map AS 
SELECT * FROM part_why_map 
UNION 
SELECT * FROM supplier_why_map
UNION
SELECT * FROM partsupp_why_map 
UNION 
SELECT * FROM customer_why_map 
UNION 
SELECT * FROM orders_why_map 
UNION 
SELECT * FROM lineitem_why_map 
UNION 
SELECT * FROM nation_why_map 
UNION 
SELECT * FROM region_why_map;


ALTER TABLE why_map            
ALTER COLUMN value TYPE varchar;

UPDATE why_map set value = '{"{' || value || '}"}';  

ALTER TABLE why_map ADD PRIMARY KEY (provenance);

