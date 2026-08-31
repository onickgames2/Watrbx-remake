FROM php:8.2-apache

# Instala extensões e pacotes do sistema
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

# Copia o Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copia os arquivos do projeto
COPY . /var/www/html/

WORKDIR /var/www/html

# Cria o .env se não existir
RUN if [ -f .env.example ] && [ ! -f .env ]; then cp .env.example .env; fi

# Instala pacotes do Composer
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-dev --ignore-platform-reqs --no-interaction

# Ajusta permissões totais para o Apache (www-data) ler e escrever
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Aponta a raiz do Apache para /public
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/conf-available/*.conf

# Direciona os erros do Apache diretamente para os logs do Render
RUN ln -sf /dev/stdout /var/log/apache2/access.log \
    && ln -sf /dev/stderr /var/log/apache2/error.log

EXPOSE 80
