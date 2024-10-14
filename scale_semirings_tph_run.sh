#!/bin/bash
#this script creates 2 tpc_scale_h databases and adds provenance to the first one
#change database details before running

# Database details
USER="postgres"
PASSWORD="1234"
DATABASES=("tpc_scale_0_1" "tpc_scale_0_2" "tpc_scale_0_3" "tpc_scale_0_4" "tpc_scale_0_5" "tpc_scale_0_6" "tpc_scale_0_7" "tpc_scale_0_8" "tpc_scale_0_9" "tpc_scale_1_0")
HOST="localhost"

QUERIES=("6_tpch_why.sql" )


DIRECTORY="/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/query_templates/"
INPUT="/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/query_templates/templates.lst"
OUTPUT_DIR="/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/query_templates"


CSV="scale_why_tpch.csv"

echo "scale_factor,query,why(s)" > $CSV


for QUERY in ${QUERIES[@]}
do

for DATABASE in ${DATABASES[@]}
do

          echo "Running $QUERY on $DATABASE"
          START=$(date +%s.%N)
          PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $OUTPUT_DIR"/${QUERY}" -o $DIRECTORY"${QUERY}_output.txt"
          END=$(date +%s.%N)
          TIMES=$(echo "$END - $START" | bc)
          echo "$DATABASE,$QUERY,$TIMES" >> $CSV
          find /var/lib/postgresql/16/main/ -type f -name "*.mmap" -exec rm -f {} +
         service postgresql restart


done  

done



    find /var/lib/postgresql/16/main/ -type f -name "*.mmap" -exec rm -f {} +
    service postgresql restart
  




