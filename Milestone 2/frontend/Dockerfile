FROM httpd:2.4-alpine

# Copy custom Apache config
COPY httpd.conf /usr/local/apache2/conf/httpd.conf

# Copy static frontend assets
COPY index.html /usr/local/apache2/htdocs/

# Ensure proper permissions
RUN chown -R daemon:daemon /usr/local/apache2/htdocs /usr/local/apache2/logs

USER daemon

EXPOSE 8080
