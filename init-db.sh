#!/bin/bash
# init-db.sh
set -e


# Kreiranje baze
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    -- Kreiranje baze sa PostGIS ekstenzijom
    CREATE DATABASE gis_db;
    \c gis_db;
    
    -- Uključivanje PostGIS ekstenzija
    CREATE EXTENSION postgis;
    CREATE EXTENSION postgis_topology;
    CREATE EXTENSION pg_strom;
    
    -- Kreiranje korisnika za aplikaciju
    CREATE USER osmuser WITH PASSWORD 'osmpassword';
    GRANT ALL PRIVILEGES ON DATABASE gis_db TO osmuser;
    
    -- Konfiguracija pg_storm
    ALTER SYSTEM SET pg_storm.enable_gpuscan = on;
    ALTER SYSTEM SET pg_storm.enable_gpuhashjoin = on;
    ALTER SYSTEM SET pg_storm.enable_gpupreagg = on;
    ALTER SYSTEM SET pg_storm.enable_gpupreagg_hashing = on;
    ALTER SYSTEM SET pg_storm.enable_gpudistinct = on;
    ALTER SYSTEM SET pg_storm.enable_gpunestloop = on;
    ALTER SYSTEM SET pg_storm.max_gpumem = 6144;
    ALTER SYSTEM SET pg_storm.gpu_device_id = 0;
    SELECT pg_reload_conf();
EOSQL

echo "Inicijalizacija baze završena!"
