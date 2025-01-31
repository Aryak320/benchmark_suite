#!/bin/bash


# Database details
USER=""
PASSWORD=""
DATABASES=("tpc_scale_0_1" "tpc_scale_0_2" "tpc_scale_0_3" "tpc_scale_0_4" "tpc_scale_0_5" "tpc_scale_0_6" "tpc_scale_0_7" "tpc_scale_0_8" "tpc_scale_0_9" "tpc_scale_1_0")


HOST=""
sf=9
PORT="5432"
QUERIES=("3_tpch_gprom.sql")

DIRECTORY="benchmark_suite/query_templates"
OUTPUT_DIR="" #enter path to output directory



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




