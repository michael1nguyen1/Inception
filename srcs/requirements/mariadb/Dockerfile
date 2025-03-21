FROM alpine:3.20

RUN apk update && apk add --no-cache \
    mariadb \
    mariadb-client

COPY ./conf/my.cnf /etc/my.cnf
COPY ./tools/setup.sh /setup.sh

RUN chmod +x /setup.sh

EXPOSE 3306

ENTRYPOINT ["/setup.sh"]
