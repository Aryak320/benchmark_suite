#!/bin/bash

# Database details
USER="postgres"
PASSWORD="1234"
DATABASES=("tpc_scale_0_1" "tpc_scale_0_2" "tpc_scale_0_3" "tpc_scale_0_4" "tpc_scale_0_5" "tpc_scale_0_6" "tpc_scale_0_7" "tpc_scale_0_8" "tpc_scale_0_9" "tpc_scale_1_0")
HOST="localhost"
sf=1
DIRECTORY="/home/slide/sena/BENCHMARK/TPC-H/benchmark_suite/query_templates"
OUTPUT_DIR="/home/slide/sena/BENCHMARK/TPC-H/benchmark_suite/OuT"

CSV="provsqlq3.csv"
echo "scale_factor,noprov(s),prov(s),why(s)" > $CSV
TIMES_prov=0
TIMES_noprov=0
TIMES_w=0
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

     PGPASSWORD=$PASSWORD psql -U $USER -d $DATABASE -h $HOST <schema/index.sql

    PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d ${DATABASE} -c 'ANALYZE'

      echo "Running query3.sql on vanilla $DATABASE"

      for i in {1,2,3,4,5,6,7,8,9,10} 
          do
              echo "run $i"
              START=$(date +%s.%N)
              PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $DIRECTORY"/3_tpch.sql" -o $OUTPUT_DIR"/3_tpch_output.txt"
              END=$(date +%s.%N)
              ADD_TIMES=$(echo "($ADD_TIMES + $END - $START)" | bc -l) 
              service postgresql restart
          done
      TIMES_noprov=$(echo "($ADD_TIMES)/10" | bc -l)
      ADD_TIMES=0

     echo "adding provenance annotations to ${DATABASE}"

     PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASE} -h $HOST <schema/add_provenance.sql
     PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASE} -h $HOST <schema/index.sql
     PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASE} -h $HOST <schema/setup_semiring_parallel.sql
     echo "Setting why semiring to ${DATABASE}"
     rm prov_temp.sql
     touch prov_tem.sql
       for tbl in part supplier partsupp customer orders lineitem nation region
        do
         sed "s/(_TBL)/${tbl}/g" schema/whyprov.sql >>prov_temp.sql
       done
     
    PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASE} -h $HOST <prov_temp.sql

   
    PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASE} -h $HOST <schema/create_why_map.sql

    PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d ${DATABASE} -c 'ANALYZE'
    
    echo "Running query 3 on provenance added $DATABASE for circuit computation only"
          
          
      for i in {1,2,3,4,5,6,7,8,9,10} 
        do
          echo "run $i"
          START=$(date +%s.%N)
          PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $DIRECTORY"/3_tpch.sql" -o $OUTPUT_DIR"/3_tpch_annotation_output.txt"
          END=$(date +%s.%N)
          ADD_TIMES=$(echo "($ADD_TIMES + $END - $START)" | bc -l)
          service postgresql restart

        done
      
      TIMES_prov=$(echo "($ADD_TIMES)/10" | bc -l)
      ADD_TIMES=0


    
    echo "Running query 3 on provenance added $DATABASE for WHY semiring"
      for i in {1,2,3,4,5,6,7,8,9,10} 
        do
          echo "run $i"
          START=$(date +%s.%N)
          PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $DIRECTORY"/3_tpch_why.sql" -o $OUTPUT_DIR"/3_tpch_why_output.txt"
          END=$(date +%s.%N)
          ADD_TIMES=$(echo "($ADD_TIMES + $END - $START)" | bc -l)
          service postgresql restart
         done

       TIMES_w=$(echo "($ADD_TIMES)/10" | bc -l)
       ADD_TIMES=0
    
    echo "$sf,$TIMES_noprov,$TIMES_prov,$TIMES_w" >> $CSV
    sf=$(bc <<< "$sf + 1")


    find /var/lib/postgresql/16/main/ -type f -name "*.mmap" -exec rm -f {} +
    PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d postgres -c 'DROP DATABASE '${DATABASE}
    service postgresql restart
 done




