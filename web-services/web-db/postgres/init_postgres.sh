#!/bin/bash

set -e

echo "Initializing Service Databases..."

sleep 10 # I hate this but I can't make pg_isready work

# Create gitea user and database
psql -v ON_ERROR_STOP=1 --username "${POSTGRES_USER}" -h localhost <<-EOSQL
  CREATE USER ${GITEA_DB_USER} WITH PASSWORD '${GITEA_DB_PASSWORD}';
  CREATE DATABASE ${GITEA_DB_NAME} OWNER ${GITEA_DB_USER};
  GRANT ALL PRIVILEGES ON DATABASE ${GITEA_DB_NAME} TO ${GITEA_DB_USER};
EOSQL

echo "gitea user and database created successfully."

# Create woodpecker user and database
psql -v ON_ERROR_STOP=1 --username "${POSTGRES_USER}" -h localhost <<-EOSQL
  CREATE USER ${WOODPECKER_DB_USER} WITH PASSWORD '${WOODPECKER_DB_PASSWORD}';
  CREATE DATABASE ${WOODPECKER_DB_NAME} OWNER ${WOODPECKER_DB_USER};
  GRANT ALL PRIVILEGES ON DATABASE ${WOODPECKER_DB_NAME} TO ${WOODPECKER_DB_USER};
EOSQL

echo "woodpecker user and database created successfully."