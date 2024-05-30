#!/usr/bin/env bash
 
# Executes docker-compose to rollback an existing database.

# Environment:
#    APREXIS_VARIETY              the version of Aprexis to run (api or platform).
#    APREXIS_DOCKER_COMPOSE_FILE  the docker compose file to use to build the system. Default depends on APREXIS_VARIETY.
#    STEP                         the number of steps to rollback (default 1).

# Author:  Ian Brown
# Since:   2021/10/07
# Version: 1.0.0

SHELL_DIR=`dirname "$0"`
APREXIS_VARIETY=${APREXIS_VARIETY:-api}
APREXIS_DOCKER_COMPOSE_FILE=docker-compose-${APREXIS_VARIETY}.yml
STEP=${STEP:-1}

if [ "${APREXIS_VARIETY}" = 'engine' ]; then
  APREXIS_SHELL='engine'
else
  APREXIS_SHELL='platform'
fi

if [ $# -eq 0 ]; then
  ${SHELL_DIR}/start_db.sh
fi

docker-compose -f ${APREXIS_DOCKER_COMPOSE_FILE} \
    run -T --no-deps --rm ${APREXIS_SHELL} bash --login -c "/aprexis/setup-for-rails.sh; bundle exec rails db:rollback STEP=${STEP}"

if [ $# -eq 0 ]; then
  ${SHELL_DIR}/stop_db.sh
fi

