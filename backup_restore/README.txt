--Create a fresh Database:
drop database db1;
create database db1;
--Load Company
psql -d db1 -f /kurs/pgcourse/sql/company.sql
--Create a Dump Backup from db1
pg_dump -d db1 -f db1.sql
--Create a Dump with insert Statements
pg_dump -d db1 --insert -f company.backup.sql
--Dump only Metadata
pg_dump -d db1 --schema-only -f company.backup.sql
--Dump only Data
pg_dump -d db1 --data-only -f company.data.sql
--Dump only Data wit INSERTs
pg_dump -d db1 --insert --data-only -f company.backup_data.sql
--Dump only Data with Inserts and disables Triggers
pg_dump -d db1 --insert --disable-triggers --data-only -f company.backup_data.sql



insert into team (name) values ('aaa');
pg_dump -d db1 -Ft -f db1.tar
pg_restore -d db3 -t team db1.tar
pg_restore -d db3 --data-only -t team db1.tar
