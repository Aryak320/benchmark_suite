CREATE EXTENSION "uuid-ossp";
CREATE EXTENSION provsql;

SET search_path TO public,provsql;

CREATE TABLE nb_gates (x INT);
INSERT INTO nb_gates SELECT get_nb_gates();