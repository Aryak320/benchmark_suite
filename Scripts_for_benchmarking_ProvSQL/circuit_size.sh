#!/bin/bash


# Database details
USER="postgres"
PASSWORD="1234"
DATABASES=("tpc_scale_0_1" "tpc_scale_0_2" "tpc_scale_0_3" "tpc_scale_0_4" "tpc_scale_0_5" "tpc_scale_0_6" "tpc_scale_0_7" "tpc_scale_0_8" "tpc_scale_0_9" "tpc_scale_1_0")
# DATABASES=( "tpc_scale_0_3"  "tpc_scale_0_4")


HOST="localhost"

#QUERIES=( "6_tpch.sql" "7_tpch.sql" "9_tpch.sql" "12_tpch.sql" "19_tpch.sql" )
QUERIES=("1_tpch.sql") 
#QUERIES=( "7_tpch.sql" "9_tpch.sql" )
QUERY_A="gate.sql"

DIRECTORY="/home/slide/sena/BENCHMARK/TPC-H/benchmark_suite/query_templates/"
OUTPUT_DIR="/home/slide/sena/BENCHMARK/TPC-H/benchmark_suite/OuT"
find /var/lib/postgresql/16/main/ -type f -name "*.mmap" -exec rm -f {} +

 for QUERY in ${QUERIES[@]}
  do
          
    sf=1
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
    PGPASSWORD=$PASSWORD psql -U $USER -d $DATABASE -h $HOST <schema/create_nb_gate_table.sql
    PGPASSWORD=$PASSWORD psql -U $USER -d $DATABASE -h $HOST <schema/add_provenance.sql
    PGPASSWORD=$PASSWORD psql -U $USER -d $DATABASE -h $HOST <schema/index.sql
    PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d ${DATABASE} -c 'ANALYZE'
    
    echo "Running $QUERY on $DATABASE"
          
        
    PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $DIRECTORY"/${QUERY}" -o $OUTPUT_DIR"/${QUERY}_output_${sf}.txt"
    PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $DIRECTORY"/${QUERY_A}" -o $OUTPUT_DIR"/${QUERY}_gates_${sf}.txt"

    find /var/lib/postgresql/16/main/ -type f -name "*.mmap" -exec rm -f {} +
    PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d postgres -c 'DROP DATABASE '${DATABASE}
    service postgresql restart
    sf=$(bc <<< "$sf + 1")


   done
done




