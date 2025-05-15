<<<<<<< HEAD
FROM php:8.2-fpm

# Installer les dépendances système
RUN apt-get update && apt-get install -y \
    git unzip curl libpq-dev libzip-dev zip \
    && docker-php-ext-install pdo pdo_mysql zip

# Installer Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Créer et copier les fichiers
WORKDIR /var/www/html
COPY . .

# Installer les dépendances PHP
RUN composer install

# Droits
RUN chown -R www-data:www-data /var/www/html

EXPOSE 9000
=======
FROM php:8.1-fpm

RUN apt-get update && apt-get install -y \
    git unzip zip curl libpq-dev libonig-dev libxml2-dev \
    && docker-php-ext-install pdo pdo_mysql

# Installer Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
>>>>>>> 88165778b6e9268267fa8135eb829ef899ed3f13
