.NOTPARALLEL:

SHELL = /usr/bin/env bash
DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
APREXIS_VARIETY := api

# Composite commands:

# Build new version of full system (API and platform) and launch.
new_up: down build new_db up

# Build new version of full system (API and platform) and launch in background.
new_up: down build new_db upd

# Bring up supporting containers.
support: postgres solr

# Basic commands:

build:
	${DIR}/export-env.sh; export APREXIS_VARIETY=${APREXIS_VARIETY}; ${DIR}/build.sh

clean_docker:
	export APREXIS_VARIETY=${APREXIS_VARIETY}; ${DIR}/clean_docker.sh

create_db:
	${DIR}/export-env.sh; export APREXIS_VARIETY=${APREXIS_VARIETY}; ${DIR}/create_db.sh

down:
	${DIR}/export-env.sh; export APREXIS_VARIETY=${APREXIS_VARIETY}; ${DIR}/down.sh

drop_db:
	${DIR}/export-env.sh; export APREXIS_VARIETY=${APREXIS_VARIETY}; ${DIR}/drop_db.sh

force_build:
	${DIR}/export-env.sh; export APREXIS_VARIETY=${APREXIS_VARIETY}; ${DIR}/force_build.sh

index_db:
	${DIR}/export-env.sh; export APREXIS_VARIETY=${APREXIS_VARIETY}; ${DIR}/index_db.sh

load_data:
	${DIR}/export-env.sh; export APREXIS_VARIETY=${APREXIS_VARIETY}; ${DIR}/load_data.sh

new_db:
	${DIR}/export-env.sh; export APREXIS_VARIETY=${APREXIS_VARIETY}; ${DIR}/new_db.sh

prepare_test_db:
	${DIR}/export-env.sh; export APREXIS_VARIETY=${APREXIS_VARIETY}; ${DIR}/prepare_test_db.sh

prune:
	docker system prune

up:
	${DIR}/export-env.sh; export APREXIS_VARIETY=${APREXIS_VARIETY}; ${DIR}/up.sh

upd:
	${DIR}/export-env.sh; export APREXIS_VARIETY=${APREXIS_VARIETY}; ${DIR}/up.sh

platform_shell:
	${DIR}/export-env.sh; export APREXIS_VARIETY=${APREXIS_VARIETY}; ${DIR}/shell.sh platform

api_shell:
	${DIR}/export-env.sh; export APREXIS_VARIETY=${APREXIS_VARIETY}; ${DIR}/shell.sh api

postgres:
	${DIR}/export-env.sh; export APREXIS_VARIETY=${APREXIS_VARIETY}; ${DIR}/upd.sh postgres

redis:
	${DIR}/export-env.sh; export APREXIS_VARIETY=${APREXIS_VARIETY}; ${DIR}/upd.sh redis

solr: redis
	${DIR}/export-env.sh; export APREXIS_VARIETY=${APREXIS_VARIETY}; ${DIR}/upd.sh solr
