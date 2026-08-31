FROM php:8.2-apache

RUN apt-get update && apt-get install -y \
    git \
    unzip \
    zip \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    && docker-php-ext-install pdo pdo_mysql zip \
    && rm -rf /var/lib/apt/lists/*

# Exibe erros do PHP na tela para não dar 502 silenciando o container
RUN echo "display_errors = On" >> /usr/local/etc/php/conf.d/docker-php-errors.ini \
    && echo "error_reporting = E_ALL" >> /usr/local/etc/php/conf.d/docker-php-errors.ini

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN a2enmod rewrite

COPY . /var/www/html/
RUN if [ -f .env.example ] && [ ! -f .env ]; then cp .env.example .env; fi

WORKDIR /var/www/html
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-dev --ignore-platform-reqs --no-interaction

RUN chown -R www-data:www-data /var/www/html

ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/conf-available/*.conf

EXPOSE 80
