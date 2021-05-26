#!/usr/bin/env bash

# Executes docker-compose to load data into the database. It uses the latest file in the aprexis-data folder (if any) to initialize
# the table contents, or seeds the database if no such file exists.

# Environment:
#    APREXIS_VARIETY              the version of Aprexis to run (api or platform).
#    APREXIS_DOCKER_COMPOSE_FILE  the docker compose file to use to build the system. Default depends on APREXIS_VARIETY.

# Author:  Ian Brown
# Since:   2021/05/25
# Version: 1.0.0

APREXIS_DOCKER_COMPOSE_FILE=docker-compose-${APREXIS_VARIETY}.yml
data_file=$(find ./aprexis-data -type f ! -iname ".*" -printf '%T+ %p\n'  | sort -r | head -n 1 | cut -d' ' -f2)

if [ "${data_file}" = "" ]; then
  echo "Loading schema"
  docker-compose -f ${APREXIS_DOCKER_COMPOSE_FILE} \
    run --rm platform bash --login -c "/aprexis/setup-for-rails.sh; bundle exec rails db:schema:load"
else
  echo "Loading ${data_file}"
  if [[ "${data_file}" == *.gz ]]; then
    zcat "${data_file}" | docker-compose -f ${APREXIS_DOCKER_COMPOSE_FILE} \
      run --rm platform bash --login -c "/aprexis/setup-for-rails.sh; psql -h postgres -U postgres aprexis_development"
  else
    cat "${data_file}" | docker-compose -f ${APREXIS_DOCKER_COMPOSE_FILE} \
      run --rm platform bash --login -c "/aprexis/setup-for-rails.sh; psql -h postgres -U postgres aprexis_development"
  fi

  echo "Migrating to latest schema"
  docker-compose -f ${APREXIS_DOCKER_COMPOSE_FILE} \
    run --rm platform bash --login -c "/aprexis/setup-for-rails.sh; bundle exec rails db:migrate"
fi
