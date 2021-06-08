#!/usr/bin/env bash

# Executes docker-compose to run a shell on one of the Aprexis system containers.

# Parameter:
#    $1                           the container.

# Environment:
#    APREXIS_VARIETY              the version of Aprexis to run (api or platform).
#    APREXIS_DOCKER_COMPOSE_FILE  the docker compose file to use to build the system. Default depends on APREXIS_VARIETY.

# Author:  Ian Brown
# Since:   2021/05/24
# Version: 1.0.0

APREXIS_VARIETY=${APREXIS_VARIETY:-api}
APREXIS_DOCKER_COMPOSE_FILE=docker-compose-${APREXIS_VARIETY}.yml

docker-compose -f ${APREXIS_DOCKER_COMPOSE_FILE} run $1 /bin/bash --login
