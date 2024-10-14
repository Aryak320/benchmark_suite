#USER="maybms"
PASSWORD="maybms"
#DATABASES=("tpc3" "tpc3_np")
#HOST="localhost"
  
     
     PGPASSWORD=$PASSWORD createdb tpc -U maybms
     PGPASSWORD=$PASSWORD psql -U maybms -d tpc -f dss.ddl
     

     for i in `ls *.tbl`; 
      do
       table=${i/.tbl/}
       echo "Loading $table..."
       sed 's/|$//' $i > /tmp/$i
       PGPASSWORD=$PASSWORD psql -U maybms -d tpc -q -c "TRUNCATE $table"
       PGPASSWORD=$PASSWORD psql -U maybms -d tpc  -c "\\copy $table FROM '/tmp/$i' CSV DELIMITER '|'"
      done

    done


