#!/bin/sh

# Check if the database directory is empty
if [ -d "/var/lib/mysql/mysql" ]; then
    echo "Database already initialized"
else
    # Initialize MySQL data directory
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # Start MariaDB service
    /usr/bin/mysqld --user=mysql --bootstrap << SQL
USE mysql;
FLUSH PRIVILEGES;

-- Create database and user
CREATE DATABASE IF NOT EXISTS \${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '\${MYSQL_USER}'@'%' IDENTIFIED BY '\${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \${MYSQL_DATABASE}.* TO '\${MYSQL_USER}'@'%';

-- Set root password and allow remote connections
ALTER USER 'root'@'localhost' IDENTIFIED BY '\${MYSQL_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
SQL
fi

exec /usr/bin/mysqld --user=mysql --console
