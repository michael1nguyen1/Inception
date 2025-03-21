#!/bin/sh

# Wait for MariaDB to be ready
while ! mysqladmin ping -h mariadb --silent; do
    echo "Waiting for MariaDB to be ready..."
    sleep 1
done

# Check if WordPress is already installed
if [ ! -f "wp-config.php" ]; then
    echo "Installing WordPress..."
    
    # Download WordPress
    wp core download --allow-root
    
    # Create configuration
    wp config create --dbname=\${MYSQL_DATABASE} \
                     --dbuser=\${MYSQL_USER} \
                     --dbpass=\${MYSQL_PASSWORD} \
                     --dbhost=\${WORDPRESS_DB_HOST} \
                     --allow-root
    
    # Install WordPress
    wp core install --url=\${DOMAIN_NAME} \
                    --title="Inception WordPress" \
                    --admin_user=\${WP_ADMIN_USER} \
                    --admin_password=\${WP_ADMIN_PASSWORD} \
                    --admin_email=\${WP_ADMIN_EMAIL} \
                    --allow-root
    
    # Create a regular user
    wp user create \${WP_USER} \${WP_USER_EMAIL} \
                   --user_pass=\${WP_USER_PASSWORD} \
                   --role=author \
                   --allow-root
    
    echo "WordPress installed successfully!"
else
    echo "WordPress already installed."
fi

# Start PHP-FPM
exec php-fpm82 -F
