#!/usr/bin/env bash

# Executes docker-compose to load data into the database. It uses the latest file in the aprexis-data folder (if any) to initialize
# the table contents, or seeds the database if no such file exists.

# Environment:
#    APREXIS_VARIETY              the version of Aprexis to run (api or platform).
#    APREXIS_DOCKER_COMPOSE_FILE  the docker compose file to use to build the system. Default depends on APREXIS_VARIETY.
#    APREXIS_DATA_FOLDER          the folder containing the database dump to load. Default is ./aprexis-data/database.

# Author:  Ian Brown
# Since:   2021/05/25
# Version: 1.1.0

SHELL_DIR=`dirname "$0"`
APREXIS_VARIETY=${APREXIS_VARIETY:-api}
APREXIS_DOCKER_COMPOSE_FILE=docker-compose-${APREXIS_VARIETY}.yml
APREXIS_DATA_FOLDER=${APREXIS_DATA_FOLDER:-./aprexis-data/database}
data_file=$(ls -t `find ${APREXIS_DATA_FOLDER} -type f ! -iname ".*"` | head -n 1 | cut -d' ' -f2)


if [ "${APREXIS_VARIETY}" = 'engine' ]; then
  APREXIS_SHELL='engine'
else
  APREXIS_SHELL='platform'
fi

if [ $# -eq 0 ]; then
  ${SHELL_DIR}/start_db.sh
fi

if [ "${data_file}" = "" ]; then
  echo "Loading schema"
  docker-compose -f ${APREXIS_DOCKER_COMPOSE_FILE} \
    run -T --no-deps --rm engine bundle exec rails db:schema:load
else
  echo "Loading ${data_file}"
  if [[ "${data_file}" == *.gz ]]; then
    gunzip -c "${data_file}" | docker-compose -f ${APREXIS_DOCKER_COMPOSE_FILE} \
      run -T --no-deps --rm ${APREXIS_SHELL} psql -h postgres -U postgres aprexis_development
  else
    cat "${data_file}" | docker-compose -f ${APREXIS_DOCKER_COMPOSE_FILE} \
      run -T --no-deps --rm ${APREXIS_SHELL} psql -h postgres -U postgres aprexis_development
  fi

  echo "Ensuring that the name field has a value"
  cat set_name_from_question_key.sql | docker-compose -f ${APREXIS_DOCKER_COMPOSE_FILE} \
      run -T --no-deps --rm ${APREXIS_SHELL} psql -h postgres -U postgres aprexis_development

  echo "UPDATE gold_standard_package_versions SET ncpdp_exceptional_count = ncpdp_exceptional_count::numeric::integer::varchar, ncpdp_script_form_code = ncpdp_script_form_code::numeric::integer::varchar, inner_package_count = inner_package_count::numeric::integer::varchar;" | docker-compose -f ${APREXIS_DOCKER_COMPOSE_FILE} \
      run -T --no-deps --rm ${APREXIS_SHELL} psql -h postgres -U postgres aprexis_development

  echo "UPDATE gold_standard_packages SET ncpdp_exceptional_count = ncpdp_exceptional_count::numeric::integer::varchar, ncpdp_script_form_code = ncpdp_script_form_code::numeric::integer::varchar, inner_package_count = inner_package_count::numeric::integer::varchar;" | docker-compose -f ${APREXIS_DOCKER_COMPOSE_FILE} \
      run -T --no-deps --rm ${APREXIS_SHELL} psql -h postgres -U postgres aprexis_development

  echo "Migrating to latest schema"
  ${SHELL_DIR}/migrate_db.sh --have-databases
fi

if [ $# -eq 0 ]; then
  ${SHELL_DIR}/stop_db.sh
fi
