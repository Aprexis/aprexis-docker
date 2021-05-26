#!/usr/bin/env bash

# Executes docker-compose to initialize a new, clean database. It uses the latest file in the aprexis-data folder (if any) to initialize
# the table contents, or seeds the database if no such file exists.

# Environment:
#    APREXIS_VARIETY              the version of Aprexis to run (api or platform).
#    APREXIS_DOCKER_COMPOSE_FILE  the docker compose file to use to build the system. Default depends on APREXIS_VARIETY.

# Author:  Ian Brown
# Since:   2021/05/21
# Version: 1.0.0

SHELL_DIR=`dirname "$0"`
APREXIS_DOCKER_COMPOSE_FILE=docker-compose-${APREXIS_VARIETY}.yml

${SHELL_DIR}/drop_db.sh
${SHELL_DIR}/create_db.sh
${SHELL_DIR}/load_data.sh
${SHELL_DIR}/enable_users.sh
${SHELL_DIR}/prepare_test_db.sh

${SHELL_DIR}/down.sh
