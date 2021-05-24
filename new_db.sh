#!/usr/bin/env bash

# Executes docker-compose to initial a new, clean database. It uses the latest file in the aprexis-data folder (if any) to initialize
# the table contents, or seeds the database if no such file exists.

# Environment:
#    APREXIS_VARIETY              the version of Aprexis to run (api or platform).
#    APREXIS_DOCKER_COMPOSE_FILE  the docker compose file to use to build the system. Default depends on APREXIS_VARIETY.

# Author:  Ian Brown
# Since:   2021/05/21
# Version: 1.0.0

APREXIS_DOCKER_COMPOSE_FILE=docker-compose-${APREXIS_VARIETY}.yml

data_file=$(find ./aprexis-data -type f ! -iname ".*" -printf '%T+ %p\n'  | sort -r | head -n 1 | cut -d' ' -f2)

echo "Dropping existing database"
docker-compose -f ${APREXIS_DOCKER_COMPOSE_FILE} \
    run --rm platform bash -c "/aprexis/setup-for-rails.sh; RAILS_ENV=development_docker bundle exec rails db:environment:set db:exists" && \
  docker-compose -f ${APREXIS_DOCKER_COMPOSE_FILE} \
    run --rm platform bash -c "/aprexis/setup-for-rails.sh; RAILS_ENV=development_docker bundle exec rails db:environment:set db:drop"

echo "Creating new database"
docker-compose -f ${APREXIS_DOCKER_COMPOSE_FILE} \
  run --rm platform bash -c "/aprexis/setup-for-rails.sh; RAILS_ENV=development_docker bundle exec rails db:create"

if [ "${data_file}" = "" ]; then
  echo "Loading schema"
  docker-compose -f ${APREXIS_DOCKER_COMPOSE_FILE} \
    run --rm platform bash -c "/aprexis/setup-for-rails.sh; RAILS_ENV=development_docker bundle exec rails db:schema:load"
else
  echo "Loading ${data_file}"
  if [[ "${data_file}" == *.gz ]]; then
    zcat "${data_file}" | docker-compose -f ${APREXIS_DOCKER_COMPOSE_FILE} \
      run --rm platform bash -c "/aprexis/setup-for-rails.sh; psql -h postgres -U postgres aprexis_development"
  else
    cat "${data_file}" | docker-compose -f ${APREXIS_DOCKER_COMPOSE_FILE} \
      run --rm platform bash -c "/aprexis/setup-for-rails.sh; psql -h postgres -U postgres aprexis_development"
  fi

  echo "Migrating to latest schema"
  docker-compose -f ${APREXIS_DOCKER_COMPOSE_FILE} \
    run --rm platform bash -c "/aprexis/setup-for-rails.sh; RAILS_ENV=development_docker bundle exec rails db:migrate"
fi

echo "Enabling all users"
cat enable-users | docker-compose -f ${APREXIS_DOCKER_COMPOSE_FILE} \
  run --rm platform bash -c "/aprexis/setup-for-rails.sh; RAILS_ENV=development_docker bundle exec rails c"

echo "Indexing"
docker-compose -f ${APREXIS_DOCKER_COMPOSE_FILE} \
  run --rm platform bash -c "/aprexis/setup-for-rails.sh; RAILS_ENV=development_docker bundle exec rails sunspot:reindex"

echo "Closing down started services"
docker-compose -f ${APREXIS_DOCKER_COMPOSE_FILE} down
