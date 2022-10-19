FROM alpine:3.16.2

USER root

MAINTAINER Marco Introini <mint.dev@pm.me>
LABEL Description="Alpine Linux for PHP 8.1 with Apache2"

RUN apk --no-cache --update \
    add apache2 \
    apache2-ssl \
    coreutils \
    curl \
    php81 \
    php81-apache2 \
    php81-bcmath \
    php81-bz2 \
    php81-calendar \
    php81-common \
    php81-ctype \
    php81-curl \
    php81-dom \
    php81-gd \
    php81-iconv \
    php81-mbstring \
    php81-mysqli \
    php81-mysqlnd \
    php81-openssl \
    php81-pdo_mysql \
    php81-pdo_pgsql \
    php81-pdo_sqlite \
    php81-phar \
    php81-session \
    php81-xml \
    php81-soap \
    && ln -s /usr/bin/php81 /usr/bin/php

WORKDIR /var/www
COPY docker/httpd.conf /etc/apache2/httpd.conf
COPY docker/php.ini /etc/php81/php.ini
COPY composer.json .
COPY composer.lock .

RUN mkdir -p /etc/apache2/log/ \
    && chmod 777 /var/log/apache2/

RUN wget https://getcomposer.org/download/latest-stable/composer.phar \
  && /usr/bin/php composer.phar install --no-dev -o \
  && rm -rf composer.phar

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

EXPOSE 80

HEALTHCHECK CMD wget -q --no-cache --spider localhost

ENTRYPOINT ["httpd", "-D", "FOREGROUND"]