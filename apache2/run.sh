#!/bin/bash

NGINX_CACHE_DIR="/tmp/nginx/cache"
mkdir -p ${NGINX_CACHE_DIR}

DOCKER_IMAGE="$(cat .docker_image)"

docker rm -f nginx;

# URI="proxy.minerva.net"
# --add-host "${URI}":127.0.0.1 \
# -it \
# -d \
# --dns=127.0.0.1 \
# --dns-search=minerva.net \

docker run \
-it \
--name nginx \
--hostname=nginx \
-p 88:80 \
-p 8443:443 \
-p 222:22 \
-v $NGINX_CACHE_DIR:/var/cache/nginx \
${DOCKER_IMAGE} \
/bin/bash
