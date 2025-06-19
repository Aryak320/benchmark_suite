#!/bin/bash


# Database details
USER="postgres"
PASSWORD="1234"
DATABASES=("tpc_scale_0_1" "tpc_scale_0_2" "tpc_scale_0_3" "tpc_scale_0_4" "tpc_scale_0_5" "tpc_scale_0_6" "tpc_scale_0_7" "tpc_scale_0_8" "tpc_scale_0_9" "tpc_scale_1_0")


HOST="localhost"
sf=1
PORT="5432"
QUERIES=("3_tpch_gprom.sql")

DIRECTORY="/home/slide/sena/BENCHMARK/TPC-H/benchmark_suite/query_templates"
OUTPUT_DIR="/home/slide/sena/BENCHMARK/TPC-H/benchmark_suite/OuT"



CSV="scale_gprom_tpch_non_indexed.csv"

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

      # PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASE} -h $HOST <schema/index.sql
      # PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d ${DATABASE} -c 'ANALYZE'

    for QUERY in ${QUERIES[@]}
      do
          echo "Running $QUERY on $DATABASE"
          START=$(date +%s.%N)
          gprom -sqlfile $DIRECTORY"/${QUERY}" -backend postgres -user $USER -passwd $PASSWORD -db $DATABASE -host $HOST -port $PORT  > $OUTPUT_DIR"/${QUERY}_output_${sf}.txt"
          gprom -sqlfile $DIRECTORY"/${QUERY}" -backend postgres -user $USER -passwd $PASSWORD -db $DATABASE -host $HOST -port $PORT  > $OUTPUT_DIR"/${QUERY}_output_${sf}.txt"
          gprom -sqlfile $DIRECTORY"/${QUERY}" -backend postgres -user $USER -passwd $PASSWORD -db $DATABASE -host $HOST -port $PORT  > $OUTPUT_DIR"/${QUERY}_output_${sf}.txt"
          gprom -sqlfile $DIRECTORY"/${QUERY}" -backend postgres -user $USER -passwd $PASSWORD -db $DATABASE -host $HOST -port $PORT  > $OUTPUT_DIR"/${QUERY}_output_${sf}.txt"
          gprom -sqlfile $DIRECTORY"/${QUERY}" -backend postgres -user $USER -passwd $PASSWORD -db $DATABASE -host $HOST -port $PORT  > $OUTPUT_DIR"/${QUERY}_output_${sf}.txt"
          gprom -sqlfile $DIRECTORY"/${QUERY}" -backend postgres -user $USER -passwd $PASSWORD -db $DATABASE -host $HOST -port $PORT  > $OUTPUT_DIR"/${QUERY}_output_${sf}.txt"
          gprom -sqlfile $DIRECTORY"/${QUERY}" -backend postgres -user $USER -passwd $PASSWORD -db $DATABASE -host $HOST -port $PORT  > $OUTPUT_DIR"/${QUERY}_output_${sf}.txt"
          gprom -sqlfile $DIRECTORY"/${QUERY}" -backend postgres -user $USER -passwd $PASSWORD -db $DATABASE -host $HOST -port $PORT  > $OUTPUT_DIR"/${QUERY}_output_${sf}.txt"
          gprom -sqlfile $DIRECTORY"/${QUERY}" -backend postgres -user $USER -passwd $PASSWORD -db $DATABASE -host $HOST -port $PORT  > $OUTPUT_DIR"/${QUERY}_output_${sf}.txt"
          gprom -sqlfile $DIRECTORY"/${QUERY}" -backend postgres -user $USER -passwd $PASSWORD -db $DATABASE -host $HOST -port $PORT  > $OUTPUT_DIR"/${QUERY}_output_${sf}.txt"
          END=$(date +%s.%N)
          TIMES=$(echo "($END - $START)/10" | bc -l)
          
          echo "$sf,$QUERY,$TIMES" >> $CSV
      done
    
    sf=$(bc <<< "$sf + 1")
    PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d postgres -c 'DROP DATABASE '${DATABASE}
    service postgresql restart
   done




