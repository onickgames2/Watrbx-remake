FROM php:8.2-apache

# Ativa o mod_rewrite do Apache (necessário por causa da pasta /routes e .htaccess)
RUN a2enmod rewrite

# Copia os arquivos do projeto para o diretório web do Apache
COPY . /var/www/html/

# Aponta a raiz do Apache para a pasta /public (padrão em projetos PHP com rotas)
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/conf-available/*.conf

EXPOSE 80
