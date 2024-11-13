SET search_path TO public,provsql;

alter table part add column probability double precision;
update part set probability=0.5;
SELECT set_prob(provenance(),probability) FROM part;
SET search_path TO public,provsql;

alter table supplier add column probability double precision;
update supplier set probability=0.5;
SELECT set_prob(provenance(),probability) FROM supplier;
SET search_path TO public,provsql;

alter table partsupp add column probability double precision;
update partsupp set probability=0.5;
SELECT set_prob(provenance(),probability) FROM partsupp;
SET search_path TO public,provsql;

alter table customer add column probability double precision;
update customer set probability=0.5;
SELECT set_prob(provenance(),probability) FROM customer;
SET search_path TO public,provsql;

alter table orders add column probability double precision;
update orders set probability=0.5;
SELECT set_prob(provenance(),probability) FROM orders;
SET search_path TO public,provsql;

alter table lineitem add column probability double precision;
update lineitem set probability=0.5;
SELECT set_prob(provenance(),probability) FROM lineitem;
SET search_path TO public,provsql;

alter table nation add column probability double precision;
update nation set probability=0.5;
SELECT set_prob(provenance(),probability) FROM nation;
SET search_path TO public,provsql;

alter table region add column probability double precision;
update region set probability=0.5;
SELECT set_prob(provenance(),probability) FROM region;
