#!/bin/bash


# Database details
USER=""
PASSWORD=""
DATABASES=("tpc_scale_0_1" "tpc_scale_0_2" "tpc_scale_0_3" "tpc_scale_0_4" "tpc_scale_0_5" "tpc_scale_0_6" "tpc_scale_0_7" "tpc_scale_0_8" "tpc_scale_0_9" "tpc_scale_1_0")
HOST=""
sf=1

DIRECTORY="benchmark_suite/query_templates/"
INPUT="benchmark_suite/query_templates/provsql_qset_gprom.lst"
OUTPUT_DIR="" #enter path to output directory
RNGSEED=3467678
DIALECT="ansi"

CSV="compare_provsql_gprom.csv"

echo "scale_factor,noprov(s),prov(s),why(s)" > $CSV


/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/tools/dsqgen -DIRECTORY $DIRECTORY -INPUT $INPUT -OUTPUT_DIR $OUTPUT_DIR -DIALECT $DIALECT -RNGSEED $RNGSEED

# Rename the output file
mv $OUTPUT_DIR/query_0.sql $OUTPUT_DIR/qset.sql




cp $OUTPUT_DIR/qset.sql $OUTPUT_DIR/qset_org.sql



python3 why.py $OUTPUT_DIR/qset.sql
sed -i '1iSET search_path to public, provsql ;' $OUTPUT_DIR"/qset_why.sql"
sed -i "1i--${RNGSEED}" $OUTPUT_DIR"/qset_why.sql"


TIMES_prov=0
TIMES_noprov=0
TIMES_w=0

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

      echo "Running qset_org.sql on vanilla $DATABASE"
      START=$(date +%s.%N)
      PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $OUTPUT_DIR"/qset_org.sql" -o $DIRECTORY"qset_org_output.txt"
      END=$(date +%s.%N)
      TIMES_noprov=$(echo "$END - $START" | bc)
      service postgresql restart

     echo "adding provenance annotations to ${DATABASE}"

     PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASE} -h $HOST <schema/add_provenance.sql
     PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASE} -h $HOST <schema/index.sql
     PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASE} -h $HOST <schema/setup_semiring_parallel.sql
     echo "Setting why semiring to ${DATABASE}"



      rm prov_temp.sql
     touch prov_tem.sql
       for tbl in part supplier partsupp customer orders lineitem nation region
        do
         sed "s/(_TBL)/${tbl}/g" schema/whyprov.sql >>prov_temp.sql
       done
     
    PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASE} -h $HOST <prov_temp.sql

   
    PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASE} -h $HOST <schema/create_why_map.sql

    echo "Running qset_org.sql on provenance added $DATABASE"
    START=$(date +%s.%N)
    PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $OUTPUT_DIR"/qset_org.sql" -o $DIRECTORY"qset_org_output.txt"
    END=$(date +%s.%N)
    TIMES_prov=$(echo "$END - $START" | bc)

    service postgresql restart

    echo "Running qset_why.sql on provenance added $DATABASE"
    START=$(date +%s.%N)
    PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $OUTPUT_DIR"/qset_why.sql" -o $DIRECTORY"qset_why_output.txt"
    END=$(date +%s.%N)
    TIMES_w=$(echo "$END - $START" | bc)

    
    echo "$sf,$TIMES_noprov,$TIMES_prov,$TIMES_w" >> $CSV
    sf=$(bc <<< "$sf + 1")


    find /var/lib/postgresql/16/main/ -type f -name "*.mmap" -exec rm -f {} +
    PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d postgres -c 'DROP DATABASE '${DATABASE}
    service postgresql restart
 done




