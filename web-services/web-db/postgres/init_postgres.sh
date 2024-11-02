#!/bin/bash

set -e

echo "Initializing Service Databases..."

# Function to check if PostgreSQL is ready
function wait_for_postgres() {
  until psql -h database -U "${POSTGRES_USER}" -c '\q' 2>/dev/null; do
    echo "PostgreSQL is unavailable - sleeping"
    sleep 1
  done
  echo "PostgreSQL is up - executing command"
}

# Wait for PostgreSQL to be ready
wait_for_postgres

# Create gitea user and database
psql -v ON_ERROR_STOP=1 --username "${POSTGRES_USER}" -h database <<-EOSQL
  CREATE USER ${GITEA_DB_USER} WITH PASSWORD '${GITEA_DB_PASSWORD}';
  CREATE DATABASE ${GITEA_DB_NAME} OWNER ${GITEA_DB_USER};
  GRANT ALL PRIVILEGES ON DATABASE ${GITEA_DB_NAME} TO ${GITEA_DB_USER};
EOSQL

echo "gitea user and database created successfully."

# Create woodpecker user and database
psql -v ON_ERROR_STOP=1 --username "${POSTGRES_USER}" -h database <<-EOSQL
  CREATE USER ${WOODPECKER_DB_USER} WITH PASSWORD '${WOODPECKER_DB_PASSWORD}';
  CREATE DATABASE ${WOODPECKER_DB_NAME} OWNER ${WOODPECKER_DB_USER};
  GRANT ALL PRIVILEGES ON DATABASE ${WOODPECKER_DB_NAME} TO ${WOODPECKER_DB_USER};
EOSQL

echo "woodpecker user and database created successfully."