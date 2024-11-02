#!/bin/bash

set -e

# Wait for PostgreSQL to be ready
until pg_isready -h localhost -p 5432; do
  echo "Waiting for PostgreSQL to be ready..."
  sleep 2
done

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