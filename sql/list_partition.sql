CREATE TABLE t_test (
 id serial,
 first_name text NOT NULL,
 country text
 ) PARTITION BY LIST(country);

CREATE TABLE t_test_aut PARTITION OF t_test FOR VALUES IN ('aut');
CREATE TABLE t_test_ger PARTITION OF t_test FOR VALUES IN ('ger');
CREATE TABLE t_test_def PARTITION OF t_test DEFAULT;

INSERT INTO t_test(first_name,country) SELECT 'patrick','aut' FROM generate_series(1,1000);
INSERT INTO t_test(first_name,country) SELECT 'julian','ger' FROM generate_series(1,1000);

EXPLAIN SELECT * FROM t_test WHERE country = 'aut';
/*

                             QUERY PLAN
---------------------------------------------------------------------
 Append  (cost=0.00..23.50 rows=1000 width=16)
   ->  Seq Scan on t_test_aut  (cost=0.00..18.50 rows=1000 width=16)
         Filter: (country = 'aut'::text)
(3 rows)
*/
EXPLAIN SELECT * FROM t_test WHERE first_name = 'patrick';
/*
                             QUERY PLAN
---------------------------------------------------------------------
 Append  (cost=0.00..62.65 rows=1005 width=16)
   ->  Seq Scan on t_test_aut  (cost=0.00..18.50 rows=1000 width=16)
         Filter: (first_name = 'patrick'::text)
   ->  Seq Scan on t_test_ger  (cost=0.00..18.50 rows=1 width=15)
         Filter: (first_name = 'patrick'::text)
   ->  Seq Scan on t_test_def  (cost=0.00..20.62 rows=4 width=68)
         Filter: (first_name = 'patrick'::text)
(7 rows)

*/
