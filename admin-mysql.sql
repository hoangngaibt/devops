mysql -u root -p
mysqladmin -u root -p version

mysqladmin -u root -p status

mysqladmin -u root -p extended-status
mysqladmin  -u root -p variables
mysqladmin -u root -p processlist

mysqladmin -u root -p flush-hosts
mysqladmin -u root -p flush-tables
mysqladmin -u root -p flush-threads
mysqladmin -u root -p flush-logs
mysqladmin -u root -p flush-privileges
mysqladmin -u root -p flush-status

# flush-hosts: Flush all host information from the host cache.
# flush-tables: Flush all tables.
# flush-threads: Flush all threads cache.
# flush-logs: Flush all information logs.
# flush-privileges: Reload the grant tables (same as reload).
# flush-status: Clear status variables.

mysqladmin -u root -p kill 5,10

mysqladmin  -u root -p start-slave
mysqladmin  -u root -p stop-slave

use mysql;

INSERT INTO user 
   (host, user, password, 
   select_priv, insert_priv, update_priv) 
   VALUES ('localhost', 'guest', 
   PASSWORD('guest123'), 'Y', 'Y', 'Y');

FLUSH PRIVILEGES;

SELECT host, user, password FROM user WHERE user = 'guest';

GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP ON TUTORIALS.* TO 'zara'@'localhost' IDENTIFIED BY 'zara123';

SHOW DATABASES;

Administrative MySQL Command
Here is the list of the important MySQL commands, which you will use time to time to work with MySQL database

USE Databasename; − This will be used to select a database in the MySQL workarea.

SHOW DATABASES; − Lists out the databases that are accessible by the MySQL DBMS.

SHOW TABLES; − Shows the tables in the database once a database has been selected with the use command.

SHOW COLUMNS FROM tablename: Shows the attributes, types of attributes, key information, whether NULL is permitted, defaults, and other information for a table.

SHOW INDEX FROM tablename; − Presents the details of all indexes on the table, including the PRIMARY KEY.

SHOW TABLE STATUS LIKE tablename\G; − Reports details of the MySQL DBMS performance and statistics.  

exit

create TUTORIALS; create database
DROP TUTORIALS; drop database

SELECT user,host FROM mysql.user;  list all user

SELECT DISTINCT user FROM mysql.user;
SELECT user, account_locked, password_expired FROM mysql.user;
SELECT user,host, command FROM information_schema.processlist;

SHOW GRANTS FOR <username>@<host>;
SHOW GRANTS;


# To check the sizes of all of your databases
SELECT table_schema AS "Database", 
ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS "Size (MB)" 
FROM information_schema.TABLES 
GROUP BY table_schema;

# To check the sizes of all of the tables in a specific database

SELECT table_name AS "Table",
ROUND(((data_length + index_length) / 1024 / 1024), 2) AS "Size (MB)"
FROM information_schema.TABLES
WHERE table_schema = "database_name"
ORDER BY (data_length + index_length) DESC;

# replicate
CREATE USER 'replica'@'%' IDENTIFIED WITH mysql_native_password BY '************************!';
GRANT REPLICATION SLAVE ON *.* TO 'replica'@'%';
SHOW MASTER STATUS;
//
CHANGE REPLICATION SOURCE TO
SOURCE_HOST='10.18.0.17',
SOURCE_USER='replica',
SOURCE_PASSWORD='************************!',
SOURCE_LOG_FILE='binlog.000005',
SOURCE_LOG_POS=157;

START SLAVE;
show replica status\G
SHOW SLAVE STATUS\G
//
ALTER USER 'replica'@'%' IDENTIFIED WITH mysql_native_password BY '************************!';
flush privileges;

mysqldump -u root --all-databases > reader.sql
mysql -u root < reader.sql

Select user from mysql.user; 
 
ALTER USER 'replication_user'@'%' IDENTIFIED BY '**********************';

CREATE USER 'backup'@'%' IDENTIFIED BY '************************';
GRANT SELECT, BACKUP_ADMIN, RELOAD, PROCESS, SUPER, REPLICATION CLIENT ON *.* 
    TO `backup`@`%`;
GRANT CREATE, INSERT, DROP, UPDATE ON mysql.backup_progress TO 'backup'@'%'; 
GRANT CREATE, INSERT, DROP, UPDATE, SELECT, ALTER ON mysql.backup_history 
    TO 'backup'@'%';