#!/bin/bash

exec 2>&1
set -e
set -x

export DEBIAN_FRONTEND=noninteractive

# Install basic packages
apt-get update && \
apt-get install -y tzdata sed && \
ln -sf /usr/share/zoneinfo/Europe/Sofia /etc/localtime && \
dpkg-reconfigure --frontend noninteractive tzdata && \
sed -i 's/http:\/\/archive.ubuntu.com/http:\/\/ubuntu.ipacct.com./g' /etc/apt/sources.list && \
apt-get update && \
apt-get dist-upgrade -y &&
apt-get install -y \
    apache2 \
    libapache2-mod-php7.2 \
    mysql-client \
    php7.2-curl \
    php7.2-intl \
    php7.2-gd \
    php7.2-dom \
    php7.2-iconv \
    php7.2-xsl \
    php7.2-mbstring \
    php7.2-ctype \
    php7.2-zip \
    php7.2-pdo \
    php7.2-xml \
    php7.2-bz2 \
    php7.2-calendar \
    php7.2-exif \
    php7.2-fileinfo \
    php7.2-json \
    php7.2-mysqli \
    php7.2-mysql \
    php7.2-posix \
    php7.2-tokenizer \
    php7.2-xmlwriter \
    php7.2-xmlreader \
    php7.2-phar \
    php7.2-soap \
    php7.2-mysql \
    php7.2-fpm \
    php7.2-bcmath \
    unzip \
    uuid-dev \
    supervisor \
    openssh-server \
    dnsmasq \
    curl \
    wget \
    htop \
    mc \
    dnsutils \
    sed \
    vim-tiny \
    && a2enmod rewrite \
    && a2enmod headers \
    && export LANG=en_US.UTF-8 \
    && sed -i -e"s/^memory_limit\s*=\s*128M/memory_limit = 512M/" /etc/php/7.2/apache2/php.ini \
    && rm /var/www/html/* \
    && sed -i "s/None/all/g" /etc/apache2/apache2.conf \
    && mkdir -p /var/log/supervisor

# env APACHE_RUN_USER    www-data
# env APACHE_RUN_GROUP   www-data
# env APACHE_PID_FILE    /var/run/apache2.pid
# env APACHE_RUN_DIR     /var/run/apache2
# env APACHE_LOCK_DIR    /var/lock/apache2
# env APACHE_LOG_DIR     /var/log/apache2
# env LANG               C

# Forward request and error logs to docker log collector
mkdir -p /var/log/apache
ln -sf /dev/stdout /var/log/apache/access.log
ln -sf /dev/stderr /var/log/apache/error.log

# reduce docker image size
cd /
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apt/archives/*.deb
