#!/usr/bin/env bash

# Executes docker-compose to initialize the test database.

# Environment:
#    APREXIS_VARIETY              the version of Aprexis to run (api or platform).
#    APREXIS_DOCKER_COMPOSE_FILE  the docker compose file to use to build the system. Default depends on APREXIS_VARIETY.

# Author:  Ian Brown
# Since:   2021/05/26
# Version: 1.0.0

SHELL_DIR=`dirname "$0"`
APREXIS_VARIETY=${APREXIS_VARIETY:-api}
APREXIS_DOCKER_COMPOSE_FILE=docker-compose-${APREXIS_VARIETY}.yml

if [ $# -eq 0 ]; then
  ${SHELL_DIR}/start_db.sh
fi

echo "Set up test database"
docker-compose -f ${APREXIS_DOCKER_COMPOSE_FILE} \
  run --no-deps --rm platform bash --login -c "/aprexis/setup-for-rails.sh; bundle exec rails db:test:prepare"

if [ $# -eq 0 ]; then
  ${SHELL_DIR}/stop_db.sh
fi
