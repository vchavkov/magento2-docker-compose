#!/bin/bash

exec 2>&1
set -e
set -x

ROOT_PASS="mn2111td"

NGINX_VERSION=1.15.9
NGX_CACHE_PURGE_VERSION=2.3
NGX_CACHE_HEADERS_MORE=0.33
NPS_VERSION=1.13.35.1-beta
PS_NGX_EXTRA_FLAGS=""

# Install basic packages and build tools
apt-get update
apt-get dist-upgrade -y
apt-get install -y \
    build-essential \
    zlib1g-dev \
    libssl-dev \
    libpcre3 \
    libpcre3-dev \
    unzip \
    uuid-dev \
    supervisor \
    openssh-server \
    dnsmasq \
    curl \
    wget \
    htop \
    dnsutils \
    sed \
    vim-tiny

mkdir /var/run/sshd
echo "root:${ROOT_PASS}" | chpasswd
sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# NOTVISIBLE "in users profile"
echo "export VISIBLE=now" >> /etc/profile

# Get sources
cd /tmp

# pagespeed-ngx
wget https://github.com/apache/incubator-pagespeed-ngx/archive/v${NPS_VERSION}.zip
unzip v${NPS_VERSION}.zip
nps_dir=$(find . -name "*pagespeed-ngx-${NPS_VERSION}" -type d)
cd "$nps_dir"
NPS_RELEASE_NUMBER=${NPS_VERSION/beta/}
NPS_RELEASE_NUMBER=${NPS_VERSION/stable/}
psol_url=https://dl.google.com/dl/page-speed/psol/${NPS_RELEASE_NUMBER}.tar.gz
[ -e scripts/format_binary_url.sh ] && psol_url=$(scripts/format_binary_url.sh PSOL_BINARY_URL)
wget ${psol_url}
tar -xzvf $(basename ${psol_url})  # extracts to psol/

cd /tmp

# nginx
wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
tar -zxvf nginx-${NGINX_VERSION}.tar.gz && mv nginx-${NGINX_VERSION} nginx && rm nginx-${NGINX_VERSION}.tar.gz

# ngx_cache_purge
wget https://github.com/vchavkov/static-assets/raw/master/nginx/ngx_cache_purge-${NGX_CACHE_PURGE_VERSION}.tar.gz
tar -zxvf ngx_cache_purge-${NGX_CACHE_PURGE_VERSION}.tar.gz && mv ngx_cache_purge-${NGX_CACHE_PURGE_VERSION} ngx_cache_purge && rm ngx_cache_purge-${NGX_CACHE_PURGE_VERSION}.tar.gz

# headers-more-nginx
wget https://github.com/openresty/headers-more-nginx-module/archive/v${NGX_CACHE_HEADERS_MORE}.tar.gz
tar -zxvf v${NGX_CACHE_HEADERS_MORE}.tar.gz && mv headers-more-nginx-module-${NGX_CACHE_HEADERS_MORE} ngx_headers_more && rm v${NGX_CACHE_HEADERS_MORE}.tar.gz

# Configure and build software
cd /tmp/nginx && ./configure \
  --sbin-path=/usr/local/sbin \
  --conf-path=/etc/nginx/nginx.conf \
  --error-log-path=/var/log/nginx/error.log \
  --http-log-path=/var/log/nginx/access.log \
  --user=www-data \
  --group=www-data \
  --with-http_gzip_static_module \
  --with-http_ssl_module \
  --without-mail_pop3_module \
  --without-mail_imap_module \
  --without-mail_smtp_module \
  --add-module=/tmp/$nps_dir ${PS_NGX_EXTRA_FLAGS}\
  --add-module=/tmp/ngx_headers_more \
  --add-module=/tmp/ngx_cache_purge && \
  make && make install


# Copy configuration files into /etc/nginx and clean up config file to point to
# correct root
mv /usr/local/nginx/html /var/www && \
  chown -R www-data:www-data /var/www && \
  mkdir -p /etc/nginx/conf.d && \
  mkdir -p /etc/nginx/sites-available && \
  mkdir -p /etc/nginx/sites-enabled && \
  sed -i 's/root\s*html;.*$/root \/var\/www;/' /etc/nginx/nginx.conf && \
  echo "\ninclude /etc/nginx/conf.d/\*.conf;" >> /etc/nginx/nginx.conf

# Forward request and error logs to docker log collector
ln -sf /dev/stdout /var/log/nginx/access.log
ln -sf /dev/stderr /var/log/nginx/error.log

# volumes
mkdir -p /var/cache/nginx
chown www-data:www-data -R /var/cache/nginx

# reduce docker image size
cd /
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apt/archives/*.deb
