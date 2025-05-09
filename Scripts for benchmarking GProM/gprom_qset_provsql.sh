#!/bin/bash

# Database details
USER=""
PASSWORD=""
DATABASES=("tpc_scale_0_1" "tpc_scale_0_2" "tpc_scale_0_3" "tpc_scale_0_4" "tpc_scale_0_5" "tpc_scale_0_6" "tpc_scale_0_7" "tpc_scale_0_8" "tpc_scale_0_9" "tpc_scale_1_0")
HOST=""
sf=1
PORT="5432"

DIRECTORY="benchmark_suite/query_templates"
INPUT="benchmark_suite/query_templates/gprom_qset_provsql.lst"
INPUT_P="/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/query_templates/templates.lst"
OUTPUT_DIR="/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/query_templates/"

RNGSEED=3467678
DIALECT="ansi"

CSV="gprom_qset_provsql.csv"

echo "scale_factor,gprom_prov(s)" > $CSV


/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/tools/dsqgen -DIRECTORY $DIRECTORY -INPUT $INPUT -OUTPUT_DIR $OUTPUT_DIR -DIALECT $DIALECT -RNGSEED $RNGSEED

# Rename the output file
 mv $OUTPUT_DIR/query_0.sql $OUTPUT_DIR/qset.sql
 TIMES=0
 #       ADD_TIMES=0
 counter=1

  
  touch "$DIRECTORY/qset_gprom_output.txt"

  buffer=""
  while IFS= read -r line; do
    
    if [[ "$line" == *"-- start"* ]]; then
        buffer="$line"$'\n'
    
    elif [[ "$line" == *"-- end"* ]]; then
        buffer+="$line"$'\n'
        echo -e "$buffer" > "$DIRECTORY/query${counter}.sql"
        buffer=""
        ((counter++))
    
    elif [[ -n "$buffer" ]]; then
        buffer+="$line"$'\n'
    fi
  done < "$DIRECTORY/qset.sql"



for DATABASE in ${DATABASES[@]}
    do
      count_times=0.0
      
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



      for (( a=1; a<counter; a++ ))
         do
          #avg runtime
    #       for i in {1,2,3,4,5,6,7,8,9,10} 
    #       do
    #       echo "run $i"
    #        START=$(date +%s.%N)

          #gprom -sqlfile $DIRECTORY/query${a}.sql -backend postgres -user $USER -passwd $PASSWORD -db $DATABASE -host $HOST -port $PORT  > $DIRECTORY"/gprom${a}_output.txt"

         # END=$(date +%s.%N)
    #       ADD_TIMES=$(echo "($ADD_TIMES + $END - $START)" | bc -l)
    #       service postgresql restart
               
    #       done

    #       difference=$(echo "($ADD_TIMES)/10" | bc -l)
    #       count_times=$(echo "$count_times + $difference" | bc)
    #       ADD_TIMES=0

          echo "running query$a"
          START=$(date +%s.%N)

          gprom -sqlfile $DIRECTORY/query${a}.sql -backend postgres -user $USER -passwd $PASSWORD -db $DATABASE -host $HOST -port $PORT  > $DIRECTORY"/gprom${a}_output.txt"

          END=$(date +%s.%N)

          difference=$(echo "$END - $START" | bc)


          count_times=$(echo "$count_times + $difference" | bc)


         done
 

    TIMES=$(echo "$count_times" | bc)
    

    echo "$sf,$TIMES" >> $CSV
    sf=$(bc <<< "$sf + 1")
    PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d postgres -c 'DROP DATABASE '${DATABASE}
    service postgresql restart
   done




