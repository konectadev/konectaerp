# Dockerfile.postgres
FROM postgres:15-alpine

# Copy configuration files
COPY postgresql-custom.conf /etc/postgresql/
COPY pg_hba.conf /tmp/pg_hba.conf
COPY init-db.sql /docker-entrypoint-initdb.d/
COPY init-pg-hba.sh /docker-entrypoint-initdb.d/

# Set proper permissions
RUN chmod 644 /docker-entrypoint-initdb.d/init-db.sql
RUN chmod +x /docker-entrypoint-initdb.d/init-pg-hba.sh
RUN chmod 644 /etc/postgresql/postgresql-custom.conf
RUN chmod 644 /tmp/pg_hba.conf

# Use custom config
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql-custom.conf"]