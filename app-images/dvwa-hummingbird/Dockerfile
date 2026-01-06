FROM docker.io/php:8-apache AS builder

WORKDIR /tmp

# Install build dependencies and compile PHP extensions
RUN apt-get update \
 && export DEBIAN_FRONTEND=noninteractive \
 && apt-get install -y zlib1g-dev libpng-dev libjpeg-dev libfreetype6-dev build-essential default-mysql-client default-libmysqlclient-dev \
 && docker-php-ext-configure gd --with-jpeg --with-freetype \
 && docker-php-ext-install gd mysqli pdo pdo_mysql \
 && apt-get clean -y && rm -rf /var/lib/apt/lists/*

FROM quay.io/hummingbird/php:8

LABEL maintainer="Foster <mfoster@redhat.com>"

WORKDIR /var/www/html

# Copy compiled extensions and configuration from builder
COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=builder /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/


COPY --chown=33:33 . .
COPY --chown=33:33 config/config.inc.php.dist config/config.inc.php
