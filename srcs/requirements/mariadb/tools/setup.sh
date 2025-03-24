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
    
    # Run any SQL scripts from /docker-entrypoint-initdb.d
    for f in /docker-entrypoint-initdb.d/*; do
        case "$f" in
            *.sql)    echo "Running SQL script $f"; mysql < "$f" ;;
            *)        echo "Ignoring $f" ;;
        esac
    done
    
    # Shutdown the temporary MariaDB server
    mysqladmin -u root shutdown
    
    echo "MariaDB data directory initialized!"
else
    echo "MariaDB data directory already initialized."
fi

# Ensure proper permissions
chown -R mysql:mysql /var/lib/mysql
chown -R mysql:mysql /run/mysqld

echo "Starting MariaDB server..."
exec /usr/bin/mysqld --user=mysql --console