#!/bin/bash
# download-osm.sh
set -e

echo "Preuzimanje OSM podataka za Srbiju..."

# Direktorijum za podatke
DATA_DIR="/opt/osmdata"
mkdir -p $DATA_DIR
cd $DATA_DIR

# Preuzimanje podataka za Srbiju (možete promeniti region po potrebi)
# Opcija 1: Preko geofabrik (ceo region)
wget -O serbia-latest.osm.pbf https://download.geofabrik.de/europe/serbia-latest.osm.pbf

# Opcija 2: Preko Overpass API (custom region - Srbija sa okolinom)
#BBOX="18.8,41.8,23.0,46.2"
#OSM_FILE="serbia.osm"

# Preuzimanje podataka koristeći Overpass API
#curl -X POST -d "[out:xml][timeout:1800];(node(${BBOX});way(${BBOX});relation(${BBOX}););out body;>;out skel qt;" \
#    https://overpass-api.de/api/interpreter > "${OSM_FILE}"

#echo "Konvertovanje OSM podataka u PBF format..."
#osmconvert "${OSM_FILE}" -o="serbia-latest.osm.pbf"
#rm "${OSM_FILE}"

echo "OSM podaci preuzeti u ${DATA_DIR}/serbia-latest.osm.pbf"
