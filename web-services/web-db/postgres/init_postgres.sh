#!/bin/bash

set -e

# Wait for PostgreSQL to be ready
until pg_isready -h localhost -U ${POSTGRES_USER} -p 5432; do
  case $? in
    1)
      echo "PostgreSQL is rejecting connections. Waiting..."
      ;;
    2)
      echo "No response from PostgreSQL. Waiting..."
      ;;
    3)
      echo "Invalid parameters for pg_isready. Exiting..."
      exit 1
      ;;
  esac
  sleep 2
done

echo "PostgreSQL is ready to accept connections."

# Create gitea user and database
psql -v ON_ERROR_STOP=1 --username "postgres" <<-EOSQL
  CREATE USER gitea WITH PASSWORD '${GITEA_DB_PASSWORD}';
  CREATE DATABASE gitea OWNER gitea;
  GRANT ALL PRIVILEGES ON DATABASE gitea TO gitea;
EOSQL

echo "gitea user and database created successfully."

# Create woodpecker user and database
psql -v ON_ERROR_STOP=1 --username "postgres" <<-EOSQL
  CREATE USER woodpecker WITH PASSWORD '${WOODPECKER_DB_PASSWORD}';
  CREATE DATABASE woodpecker OWNER woodpecker;
  GRANT ALL PRIVILEGES ON DATABASE woodpecker TO woodpecker;
EOSQL

echo "woodpecker user and database created successfully."