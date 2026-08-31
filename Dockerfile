FROM php:8.2-apache

# Instala ferramentas necessárias e a extensão do Composer
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Instala o Composer para gerenciar as dependências PHP
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Ativa o mod_rewrite do Apache
RUN a2enmod rewrite

# Copia os arquivos do projeto
COPY . /var/www/html/

# Instala as dependências listadas no composer.json
WORKDIR /var/www/html
RUN composer install --no-dev --optimize-autoloader

# Aponta a raiz do Apache para a pasta /public
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/conf-available/*.conf

EXPOSE 80
