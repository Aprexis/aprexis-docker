.NOTPARALLEL:

SHELL = /usr/bin/env bash
DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
APREXIS_VARIETY := api

# Composite commands:

# Build new version of full system (API and platform) and launch.
new_up: down build new_db up

# Build new version of full system (API and platform) and launch in background.
new_upd: down build new_db upd

# Bring up supporting containers.
support: postgres redis

# Basic commands:

build:
	${DIR}/export-env.sh; export APREXIS_VARIETY=${APREXIS_VARIETY}; ${DIR}/build.sh

build_api:
	${DIR}/export-env.sh; export APREXIS_VARIETY=engine; ${DIR}/build.sh

build_engine:
	${DIR}/export-env.sh; export APREXIS_VARIETY=engine; ${DIR}/build.sh

build_etl:
	${DIR}/export-env.sh; export APREXIS_VARIETY=etl; ${DIR}/build.sh

build_platform:
	${DIR}/export-env.sh; export APREXIS_VARIETY=platform; ${DIR}/build.sh

clean_docker:
	export APREXIS_VARIETY=${APREXIS_VARIETY}; ${DIR}/clean_docker.sh

create_db:
	${DIR}/export-env.sh; export APREXIS_VARIETY=engine; ${DIR}/create_db.sh

down:
	${DIR}/export-env.sh; export APREXIS_VARIETY=${APREXIS_VARIETY}; ${DIR}/down.sh

drop_db:
	${DIR}/export-env.sh; export APREXIS_VARIETY=engine; ${DIR}/drop_db.sh

enable_users:
	${DIR}/export-env.sh; export APREXIS_VARIETY=engine; ${DIR}/enable_users.sh

force_build:
	${DIR}/export-env.sh; export APREXIS_VARIETY=${APREXIS_VARIETY}; ${DIR}/force_build.sh

load_data:
	${DIR}/export-env.sh; export APREXIS_VARIETY=engine; ${DIR}/load_data.sh

migrate_db:
	${DIR}/export-env.sh; export APREXIS_VARIETY=engine; ${DIR}/migrate_db.sh

new_db:
	${DIR}/export-env.sh; export APREXIS_VARIETY=engine; ${DIR}/new_db.sh

prepare_test_db:
	${DIR}/export-env.sh; export APREXIS_VARIETY=engine; ${DIR}/prepare_test_db.sh

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

etl_shell:
	${DIR}/export-env.sh; export APREXIS_VARIETY=etl; ${DIR}/shell.sh etl

engine_shell:
	${DIR}/export-env.sh; export APREXIS_VARIETY=engine; ${DIR}/shell.sh engine

postgres:
	${DIR}/export-env.sh; export APREXIS_VARIETY=${APREXIS_VARIETY}; ${DIR}/upd.sh postgres

redis:
	${DIR}/export-env.sh; export APREXIS_VARIETY=${APREXIS_VARIETY}; ${DIR}/upd.sh redis


stop_android:
	adb devices | grep emulator | cut -f1 | while read line; do adb -s $line emu kill; done
	rm -f ~/.android/avd/*.avd/*.lock
