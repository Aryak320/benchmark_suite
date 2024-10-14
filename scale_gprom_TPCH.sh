#!/bin/bash
#this script creates 2 tpc_scale_h databases and adds provenance to the first one
#change database details before running

# Database details
USER="postgres"
PASSWORD="1234"
DATABASES=("tpc_scale_0_1" "tpc_scale_0_2" "tpc_scale_0_3" "tpc_scale_0_4" "tpc_scale_0_5" "tpc_scale_0_6" "tpc_scale_0_7" "tpc_scale_0_8" "tpc_scale_0_9" "tpc_scale_1_0")
HOST="localhost"
sf=1
PORT="5432"
QUERIES=("3_tpch_gprom.sql")

DIRECTORY="/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/query_templates"
INPUT="/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/query_templates/templates_gprom.lst"
INPUT_P="/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/query_templates/templates.lst"
OUTPUT_DIR="/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/query_templates/"



CSV="scale_gprom_tpch.csv"

echo "scale_factor,query,time(s)" > $CSV






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


    for QUERY in ${QUERIES[@]}
      do
          echo "Running $QUERY on $DATABASE"
          START=$(date +%s.%N)
          gprom -sqlfile $OUTPUT_DIR"/${QUERY}" -backend postgres -user $USER -passwd $PASSWORD -db $DATABASE -host $HOST -port $PORT  > $DIRECTORY"/${QUERY}_output_${sf}.txt"
          gprom -sqlfile $OUTPUT_DIR"/${QUERY}" -backend postgres -user $USER -passwd $PASSWORD -db $DATABASE -host $HOST -port $PORT  > $DIRECTORY"/${QUERY}_output_${sf}.txt"
          gprom -sqlfile $OUTPUT_DIR"/${QUERY}" -backend postgres -user $USER -passwd $PASSWORD -db $DATABASE -host $HOST -port $PORT  > $DIRECTORY"/${QUERY}_output_${sf}.txt"
          gprom -sqlfile $OUTPUT_DIR"/${QUERY}" -backend postgres -user $USER -passwd $PASSWORD -db $DATABASE -host $HOST -port $PORT  > $DIRECTORY"/${QUERY}_output_${sf}.txt"
          gprom -sqlfile $OUTPUT_DIR"/${QUERY}" -backend postgres -user $USER -passwd $PASSWORD -db $DATABASE -host $HOST -port $PORT  > $DIRECTORY"/${QUERY}_output_${sf}.txt"
          gprom -sqlfile $OUTPUT_DIR"/${QUERY}" -backend postgres -user $USER -passwd $PASSWORD -db $DATABASE -host $HOST -port $PORT  > $DIRECTORY"/${QUERY}_output_${sf}.txt"
          gprom -sqlfile $OUTPUT_DIR"/${QUERY}" -backend postgres -user $USER -passwd $PASSWORD -db $DATABASE -host $HOST -port $PORT  > $DIRECTORY"/${QUERY}_output_${sf}.txt"
          gprom -sqlfile $OUTPUT_DIR"/${QUERY}" -backend postgres -user $USER -passwd $PASSWORD -db $DATABASE -host $HOST -port $PORT  > $DIRECTORY"/${QUERY}_output_${sf}.txt"
          gprom -sqlfile $OUTPUT_DIR"/${QUERY}" -backend postgres -user $USER -passwd $PASSWORD -db $DATABASE -host $HOST -port $PORT  > $DIRECTORY"/${QUERY}_output_${sf}.txt"
          gprom -sqlfile $OUTPUT_DIR"/${QUERY}" -backend postgres -user $USER -passwd $PASSWORD -db $DATABASE -host $HOST -port $PORT  > $DIRECTORY"/${QUERY}_output_${sf}.txt"
          END=$(date +%s.%N)
          TIMES=$(echo "($END - $START)/10" | bc -l)
          
          echo "$sf,$QUERY,$TIMES" >> $CSV
      done
    
    sf=$(bc <<< "$sf + 1")
    PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d postgres -c 'DROP DATABASE '${DATABASE}
    service postgresql restart
   done




