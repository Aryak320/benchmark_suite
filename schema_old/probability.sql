SET search_path TO public,provsql;

alter table (_TBL) add column probability double precision;
update (_TBL) set probability=0.5;
SELECT set_prob(provenance(),probability) FROM (_TBL);
