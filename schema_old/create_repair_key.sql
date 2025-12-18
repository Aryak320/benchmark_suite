create table part_s as 
pick tuples from  part INDEPENDENTLY with probability probability;

create table supplier_s as 
pick tuples from  supplier INDEPENDENTLY with probability probability;

create table partsupp_s as 
pick tuples from  partsupp INDEPENDENTLY with probability probability;

create table customer_s as 
pick tuples from customer INDEPENDENTLY with probability probability;

create table orders_s as 
pick tuples from orders INDEPENDENTLY with probability probability;

create table lineitem_s as 
pick tuples from  lineitem INDEPENDENTLY with probability probability;

create table nation_s as 
pick tuples from  nation INDEPENDENTLY with probability probability;

create table region_s as 
pick tuples from region INDEPENDENTLY with probability probability;


