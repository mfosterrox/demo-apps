FROM docker.io/library/postgres:alpine

ENV POSTGRES_USER=patient_portal
ENV POSTGRES_PASSWORD=secret
ENV POSTGRES_HOST_AUTH_METHOD=scram-sha-256
ENV POSTGRES_INITDB_ARGS=--auth-host=scram-sha-256
ENV PGDATA=/pgdata/data

COPY data.sql /docker-entrypoint-initdb.d/data.sql

# This is required for OpenShift because the base PostgreSQL image
# runs as root
RUN mkdir /pgdata && \
    chgrp -R root /docker-entrypoint-initdb.d/data.sql /pgdata && \
    chmod -R g+rwX /docker-entrypoint-initdb.d/data.sql /pgdata
