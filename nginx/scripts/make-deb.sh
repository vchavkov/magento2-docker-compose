#!/bin/bash

exec 2>&1
set -e
set -x

WORK_DIR="/usr/src"

NGINX_VERSION=1.15.12
NGX_CACHE_PURGE_VERSION=2.3
NGX_CACHE_HEADERS_MORE=0.33
NPS_VERSION=1.13.35.2-stable
PS_NGX_EXTRA_FLAGS=""
NGX_EXTRA_FLAGS=" \
--with-cc-opt='-DNGX_HTTP_HEADERS' \
--with-http_gzip_static_module \
--with-http_ssl_module \
--without-mail_pop3_module \
--without-mail_imap_module \
--without-mail_smtp_module \
--add-module=${WORK_DIR}/ngx_pagespeed ${PS_NGX_EXTRA_FLAGS} \
--add-module=${WORK_DIR}/ngx_headers_more \
--add-module=${WORK_DIR}/ngx_cache_purge \
--add-module=${WORK_DIR}/ngx_brotli"
# NGX_EXTRA_FLAGS="--add-module=${WORK_DIR}/ngx_pagespeed ${PS_NGX_EXTRA_FLAGS} --add-module=${WORK_DIR}/ngx_headers_more --add-module=${WORK_DIR}/ngx_cache_purge"

# Install basic packages and build tools
apt-get update
apt-get dist-upgrade -y
apt-get install -y \
    dpkg-dev \
    build-essential \
    zlib1g-dev \
    libssl-dev \
    libpcre3 \
    libpcre3-dev \
    unzip \
    uuid-dev \
    devscripts \
    debian-keyring \
    sed

cd "${WORK_DIR}"

# clean up
rm -rf "nginx_${NGINX_VERSION}"*
rm -rf "nginx-${NGINX_VERSION}"*
rm -rf "ngx_"*
rm -rf *".deb"
rm -rf *".tar.gz"*
rm -rf "incubator-pagespeed-ngx"*

# nginx src
apt-get source nginx

# nginx deps
apt-get build-dep nginx

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
cd "${WORK_DIR}" && mv "$nps_dir" ngx_pagespeed && rm -rf "$nps_dir"

# ngx_cache_purge
wget https://github.com/vchavkov/static-assets/raw/master/nginx/ngx_cache_purge-${NGX_CACHE_PURGE_VERSION}.tar.gz
tar -zxvf ngx_cache_purge-${NGX_CACHE_PURGE_VERSION}.tar.gz && mv ngx_cache_purge-${NGX_CACHE_PURGE_VERSION} ngx_cache_purge && rm ngx_cache_purge-${NGX_CACHE_PURGE_VERSION}.tar.gz

# headers-more-nginx
wget https://github.com/openresty/headers-more-nginx-module/archive/v${NGX_CACHE_HEADERS_MORE}.tar.gz
tar -zxvf v${NGX_CACHE_HEADERS_MORE}.tar.gz && mv headers-more-nginx-module-${NGX_CACHE_HEADERS_MORE} ngx_headers_more && rm v${NGX_CACHE_HEADERS_MORE}.tar.gz

# Brotli compression
git clone https://github.com/google/ngx_brotli.git && cd ngx_brotli && git submodule update --init && cd ..

cd "${WORK_DIR}/nginx-${NGINX_VERSION}"

sed -i "s|--with-stream_realip_module|--with-stream_realip_module ${NGX_EXTRA_FLAGS}|g" debian/rules;

# make deb pkg
debuild -us -uc -b

cd "${WORK_DIR}"

# clean up
rm -rf *".zip"*
rm -rf ngx_*