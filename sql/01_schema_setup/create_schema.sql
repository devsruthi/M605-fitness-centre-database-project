--  CREATE SCHEMA 
-- *********************************************************************

CREATE SCHEMA fitness_centre_database;

USE fitness_centre_database;

set sql_safe_updates = 0;

Show variables like 'local_infile';
Set global local_infile = 1;