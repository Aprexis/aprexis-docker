#!/usr/bin/env bash

# Executes docker-compose to initialize the test database.

# Environment:
#    APREXIS_VARIETY              the version of Aprexis to run (api or platform).
#    APREXIS_DOCKER_COMPOSE_FILE  the docker compose file to use to build the system. Default depends on APREXIS_VARIETY.

# Author:  Ian Brown
# Since:   2021/05/26
# Version: 1.0.0

APREXIS_DOCKER_COMPOSE_FILE=docker-compose-${APREXIS_VARIETY}.yml

echo "Set up test database"
docker-compose -f ${APREXIS_DOCKER_COMPOSE_FILE} \
  run --rm platform bash --login -c "/aprexis/setup-for-rails.sh; bundle exec rails db:test:prepare"
