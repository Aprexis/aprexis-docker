.NOTPARALLEL:

SHELL = /usr/bin/env bash
DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
APREXIS_VARIETY := api

# Composite commands:

# Build new version of full system (API and platform) and launch.
new_up: down build new_db up


# Basic commands:

build:
	${DIR}/export-env.sh; export APREXIS_VARIETY=${APREXIS_VARIETY}; ${DIR}/build.sh

clean_docker:
	export APREXIS_VARIETY=${APREXIS_VARIETY}; ${DIR}/clean_docker.sh

down:
	${DIR}/export-env.sh; export APREXIS_VARIETY=${APREXIS_VARIETY}; ${DIR}/down.sh

force_build:
	${DIR}/export-env.sh; export APREXIS_VARIETY=${APREXIS_VARIETY}; ${DIR}/force_build.sh

new_db:
	${DIR}/export-env.sh; export APREXIS_VARIETY=${APREXIS_VARIETY}; ${DIR}/new_db.sh

up:
	${DIR}/export-env.sh; export APREXIS_VARIETY=${APREXIS_VARIETY}; ${DIR}/up.sh
