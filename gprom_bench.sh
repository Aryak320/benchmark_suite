#!/bin/bash

N=${1:-6}

USER="postgres"
PASSWORD="1234"
DATABASE="tpc3_np"
DATABASE_P="tpc3"
HOST="localhost"
PORT="5432"





DIRECTORY="/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/query_templates"
INPUT="/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/query_templates/templates_gprom.lst"
INPUT_P="/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/query_templates/templates.lst"
OUTPUT_DIR="/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/query_templates/"


DIALECT="ansi"

CSV="execution_times_gprom_1gig.csv"


echo "Query sets, ExecTimeGProM(s), ExecTimeProvSQL(s)" > $CSV



QUERY_DIR="/home/slide/sena/BENCHMARK/BENCH/PROV.BENCHMARK/bnch_gprom"


RESULT_DIR="/home/slide/sena/BENCHMARK/BENCH/PROV.BENCHMARK/bnch_gprom"


TIME_FILE="$RESULT_DIR/execution_times_gprom.csv"


echo "reloading postgresql"
START=$(date +%s%N)
systemctl restart postgresql
END=$(date +%s%N)

for i in $(seq 1 $N)
do
  
  RNGSEED=$((END - START))

  
  /home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/tools/dsqgen -DIRECTORY $DIRECTORY -INPUT $INPUT -OUTPUT_DIR $OUTPUT_DIR -DIALECT $DIALECT -RNGSEED $RNGSEED

  
  mv $OUTPUT_DIR/query_0.sql $OUTPUT_DIR/qset_$i.sql


  TIMES_G=0
  TIMES_P=0
  count_times=0.0
  counter=1

  echo "Running qset_$i.sql on GProM shell "
  touch "$DIRECTORY/qset_${i}_gprom_output.txt"

  buffer=""
  while IFS= read -r line; do
    
    if [[ "$line" == *"-- start"* ]]; then
        buffer="$line"$'\n'
    
    elif [[ "$line" == *"-- end"* ]]; then
        buffer+="$line"$'\n'
        echo -e "$buffer" > "$DIRECTORY/query${i}_in_$counter.sql"
        buffer=""
        ((counter++))
    
    elif [[ -n "$buffer" ]]; then
        buffer+="$line"$'\n'
    fi
  done < "$DIRECTORY/qset_$i.sql"

  for (( a=1; a<counter; a++ ))
  do
   START=$(date +%s.%N)

    gprom -sqlfile $DIRECTORY/query${i}_in_$a.sql -backend postgres -user $USER -passwd $PASSWORD -db $DATABASE -host $HOST -port $PORT  > $DIRECTORY"/gprom${i}_${a}_output.txt"

    END=$(date +%s.%N)

    difference=$(echo "$END - $START" | bc)


    count_times=$(echo "$count_times + $difference" | bc)


  done
 

  TIMES_G=$(echo "$count_times" | bc)
  
  /home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/tools/dsqgen -DIRECTORY $DIRECTORY -INPUT $INPUT_P -OUTPUT_DIR $OUTPUT_DIR -DIALECT $DIALECT -RNGSEED $RNGSEED

  
  mv $OUTPUT_DIR/query_0.sql $OUTPUT_DIR/qset_p_$i.sql


  python3 why.py $OUTPUT_DIR/qset_p_$i.sql
  sed -i '1iSET search_path to public, provsql ;' $DIRECTORY"/qset_p_${i}_why.sql"
  sed -i "1i--${RNGSEED}" $DIRECTORY"/qset_p_${i}_why.sql"

  echo "Running qset_why_$i.sql ProvSQL"
  START=$(date +%s.%N)
  PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE_P -f $OUTPUT_DIR"qset_p_${i}_why.sql" -o $DIRECTORY"/qset_p_why_${i}_output.txt"
  END=$(date +%s.%N)
  TIMES_P=$(echo "$END - $START" | bc)

    
  echo "reloading postgresql"
  START=$(date +%s%N)
  systemctl restart postgresql
  END=$(date +%s%N)

  echo "qset_$i.sql,$TIMES_G,$TIMES_P" >> $CSV
done



QUERY_DIR="/home/slide/sena/BENCHMARK/BENCH/PROV.BENCHMARK/bnch_gprom"


RESULT_DIR="/home/slide/sena/BENCHMARK/BENCH/PROV.BENCHMARK/bnch_gprom"


TIME_FILE="$RESULT_DIR/execution_times_gprom.csv"

