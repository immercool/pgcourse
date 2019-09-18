
CREATE USER hr password 'start';
CREATE USER web_app password 'start';

CREATE SCHEMA company AUTHORIZATION hr;
GRANT USAGE ON SCHEMA company TO web_app;

SET search_path = company,public;

CREATE TABLE employees(
id serial,
first_name text NOT NULL,
last_name text NOT NULL, 
username  character varying(12),
entry_date date NOT NULL default now(), 
leave_date  date,
CONSTRAINT employees_id_pk PRIMARY KEY (id)
);

CREATE OR REPLACE FUNCTION unq_username()
  RETURNS trigger AS
$BODY$
    DECLARE
    u_num integer;
    uniquename text;
    BEGIN
    	--u_num := (SELECT count(*) FROM employees WHERE NEW.first_name = first_name AND NEW.last_name = last_name);
    	--uniquename := NEW.first_name || NEW.last_name || CASE u_num WHEN 0 THEN '' ELSE u_num::text END;
    	uniquename :=  left(NEW.last_name,5) || left(NEW.first_name,2); 
    	--NEW.username :=  unaccent(replace(uniquename,' ',''));
    	NEW.username :=  lower(replace(uniquename,' ',''));
     RETURN NEW;
    END;
    $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION unq_username()
  OWNER TO postgres;

CREATE TRIGGER unique_username_tr
  BEFORE INSERT
  ON employees
  FOR EACH ROW
  WHEN (NEW.username IS NULL )
  EXECUTE PROCEDURE unq_username();


CREATE UNIQUE INDEX employees_unq_username_idx ON  employees (username);



CREATE TABLE departments (
id serial,
name character(5) NOT NULL,
manager_id integer REFERENCES employees (id),
active boolean DEFAULT TRUE,
CONSTRAINT departments_id_pk PRIMARY KEY(id)
);

CREATE OR REPLACE FUNCTION new_manager_trf()
  RETURNS trigger AS
$BODY$
    DECLARE
    BEGIN
    	UPDATE jobs set role = 'Manager' WHERE employee_id = NEW.manager_id;
     RETURN NEW;
    END;
    $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


CREATE TRIGGER departments_manger_tr
  AFTER UPDATE OF manager_id
  ON departments
  FOR EACH ROW
  EXECUTE PROCEDURE new_manager_trf();

Create Table team (
team_id serial,
name character(5) NOT NULL,
department_id integer REFERENCES departments (id) ON DELETE RESTRICT,
teamlead_id integer REFERENCES employees (id),
active boolean DEFAULT TRUE,
CONSTRAINT team_id_pk PRIMARY KEY (team_id)
);


CREATE TABLE salary (
employee_id integer REFERENCES employees (id) ON DELETE CASCADE,
salary decimal,
created_at timestamp with time zone DEFAULT now(),
updated_at timestamp with time zone,
CONSTRAINT salary_employee_id_pk PRIMARY KEY (employee_id)
);

REVOKE ALL ON TABLE company.salary FROM web_app;
REVOKE ALL ON company.salary FROM  public;
GRANT SELECT(employee_id,created_at,updated_at) ON TABLE company.salary TO web_app;

CREATE TYPE job_role AS ENUM ('Clerk','Teamlead','Manager','President');

Create table jobs(
employee_id integer REFERENCES employees (id) ON DELETE CASCADE,
role job_role,
function text,
begin_date date DEFAULT now(),
end_date date,
active boolean DEFAULT TRUE
);


INSERT INTO departments(name) VALUES ('Exec');
INSERT INTO departments(name) VALUES ('IT');
INSERT INTO departments(name) VALUES ('Sales');
INSERT INTO departments(name) VALUES ('HR');



INSERT INTO employees(first_name,last_name,entry_date) VALUES ('Patrick','Thomschitz',timestamp '2014-01-10 20:00:00' + random() * (timestamp '2018-01-20 20:00:00' - timestamp '2014-01-10 10:00:00'));
INSERT INTO employees(first_name,last_name,entry_date) VALUES ('Dieter','Weiß',timestamp '2014-01-10 20:00:00' + random() * (timestamp '2018-01-20 20:00:00' - timestamp '2014-01-10 10:00:00'));
INSERT INTO employees(first_name,last_name,entry_date) VALUES ('Niklas','Becker',timestamp '2014-01-10 20:00:00' + random() * (timestamp '2018-01-20 20:00:00' - timestamp '2014-01-10 10:00:00'));
INSERT INTO employees(first_name,last_name,entry_date) VALUES ('Vanessa','Strauss',timestamp '2014-01-10 20:00:00' + random() * (timestamp '2018-01-20 20:00:00' - timestamp '2014-01-10 10:00:00'));
INSERT INTO employees(first_name,last_name,entry_date) VALUES ('Christian','Jäger',timestamp '2014-01-10 20:00:00' + random() * (timestamp '2018-01-20 20:00:00' - timestamp '2014-01-10 10:00:00'));
INSERT INTO employees(first_name,last_name,entry_date) VALUES ('Annett','Bohm',timestamp '2014-01-10 20:00:00' + random() * (timestamp '2018-01-20 20:00:00' - timestamp '2014-01-10 10:00:00'));
INSERT INTO employees(first_name,last_name,entry_date) VALUES ('Max','Walter',timestamp '2014-01-10 20:00:00' + random() * (timestamp '2018-01-20 20:00:00' - timestamp '2014-01-10 10:00:00'));
INSERT INTO employees(first_name,last_name,entry_date) VALUES ('David','Ackerman',timestamp '2014-01-10 20:00:00' + random() * (timestamp '2018-01-20 20:00:00' - timestamp '2014-01-10 10:00:00'));
INSERT INTO employees(first_name,last_name,entry_date) VALUES ('Patrick','Sommer',timestamp '2014-01-10 20:00:00' + random() * (timestamp '2018-01-20 20:00:00' - timestamp '2014-01-10 10:00:00'));
INSERT INTO employees(first_name,last_name,entry_date) VALUES ('Marcel','Baumgartner',timestamp '2014-01-10 20:00:00' + random() * (timestamp '2018-01-20 20:00:00' - timestamp '2014-01-10 10:00:00'));
INSERT INTO employees(first_name,last_name,entry_date) VALUES ('Lucas','Theiss',timestamp '2014-01-10 20:00:00' + random() * (timestamp '2018-01-20 20:00:00' - timestamp '2014-01-10 10:00:00'));

INSERT INTO salary(employee_id,created_at,salary)   SELECT 
id, 
entry_date,
trunc((random() * (10000 + 1))::numeric,2) FROM employees;

INSERT INTO jobs(employee_id,role,begin_date)  SELECT 
id, 'Clerk', entry_date from employees;

UPDATE departments set manager_id = (SELECT id from employees ORDER BY random () LIMIT 1) WHERE id = 1;
UPDATE departments set manager_id = (SELECT id from employees ORDER BY random () LIMIT 1) WHERE id = 2;
UPDATE departments set manager_id = (SELECT id from employees ORDER BY random () LIMIT 1) WHERE id = 3;
UPDATE departments set manager_id = (SELECT id from employees ORDER BY random () LIMIT 1) WHERE id = 4;


CREATE VIEW employee_details AS SELECT 
emp.*,
job.role,
sal.salary
FROM employees as emp
LEFT JOIN jobs as job ON (job.employee_id = id)
LEFT JOIN salary as sal ON (sal.employee_id = id)
WHERE emp.leave_date IS NULL;


select * from employee_details;

select * from employees WHERE id = 5;