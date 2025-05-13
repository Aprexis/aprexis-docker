#!/usr/bin/env bash

# Executes docker-compose to initialize a new, clean database. It uses the latest file in the aprexis-data folder to load
# the tables after they have been created.

# Environment:
#    APREXIS_VARIETY              the version of Aprexis to run (api or platform).
#    APREXIS_DOCKER_COMPOSE_FILE  the docker compose file to use to build the system. Default depends on APREXIS_VARIETY.
#    APREXIS_DATA_FOLDER          the folder containing the database dump to load. Default is ./aprexis-data/anonymized.

# Author:  Ian Brown
# Since:   2024/08/23
# Version: 1.0.0

SHELL_DIR=`dirname "$0"`
APREXIS_VARIETY=${APREXIS_VARIETY:-api}
APREXIS_DOCKER_COMPOSE_FILE=docker-compose-${APREXIS_VARIETY}.yml
APREXIS_DATA_FOLDER=${APREXIS_DATA_FOLDER:-./aprexis-data/anonymized}
data_file=$(ls -t `find ${APREXIS_DATA_FOLDER} -type f ! -iname ".*"` | head -n 1 | cut -d' ' -f2)

if [ "${data_file}" = "" ]; then
  echo "No data file to load. Aborting..."
  exit -1
fi


${SHELL_DIR}/start_db.sh APREXIS_VARIETY=${APREXIS_VARIETY} APREXIS_DOCKER_COMPOSE_FILE=${APREXIS_DOCKER_COMPOSE_FILE}
${SHELL_DIR}/drop_db.sh --have-databases APREXIS_VARIETY=${APREXIS_VARIETY} APREXIS_DOCKER_COMPOSE_FILE=${APREXIS_DOCKER_COMPOSE_FILE}
${SHELL_DIR}/create_db.sh --have-databases APREXIS_VARIETY=${APREXIS_VARIETY} APREXIS_DOCKER_COMPOSE_FILE=${APREXIS_DOCKER_COMPOSE_FILE}
${SHELL_DIR}/load_anonymized_data.sh --have-databases APREXIS_VARIETY=${APREXIS_VARIETY} APREXIS_DOCKER_COMPOSE_FILE=${APREXIS_DOCKER_COMPOSE_FILE} APREXIS_DATA_FOLDER=${APREXIS_DATA_FOLDER}
${SHELL_DIR}/enable_users.sh --have-databases APREXIS_VARIETY=${APREXIS_VARIETY} APREXIS_DOCKER_COMPOSE_FILE=${APREXIS_DOCKER_COMPOSE_FILE}
${SHELL_DIR}/prepare_test_db.sh --have-databases APREXIS_VARIETY=${APREXIS_VARIETY} APREXIS_DOCKER_COMPOSE_FILE=${APREXIS_DOCKER_COMPOSE_FILE}

${SHELL_DIR}/down.sh
