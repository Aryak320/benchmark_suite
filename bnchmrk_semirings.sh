#!/bin/bash

# Number of iterations
N=${1:-6}

# Database details
USER="postgres"
PASSWORD="1234"
DATABASE="tpc3"
HOST="localhost"

# Directory and file paths
DIRECTORY="/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/query_templates/"
INPUT="/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/query_templates/templates.lst"
OUTPUT_DIR="/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/query_templates"

DIALECT="ansi"

CSV="execution_times_1gig_semirings.csv"

echo "Query sets, formula(s), counting(s), why(s)" > $CSV

echo "reloading postgresql"
START=$(date +%s%N)
systemctl restart postgresql
END=$(date +%s%N)

for i in $(seq 1 $N)
do
  # Use the reload time as the RNGSEED value
  RNGSEED=$((END - START))

  # Run the dsqgen command
  /home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/tools/dsqgen -DIRECTORY $DIRECTORY -INPUT $INPUT -OUTPUT_DIR $OUTPUT_DIR -DIALECT $DIALECT -RNGSEED $RNGSEED

  # Rename the output file
  mv $OUTPUT_DIR/query_0.sql $OUTPUT_DIR/qset_$i.sql

  python3 counting.py $OUTPUT_DIR/qset_$i.sql
  sed -i '1iSET search_path to public, provsql ;' $OUTPUT_DIR"/qset_${i}_counting.sql"
  sed -i "1i--${RNGSEED}" $OUTPUT_DIR"/qset_${i}_counting.sql"

  python3 formula.py $OUTPUT_DIR/qset_$i.sql
  sed -i '1iSET search_path to public, provsql ;' $OUTPUT_DIR"/qset_${i}_formula.sql"
  sed -i "1i--${RNGSEED}" $OUTPUT_DIR"/qset_${i}_formula.sql"

  python3 why.py $OUTPUT_DIR/qset_$i.sql
  sed -i '1iSET search_path to public, provsql ;' $OUTPUT_DIR"/qset_${i}_why.sql"
  sed -i "1i--${RNGSEED}" $OUTPUT_DIR"/qset_${i}_why.sql"

  TIMES_FORMULA=0
  TIMES_COUNTING=0
  TIMES_WHY=0

  echo "Running qset_formula_$i.sql"
  START=$(date +%s.%N)
  PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $OUTPUT_DIR"/qset_${i}_formula.sql" -o $DIRECTORY"qset_formula_${i}_output.txt"
  END=$(date +%s.%N)
  TIMES_FORMULA=$(echo "$END - $START" | bc)

  echo "Running qset_counting_$i.sql"
  START=$(date +%s.%N)
  PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $OUTPUT_DIR"/qset_${i}_counting.sql" -o $DIRECTORY"qset_counting_${i}_output.txt"
  END=$(date +%s.%N)
  TIMES_COUNTING=$(echo "$END - $START" | bc)

  echo "Running qset_why_$i.sql"
  START=$(date +%s.%N)
  PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $OUTPUT_DIR"/qset_${i}_why.sql" -o $DIRECTORY"qset_why_${i}_output.txt"
  END=$(date +%s.%N)
  TIMES_WHY=$(echo "$END - $START" | bc)

  echo "reloading postgresql"
  START=$(date +%s%N)
  systemctl restart postgresql
  END=$(date +%s%N)
  
 
  echo "qset_$i.sql,$TIMES_FORMULA,$TIMES_COUNTING,$TIMES_WHY" >> $CSV
done
