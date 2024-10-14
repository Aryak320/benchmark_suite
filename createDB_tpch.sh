#!/bin/bash
#this script creates 2 tpch databases and adds provenance to the first one
#change database details before running

# Database details
USER="postgres"
PASSWORD="1234"
DATABASES=("tpc3" "tpc3_np")
HOST="localhost"

for DATABASE in ${DATABASES[@]}
    do
        
     echo "Creating database $DATABASE "  
     
     PGPASSWORD=$PASSWORD createdb $DATABASE -U $USER -h $HOST
     PGPASSWORD=$PASSWORD psql -U $USER -d $DATABASE -h $HOST -f dss.ddl
     ./dbgen -vf -s 1

     for i in `ls *.tbl`; 
      do
       table=${i/.tbl/}
       echo "Loading $table..."
       sed 's/|$//' $i > /tmp/$i
       PGPASSWORD=$PASSWORD psql -U $USER -d $DATABASE -h $HOST -q -c "TRUNCATE $table"
       PGPASSWORD=$PASSWORD psql -U $USER -d $DATABASE -h $HOST -c "\\copy $table FROM '/tmp/$i' CSV DELIMITER '|'"
      done

    done


echo "adding provenance annotations to ${DATABASES[0]}"

PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASES[0]} -h $HOST <schema/add_provenance.sql
PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASES[0]} -h $HOST <schema/index.sql
PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASES[0]} -h $HOST <schema/setup_semiring_parallel.sql
echo "Setting semirings to ${DATABASES[0]}"
rm prov_temp.sql
touch prov_tem.sql
for tbl in part supplier partsupp customer orders lineitem nation region
do
  sed "s/(_TBL)/${tbl}/g" schema/formula.sql >>prov_temp.sql
done
PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASES[0]} -h $HOST<prov_temp.sql

rm prov_temp.sql
touch prov_tem.sql
for tbl in part supplier partsupp customer orders lineitem nation region
do
  sed "s/(_TBL)/${tbl}/g" schema/counting.sql >>prov_temp.sql
done

PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASES[0]} -h $HOST <prov_temp.sql

rm prov_temp.sql
touch prov_tem.sql
for tbl in part supplier partsupp customer orders lineitem nation region
do
  sed "s/(_TBL)/${tbl}/g" schema/whyprov.sql >>prov_temp.sql
done

PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASES[0]} -h $HOST <prov_temp.sql

PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASES[0]} -h $HOST <schema/create_formula_map.sql
PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASES[0]} -h $HOST <schema/create_counting_map.sql
PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASES[0]} -h $HOST <schema/create_why_map.sql