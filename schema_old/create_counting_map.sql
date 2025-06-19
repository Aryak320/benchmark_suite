CREATE TABLE counting_map AS SELECT * FROM part_counting_mapping UNION SELECT * FROM supplier_counting_mapping UNION SELECT * FROM partsupp_counting_mapping UNION SELECT * FROM customer_counting_mapping UNION SELECT * FROM orders_counting_mapping UNION SELECT * FROM lineitem_counting_mapping UNION SELECT * FROM nation_counting_mapping UNION SELECT * FROM region_counting_mapping ;

ALTER TABLE counting_map ADD PRIMARY KEY (provenance);
