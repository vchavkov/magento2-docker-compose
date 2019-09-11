#!/bin/bash

source ./scripts/.conf

docker cp ./bin/*.sh ${CONTAINER_NAME}:/tmp/ && \
docker cp ./conf/ ${CONTAINER_NAME}:/
