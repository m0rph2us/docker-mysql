use mysql;

CREATE USER 'user'@'%' IDENTIFIED BY '1234';
GRANT SELECT, INSERT, UPDATE, DELETE ON *.* TO 'user'@'%';

CHANGE MASTER TO MASTER_HOST='mysql-master',
MASTER_PORT=3306,
MASTER_USER='repl_user',
MASTER_PASSWORD='repl_password',
MASTER_LOG_FILE='mysql-bin.000003',
MASTER_LOG_POS=154;