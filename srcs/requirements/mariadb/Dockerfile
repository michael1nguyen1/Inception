FROM alpine:3.20

RUN apk update && apk add --no-cache \
    mariadb \
    mariadb-client

# Create necessary directories with proper permissions
RUN mkdir -p /run/mysqld && \
    chown -R mysql:mysql /run/mysqld && \
    mkdir -p /var/lib/mysql && \
    chown -R mysql:mysql /var/lib/mysql

# Copy configuration
COPY ./conf/my.cnf /etc/my.cnf
COPY ./tools/setup.sh /setup.sh

# Make the script executable
RUN chmod +x /setup.sh

EXPOSE 3306

ENTRYPOINT ["/setup.sh"]