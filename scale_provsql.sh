#!/bin/bash

# Database details
USER="postgres"
PASSWORD="1234"
DATABASES=("tpc_scale_0_1" "tpc_scale_0_2" "tpc_scale_0_3" "tpc_scale_0_4" "tpc_scale_0_5" "tpc_scale_0_6" "tpc_scale_0_7" "tpc_scale_0_8" "tpc_scale_0_9" "tpc_scale_1_0")
HOST="localhost"
sf=1

DIRECTORY="/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/query_templates/"
INPUT="/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/query_templates/query_additional.lst"
OUTPUT_DIR="/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/query_templates"
RNGSEED=3467678
DIALECT="ansi"

CSV="dummy.csv"

echo "scale_factor, prob_eval(s)" > $CSV


/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/tools/dsqgen -DIRECTORY $DIRECTORY -INPUT $INPUT -OUTPUT_DIR $OUTPUT_DIR -DIALECT $DIALECT -RNGSEED $RNGSEED

mv $OUTPUT_DIR/query_0.sql $OUTPUT_DIR/qset.sql

# python3 probab.py $OUTPUT_DIR/qset.sql
# sed -i '1iSET search_path to public, provsql ;' $OUTPUT_DIR"/qset_probab.sql"
# sed -i "1i--${RNGSEED}" $OUTPUT_DIR"/qset_probab.sql"

TIMES=0


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




    echo "Running qset_probab.sql on $DATABASE"
    START=$(date +%s.%N)
    PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $OUTPUT_DIR"/qset_probab.sql" -o $DIRECTORY"qset_probab_output.txt"
    END=$(date +%s.%N)
    TIMES=$(echo "$END - $START" | bc)

    echo "$sf,$TIMES" >> $CSV
    sf=$(bc <<< "$sf + 1")
    
    find /var/lib/postgresql/16/main/ -type f -name "*.mmap" -exec rm -f {} +
    PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d postgres -c 'DROP DATABASE '${DATABASE}

    service postgresql restart
    done




