#!/bin/bash
# import-osm.sh
set -e

echo "Uvoz OSM podataka u bazu..."

# Parametri
OSM_FILE="/opt/osmdata/serbia-latest.osm.pbf"
DB_NAME="gis_db"
DB_USER="postgres"
DB_HOST="localhost"

# Provera da li fajl postoji
if [ ! -f "$OSM_FILE" ]; then
    echo "OSM fajl nije pronađen. Pokrenite download-osm.sh prvo."
    exit 1
fi

# Uvoz podataka sa GPU optimizacijom
osm2pgsql \
    -d $DB_NAME \
    --create \
    --slim \
    -C 2000 \
    --number-processes 4 \
    --hstore \
    --extra-attributes \
    --style /usr/share/osm2pgsql/default.style \
    $OSM_FILE

echo "Uvoz podataka završen!"

# Optimizacija baze nakon uvoza
psql -d $DB_NAME -U $DB_USER <<-EOSQL
    VACUUM ANALYZE;
    REINDEX DATABASE $DB_NAME;
EOSQL

echo "Optimizacija baze završena!"
