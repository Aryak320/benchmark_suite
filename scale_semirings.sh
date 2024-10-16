#!/bin/bash
#this script creates 2 tpc_scale_h databases and adds provenance to the first one
#change database details before running

# Database details
USER="postgres"
PASSWORD="1234"
DATABASES=("tpc_scale_0_1" "tpc_scale_0_2" "tpc_scale_0_3" "tpc_scale_0_4" "tpc_scale_0_5" "tpc_scale_0_6" "tpc_scale_0_7" "tpc_scale_0_8" "tpc_scale_0_9" "tpc_scale_1_0")
HOST="localhost"
sf=1

DIRECTORY="/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/query_templates/"
INPUT="/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/query_templates/templates.lst"
OUTPUT_DIR="/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/query_templates"
RNGSEED=3467678
DIALECT="ansi"

CSV="scale_semirings.csv"

echo "scale_factor, formula(s), counting(s), why(s)" > $CSV


/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/tools/dsqgen -DIRECTORY $DIRECTORY -INPUT $INPUT -OUTPUT_DIR $OUTPUT_DIR -DIALECT $DIALECT -RNGSEED $RNGSEED

# Rename the output file
mv $OUTPUT_DIR/query_0.sql $OUTPUT_DIR/qset.sql

  python3 counting.py $OUTPUT_DIR/qset.sql
  sed -i '1iSET search_path to public, provsql ;' $OUTPUT_DIR"/qset_counting.sql"
  sed -i "1i--${RNGSEED}" $OUTPUT_DIR"/qset_counting.sql"

  python3 formula.py $OUTPUT_DIR/qset.sql
  sed -i '1iSET search_path to public, provsql ;' $OUTPUT_DIR"/qset_formula.sql"
  sed -i "1i--${RNGSEED}" $OUTPUT_DIR"/qset_formula.sql"

  python3 why.py $OUTPUT_DIR/qset.sql
  sed -i '1iSET search_path to public, provsql ;' $OUTPUT_DIR"/qset_why.sql"
  sed -i "1i--${RNGSEED}" $OUTPUT_DIR"/qset_why.sql"


TIMES_f=0
TIMES_c=0
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
     echo "adding provenance annotations to ${DATABASE}"

     PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASE} -h $HOST <schema/add_provenance.sql
     PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASE} -h $HOST <schema/index.sql
     PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASE} -h $HOST <schema/setup_semiring_parallel.sql
     echo "Setting semirings to ${DATABASE}"
     rm prov_temp.sql
     touch prov_tem.sql
     for tbl in part supplier partsupp customer orders lineitem nation region
       do
        sed "s/(_TBL)/${tbl}/g" schema/formula.sql >>prov_temp.sql
      done
     PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASE} -h $HOST<prov_temp.sql

     rm prov_temp.sql
     touch prov_tem.sql
      for tbl in part supplier partsupp customer orders lineitem nation region
         do
          sed "s/(_TBL)/${tbl}/g" schema/counting.sql >>prov_temp.sql
          done

       PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASE} -h $HOST <prov_temp.sql

      rm prov_temp.sql
     touch prov_tem.sql
       for tbl in part supplier partsupp customer orders lineitem nation region
        do
         sed "s/(_TBL)/${tbl}/g" schema/whyprov.sql >>prov_temp.sql
       done
     
     PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASE} -h $HOST <prov_temp.sql

    PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASE} -h $HOST <schema/create_formula_map.sql
    PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASE} -h $HOST <schema/create_counting_map.sql
    PGPASSWORD=$PASSWORD psql -U $USER -d ${DATABASE} -h $HOST <schema/create_why_map.sql

    

    echo "Running qset_formula.sql on $DATABASE"
    START=$(date +%s.%N)
    PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $OUTPUT_DIR"/qset_formula.sql" -o $DIRECTORY"qset_formula_output.txt"
    END=$(date +%s.%N)
    TIMES_f=$(echo "$END - $START" | bc)

    echo "Running qset_counting.sql on $DATABASE"
    START=$(date +%s.%N)
    PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $OUTPUT_DIR"/qset_counting.sql" -o $DIRECTORY"qset_counting_output.txt"
    END=$(date +%s.%N)
    TIMES_c=$(echo "$END - $START" | bc)

    echo "Running qset_why.sql on $DATABASE"
    START=$(date +%s.%N)
    PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $OUTPUT_DIR"/qset_why.sql" -o $DIRECTORY"qset_why_output.txt"
    END=$(date +%s.%N)
    TIMES_w=$(echo "$END - $START" | bc)

    
    echo "$sf,$TIMES_f,$TIMES_c,$TIMES_w" >> $CSV
    sf=$(bc <<< "$sf + 1")


    find /var/lib/postgresql/16/main/ -type f -name "*.mmap" -exec rm -f {} +
    #PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d postgres -c 'DROP DATABASE '${DATABASE}
    service postgresql restart
    done




