CREATE EXTENSION "uuid-ossp";
CREATE EXTENSION provsql;

SET search_path TO public,provsql;

SELECT add_provenance('part');
SELECT add_provenance('supplier');
SELECT add_provenance('partsupp');
SELECT add_provenance('customer');
SELECT add_provenance('orders');
SELECT add_provenance('lineitem');
SELECT add_provenance('nation');
SELECT add_provenance('region');
