FROM php:8.2-fpm

# Installer les dépendances système
RUN apt-get update && apt-get install -y \
    git unzip curl libpq-dev libzip-dev zip \
    && docker-php-ext-install pdo pdo_mysql zipFROM php:8.2-fpm

# Installer les dépendances système
RUN apt-get update && apt-get install -y \
    git unzip curl libpq-dev libzip-dev zip supervisor \
    && docker-php-ext-install pdo pdo_mysql zip

# Installer Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Créer le dossier de travail
WORKDIR /var/www/html

# Copier les fichiers de l'application
COPY . .

# Installer les dépendances PHP Symfony + Prometheus Bundle
RUN composer install --no-interaction --optimize-autoloader \
    && composer require artprima/prometheus-metrics-bundle

# Télécharger et installer Prometheus
RUN curl -LO https://github.com/prometheus/prometheus/releases/download/v2.46.0/prometheus-2.46.0.linux-amd64.tar.gz \
    && tar xzf prometheus-2.46.0.linux-amd64.tar.gz \
    && mv prometheus-2.46.0.linux-amd64 /opt/prometheus \
    && ln -s /opt/prometheus/prometheus /usr/local/bin/prometheus \
    && ln -s /opt/prometheus/promtool /usr/local/bin/promtool

# Copier les fichiers de configuration Prometheus et supervisord
COPY prometheus/prometheus.yml /etc/prometheus/prometheus.yml
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Donner les bons droits
RUN chown -R www-data:www-data /var/www/html

# Exposer les ports PHP-FPM et Prometheus
EXPOSE 9000 9090

# Lancer PHP-FPM et Prometheus via supervisord
CMD ["/usr/bin/supervisord"]

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
