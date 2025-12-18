SET search_path TO public,provsql;
SELECT get_nb_gates()-x AS nb FROM nb_gates;
DROP TABLE nb_gates;