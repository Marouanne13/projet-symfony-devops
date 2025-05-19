FROM php:8.2-fpm

# Installer les dépendances système
RUN apt-get update && apt-get install -y \
    git unzip curl libpq-dev libzip-dev zip \
    && docker-php-ext-install pdo pdo_mysql zip

# Installer Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Créer le dossier de travail
WORKDIR /var/www/html

# Copier les fichiers de l'application
COPY . .

# Installer les dépendances PHP
RUN composer install --no-interaction --optimize-autoloader \
    && composer require artprima/prometheus-metrics-bundle


# Donner les bons droits
RUN chown -R www-data:www-data /var/www/html

EXPOSE 9000
