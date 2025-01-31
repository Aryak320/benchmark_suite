#!/bin/bash

# Database details
USER=""
PASSWORD=""
DATABASES=("tpc_scale_0_1" "tpc_scale_0_2" "tpc_scale_0_3" "tpc_scale_0_4" "tpc_scale_0_5" "tpc_scale_0_6" "tpc_scale_0_7" "tpc_scale_0_8" "tpc_scale_0_9" "tpc_scale_1_0")

HOST=""
sf=1
QUERIES=("6_tpch.sql" "7_tpch.sql" "9_tpch.sql" "12_tpch.sql" "19_tpch.sql")
DIRECTORY="benchmark_suite/query_templates/"
OUTPUT_DIR="" #enter path to output directory


CSV="scale_avg_semirings_tpch.csv"

echo "scale_factor,query,formula(s),counting(s),why(s)" > $CSV
#Query generation
 for QUERY in ${QUERIES[@]}
     do
     python3 counting_tpch.py $OUTPUT_DIR/${QUERY}
     sed -i '1iSET search_path to public, provsql ;' $OUTPUT_DIR"/${QUERY%.*}_counting.sql"


     python3 formula_tpch.py $OUTPUT_DIR/${QUERY}
     sed -i '1iSET search_path to public, provsql ;' $OUTPUT_DIR"/${QUERY%.*}_formula.sql"


     python3 why_tpch.py $OUTPUT_DIR/${QUERY}
     sed -i '1iSET search_path to public, provsql ;' $OUTPUT_DIR"/${QUERY%.*}_why.sql"

     done


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
    
    for QUERY in ${QUERIES[@]}
     do
          echo "running $QUERY formula"
          for i in {1,2,3,4,5,6,7,8,9,10} 
          do
             echo "iteration formula $i"
             START=$(date +%s.%N)
             PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $OUTPUT_DIR"/${QUERY%.*}_formula.sql" -o $DIRECTORY"${QUERY%.*}_formula_output_${sf}.txt"
             END=$(date +%s.%N)
             ADD_TIMES_f=$(echo "($ADD_TIMES_f + $END - $START)" | bc -l)
            service postgresql restart
          done

          TIMES_f=$(echo "($ADD_TIMES_f)/10" | bc -l)
          echo "running $QUERY counting"
          for i in {1,2,3,4,5,6,7,8,9,10} 
          do
            echo "iteration counting $i"
             START=$(date +%s.%N)
             PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $OUTPUT_DIR"/${QUERY%.*}_counting.sql" -o $DIRECTORY"${QUERY%.*}_counting_output_${sf}.txt"
             END=$(date +%s.%N)
             ADD_TIMES_c=$(echo "($ADD_TIMES_c + $END - $START)" | bc -l)
             TIMES_c=$(echo "$END - $START" | bc)
             service postgresql restart
          done

          TIMES_c=$(echo "($ADD_TIMES_c)/10" | bc -l)
          echo "running $QUERY why"
          for i in {1,2,3,4,5,6,7,8,9,10} 
          do
             echo "iteration why $i"
             START=$(date +%s.%N)
             PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $OUTPUT_DIR"/${QUERY%.*}_why.sql" -o $DIRECTORY"${QUERY%.*}_why_output_${sf}.txt"

             #timeout 1500  env PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d $DATABASE -f $OUTPUT_DIR"/${QUERY%.*}_why.sql" -o $DIRECTORY"${QUERY%.*}_why_output.txt"
             END=$(date +%s.%N)
             ADD_TIMES_w=$(echo "($ADD_TIMES_w + $END - $START)" | bc -l)
         
             service postgresql restart
          done
          TIMES_w=$(echo "($ADD_TIMES_w)/10" | bc -l)
          
          ADD_TIMES_f=0
          ADD_TIMES_w=0
          ADD_TIMES_c=0


          echo "$sf,$QUERY,$TIMES_f,$TIMES_c,$TIMES_w" >> $CSV

      done
     
    PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -d postgres -c 'DROP DATABASE '${DATABASE}

    find /var/lib/postgresql/16/main/ -type f -name "*.mmap" -exec rm -f {} +
    service postgresql restart
    sf=$(bc <<< "$sf + 1")
  
  done  




    




