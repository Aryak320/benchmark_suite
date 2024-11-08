
alter table part add column probability double precision;
update part set probability=0.5;



alter table supplier add column probability double precision;
update supplier set probability=0.5;



alter table partsupp add column probability double precision;
update partsupp set probability=0.5;



alter table customer add column probability double precision;
update customer set probability=0.5;



alter table orders add column probability double precision;
update orders set probability=0.5;



alter table lineitem add column probability double precision;
update lineitem set probability=0.5;



alter table nation add column probability double precision;
update nation set probability=0.5;



alter table region add column probability double precision;
update region set probability=0.5;


