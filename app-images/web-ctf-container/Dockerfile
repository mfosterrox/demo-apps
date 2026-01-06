# https://github.com/HightechSec/web-ctf-container
FROM php:8.1-apache

LABEL maintainer="Foster <mfoster@redhat.com>"

# Install git for cloning
RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
    rm -rf /var/lib/apt/lists/*

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Configure Apache to listen on port 8080 instead of 80 (for non-root user)
RUN echo "Listen 8080" > /etc/apache2/ports.conf && \
    echo "<IfModule ssl_module>" >> /etc/apache2/ports.conf && \
    echo "    Listen 8443" >> /etc/apache2/ports.conf && \
    echo "</IfModule>" >> /etc/apache2/ports.conf && \
    echo "<VirtualHost *:8080>" > /etc/apache2/sites-available/000-default.conf && \
    echo "    ServerAdmin webmaster@localhost" >> /etc/apache2/sites-available/000-default.conf && \
    echo "    DocumentRoot /var/www/html" >> /etc/apache2/sites-available/000-default.conf && \
    echo "    <Directory /var/www/html>" >> /etc/apache2/sites-available/000-default.conf && \
    echo "        Options Indexes FollowSymLinks" >> /etc/apache2/sites-available/000-default.conf && \
    echo "        AllowOverride All" >> /etc/apache2/sites-available/000-default.conf && \
    echo "        Require all granted" >> /etc/apache2/sites-available/000-default.conf && \
    echo "    </Directory>" >> /etc/apache2/sites-available/000-default.conf && \
    echo "    ErrorLog \${APACHE_LOG_DIR}/error.log" >> /etc/apache2/sites-available/000-default.conf && \
    echo "    CustomLog \${APACHE_LOG_DIR}/access.log combined" >> /etc/apache2/sites-available/000-default.conf && \
    echo "</VirtualHost>" >> /etc/apache2/sites-available/000-default.conf && \
    a2ensite 000-default.conf && \
    echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Set working directory
WORKDIR /var/www/html

# Clone the repository
RUN git clone https://github.com/HightechSec/web-ctf-container.git /tmp/web-ctf && \
    cp -r /tmp/web-ctf/* /var/www/html/ && \
    rm -rf /tmp/web-ctf

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

EXPOSE 8080

# Override CMD to ensure Apache starts on port 8080
CMD ["apache2-foreground"]

