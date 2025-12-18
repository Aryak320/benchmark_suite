#!/bin/bash

# Database details
USER="maybms"
PASSWORD="maybms"
PORT="5433"
DATABASES=("tpc_scale_0_1" "tpc_scale_0_2" "tpc_scale_0_3" "tpc_scale__0_4" "tpc_scale_0_5" "tpc_scale_0_6" "tpc_scale_0_7" "tpc_scale_0_8" "tpc_scale_0_9" "tpc_scale_1_0")
HOST="localhost"
QUERIES=("query10_cm.sql" "query13_cm.sql"  "query14_cm.sql" "query16_cm.sql")
sf=1

DIRECTORY="benchmark_suite/query_templates/"
OUTPUT_DIR=""


CSV="maybms_unsafe.csv"

echo "scale_factor,query,prob_eval(s)" > $CSV



TIMES=0
ADD_TIMES=0

for DATABASE in ${DATABASES[@]}
    do
        
     echo "Creating database $DATABASE "  
     
     PGPASSWORD=$PASSWORD createdb $DATABASE -U $USER -h $HOST -p $PORT
     PGPASSWORD=$PASSWORD psql -U $USER -d $DATABASE -h $HOST -p $PORT -f dss.ddl
     ./dbgen -vf -s $sf
     
     for i in `ls *.tbl`; 
      do
       table=${i/.tbl/}
       echo "Loading $table..."
       sed 's/|$//' $i > /tmp/$i
       PGPASSWORD=$PASSWORD psql -U $USER -d $DATABASE -h $HOST -p $PORT -q -c "TRUNCATE $table"
       PGPASSWORD=$PASSWORD psql -U $USER -d $DATABASE -h $HOST -p $PORT -c "\\copy $table FROM '/tmp/$i' CSV DELIMITER '|'"
      done
   
    

    rm prov_temp.sql
    touch prov_temp.sql
    for tbl in part supplier partsupp customer orders lineitem nation region
      do
        sed "s/(_TBL)/${tbl}/g" schema/probability_maybms.sql >>prov_temp.sql
      done
    PGPASSWORD=$PASSWORD psql -U $USER -d $DATABASE -h $HOST -p $PORT<prov_temp.sql
    PGPASSWORD=$PASSWORD psql -U $USER -d $DATABASE -h $HOST -p $PORT<schema/index.sql
    PGPASSWORD=$PASSWORD psql -U $USER -d $DATABASE -h $HOST -p $PORT<schema/create_repair_key.sql
   
    # for QUERY in ${QUERIES[@]}
    #   do
    #       echo "Running $QUERY on $DATABASE"
    #       for i in {1,2,3,4,5,6,7,8,9,10} 
    #       do
          
    #       START=$(date +%s.%N)
    #       PGPASSWORD=$PASSWORD psql -U $USER -d $DATABASE -h $HOST -p $PORT -f $OUTPUT_DIR"/${QUERY}" -o $DIRECTORY"/${QUERY}_maybms_output_${sf}.txt"
    #       END=$(date +%s.%N)
    #       ADD_TIMES=$(echo "($ADD_TIMES + $END - $START)" | bc -l)
    #       sshpass -p $PASSWORD ssh -p 2222 -oHostKeyAlgorithms=+ssh-dss  maybms@127.0.0.1 sudo bash stop_postgres.sh        
    #       sleep 3
    #       sshpass -p $PASSWORD ssh -p 2222 -oHostKeyAlgorithms=+ssh-dss  maybms@127.0.0.1 sudo bash start_postgres.sh        
    #       sleep 3

    #       done

    #       TIMES=$(echo "($ADD_TIMES)/10" | bc -l)
    #       echo "$sf,$QUERY,$TIMES" >> $CSV
    #       ADD_TIMES=0
    #   done
    for QUERY in ${QUERIES[@]}
      do
        echo "Running $QUERY on $DATABASE"
        START=$(date +%s.%N)
        PGPASSWORD=$PASSWORD psql -U $USER -d $DATABASE -h $HOST -p $PORT -f $OUTPUT_DIR"/${QUERY}" -o $DIRECTORY"/${QUERY}_maybms_output_${sf}.txt"
        END=$(date +%s.%N)
        TIMES=$(echo "$END - $START" | bc)
        echo "$sf,$QUERY,$TIMES" >> $CSV
        sshpass -p $PASSWORD ssh -p 2222 -oHostKeyAlgorithms=+ssh-dss  maybms@127.0.0.1 sudo bash stop_postgres.sh        
        sleep 3
        sshpass -p $PASSWORD ssh -p 2222 -oHostKeyAlgorithms=+ssh-dss  maybms@127.0.0.1 sudo bash start_postgres.sh        
        sleep 3

      done
   
    sf=$(bc <<< "$sf + 1")
    
    PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -p $PORT -d maybms -c 'DROP DATABASE '${DATABASE}
    sshpass -p $PASSWORD ssh -p 2222 -oHostKeyAlgorithms=+ssh-dss  maybms@127.0.0.1 sudo bash stop_postgres.sh        
    sleep 3
    sshpass -p $PASSWORD ssh -p 2222 -oHostKeyAlgorithms=+ssh-dss  maybms@127.0.0.1 sudo bash start_postgres.sh        
    sleep 3

   done





