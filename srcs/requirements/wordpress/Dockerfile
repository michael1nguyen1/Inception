FROM alpine:3.20

RUN apk update && apk add --no-cache \
    php82 \
    php82-fpm \
    php82-mysqli \
    php82-ctype \
    php82-curl \
    php82-dom \
    php82-exif \
    php82-fileinfo \
    php82-mbstring \
    php82-openssl \
    php82-xml \
    php82-zip \
    php82-gd \
    php82-phar \
    php82-json \
    php82-tokenizer \
    php82-simplexml \
    curl \
    wget \
    mariadb-client

# Create directory for php configuration
RUN mkdir -p /etc/php82/conf.d/

# Create custom php.ini with increased memory limit
RUN echo "memory_limit = 256M" > /etc/php82/conf.d/99-memory.ini

# Create a symlink from php82 to php for wp-cli
RUN ln -sf /usr/bin/php82 /usr/bin/php

# Install wp-cli
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# PHP-FPM configuration
COPY ./conf/www.conf /etc/php82/php-fpm.d/www.conf

# WordPress setup script
COPY ./tools/setup.sh /setup.sh
RUN chmod +x /setup.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["/setup.sh"]