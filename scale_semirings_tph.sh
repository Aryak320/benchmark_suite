#!/bin/bash
#this script creates 2 tpc_scale_h databases and adds provenance to the first one
#change database details before running

# Database details
USER="postgres"
PASSWORD="1234"
DATABASES=("tpc_scale_0_1" "tpc_scale_0_2" "tpc_scale_0_3" "tpc_scale_0_4" "tpc_scale_0_5" "tpc_scale_0_6" "tpc_scale_0_7" "tpc_scale_0_8" "tpc_scale_0_9" "tpc_scale_1_0")
HOST="localhost"
sf=1
QUERIES=( "6_tpch_why.sql" "7_tpch_why.sql"  )


DIRECTORY="/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/query_templates/"
INPUT="/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/query_templates/templates.lst"
OUTPUT_DIR="/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/query_templates"


CSV="scale_semirings_tpch.csv"

echo "scale_factor,query,formula(s),counting(s),why(s)" > $CSV

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
     echo "adding provenance annotations to ${DATABASE}"

     PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASE} -h $HOST <schema/add_provenance.sql
     PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASE} -h $HOST <schema/index.sql
     PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASE} -h $HOST <schema/setup_semiring_parallel.sql
     echo "Setting semirings to ${DATABASE}"
     #rm prov_temp.sql
    # touch prov_tem.sql
     #for tbl in part supplier partsupp customer orders lineitem nation region
     #  do
    #    sed "s/(_TBL)/${tbl}/g" schema/formula.sql >>prov_temp.sql
    #  done
    # PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASE} -h $HOST<prov_temp.sql

   #  rm prov_temp.sql
   #  touch prov_tem.sql
   #   for tbl in part supplier partsupp customer orders lineitem nation region
    #     do
     #     sed "s/(_TBL)/${tbl}/g" schema/counting.sql >>prov_temp.sql
     #     done
#
 #      PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASE} -h $HOST <prov_temp.sql

      rm prov_temp.sql
     touch prov_tem.sql
       for tbl in part supplier partsupp customer orders lineitem nation region
        do
         sed "s/(_TBL)/${tbl}/g" schema/whyprov.sql >>prov_temp.sql
       done
     
     PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASE} -h $HOST <prov_temp.sql

    #PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASE} -h $HOST <schema/create_formula_map.sql
    #PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASE} -h $HOST <schema/create_counting_map.sql
    PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASE} -h $HOST <schema/create_why_map.sql
    
    for QUERY in ${QUERIES[@]}
     do
          START=$(date +%s.%N)
          PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $OUTPUT_DIR"/${QUERY}" -o $DIRECTORY"${QUERY}_why_output.txt"
          END=$(date +%s.%N)
          TIMES=$(echo "$END - $START" | bc)
          echo "$DATABASE,$QUERY,$TIMES" >> $CSV
     done

    find /var/lib/postgresql/16/main/ -type f -name "*.mmap" -exec rm -f {} +
    service postgresql restart
  
  done  




    




