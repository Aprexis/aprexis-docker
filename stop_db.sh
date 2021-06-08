#!/usr/bin/env bash

# Executes docker-compose to shutdown the databases.

# Environment:
#    APREXIS_VARIETY              the version of Aprexis to run (api or platform).
#    APREXIS_DOCKER_COMPOSE_FILE  the docker compose file to use to build the system. Default depends on APREXIS_VARIETY.

# Author:  Ian Brown
# Since:   2021/06/08
# Version: 1.0.0

APREXIS_VARIETY=${APREXIS_VARIETY:-api}
APREXIS_DOCKER_COMPOSE_FILE=docker-compose-${APREXIS_VARIETY}.yml

echo "Closing databases"
docker-compose -f ${APREXIS_DOCKER_COMPOSE_FILE} stop postgres
docker-compose -f ${APREXIS_DOCKER_COMPOSE_FILE} stop redis
