#!/bin/bash

TARGET_HOSTS="\
192.168.3.114 \
45.56.84.78 \
139.162.191.120 \
"

for TARGET_HOST in $TARGET_HOSTS; do
    printf "Sync $TARGET_HOST ...\n"
    rsync -av --delete ./ --exclude="sync.sh" root@${TARGET_HOST}:nginx/
    rsync -av --delete ../conf/etc/nginx/sites-enabled/ root@${TARGET_HOST}:/etc/nginx/sites-enabled/
    rsync -av --delete ../conf/etc/nginx/conf.d/ root@${TARGET_HOST}:/etc/nginx/conf.d/
    rsync -av --delete ../conf/etc/nginx/snippets/ root@${TARGET_HOST}:/etc/nginx/snippets/
    rsync -av ../conf/etc/nginx/nginx.conf root@${TARGET_HOST}:/etc/nginx/nginx.conf
done;