#!/usr/bin/env bash

# Exports the contents of the /root/.env file into the shell, ignoring any that have already been set. This is
# designed to be run inside a docker container.

# Author:  Ian Brown
# Since:   2021/05/25
# Version: 1.0.0

trap 'rm -f "$TMPFILE"' EXIT
TMPFILE=$(mktemp) || exit 1
grep -v '^#' /root/.env | sed 's/\=.*//' | sed '/^[[:space:]]*$/d' >>${TMPFILE}

while read -r variable_name; do
  variable_value=$(printenv "${variable_name}")
  if [ "${variable_value}" = "" ]; then
    export $(grep "${variable_name}" /root/.env | xargs)
  fi
done < ${TMPFILE}
