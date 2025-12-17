Docker setup koji kombinuje *PostgreSQL + PostGIS + PG-Strom + pgvector + pgai*
i pokazuje kako uvesti semantičku pretragu ,vektore i openai za LLM upite u bazu.
Takodje se testira GPU ubrzanje.

Sve što treba je NVIDIA driveri na hostu i NVIDIA Container Toolkit (da bi container video GPU).
Dati su Dockerfile, docker-compose, inicijalizacione skripte i komande za import + test.

Šta se dobija
  •  Dockerfile koji pravi sliku sa: CUDA toolchain, PostgreSQL 16, PostGIS, osm2pgsql, 
     i kompajliran pg-strom , pgvector i pgai.
  •  docker-compose.yml za lako podizanje servisa (volumes za podatke).
  •  init-db.sh koji kreira DB, omogućava ekstenzije i importuje OSM pomoću osm2pgsql.
  •  Primer SQL upita koji pokazuje kako se PG-Strom može iskoristiti.

⸻

Važno pre pokretanja (preduslovi)
   - Na hostu moraju biti instalirani NVIDIA driveri i NVIDIA Container Toolkit (nvidia-docker2).
   - GPU-ovi moraju biti dostupni u hostu (nvidia-smi radi).
   - Ako nema CUDA na hostu, nije problem — toolchain i runtime su u containeru,
     ali driver verzija mora biti kompatibilna sa CUDA verzijom koju se koristi u slici.
   - Disk prostor: OSM .pbf fajl i DB zahtevaju nekoliko GB (zavisno od regiona).

⸻
