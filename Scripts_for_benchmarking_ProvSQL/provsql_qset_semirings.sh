#!/bin/bash
#add database details before running

# Database details
USER="postgres"
PASSWORD="1234"
DATABASES=("tpc_scale_0_1" "tpc_scale_0_2" "tpc_scale_0_3" "tpc_scale_0_4" "tpc_scale_0_5" "tpc_scale_0_6" "tpc_scale_0_7" "tpc_scale_0_8" "tpc_scale_0_9" "tpc_scale_1_0")
HOST="localhost"
sf=1

DIRECTORY="/home/slide/sena/BENCHMARK/TPC-H/benchmark_suite/query_templates/"
INPUT="/home/slide/sena/BENCHMARK/TPC-H/benchmark_suite/query_templates/provsql_prov.lst"
OUTPUT_DIR="/home/slide/sena/BENCHMARK/TPC-H/benchmark_suite/OuT" #enter path to output directory
RNGSEED=3467678
DIALECT="ansi"

CSV="provsql_qset_semirings.csv"

echo "scale_factor,formula(s),counting(s),why(s)" > $CSV


/home/slide/sena/BENCHMARK/DSGen-software-code-3.2.0rc1/tools/dsqgen -DIRECTORY $DIRECTORY -INPUT $INPUT -OUTPUT_DIR $OUTPUT_DIR -DIALECT $DIALECT -RNGSEED $RNGSEED

# Rename the output file
mv $OUTPUT_DIR/query_0.sql $OUTPUT_DIR/qset.sql

  python3 counting_tpch.py $OUTPUT_DIR/qset.sql
  sed -i '1iSET search_path to public, provsql ;' $OUTPUT_DIR"/qset_counting.sql"
  sed -i "1i--${RNGSEED}" $OUTPUT_DIR"/qset_counting.sql"

  python3 formula_tpch.py $OUTPUT_DIR/qset.sql
  sed -i '1iSET search_path to public, provsql ;' $OUTPUT_DIR"/qset_formula.sql"
  sed -i "1i--${RNGSEED}" $OUTPUT_DIR"/qset_formula.sql"

  python3 why_tpch.py $OUTPUT_DIR/qset.sql
  sed -i '1iSET search_path to public, provsql ;' $OUTPUT_DIR"/qset_why.sql"
  sed -i "1i--${RNGSEED}" $OUTPUT_DIR"/qset_why.sql"


TIMES_f=0
TIMES_c=0
TIMES_w=0
ADD_TIMES_f=0
ADD_TIMES_w=0
ADD_TIMES_c=0

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

    PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d ${DATABASE} -c 'ANALYZE'


    echo "Running qset_formula.sql on $DATABASE"
    for i in {1,2,3,4,5,6,7,8,9,10} 
    do
    echo "iteration formula $i"
    START=$(date +%s.%N)
    PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $OUTPUT_DIR"/qset_formula.sql" -o $OUTPUT_DIR"qset_formula_output.txt"
    END=$(date +%s.%N)
    ADD_TIMES_f=$(echo "($ADD_TIMES_f + $END - $START)" | bc -l)
    service postgresql restart
    done
    TIMES_f=$(echo "($ADD_TIMES_f)/10" | bc -l)

    echo "Running qset_counting.sql on $DATABASE"
    for i in {1,2,3,4,5,6,7,8,9,10}
    do
    echo "iteration counting $i"
    START=$(date +%s.%N)
    PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $OUTPUT_DIR"/qset_counting.sql" -o $OUTPUT_DIR"qset_counting_output.txt"
    END=$(date +%s.%N)
    ADD_TIMES_c=$(echo "($ADD_TIMES_c + $END - $START)" | bc -l)
    service postgresql restart
    done
    TIMES_c=$(echo "($ADD_TIMES_c)/10" | bc -l)   

    echo "Running qset_why.sql on $DATABASE"
    for i in {1,2,3,4,5,6,7,8,9,10} 
    do
    echo "iteration why $i"
    START=$(date +%s.%N)
    PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $OUTPUT_DIR"/qset_why.sql" -o $OUTPUT_DIR"qset_why_output.txt"
    END=$(date +%s.%N)
    ADD_TIMES_w=$(echo "($ADD_TIMES_w + $END - $START)" | bc -l)
    service postgresql restart
    done
    TIMES_w=$(echo "($ADD_TIMES_w)/10" | bc -l)
    
    ADD_TIMES_f=0
    ADD_TIMES_w=0
    ADD_TIMES_c=0
    echo "$sf,$TIMES_f,$TIMES_c,$TIMES_w" >> $CSV
    sf=$(bc <<< "$sf + 1")


    find /var/lib/postgresql/16/main/ -type f -name "*.mmap" -exec rm -f {} +
    PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d postgres -c 'DROP DATABASE '${DATABASE}
    service postgresql restart
  done




