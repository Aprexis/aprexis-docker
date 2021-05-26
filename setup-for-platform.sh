#!/usr/bin/env bash
cp /tmp/hosts /etc/hosts; /aprexis/wait-for-it.sh redis:6379; /aprexis/wait-for-it.sh postgres:5432; /aprexis/wait-for-it.sh solr:8983
