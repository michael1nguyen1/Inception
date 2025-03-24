#!/bin/sh

echo "Starting WordPress setup..."

# Wait for MariaDB to be available at network level
echo "Waiting for MariaDB to be accessible..."
until nc -z mariadb 3306; do
    echo "Waiting for MariaDB service..."
    sleep 2
done

# Give MariaDB extra time to initialize fully
echo "MariaDB is reachable. Waiting for initialization to complete..."
sleep 5

# Test connection to make sure it's actually working
echo "Testing database connection..."
attempts=0
max_attempts=30

while [ $attempts -lt $max_attempts ]; do
    if mysql -h mariadb -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -e "SELECT 1" >/dev/null 2>&1; then
        echo "Successfully connected to database!"
        break
    fi
    
    attempts=$(expr $attempts + 1)
    echo "Connection attempt $attempts/$max_attempts failed, retrying..."
    sleep 3
    
    if [ $attempts -eq $max_attempts ]; then
        echo "Could not connect to database after $max_attempts attempts. Continuing anyway..."
    fi
done

echo "Setting up WordPress..."

# Check if WordPress is already installed
if [ ! -f "wp-config.php" ]; then
    echo "Installing WordPress..."
    
    # Download WordPress with increased memory limit
    php -d memory_limit=512M /usr/local/bin/wp core download --allow-root
    
    # Create configuration
    wp config create --dbname=${MYSQL_DATABASE} \
                     --dbuser=${MYSQL_USER} \
                     --dbpass=${MYSQL_PASSWORD} \
                     --dbhost=${WORDPRESS_DB_HOST} \
                     --allow-root
    
    # Install WordPress
    wp core install --url=${DOMAIN_NAME} \
                    --title="Inception WordPress" \
                    --admin_user=${WP_ADMIN_USER} \
                    --admin_password=${WP_ADMIN_PASSWORD} \
                    --admin_email=${WP_ADMIN_EMAIL} \
                    --allow-root
    
    # Create a regular user
    wp user create ${WP_USER} ${WP_USER_EMAIL} \
                   --user_pass=${WP_USER_PASSWORD} \
                   --role=author \
                   --allow-root
    
    echo "WordPress installed successfully!"
else
    echo "WordPress already installed."
fi

echo "Starting PHP-FPM..."
# Start PHP-FPM
exec php-fpm82 -F