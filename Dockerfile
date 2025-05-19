FROM php:8.2-fpm

# Installer les dépendances système + Supervisor
RUN apt-get update && apt-get install -y \
    git unzip curl libpq-dev libzip-dev zip supervisor \
    && docker-php-ext-install pdo pdo_mysql zip

# Installer Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Créer le dossier de travail
WORKDIR /var/www/html

# Copier le code source Symfony dans le conteneur
COPY . .

# Installer les dépendances Symfony + Prometheus Metrics Bundle
RUN composer install --no-interaction --optimize-autoloader \
    && composer require artprima/prometheus-metrics-bundle

# Télécharger Prometheus
RUN curl -LO https://github.com/prometheus/prometheus/releases/download/v2.46.0/prometheus-2.46.0.linux-amd64.tar.gz \
    && tar xzf prometheus-2.46.0.linux-amd64.tar.gz \
    && mv prometheus-2.46.0.linux-amd64 /opt/prometheus \
    && ln -s /opt/prometheus/prometheus /usr/local/bin/prometheus \
    && ln -s /opt/prometheus/promtool /usr/local/bin/promtool

# Copier la configuration Prometheus et Supervisor
COPY prometheus/prometheus.yml /etc/prometheus/prometheus.yml
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Donner les droits
RUN chown -R www-data:www-data /var/www/html

# Exposer les ports PHP-FPM + Prometheus
EXPOSE 9000 9090

# Lancer Supervisor (qui lancera PHP + Prometheus)
CMD ["/usr/bin/supervisord"]
