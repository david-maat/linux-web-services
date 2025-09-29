FROM ubuntu:24.04@sha256:353675e2a41babd526e2b837d7ec780c2a05bca0164f7ea5dbbd433d21d166fc

RUN apt update && apt install -y apache2 php php-fpm && a2enmod proxy_fcgi proxy
COPY ./www /var/www/html
RUN chown -R www-data:www-data /var/www/html


# Replace default site with FPM-enabled config
COPY ./000-default.conf /etc/apache2/sites-available/000-default.conf
RUN a2ensite 000-default
EXPOSE 80
CMD service php8.3-fpm start && apache2ctl -D FOREGROUND

