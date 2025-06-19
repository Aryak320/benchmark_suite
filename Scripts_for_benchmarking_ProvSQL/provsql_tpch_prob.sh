#!/bin/bash

# Database details
USER="postgres"
PASSWORD="1234"
DATABASES=("tpc1" "tpc2" "tpc3" "tpc4" "tpc5" "tpc6" "tpc7" "tpc8" "tpc9" "tpc10" )
# DATABASES=("tpc_scale_0_1" "tpc_scale_0_2" "tpc_scale_0_3" "tpc_scale_0_4" "tpc_scale_0_5")
HOST="localhost"
sf=1
QUERIES=("6_probab.sql" "9_probab.sql"  "12_probab.sql" "19_probab.sql" )
# QUERIES=("tpch_4_p.sql" "tpch_12_p.sql"  "tpch_15_p.sql")
#QUERY="tpch_1_p.sql"
DIRECTORY="/home/slide/sena/BENCHMARK/TPC-H/benchmark_suite/query_templates/"
OUTPUT_DIR="/home/slide/sena/BENCHMARK/TPC-H/benchmark_suite/OuT"


CSV="provsql_prob_tpch.csv"
echo "scale_factor,query,prob_eval(s)" > $CSV


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

    rm prov_temp.sql
    touch prov_temp.sql
    for tbl in part supplier partsupp customer orders lineitem nation region
      do
        sed "s/(_TBL)/${tbl}/g" schema/probability.sql >>prov_temp.sql
      done
    PGPASSWORD=$PASSWORD psql -U $USER -d $DATABASE -h $HOST<prov_temp.sql
    PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d ${DATABASE} -c 'ANALYZE'

    for QUERY in ${QUERIES[@]}
      do
           echo "Running $QUERY on $DATABASE"
          for i in {1,2,3,4,5,6,7,8,9,10} 
          do
          echo "run $i"
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
    
    find /var/lib/postgresql/16/main/ -type f -name "*.mmap" -exec rm -f {} +
    PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d postgres -c 'DROP DATABASE '${DATABASE}

    service postgresql restart
    done




