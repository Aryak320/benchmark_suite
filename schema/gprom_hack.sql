-- 1. Add prov columns
ALTER TABLE customer ADD COLUMN IF NOT EXISTS prov TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS prov TEXT;
ALTER TABLE lineitem ADD COLUMN IF NOT EXISTS prov TEXT;
ALTER TABLE part ADD COLUMN IF NOT EXISTS prov TEXT;
ALTER TABLE supplier ADD COLUMN IF NOT EXISTS prov TEXT;
ALTER TABLE nation ADD COLUMN IF NOT EXISTS prov TEXT;
ALTER TABLE region ADD COLUMN IF NOT EXISTS prov TEXT;
ALTER TABLE partsupp ADD COLUMN IF NOT EXISTS prov TEXT;

-- 2. Update prov columns with composite IDs

-- customer uses c_custkey
UPDATE customer SET prov = 'customer_' || c_custkey;

-- orders uses o_orderkey
UPDATE orders SET prov = 'orders_' || o_orderkey;

-- lineitem uses composite key (l_orderkey, l_linenumber)
UPDATE lineitem SET prov = 'lineitem_' || l_orderkey || '_' || l_linenumber;

-- part uses p_partkey
UPDATE part SET prov = 'part_' || p_partkey;

-- supplier uses s_suppkey
UPDATE supplier SET prov = 'supplier_' || s_suppkey;

-- nation uses n_nationkey
UPDATE nation SET prov = 'nation_' || n_nationkey;

-- region uses r_regionkey
UPDATE region SET prov = 'region_' || r_regionkey;

-- partsupp uses composite key (ps_partkey, ps_suppkey)
UPDATE partsupp SET prov = 'partsupp_' || ps_partkey || '_' || ps_suppkey;