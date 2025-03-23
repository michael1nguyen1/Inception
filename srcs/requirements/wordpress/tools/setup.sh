#!/bin/sh

echo "Starting WordPress setup..."

# Wait for MariaDB to be ready - improved version with retries
max_retries=30
counter=0
until mysql -h mariadb -u root -p${MYSQL_ROOT_PASSWORD} -e "SELECT 1" >/dev/null 2>&1
do
    counter=$(expr $counter + 1)
    if [ $counter -gt $max_retries ]; then
        echo "Failed to connect to MariaDB after $max_retries attempts. Exiting."
        exit 1
    fi
    echo "Waiting for MariaDB to be ready... ($counter/$max_retries)"
    sleep 5
done

echo "MariaDB is ready! Setting up WordPress..."

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
