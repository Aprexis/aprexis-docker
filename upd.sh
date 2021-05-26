#!/usr/bin/env bash

# Executes docker-compose to bring the system up in detached mode.

# Parameters:
#    $1                           the optional container to bring up. The default is all.

# Environment:
#    APREXIS_VARIETY              the version of Aprexis to run (api or platform).
#    APREXIS_DOCKER_COMPOSE_FILE  the docker compose file to use to build the system. Default depends on APREXIS_VARIETY.

# Author:  Ian Brown
# Since:   2021/05/21
# Version: 1.0.0

APREXIS_DOCKER_COMPOSE_FILE=docker-compose-${APREXIS_VARIETY}.yml

docker-compose -f ${APREXIS_DOCKER_COMPOSE_FILE} up -d $1
