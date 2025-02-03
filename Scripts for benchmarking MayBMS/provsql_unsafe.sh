#!/bin/bash

# Database details
PASSWORD=""
DATABASES=("tpc_scale_0_1" "tpc_scale_0_2" "tpc_scale_0_3" "tpc_scale_0_4" "tpc_scale_0_5" "tpc_scale_0_6" "tpc_scale_0_7" "tpc_scale_0_8" "tpc_scale_0_9" "tpc_scale_1_0")
HOST=""
sf=1
QUERIES=("query11_cp.sql" "query14_cp.sql"  "query15_cp.sql" "query17_cp.sql")
DIRECTORY="benchmark_suite/query_templates/"
OUTPUT_DIR=""


CSV="probab_unsafe_provsql.csv"
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
    PGPASSWORD=$PASSWORD psql -U $USER -d $DATABASE -h $HOST <schema/add_provenance.sql > /dev/null 2>&1
    PGPASSWORD=$PASSWORD psql -U $USER -d $DATABASE -h $HOST <schema/index.sql > /dev/null 2>&1

    rm prov_temp.sql
    touch prov_temp.sql
    for tbl in part supplier partsupp customer orders lineitem nation region
      do
        sed "s/(_TBL)/${tbl}/g" schema/probability.sql >>prov_temp.sql
      done
    PGPASSWORD=$PASSWORD psql -U $USER -d $DATABASE -h $HOST<prov_temp.sql > /dev/null 2>&1

    # for QUERY in ${QUERIES[@]}
    #   do
    #        echo "Running $QUERY on $DATABASE"
    #       for i in {1,2,3,4,5,6,7,8,9,10} 
    #       do
    #       echo "run $i"
    #       START=$(date +%s.%N)
    #       PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $OUTPUT_DIR"/${QUERY}" -o $DIRECTORY"/${QUERY}_output_${sf}.txt"
    #       END=$(date +%s.%N)
    #       ADD_TIMES=$(echo "($ADD_TIMES + $END - $START)" | bc -l)
    #       service postgresql restart
               
    #       done

    #       TIMES=$(echo "($ADD_TIMES)/10" | bc -l)
    #       echo "$sf,$QUERY,$TIMES" >> $CSV
    #       ADD_TIMES=0
    #   done
    for QUERY in ${QUERIES[@]}
    do    
        #   PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d postgres -c 'SET search_path to public'
        #   PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d postgres -c 'SET search_path to provsql'
          echo "Running $QUERY on $DATABASE"
          START=$(date +%s.%N)
          PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $OUTPUT_DIR"/${QUERY}" -o $DIRECTORY"/${QUERY}_output_${sf}.txt"
          END=$(date +%s.%N)
          TIMES=$(echo "$END - $START" | bc)
          echo "$sf,$QUERY,$TIMES" >> $CSV
    done
    
    sf=$(bc <<< "$sf + 1")
    
    find /var/lib/postgresql/16/main/ -type f -name "*.mmap" -exec rm -f {} +
    PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d postgres -c 'DROP DATABASE '${DATABASE}

    service postgresql restart
    done




