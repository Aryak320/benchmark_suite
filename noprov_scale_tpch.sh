#!/bin/bash
#this script creates 2 tpc_scale_h databases and adds provenance to the first one
#change database details before running

# Database details
USER="postgres"
PASSWORD="1234"
DATABASES=("tpc_scale_0_1" "tpc_scale_0_2" "tpc_scale_0_3" "tpc_scale_0_4" "tpc_scale_0_5" "tpc_scale_0_6" "tpc_scale_0_7" "tpc_scale_0_8" "tpc_scale_0_9" "tpc_scale_1_0" )
HOST="localhost"
sf=1
#QUERIES=("1_tpch.sql"  "6_tpch.sql" "3_tpch.sql" "7_tpch.sql" "9_tpch.sql" "10_tpch.sql" "12_tpch.sql" "14_tpch.sql" "19_tpch.sql" )
QUERIES=("1_tpch.sql"  )

DIRECTORY="/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/query_templates"
INPUT="/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/query_templates/templates.lst"
OUTPUT_DIR="/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/query_templates"


CSV="s_no_prov_tpch_1_query.csv"
CSV_PROV="s_prov_tpch.csv"

echo "scale_factor,query,time(s)" > $CSV
#echo "scale_factor,query,time(s)" > $CSV_PROV


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
     PGPASSWORD=$PASSWORD psql -U $USER -d $DATABASE -h $HOST <schema/index.sql

    for QUERY in ${QUERIES[@]}
      do
           echo "Running $QUERY on $DATABASE"
          for i in {1,2,3,4,5,6,7,,8,9,10} 
          do
          
          START=$(date +%s.%N)
          PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $OUTPUT_DIR"/${QUERY}" -o $DIRECTORY"/${QUERY}_output_${sf}.txt"
          END=$(date +%s.%N)
          ADD_TIMES=$(echo "($ADD_TIMES + $END - $START)" | bc -l)
          service postgresql restart
          done

          TIMES=$(echo "($ADD_TIMES)/10" | bc -l)
          echo "$sf,$QUERY,$TIMES" >> $CSV
          ADD_TIMES=0
      done
    
   # service postgresql restart
   # echo "Adding provenance"
   # PGPASSWORD=$PASSWORD psql -U $USER -d $DATABASE -h $HOST <schema/add_provenance.sql
    
   #echo "Running queries for prov comp"
   # for QUERY in ${QUERIES[@]}
    #  do
    #      echo "Running $QUERY on $DATABASE"
   #       START=$(date +%s.%N)
   #       PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $OUTPUT_DIR"/${QUERY}" -o $DIRECTORY"/${QUERY}_output_prov_${sf}.txt"
  #        PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $OUTPUT_DIR"/${QUERY}" -o $DIRECTORY"/${QUERY}_output_prov_${sf}.txt"
 #         PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $OUTPUT_DIR"/${QUERY}" -o $DIRECTORY"/${QUERY}_output_prov_${sf}.txt"
 #         PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $OUTPUT_DIR"/${QUERY}" -o $DIRECTORY"/${QUERY}_output_prov_${sf}.txt"
          # PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $OUTPUT_DIR"/${QUERY}" -o $DIRECTORY"/${QUERY}_output_prov_${sf}.txt"
        #  PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $OUTPUT_DIR"/${QUERY}" -o $DIRECTORY"/${QUERY}_output_prov_${sf}.txt"
       #   PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $OUTPUT_DIR"/${QUERY}" -o $DIRECTORY"/${QUERY}_output_prov_${sf}.txt"
      #    PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $OUTPUT_DIR"/${QUERY}" -o $DIRECTORY"/${QUERY}_output_prov_${sf}.txt"
     #     PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $OUTPUT_DIR"/${QUERY}" -o $DIRECTORY"/${QUERY}_output_prov_${sf}.txt"

    #      END=$(date +%s.%N)
     #     TIMES=$(echo "($END - $START)/10" | bc -l)
    #      echo "$sf,$QUERY,$TIMES" >> $CSV_PROV
   #   done
    sf=$(bc <<< "$sf + 1")
    
    #find /var/lib/postgresql/16/main/ -type f -name "*.mmap" -exec rm -f {} +

    PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d postgres -c 'DROP DATABASE '${DATABASE}
    service postgresql restart
    done




