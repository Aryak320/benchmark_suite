#!/bin/bash

# Database details
USER="maybms"
PASSWORD="maybms"
PORT="5433"
DATABASE="maybms"
HOST="localhost"


 for i in {1,2,3,4,5,6,7,,8,9,10} 
          do
          
          
          PGPASSWORD=$PASSWORD psql -U $USER -h $HOST -p $PORT -d maybms -c 'SHOW CONFIG_FILE;'
          sshpass -p $PASSWORD ssh -p 2222 -oHostKeyAlgorithms=+ssh-dss  maybms@127.0.0.1  sudo bash stop_postgres.sh        
          sleep 3
          sshpass -p $PASSWORD ssh -p 2222 -oHostKeyAlgorithms=+ssh-dss  maybms@127.0.0.1 sudo bash start_postgres.sh        
          sleep 3

          done