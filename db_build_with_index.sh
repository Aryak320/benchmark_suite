#!/bin/bash


# Database details
USER="postgres"
PASSWORD="1234"
DATABASES=("tpc_scale_0_2")


HOST="localhost"
sf=1
PORT="5432"
QUERIES=("4_tpch_gprom.sql")

DIRECTORY="/home/slide/sena/BENCHMARK/TPC-H/benchmark_suite/query_templates"
OUTPUT_DIR="/home/slide/sena/BENCHMARK/TPC-H/benchmark_suite/OuT"
INPUT="/home/slide/sena/BENCHMARK/TPC-H/benchmark_suite/query_templates/gprom_test.lst"
RNGSEED=3467678
DIALECT="ansi"

# /home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/tools/dsqgen -DIRECTORY $DIRECTORY -INPUT $INPUT -OUTPUT_DIR $OUTPUT_DIR -DIALECT $DIALECT -RNGSEED $RNGSEED

# # Rename the output file
#  mv $OUTPUT_DIR/query_0.sql $OUTPUT_DIR/qset.sql


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
            # PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASE} -h $HOST <schema/index.sql
#PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d ${DATABASE} -c 'ANALYZE'

    for QUERY in ${QUERIES[@]}
      do
          echo "Running $QUERY on $DATABASE"
          gprom -sqlfile $DIRECTORY"/${QUERY}" -backend postgres -user $USER -passwd $PASSWORD -db $DATABASE -host $HOST -port $PORT  > $OUTPUT_DIR"/${QUERY}_output_${sf}.txt"
      done
    
    sf=$(bc <<< "$sf + 1")
    service postgresql restart
   done




