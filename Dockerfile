# Build stage
FROM composer:2.6 AS composer

WORKDIR /app

COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist

COPY . .
RUN composer dump-autoload --optimize

# Node stage
FROM node:20-alpine AS node

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build

# Final stage
FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zip \
    unzip \
    git \
    curl \
    poppler-utils \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql \
    && pecl install redis \
    && docker-php-ext-enable redis

# Configure PHP-FPM
RUN sed -i 's/listen = 127.0.0.1:9000/listen = 9000/g' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/;listen.allowed_clients = 127.0.0.1/listen.allowed_clients = 127.0.0.1/g' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/;clear_env = no/clear_env = no/g' /usr/local/etc/php-fpm.d/www.conf

# Set working directory
WORKDIR /var/www/html

# Copy built files from previous stages
COPY --from=composer /app/vendor ./vendor
COPY --from=node /app/public/build ./public/build
COPY . .

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage

# Expose port 9000 for PHP-FPM
EXPOSE 9000

# Start PHP-FPM
CMD ["php-fpm", "--nodaemonize"]
