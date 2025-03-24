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
sleep 15

echo "Setting up WordPress..."

# Check if WordPress is already installed
if [ ! -f "wp-config.php" ]; then
    echo "Installing WordPress..."
    
    # Download WordPress
    wp core download --allow-root
    
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