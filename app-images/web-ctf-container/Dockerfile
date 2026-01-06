# https://github.com/HightechSec/web-ctf-container
FROM php:8.1-apache

LABEL maintainer="Foster <mfoster@redhat.com>"

# Install git for cloning
RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
    rm -rf /var/lib/apt/lists/*

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# Clone the repository
RUN git clone https://github.com/HightechSec/web-ctf-container.git /tmp/web-ctf && \
    cp -r /tmp/web-ctf/* /var/www/html/ && \
    rm -rf /tmp/web-ctf

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

EXPOSE 80

# Apache will start automatically via the base image's CMD

