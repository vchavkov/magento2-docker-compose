#!/bin/bash

CONTAINER_NAME="apache"
DOCKER_IMAGE="ubuntu:19.04"

docker rm -f apache;

# URI="proxy.minerva.net"
# --add-host "${URI}":127.0.0.1 \
# -it \
# -d \
# --dns=127.0.0.1 \
# --dns-search=minerva.net \

docker run \
-it \
--name ${CONTAINER_NAME} \
--hostname=${CONTAINER_NAME} \
-p 88:80 \
-p 8443:443 \
-p 222:22 \
${DOCKER_IMAGE} \
/bin/bash && \
docker cp ./bin/*.sh ${CONTAINER_NAME}:/tmp/ && \
docker cp ./conf/ ${CONTAINER_NAME}:/
