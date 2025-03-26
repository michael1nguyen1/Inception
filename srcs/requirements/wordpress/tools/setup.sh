#!/bin/sh

echo "Starting WordPress setup..."

# Wait for MariaDB to be available
until nc -z mariadb 3306; do
    echo "Waiting for MariaDB service..."
    sleep 2
done

# Test database connection
echo "Testing database connection..."
attempts=0
max_attempts=15

while [ $attempts -lt $max_attempts ]; do
    if mysql -h mariadb -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -e "SELECT 1" >/dev/null 2>&1; then
        echo "Database connection established."
        break
    fi
    
    attempts=$((attempts + 1))
    sleep 2
    
    if [ $attempts -eq $max_attempts ]; then
        echo "Could not connect to database after $max_attempts attempts."
        exit 1
    fi
done

# Create and set permissions on web directory
mkdir -p /var/www/html
chown -R nobody:nobody /var/www/html
cd /var/www/html

# Check if WordPress is already installed
if [ ! -f "/var/www/html/wp-config.php" ]; then
    echo "Installing WordPress..."
    
    # Download and configure WordPress
    wp core download --allow-root --path=/var/www/html
    
    wp config create --dbname=${MYSQL_DATABASE} \
                     --dbuser=${MYSQL_USER} \
                     --dbpass=${MYSQL_PASSWORD} \
                     --dbhost=${WORDPRESS_DB_HOST} \
                     --path=/var/www/html \
                     --allow-root
    
    # Install WordPress with admin user
    wp core install --url=${DOMAIN_NAME} \
                    --title="Inception WordPress" \
                    --admin_user=${WP_ADMIN_USER} \
                    --admin_password=${WP_ADMIN_PASSWORD} \
                    --admin_email=${WP_ADMIN_EMAIL} \
                    --path=/var/www/html \
                    --allow-root
    
    # Create regular user
    wp user create ${WP_USER} ${WP_USER_EMAIL} \
                   --user_pass=${WP_USER_PASSWORD} \
                   --role=author \
                   --path=/var/www/html \
                   --allow-root
    
    echo "WordPress installation complete."
else
    echo "WordPress already installed. Verifying admin user..."
    
    # Update admin password to ensure it matches environment variable
    wp user update ${WP_ADMIN_USER} --user_pass=${WP_ADMIN_PASSWORD} --allow-root --path=/var/www/html
fi

# Set proper permissions
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;
chown -R nobody:nobody /var/www/html

echo "Starting PHP-FPM..."
exec php-fpm82 -F -R