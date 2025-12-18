#!/bin/bash

# Database details
USER="postgres"
PASSWORD="1234"
#DATABASE="tpc_scale_0_1_ni" #non indexed
DATABASE="tpc_scale_0_1" #indexed
HOST="localhost"

OUTPUT_DIR="/home/slide/sena/BENCHMARK/TPC-H/benchmark_suite/OuT"

CSV="rewritten_to_postgres_i.csv"

echo "scale_factor,time(s)" > $CSV


TIMES=0
ELAPSED=0
ALL_TIMES=0
for i in {1,2,3,4,5,6,7,8,9,10} 
do   
ADD_TIMES=0
      for i in {1,2,3,4,5,6,7,8,9,10,11,12,13} 
          do
             START=$(date +%s.%N)
             PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $OUTPUT_DIR"/gprom${i}_rewrite.sql" -o $OUTPUT_DIR"/${i}_result.txt"
             END=$(date +%s.%N)
             ELAPSED=$(echo "($END - $START)" | bc -l)
             ADD_TIMES=$(echo "($ADD_TIMES + $ELAPSED)" | bc -l)
             echo "query$i took $ELAPSED seconds"
          done

echo "run$i took $ADD_TIMES seconds"
ALL_TIMES=$(echo "($ALL_TIMES + $ADD_TIMES)" | bc -l)
service postgresql restart

done
TIMES=$(echo "($ALL_TIMES)/10" | bc -l)

echo "$sf,$TIMES" >> $CSV
  
#    PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d postgres -c 'DROP DATABASE '${DATABASE}
service postgresql restart




