# Build stage for frontend assets
FROM node:20-alpine AS frontend

WORKDIR /app

COPY package*.json vite.config.js ./
RUN npm ci

COPY resources ./resources

RUN npm run build


# PHP dependencies stage
FROM composer:2 AS composer

WORKDIR /app

COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist

COPY . .

# Clear dev package cache and regenerate autoloader
RUN rm -f bootstrap/cache/packages.php bootstrap/cache/services.php \
    && composer dump-autoload --optimize


# Production stage
FROM php:8.4-fpm-alpine

# Install system dependencies
RUN apk add --no-cache \
    nginx \
    supervisor \
    sqlite \
    sqlite-dev \
    curl \
    zip \
    unzip \
    libzip-dev \
    oniguruma-dev \
    && docker-php-ext-install pdo pdo_mysql pdo_sqlite mbstring zip bcmath opcache \
    && apk del sqlite-dev \
    && rm -rf /var/cache/apk/*

# Configure PHP
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

COPY docker/php.ini /usr/local/etc/php/conf.d/custom.ini
COPY docker/opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY docker/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/supervisord.conf /etc/supervisord.conf

# Set working directory
WORKDIR /var/www/html

# Copy application
COPY --from=composer /app/vendor ./vendor
COPY . .
COPY --from=frontend /app/public/build ./public/build

# Clear dev package cache (may have been copied from local) and set permissions
RUN rm -f bootstrap/cache/packages.php bootstrap/cache/services.php \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage \
    && chmod -R 755 /var/www/html/bootstrap/cache

# Create persistent data directory for SQLite database
RUN mkdir -p /var/www/html/data \
    && touch /var/www/html/data/database.sqlite \
    && chown -R www-data:www-data /var/www/html/data

COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
