#!/usr/bin/env bash

# Executes docker-compose to drop the database.

# Environment:
#    APREXIS_VARIETY              the version of Aprexis to run (api or platform).
#    APREXIS_DOCKER_COMPOSE_FILE  the docker compose file to use to build the system. Default depends on APREXIS_VARIETY.

# Author:  Ian Brown
# Since:   2021/05/25
# Version: 1.0.0

SHELL_DIR=`dirname "$0"`
APREXIS_VARIETY=${APREXIS_VARIETY:-api}
APREXIS_DOCKER_COMPOSE_FILE=docker-compose-${APREXIS_VARIETY}.yml

if [ $# -eq 0 ]; then
  ${SHELL_DIR}/start_db.sh
fi

echo "Dropping existing database"
docker-compose -f ${APREXIS_DOCKER_COMPOSE_FILE} \
    run --no-deps --rm platform bash --login -c "/aprexis/setup-for-rails.sh; psql -l -h postgres -U postgres | grep aprexis_development | wc -l" && \
  docker-compose -f ${APREXIS_DOCKER_COMPOSE_FILE} \
    run --no-deps --rm platform bash --login -c \
      "/aprexis/setup-for-rails.sh; bundle exec rails db:environment:set RAILS_ENV=development; bundle exec rails db:drop"

if [ $# -eq 0 ]; then
  ${SHELL_DIR}/stop_db.sh
fi
