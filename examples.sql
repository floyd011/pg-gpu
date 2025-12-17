-- 1. Kreiranje tabele za OSM podatke (nakon što se podaci uvezu)
-- Prvo uvezite podatke sa:
-- osm2pgsql -d gis_db -U postgres -H localhost -W --create --slim -C 2000 --number-processes 4 /opt/osm-data/serbia-latest.osm.pbf

-- 2. Pronalaženje svih restorana u Beogradu
SELECT 
    name,
    ST_AsText(way) as location,
    amenity,
    cuisine
FROM planet_osm_point 
WHERE 
    amenity = 'restaurant' 
    AND name IS NOT NULL
    AND ST_Contains(
        ST_MakeEnvelope(20.40, 44.75, 20.55, 44.85, 4326),
        way
    )
ORDER BY name;

-- 3. Pronalaženje svih benzinskih pumpi u Srbiji (koristi GPU akceleraciju)
EXPLAIN ANALYZE
SELECT 
    name,
    operator,
    brand,
    ST_Distance(
        ST_Transform(way, 3857),
        ST_Transform(ST_SetSRID(ST_MakePoint(20.45, 44.82), 4326), 3857)
    ) as distance_meters
FROM planet_osm_point 
WHERE 
    amenity = 'fuel'
    AND name IS NOT NULL
ORDER BY distance_meters
LIMIT 50;

-- 4. Agregacija po tipu objekta (GPU akcelerisano)
EXPLAIN ANALYZE
SELECT 
    amenity,
    COUNT(*) as count,
    AVG(ST_X(way)) as avg_lon,
    AVG(ST_Y(way)) as avg_lat
FROM planet_osm_point 
WHERE 
    amenity IS NOT NULL
GROUP BY amenity
HAVING COUNT(*) > 10
ORDER BY count DESC;

-- 5. Pronalaženje svih bolnica unutar 10km od centra Beograda
SELECT 
    name,
    ST_AsText(way) as location,
    healthcare,
    ST_Distance_Sphere(
        way,
        ST_SetSRID(ST_MakePoint(20.45, 44.82), 4326)
    ) as distance_meters
FROM planet_osm_point 
WHERE 
    amenity = 'hospital' 
    OR healthcare IS NOT NULL
HAVING ST_Distance_Sphere(
    way,
    ST_SetSRID(ST_MakePoint(20.45, 44.82), 4326)
) < 10000
ORDER BY distance_meters;

-- 6. Analiza puteva - dužine puteva po tipu
SELECT 
    highway,
    COUNT(*) as road_count,
    SUM(ST_Length(ST_Transform(way, 3857))) as total_length_meters
FROM planet_osm_line 
WHERE 
    highway IS NOT NULL
GROUP BY highway
ORDER BY total_length_meters DESC;

-- 7. GPU akcelerisani JOIN između tačaka i poligona
EXPLAIN ANALYZE
SELECT 
    p.name as place_name,
    a.name as admin_name,
    p.amenity,
    ST_AsText(p.way) as location
FROM planet_osm_point p
JOIN planet_osm_polygon a ON ST_Contains(a.way, p.way)
WHERE 
    p.amenity IN ('school', 'university')
    AND a.boundary = 'administrative'
    AND a.admin_level = '8'
LIMIT 100;

----- 8. GPU obod oko zgrada 

SET pg_strom.enabled = on;
SET pg_strom.enable_gpujoin = on;
SET pg_strom.enable_gpuscan = on;
SET enable_seqscan = on;

EXPLAIN ANALYZE
SELECT
    COUNT(*),
    SUM(ST_Area(
        ST_Intersection(
            ST_Buffer(ST_Transform(b.way, 3857), 30),
            ST_Buffer(ST_Transform(r.way, 3857), 30)
        )
    ))
FROM planet_osm_polygon b
JOIN planet_osm_line r
  ON ST_Intersects(
        ST_Buffer(ST_Transform(b.way, 3857), 30),
        ST_Buffer(ST_Transform(r.way, 3857), 30)
     )
WHERE
    b.building IS NOT NULL
    AND r.highway IS NOT NULL;
