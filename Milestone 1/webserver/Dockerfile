FROM ubuntu:24.04@sha256:353675e2a41babd526e2b837d7ec780c2a05bca0164f7ea5dbbd433d21d166fc

RUN apt update && apt install -y apache2 php php-fpm php-mysql curl && a2enmod proxy_fcgi proxy && rm -rf /var/www/html/*

# Create a non-root user for running Apache
RUN useradd -r -u 1001 -g www-data apacheuser

COPY ./www /var/www/html
RUN chown -R apacheuser:www-data /var/www/html && \
    sed -i 's/export APACHE_RUN_USER=www-data/export APACHE_RUN_USER=apacheuser/' /etc/apache2/envvars && \
    sed -i 's/export APACHE_RUN_GROUP=www-data/export APACHE_RUN_GROUP=www-data/' /etc/apache2/envvars && \
    chown -R apacheuser:www-data /var/log/apache2 && \
    chown -R apacheuser:www-data /var/run/apache2 && \
    mkdir -p /var/lock/apache2 && \
    chown -R apacheuser:www-data /var/lock/apache2

# Replace default site with FPM-enabled config
COPY ./000-default.conf /etc/apache2/sites-available/000-default.conf

RUN a2ensite 000-default && echo '#!/bin/sh\n\
# Inject environment variables into PHP-FPM config\n\
echo "env[MYSQL_HOST] = ${MYSQL_HOST}" >> /etc/php/8.3/fpm/pool.d/www.conf\n\
echo "env[MYSQL_DATABASE] = ${MYSQL_DATABASE}" >> /etc/php/8.3/fpm/pool.d/www.conf\n\
echo "env[MYSQL_USER] = ${MYSQL_USER}" >> /etc/php/8.3/fpm/pool.d/www.conf\n\
echo "env[MYSQL_PASSWORD] = ${MYSQL_PASSWORD}" >> /etc/php/8.3/fpm/pool.d/www.conf\n\
service php8.3-fpm start\n\
exec su apacheuser -c "apache2ctl -D FOREGROUND"' > /start.sh && \
    chmod +x /start.sh

EXPOSE 80
CMD ["/start.sh"]

