#!/usr/bin/env bash
cp /tmp/hosts /etc/hosts; /aprexis/wait-for-it.sh postgres:5432
