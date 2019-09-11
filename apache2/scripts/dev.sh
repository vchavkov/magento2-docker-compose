#!/bin/bash

source ./scripts/.conf

docker rm -f ${CONTAINER_NAME};

docker run \
-it \
--name ${CONTAINER_NAME} \
--hostname=${CONTAINER_NAME} \
-p 88:80 \
-p 8443:443 \
-p 222:22 \
${DOCKER_IMAGE} \
/bin/bash
