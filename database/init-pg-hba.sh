#!/bin/bash
set -e

# This script runs during PostgreSQL initialization
# It copies the custom pg_hba.conf to the data directory

echo "Applying custom pg_hba.conf configuration..."

# The data directory defaults to /var/lib/postgresql/data in postgres image
DATA_DIR="${PGDATA:-/var/lib/postgresql/data}"

if [ -f "/tmp/pg_hba.conf" ] && [ -d "$DATA_DIR" ]; then
    cp /tmp/pg_hba.conf "$DATA_DIR/pg_hba.conf"
    chmod 600 "$DATA_DIR/pg_hba.conf"
    chown postgres:postgres "$DATA_DIR/pg_hba.conf"
    echo "Custom pg_hba.conf has been applied to $DATA_DIR/pg_hba.conf"
else
    echo "Warning: pg_hba.conf setup skipped"
fi

