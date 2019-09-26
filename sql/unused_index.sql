--short
select schemaname, relname, indexrelname, idx_scan from pg_stat_user_indexes;

--long
SELECT s.schemaname,
s.relname AS tablename,
s.indexrelname AS indexname,
pg_relation_size(s.indexrelid) AS index_size
FROM pg_catalog.pg_stat_user_indexes s JOIN pg_catalog.pg_index i ON s.indexrelid = i.indexrelid
WHERE s.idx_scan = 0
AND 0 <>ALL (i.indkey)
AND NOT i.indisunique
AND NOT EXISTS
(SELECT 1 FROM pg_catalog.pg_constraint c WHERE c.conindid = s.indexrelid)
ORDER BY pg_relation_size(s.indexrelid) DESC;
