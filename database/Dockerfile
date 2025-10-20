# Dockerfile.postgres
FROM postgres:15-alpine

# Copy configuration files
COPY postgresql-custom.conf /etc/postgresql/
COPY pg_hba.conf /tmp/pg_hba.conf
COPY init-database.sql /docker-entrypoint-initdb.d/

# Set proper permissions
RUN chmod 644 /docker-entrypoint-initdb.d/init-database.sql
RUN chmod 644 /etc/postgresql/postgresql-custom.conf
RUN chmod 644 /tmp/pg_hba.conf

# Copy and set up initialization script
COPY setup-postgres.sh /docker-entrypoint-initdb.d/
RUN chmod +x /docker-entrypoint-initdb.d/setup-postgres.sh

# Use custom config
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql-custom.conf"]