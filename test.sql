\c gis_db

CREATE TABLE t_test AS SELECT id, id % 10 AS ten, id % 20 AS twenty
          FROM generate_series(1, 25000000) AS id
          ORDER BY id;

CREATE TABLE t_join AS SELECT *
       FROM   t_test
       ORDER BY random()
       LIMIT 1000000;

VACUUM FULL t_test;
VACUUM FULL t_join;

SELECT pg_size_pretty(pg_relation_size('t_test'));

SELECT pg_size_pretty(pg_relation_size('t_join'));
SET pg_strom.enabled=off;
explain analyze SELECT count(*) FROM t_test AS a, t_join AS b WHERE a.id = b.id GROUP BY a.ten;
SET pg_strom.enabled=on;
explain analyze SELECT count(*) FROM t_test AS a, t_join AS b WHERE a.id = b.id GROUP BY a.ten;
