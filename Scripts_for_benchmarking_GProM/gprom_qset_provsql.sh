#!/bin/bash

# Database details
USER="postgres"
PASSWORD="1234"
DATABASES=("tpc_scale_0_1" "tpc_scale_0_2" "tpc_scale_0_3" "tpc_scale_0_4" "tpc_scale_0_5" "tpc_scale_0_6" "tpc_scale_0_7" "tpc_scale_0_8" "tpc_scale_0_9" "tpc_scale_1_0")
HOST="localhost"
sf=1
PORT="5432"


DIRECTORY="/home/slide/sena/BENCHMARK/TPC-H/benchmark_suite/query_templates/"
INPUT="/home/slide/sena/BENCHMARK/TPC-H/benchmark_suite/query_templates/gprom_test.lst"
OUTPUT_DIR="/home/slide/sena/BENCHMARK/TPC-H/benchmark_suite/OuT"

RNGSEED=3467678
DIALECT="ansi"

CSV="gprom_qset_provsql.csv"

echo "scale_factor,gprom_prov(s)" > $CSV


/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/tools/dsqgen -DIRECTORY $DIRECTORY -INPUT $INPUT -OUTPUT_DIR $OUTPUT_DIR -DIALECT $DIALECT -RNGSEED $RNGSEED

# Rename the output file
 mv $OUTPUT_DIR/query_0.sql $OUTPUT_DIR/qset.sql
 TIMES=0

 counter=1

  
  touch "$OUTPUT_DIR/qset_gprom_output.txt"

  buffer=""
  while IFS= read -r line; do
    
    if [[ "$line" == *"-- start"* ]]; then
        buffer="$line"$'\n'
    
    elif [[ "$line" == *"-- end"* ]]; then
        buffer+="$line"$'\n'
        echo -e "$buffer" > "$OUTPUT_DIR/query${counter}.sql"
        buffer=""
        ((counter++))
    
    elif [[ -n "$buffer" ]]; then
        buffer+="$line"$'\n'
    fi
  done < "$OUTPUT_DIR/qset.sql"



for DATABASE in ${DATABASES[@]}
    do
      count_times=0.0
      
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
      
      PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d ${DATABASE} -h $HOST <schema/gprom_hack.sql #has provenance() , commnet this line if you dont want to use
      PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASE} -h $HOST <schema/index.sql
      PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d ${DATABASE} -c 'ANALYZE'


      for (( a=1; a<counter; a++ ))
         do

          echo "running query$a"
          START=$(date +%s.%N)

          gprom -sqlfile $OUTPUT_DIR/query${a}.sql -backend postgres -user $USER -passwd $PASSWORD -db $DATABASE -host $HOST -port $PORT  > $OUTPUT_DIR"/gprom${a}_output.txt"

          END=$(date +%s.%N)

          difference=$(echo "$END - $START" | bc)


          count_times=$(echo "$count_times + $difference" | bc)


         done
 

    TIMES=$(echo "$count_times" | bc)
    

    echo "$sf,$TIMES" >> $CSV
    sf=$(bc <<< "$sf + 1")
    PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d postgres -c 'DROP DATABASE '${DATABASE}
    service postgresql restart
   done




