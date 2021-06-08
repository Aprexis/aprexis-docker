#!/usr/bin/env bash

# Executes docker-compose to build a version of the code from a clean slate.

# Environment:
#    APREXIS_DOCKER_COMPOSE_FILE  the docker compose file to use to build the system.

# Author:  Ian Brown
# Since:   2021/05/21
# Version: 1.0.0

APREXIS_VARIETY=${APREXIS_VARIETY:-api}
APREXIS_DOCKER_COMPOSE_FILE=docker-compose-${APREXIS_VARIETY}.yml

docker-compose -f ${APREXIS_DOCKER_COMPOSE_FILE} build --force-rm --no-cache --pull
