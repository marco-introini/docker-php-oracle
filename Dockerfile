FROM php:8-apache

USER root

WORKDIR /var/www

RUN apt-get update && apt-get install -y \
        libpng-dev \
        zlib1g-dev \
        libxml2-dev \
        libzip-dev \
        libonig-dev \
        zip \
        curl \
        unzip \
        unzip \
        libaio-dev \
        libmcrypt-dev \
        git \
    && docker-php-ext-configure gd \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install zip \
    && docker-php-ext-install soap \
    && docker-php-source delete

RUN \
    docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd \
    && docker-php-ext-configure mysqli \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install mcrypt

# xdebug, if you want to debug
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

# PHP composer, if you need it (and you will)
RUN curl -sS https://getcomposer.org/installer | php --  --install-dir=/usr/bin --filename=composer

# Oracle instantclient

# Donwload oracle files - Source: https://www.oracle.com/database/technologies/instant-client/linux-arm-aarch64-downloads.html
# Use arm64 for Apple Silicon, replace with x64 for linux intel or windows
ADD https://download.oracle.com/otn_software/linux/instantclient/191000/instantclient-basic-linux.arm64-19.10.0.0.0dbru.zip /tmp/
ADD https://download.oracle.com/otn_software/linux/instantclient/191000/instantclient-sdk-linux.arm64-19.10.0.0.0dbru.zip /tmp/
# uncommet if you need sqlplus
#ADD https://download.oracle.com/otn_software/linux/instantclient/211000/instantclient-sqlplus-linux.arm64-19.10.0.0.0dbru.zip /tmp/

# unzip them
RUN unzip /tmp/instantclient-basic-linux.arm64-*.zip -d /usr/local/
RUN unzip /tmp/instantclient-sdk-linux.arm64-19.10.0.0.0dbru.zip -d /usr/local/
#RUN unzip /tmp/instantclient-sqlplus-linux.arm64-*.zip -d /usr/local/

# now we can install them creating a symlink
RUN ln -s /usr/local/instantclient_19_10 /usr/local/instantclient
#RUN ln -s /usr/local/instantclient/sqlplus /usr/bin/sqlplus

# copy local tnsnames.ora
COPY docker/tnsnames.ora /usr/local/instantclient_19_10/network/admin/

# now we must install oci8 php extensions
RUN docker-php-ext-configure oci8 --with-oci8=instantclient,/usr/local/instantclient \
    && docker-php-ext-install oci8 \
    && echo /usr/local/instantclient/ > /etc/ld.so.conf.d/oracle-insantclient.conf \
    && ldconfig

# Now let's configure apache with ssl
COPY docker/ssl.crt /etc/apache2/ssl/ssl.crt
COPY docker/ssl.key /etc/apache2/ssl/ssl.key
RUN mkdir -p /etc/apache2/log/

RUN ln -s /etc/apache2/mods-available/ssl.load  /etc/apache2/mods-enabled/ssl.load

COPY docker/vhost.conf /etc/apache2/sites-available/000-default.conf

RUN a2enmod rewrite
