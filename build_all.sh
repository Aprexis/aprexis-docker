#!/usr/bin/env bash

# Executes docker-compose to build a version of the code.

# Author:  Ian Brown
# Since:   2021/05/21
# Version: 1.0.0

source .env
docker-compose build
docker-compose run --rm platform bundle config --local GITHUB__COM x-access-token:${APREXIS_ENGINE_TOKEN}
docker-compose run --rm api bundle config --local GITHUB__COM x-access-token:${APREXIS_ENGINE_TOKEN}
docker-compose run --rm platform bundle install
docker-compose run --rm api bundle install
docker-compose run --rm engine bundle install
