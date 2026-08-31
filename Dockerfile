FROM php:8.2-apache

# Instala ferramentas do sistema e extensões de banco/sistema
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

# Copia o Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Ativa mod_rewrite
RUN a2enmod rewrite

# Copia arquivos
COPY . /var/www/html/

# Instala pacotes ignorando requisitos estritos de plataforma
WORKDIR /var/www/html
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-dev --ignore-platform-reqs --no-interaction

# Permissões do Apache
RUN chown -R www-data:www-data /var/www/html

# Aponta para /public
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/conf-available/*.conf

EXPOSE 80
