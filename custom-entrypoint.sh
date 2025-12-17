#!/bin/bash
set -e

# Ako nije definisan PGDATA, koristi default
: "${PGDATA:=/var/lib/pgsql/16/data}"

echo "PGDATA set to $PGDATA"

# Provera da li je folder prazan (bez skrivenih fajlova)
if [ -z "$(ls -A "$PGDATA")" ]; then
    echo "PGDATA folder je prazan, inicijalizujem bazu..."
    sudo chown -R postgres:postgres "$PGDATA"
    /usr/pgsql-16/bin/initdb -D "$PGDATA" --locale=C.UTF-8
    sudo cp -f /docker-entrypoint-initdb.d/postgresql.conf "$PGDATA"/postgresql.conf
    sudo cp -f /docker-entrypoint-initdb.d/pg_hba.conf "$PGDATA"/pg_hba.conf
    sudo chown -R postgres:postgres "$PGDATA"/postgresql.conf "$PGDATA"/pg_hba.conf
else
    echo "PGDATA folder nije prazan, preskačem initdb..."
fi

# Pokreni postgres
pg_ctl -D "$PGDATA" -l /var/lib/pgsql/16/logfile start

exec "$@"
