#!/bin/bash

IMAGE_TAG="nginx:1.0.0"

docker build --rm -t ${IMAGE_TAG} . --no-cache

docker images -q ${IMAGE_TAG} > .docker_image
