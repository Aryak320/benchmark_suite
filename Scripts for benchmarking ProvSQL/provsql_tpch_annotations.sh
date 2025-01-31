#!/bin/bash


# Database details
USER=""
PASSWORD=""
DATABASES=("tpc_scale_0_1" "tpc_scale_0_2" "tpc_scale_0_3" "tpc_scale_0_4" "tpc_scale_0_5" "tpc_scale_0_6" "tpc_scale_0_7" "tpc_scale_0_8" "tpc_scale_0_9" "tpc_scale_1_0")
HOST=""
sf=1
QUERIES=( "6_tpch.sql" "7_tpch.sql" "9_tpch.sql" "12_tpch.sql" "19_tpch.sql" )
#QUERIES=("1_tpch.sql") use this for query 1 of tpch as provsql doesnt scale beyond scale factor 2 and crashes. so its better to get running times for query 1 separatey and later merge it into a single csv file

DIRECTORY="benchmark_suite/query_templates/"
OUTPUT_DIR="" #enter path to output directory


CSV="scale_provsql_annotations_tpch.csv"
#CSV="scale_provsql_annotations_tpch_query1.csv" alternative csv for query 1 only
echo "scale_factor, provenance(s)" > $CSV


# Rename the output file
mv $OUTPUT_DIR/query_0.sql $OUTPUT_DIR/qset.sql

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

    for QUERY in ${QUERIES[@]}
      do
          echo "Running $QUERY on $DATABASE"
          START=$(date +%s.%N)
          PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $OUTPUT_DIR"/${QUERY}" -o $DIRECTORY"${QUERY}_output.txt"
          END=$(date +%s.%N)
          TIMES=$(echo "$END - $START" | bc)
          echo "$sf,$QUERY,$TIMES" >> $CSV
      done
    sf=$(bc <<< "$sf + 1")

    find /var/lib/postgresql/16/main/ -type f -name "*.mmap" -exec rm -f {} +
    PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d postgres -c 'DROP DATABASE '${DATABASE}
    service postgresql restart
    done




