#!/bin/bash

# Database details
USER="postgres"
PASSWORD="1234"
DATABASES=("tpc_scale_0_1" "tpc_scale_0_2" "tpc_scale_0_3" "tpc_scale__0_4" "tpc_scale_0_5" "tpc_scale_0_6" "tpc_scale_0_7" "tpc_scale_0_8" "tpc_scale_0_9" "tpc_scale_1_0" 
"tpc_scale_1_1" "tpc_scale_1_2" "tpc_scale_1_3" "tpc_scale_1_4" "tpc_scale_1_5" "tpc_scale_1_6" "tpc_scale_1_7" "tpc_scale_1_8" "tpc_scale_1_9" "tpc_scale_2_0" 
"tpc_scale_2_1" "tpc_scale_2_2" "tpc_scale_2_3" "tpc_scale__2_4" "tpc_scale_2_5" "tpc_scale_2_6" "tpc_scale_2_7" "tpc_scale_2_8" "tpc_scale_2_9" "tpc_scale_3_0" 
"tpc_scale_3_1" "tpc_scale_3_2" "tpc_scale_3_3" "tpc_scale__3_4" "tpc_scale_3_5" "tpc_scale_3_6" "tpc_scale_3_7" "tpc_scale_3_8" "tpc_scale_3_9" "tpc_scale_4_0" 
"tpc_scale_4_1" "tpc_scale_4_2" "tpc_scale_4_3" "tpc_scale__4_4" "tpc_scale_4_5" "tpc_scale_4_6" "tpc_scale_4_7" "tpc_scale_4_8" "tpc_scale_4_9" "tpc_scale_5_0")
HOST="localhost"
sf=4


CSV="scale_test_large.csv"

echo "scale_factor, prob_eval(s)" > $CSV


TIMES=0


for DATABASE in ${DATABASES[@]}
    do
        
     echo "Creating database $DATABASE "  
     
     PGPASSWORD=$PASSWORD createdb $DATABASE -U $USER -h $HOST
     PGPASSWORD=$PASSWORD psql -U $USER -d $DATABASE -h $HOST -f dss.ddl
     ./dbgen -vf -s $sf
     
     for i in `ls *.tbl`; 
      do
       table=${i/.tbl/}
       echo "Loading $table..."
       sed 's/|$//' $i > /tmp/$i
       PGPASSWORD=$PASSWORD psql -U $USER -d $DATABASE -h $HOST -q -c "TRUNCATE $table"
       PGPASSWORD=$PASSWORD psql -U $USER -d $DATABASE -h $HOST -c "\\copy $table FROM '/tmp/$i' CSV DELIMITER '|'"
      done
    PGPASSWORD=$PASSWORD psql -U $USER -d $DATABASE -h $HOST <schema/add_provenance.sql
    PGPASSWORD=$PASSWORD psql -U $USER -d $DATABASE -h $HOST <schema/index.sql

    rm prov_temp.sql
    touch prov_temp.sql
    for tbl in part supplier partsupp customer orders lineitem nation region
      do
        sed "s/(_TBL)/${tbl}/g" schema/probability.sql >>prov_temp.sql
      done
    PGPASSWORD=$PASSWORD psql -U $USER -d $DATABASE -h $HOST<prov_temp.sql




    echo "Running qset_probab.sql on $DATABASE"
    START=$(date +%s.%N)
    PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f qset_probab.sql -o qset_probab_output.txt
    END=$(date +%s.%N)
    TIMES=$(echo "$END - $START" | bc)

    echo "$sf,$TIMES" >> $CSV
    sf=$(bc <<< "$sf + 0.1")
    service postgresql restart
    done




