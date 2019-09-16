--my_table ersetzen durch wirklichn Tablename
SELECT (pg_relation_size(oid)*reltuples/(8192*relpages::bigint))::bigint as count
FROM pg_class
WHERE oid = 'my_table'::regclass;
