#!/bin/bash -e
INIT_SEM=/tmp/initialized.sem

fresh_container() {
  [ ! -f $INIT_SEM ]
}

is_running() {
  [[ -f "/var/www/consul/tmp/pids/server.pid" ]]
}

kill_proc(){
  pid=`cat /var/www/consul/tmp/pids/server.pid`

  if ! kill $pid > /dev/null 2>&1; then
    echo "Could not send SIGTERM to process $pid" >&2
  fi

  rm -f /var/www/consul/tmp/pids/server.pid
}

wait_for_db() {
  database_address=$(getent hosts ${PROC_CONSUL_DB_HOST} | awk '{ print $1 }')
  counter=0
  echo "Connecting to database at $database_address"
  while ! nc -z $database_address $PROC_CONSUL_DB_PORT; do
    counter=$((counter+1))
    if [ $counter == 30 ]; then
      echo "Error: Couldn't connect to database."
      exit 1
    fi
    echo "Trying to connect to database at $database_address. Attempt $counter."
    sleep 5
  done
}

setup_db() {
  echo "Configuring the database"
  bundle exec rake db:create
  echo "Database creation complete"
  bundle exec rake db:migrate
  echo "Database migration complete"
  bundle exec rake db:seed
  echo "Database seed complete"
}

migrate_db() {
  bundle exec rake db:migrate
}

if is_running; then
  kill_proc;
fi

[[ -z $SKIP_DB_WAIT ]] && wait_for_db

if ! fresh_container; then
  echo "#########################################################################"
  echo "                                                                       "
  echo " App initialization skipped:"
  echo " Delete the file $INIT_SEM and restart the container to reinitialize"
  echo "                                                                       "
  echo "#########################################################################"
else

  [[ $PROC_CONSUL_DB_SETUP == "true" ]] && [[ $RAILS_ENV == "development" ]] && setup_db
  echo "Initialization finished"
  touch $INIT_SEM
fi

[[ $PROC_CONSULT_MIGRATE_DB == "true" ]] && migrate_db

echo "Rails environment is: ${RAILS_ENV}"
bundle exec rake assets:precompile
bundle exec puma -C ./config/puma.rb
