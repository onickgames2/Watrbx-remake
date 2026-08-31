FROM php:8.2-apache

# Instala extensões necessárias
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

# Ativa mod_rewrite
RUN a2enmod rewrite

# Copia Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copia arquivos da aplicação
COPY . /var/www/html/

WORKDIR /var/www/html

# Cria .env se necessário
RUN if [ -f .env.example ] && [ ! -f .env ]; then cp .env.example .env; fi

# Instala dependências do Composer
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-dev --ignore-platform-reqs --no-interaction

# Ajusta permissões dos arquivos
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Redireciona a pasta pública do Apache
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/conf-available/*.conf

# Reconfigura a porta do Apache para usar a variável $PORT fornecida pelo Render (ou 80 como fallback)
RUN sed -i 's/80/${PORT}/g' /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf

EXPOSE 80
