#!/bin/bash

# Database details
USER="postgres"
PASSWORD="1234"
DATABASES=("tpc_scale_0_1" "tpc_scale_0_2" "tpc_scale_0_3" "tpc_scale_0_4" "tpc_scale_0_5" "tpc_scale_0_6" "tpc_scale_0_7" "tpc_scale_0_8" "tpc_scale_0_9" "tpc_scale_1_0")

HOST="localhost"
sf=1

DIRECTORY="benchmark_suite/query_templates"
INPUT="benchmark_suite/query_templates/provsql_prov.lst"
OUTPUT_DIR="/benchmark_suite/OuT"

RNGSEED=3467678
DIALECT="ansi"

CSV="qset_noprov.csv"

echo "scale_factor, withoutprov(s)" > $CSV


/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/tools/dsqgen -DIRECTORY $DIRECTORY -INPUT $INPUT -OUTPUT_DIR $OUTPUT_DIR -DIALECT $DIALECT -RNGSEED $RNGSEED

# Rename the output file
mv $OUTPUT_DIR/query_0.sql $OUTPUT_DIR/qset.sql


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
     
      for i in {1,2,3,4,5,6,7,8,9,10} 
          do
             echo "Running qset.sql on $DATABASE <run $i>"
             START=$(date +%s.%N)
             PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $OUTPUT_DIR"/qset.sql" -o $OUTPUT_DIR"/qset_output.txt"
             END=$(date +%s.%N)
             ADD_TIMES=$(echo "($ADD_TIMES + $END - $START)" | bc -l)
             service postgresql restart
          done

    TIMES=$(echo "($ADD_TIMES)/10" | bc -l)
    echo "$sf,$TIMES" >> $CSV
    ADD_TIMES=0
    sf=$(bc <<< "$sf + 1")
    PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d postgres -c 'DROP DATABASE '${DATABASE}
    service postgresql restart
  done




