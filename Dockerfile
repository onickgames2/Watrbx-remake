FROM php:8.2-apache

# Instala dependências do sistema
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

# Copia os arquivos do projeto
COPY . /var/www/html/

# Cria o arquivo .env a partir do .env.example se o .env não existir
RUN if [ -f .env.example ] && [ ! -f .env ]; then cp .env.example .env; fi

# Instala pacotes do Composer
WORKDIR /var/www/html
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-dev --ignore-platform-reqs --no-interaction

# Ajusta permissões dos arquivos
RUN chown -R www-data:www-data /var/www/html

# Aponta para a pasta public
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/conf-available/*.conf

EXPOSE 80
