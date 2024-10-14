create table part_s as  
repair key p_partkey in part weight by probability;

create table supplier_s as  
repair key s_suppkey in supplier weight by probability;

create table partsupp_s as  
repair key ps_partkey in partsupp weight by probability;

create table customer_s as  
repair key c_custkey in customer weight by probability;

create table orders_s as  
repair key o_orderkey in orders weight by probability;

create table lineitem_s as  
repair key l_linenumber in lineitem weight by probability;

create table nation_s as  
repair key n_nationkey in nation weight by probability;

create table region_s as  
repair key r_regionkey in region weight by probability;


