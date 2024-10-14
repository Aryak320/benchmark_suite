#!/bin/bash

# Database details
USER="maybms"
PASSWORD="maybms"
PORT="5433"
DATABASES=("tpc_scale_0_1" "tpc_scale_0_2" "tpc_scale_0_3" "tpc_scale__0_4" "tpc_scale_0_5" "tpc_scale_0_6" "tpc_scale_0_7" "tpc_scale_0_8" "tpc_scale_0_9" "tpc_scale_1_0")
HOST="localhost"
sf=1

DIRECTORY="/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/query_templates/"
INPUT="/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/query_templates/templates_maybms.lst"
OUTPUT_DIR="/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/query_templates"
RNGSEED=3467678
DIALECT="ansi"

CSV="scale_test_maybms.csv"

echo "scale_factor, prob_eval(s)" > $CSV


/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/tools/dsqgen -DIRECTORY $DIRECTORY -INPUT $INPUT -OUTPUT_DIR $OUTPUT_DIR -DIALECT $DIALECT -RNGSEED $RNGSEED

mv $OUTPUT_DIR/query_0.sql $OUTPUT_DIR/qset.sql



TIMES=0


for DATABASE in ${DATABASES[@]}
    do
        
     echo "Creating database $DATABASE "  
     
     PGPASSWORD=$PASSWORD createdb $DATABASE -U $USER -h $HOST -p $PORT
     PGPASSWORD=$PASSWORD psql -U $USER -d $DATABASE -h $HOST -p $PORT -f dss.ddl
     ./dbgen -vf -s $sf
     
     for i in `ls *.tbl`; 
      do
       table=${i/.tbl/}
       echo "Loading $table..."
       sed 's/|$//' $i > /tmp/$i
       PGPASSWORD=$PASSWORD psql -U $USER -d $DATABASE -h $HOST -p $PORT -q -c "TRUNCATE $table"
       PGPASSWORD=$PASSWORD psql -U $USER -d $DATABASE -h $HOST -p $PORT -c "\\copy $table FROM '/tmp/$i' CSV DELIMITER '|'"
      done
   
    

    rm prov_temp.sql
    touch prov_temp.sql
    for tbl in part supplier partsupp customer orders lineitem nation region
      do
        sed "s/(_TBL)/${tbl}/g" schema/probability_maybms.sql >>prov_temp.sql
      done
    PGPASSWORD=$PASSWORD psql -U $USER -d $DATABASE -h $HOST -p $PORT<prov_temp.sql
    PGPASSWORD=$PASSWORD psql -U $USER -d $DATABASE -h $HOST -p $PORT<schema/index.sql
    PGPASSWORD=$PASSWORD psql -U $USER -d $DATABASE -h $HOST -p $PORT<schema/create_repair_key.sql
   

    echo "Running qset_.sql on $DATABASE"
    START=$(date +%s.%N)
    PGPASSWORD=$PASSWORD psql -U $USER -d $DATABASE -h $HOST -p $PORT -f $OUTPUT_DIR"/qset.sql" -o $DIRECTORY"qset_probab_output.txt"
    END=$(date +%s.%N)
    TIMES=$(echo "$END - $START" | bc)

    echo "$sf,$TIMES" >> $CSV
    sf=$(bc <<< "$sf + 1")
    
   done





