#!/bin/bash


# Database details
USER="postgres"
PASSWORD="1234"
DATABASES=("tpc_scale_0_1" "tpc_scale_0_2" "tpc_scale_0_3" "tpc_scale_0_4" "tpc_scale_0_5" "tpc_scale_0_6" "tpc_scale_0_7" "tpc_scale_0_8" "tpc_scale_0_9" "tpc_scale_1_0")
#DATABASES=("tpc_scale_0_7")
#DATABASES=("tpc_scale_0_1" "tpc_scale_0_2" "tpc_scale_0_3" "tpc_scale_0_4" "tpc_scale_0_5" "tpc_scale_0_6")


HOST="localhost"
sf=1
QUERIES=( "7_tpch.sql" "9_tpch.sql" )
#QUERIES=("1_tpch.sql") 

DIRECTORY="/home/slide/sena/BENCHMARK/TPC-H/benchmark_suite/query_templates/"
OUTPUT_DIR="/home/slide/sena/BENCHMARK/TPC-H/benchmark_suite/OuT"


#CSV="scale_provsql_annotations_tpch.csv"
CSV="shm_provsql.csv"
# CSV="indb_provsql.csv"
# CSV="mmap_provsql.csv"
echo "scale_factor,query,time(s)" > $CSV



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
    PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d ${DATABASE} -c 'ANALYZE'
    for QUERY in ${QUERIES[@]}
      do
           echo "Running $QUERY on $DATABASE"
          for i in {1,2,3,4,5,6,7,8,9,10} 
          do          
          START=$(date +%s.%N)
          PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $DIRECTORY"/${QUERY}" -o $OUTPUT_DIR"/${QUERY}_output_${sf}.txt"
          END=$(date +%s.%N)
          ADD_TIMES=$(echo "($ADD_TIMES + $END - $START)" | bc -l)
          service postgresql restart
          done

          TIMES=$(echo "($ADD_TIMES)/10" | bc -l)
          echo "$sf,$QUERY,$TIMES" >> $CSV
          ADD_TIMES=0
      done
    sf=$(bc <<< "$sf + 1")

    #find /var/lib/postgresql/14/main/ -type f -name "*.mmap" -exec rm -f {} +
    PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d postgres -c 'DROP DATABASE '${DATABASE}
    service postgresql restart
    done




