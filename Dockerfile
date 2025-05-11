FROM php:8.1-fpm

RUN apt-get update && apt-get install -y \
    git unzip zip curl libpq-dev libonig-dev libxml2-dev \
    && docker-php-ext-install pdo pdo_mysql

# Installer Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
