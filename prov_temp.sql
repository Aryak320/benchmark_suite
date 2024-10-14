SET search_path TO public,provsql;

SELECT create_provenance_mapping('part_why_map','part','provenance');

SET search_path TO public,provsql;

SELECT create_provenance_mapping('supplier_why_map','supplier','provenance');

SET search_path TO public,provsql;

SELECT create_provenance_mapping('partsupp_why_map','partsupp','provenance');

SET search_path TO public,provsql;

SELECT create_provenance_mapping('customer_why_map','customer','provenance');

SET search_path TO public,provsql;

SELECT create_provenance_mapping('orders_why_map','orders','provenance');

SET search_path TO public,provsql;

SELECT create_provenance_mapping('lineitem_why_map','lineitem','provenance');

SET search_path TO public,provsql;

SELECT create_provenance_mapping('nation_why_map','nation','provenance');

SET search_path TO public,provsql;

SELECT create_provenance_mapping('region_why_map','region','provenance');

