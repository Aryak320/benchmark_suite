#!/bin/bash

# Database details
USER=""
PASSWORD=""
DATABASES=("tpc_scale_0_1" "tpc_scale_0_2" "tpc_scale_0_3" "tpc_scale_0_4" "tpc_scale_0_5" "tpc_scale_0_6" "tpc_scale_0_7" "tpc_scale_0_8" "tpc_scale_0_9" "tpc_scale_1_0")
HOST=""
sf=1

DIRECTORY="benchmark_suite/query_templates"
INPUT="benchmark_suite/query_templates/provsql_prob.lst"
OUTPUT_DIR="" #enter path to output directory of choice
RNGSEED=3467678
DIALECT="ansi"

CSV="provsql_qset_prob.csv"

echo "scale_factor, prob_eval(s)" > $CSV


dsqgen -DIRECTORY $DIRECTORY -INPUT $INPUT -OUTPUT_DIR $OUTPUT_DIR -DIALECT $DIALECT -RNGSEED $RNGSEED

mv $OUTPUT_DIR/query_0.sql $OUTPUT_DIR/qset.sql

python3 probab.py $OUTPUT_DIR/qset.sql
sed -i '1iSET search_path to public, provsql ;' $OUTPUT_DIR"/qset_probab.sql"
sed -i "1i--${RNGSEED}" $OUTPUT_DIR"/qset_probab.sql"

TIMES=0
ADD_TIMES=0

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






        
          for i in {1,2,3,4,5,6,7,8,9,10} 
             do
              echo "Running qset_probab.sql on $DATABASE <run $i>"
              START=$(date +%s.%N)
              PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $OUTPUT_DIR"/qset_probab.sql" -o $DIRECTORY"qset_probab_output.txt"
              END=$(date +%s.%N)
              ADD_TIMES=$(echo "($ADD_TIMES + $END - $START)" | bc -l)
              service postgresql restart
            done


    TIMES=$(echo "($ADD_TIMES)/10" | bc -l)           
    echo "$sf,$TIMES" >> $CSV
    ADD_TIMES=0
    sf=$(bc <<< "$sf + 1")
    
    find /var/lib/postgresql/16/main/ -type f -name "*.mmap" -exec rm -f {} +
    PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d postgres -c 'DROP DATABASE '${DATABASE}

    service postgresql restart
    done




