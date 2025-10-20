#!/bin/bash
set -e

echo "Setting up PostgreSQL HBA configuration..."

# Copy custom HBA config to data directory
cp /tmp/pg_hba.conf /var/lib/postgresql/data/pg_hba.conf

# Set proper permissions
chmod 600 /var/lib/postgresql/data/pg_hba.conf
chown postgres:postgres /var/lib/postgresql/data/pg_hba.conf

echo "PostgreSQL HBA configuration completed."