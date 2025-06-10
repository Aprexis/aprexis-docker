#!/usr/bin/env bash

# This script dumps the PostgreSQL database for the Aprexis platform into the aprexis-data/databse dir.
docker compose run --rm platform bash -c 'pg_dump -U $APREXIS_POSTGRES_USERNAME -h $APREXIS_POSTGRES_HOST --no-owner --format=plain --dbname=aprexis_development | gzip > /aprexis-data/database/aprexis_development_dump-$APREXIS_USERNAME-$(date +%Y-%m-%d-%H-%M-%S).sql.gz'
echo "Database dump completed and saved to aprexis-data/database directory."
ls -al aprexis-data/database
