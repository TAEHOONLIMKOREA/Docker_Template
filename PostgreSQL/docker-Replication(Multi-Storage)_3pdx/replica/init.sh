#!/bin/bash
set -e

# Wait for the primary server to be ready
export PGPASSWORD="madcoder"
until psql -h "$PRIMARY_HOST" -U "keti_root" -d "keti_3pdx" -c '\q'; do
  >&2 echo "Primary is unavailable - sleeping"
  sleep 1
done

# Stop PostgreSQL server
pg_ctl -D "$PGDATA" -m fast -w stop

# Clear the data directory
rm -rf "$PGDATA"/*

# Backup from primary
pg_basebackup -h "$PRIMARY_HOST" -D "$PGDATA" -U replica -Fp -Xs -P -R

# Start PostgreSQL server
pg_ctl -D "$PGDATA" -o "-c config_file=$PGDATA/postgresql.conf" -w start