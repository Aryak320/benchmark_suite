#!/bin/bash

USER=""
PASSWORD=""
DATABASES=("tpc_scale_0_1" "tpc_scale_0_2" "tpc_scale_0_3" "tpc_scale_0_4" "tpc_scale_0_5" "tpc_scale_0_6" "tpc_scale_0_7" "tpc_scale_0_8" "tpc_scale_0_9" "tpc_scale_1_0")
HOST=""
sf=1
QUERIES=("6_tpch.sql"   "7_tpch.sql" "9_tpch.sql"  "12_tpch.sql" "14_tpch.sql" "19_tpch.sql")

DIRECTORY="benchmark_suite/query_templates/"
OUTPUT_DIR=""

CSV="scale_semirings_tpch.csv"

printf "scale_factor,query,formula(s),counting(s),why(s)\n" > "$CSV"

# Query generation
for QUERY in "${QUERIES[@]}"; do
    python3 counting_tpch.py "$OUTPUT_DIR/${QUERY}"
    sed -i '1iSET search_path to public, provsql ;' "$OUTPUT_DIR/${QUERY%.*}_counting.sql"

    python3 formula_tpch.py "$OUTPUT_DIR/${QUERY}"
    sed -i '1iSET search_path to public, provsql ;' "$OUTPUT_DIR/${QUERY%.*}_formula.sql"

    python3 why_tpch.py "$OUTPUT_DIR/${QUERY}"
    sed -i '1iSET search_path to public, provsql ;' "$OUTPUT_DIR/${QUERY%.*}_why.sql"
done

for DATABASE in "${DATABASES[@]}"; do
    echo "Creating database $DATABASE"
    PGPASSWORD="$PASSWORD" createdb "$DATABASE" -U "$USER" -h "$HOST"
    PGPASSWORD="$PASSWORD" psql -U "$USER" -d "$DATABASE" -h "$HOST" -f dss.ddl
    ./dbgen -vf -s "$sf"

    for i in *.tbl; do
        table="${i/.tbl/}"
        echo "Loading $table..."
        sed 's/|$//' "$i" > "/tmp/$i"
        PGPASSWORD="$PASSWORD" psql -U "$USER" -d "$DATABASE" -h "$HOST" -q -c "TRUNCATE $table"
        PGPASSWORD="$PASSWORD" psql -U "$USER" -d "$DATABASE" -h "$HOST" -c "\\copy $table FROM '/tmp/$i' CSV DELIMITER '|'"
    done

    echo "Adding provenance annotations to ${DATABASE}"
    for script in schema/add_provenance.sql schema/index.sql schema/setup_semiring_parallel.sql; do
        PGPASSWORD="$PASSWORD" psql -U "$USER" -d "$DATABASE" -h "$HOST" < "$script"
    done

    rm prov_temp.sql
    touch prov_temp.sql
    for tbl in part supplier partsupp customer orders lineitem nation region; do
        sed "s/(_TBL)/${tbl}/g" schema/formula.sql >> prov_temp.sql
    done
    PGPASSWORD="$PASSWORD" psql -U "$USER" -d "$DATABASE" -h "$HOST" < prov_temp.sql

    for tbl in part supplier partsupp customer orders lineitem nation region; do
        sed "s/(_TBL)/${tbl}/g" schema/counting.sql >> prov_temp.sql
    done
    PGPASSWORD="$PASSWORD" psql -U "$USER" -d "$DATABASE" -h "$HOST" < prov_temp.sql

    for tbl in part supplier partsupp customer orders lineitem nation region; do
        sed "s/(_TBL)/${tbl}/g" schema/whyprov.sql >> prov_temp.sql
    done
    PGPASSWORD="$PASSWORD" psql -U "$USER" -d "$DATABASE" -h "$HOST" < prov_temp.sql

    for script in schema/create_formula_map.sql schema/create_counting_map.sql schema/create_why_map.sql; do
        PGPASSWORD="$PASSWORD" psql -U "$USER" -d "$DATABASE" -h "$HOST" < "$script"
    done

    for QUERY in "${QUERIES[@]}"; do
        echo "Running $QUERY"
        
        for TYPE in formula counting why; do
    #avg runtime

    #       for i in {1,2,3,4,5,6,7,,8,9,10} 
    #       do
          
            # START=$(date +%s.%N)
            # if ! PGPASSWORD="$PASSWORD" psql -U "$USER" -h "$HOST" -d "$DATABASE" -f "$OUTPUT_DIR/${QUERY%.*}_${TYPE}.sql" -o "$DIRECTORY/${QUERY%.*}_${TYPE}_output.txt" & sleep 1800; then
            #     pkill -P $!
            #     printf "Query timed out: %s\n" "$QUERY" >> "$CSV"
            #     continue
            # fi
            # END=$(date +%s.%N)
    #       ADD_TIMES=$(echo "($ADD_TIMES + $END - $START)" | bc -l)
    #       service postgresql restart
    #       done

    #       TIME=$(echo "($ADD_TIMES)/10" | bc -l)

            START=$(date +%s.%N)
            if ! PGPASSWORD="$PASSWORD" psql -U "$USER" -h "$HOST" -d "$DATABASE" -f "$OUTPUT_DIR/${QUERY%.*}_${TYPE}.sql" -o "$DIRECTORY/${QUERY%.*}_${TYPE}_output.txt" & sleep 1800; then
                pkill -P $!
                printf "Query timed out: %s\n" "$QUERY" >> "$CSV"
                continue
            fi
            END=$(date +%s.%N)
            TIME=$(echo "$END - $START" | bc)
            printf "%s,%s,%s\n" "$sf" "$QUERY" "$TIME" >> "$CSV"
            service postgresql restart
        done
    done

    PGPASSWORD="$PASSWORD" psql -U "$USER" -h "$HOST" -d postgres -c "DROP DATABASE ${DATABASE}"
    find /var/lib/postgresql/16/main/ -type f -name "*.mmap" -exec rm -f {} +
    service postgresql restart
    sf=$(bc <<< "$sf + 1")
done
