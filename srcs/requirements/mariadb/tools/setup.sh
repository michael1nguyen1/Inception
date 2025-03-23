#!/bin/sh

# Check if the database directory is empty
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    
    # Initialize MySQL data directory
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    
    # Start MariaDB in the background temporarily
    /usr/bin/mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
    
    # Wait for MariaDB to start
    until mysqladmin ping -s; do
        echo "Waiting for MariaDB to start..."
        sleep 1
    done
    
    # Configure MariaDB
    mysql -u root << EOF_SQL
CREATE DATABASE IF NOT EXISTS \${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '\${MYSQL_USER}'@'%' IDENTIFIED BY '\${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \${MYSQL_DATABASE}.* TO '\${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '\${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF_SQL
    
    # Shutdown the temporary MariaDB server
    mysqladmin -u root -p\${MYSQL_ROOT_PASSWORD} shutdown
    
    echo "MariaDB data directory initialized!"
else
    echo "MariaDB data directory already initialized."
fi

# Ensure proper permissions
chown -R mysql:mysql /var/lib/mysql
chown -R mysql:mysql /run/mysqld

echo "Starting MariaDB server..."
exec /usr/bin/mysqld --user=mysql --console
