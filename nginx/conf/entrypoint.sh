#!/bin/bash

set -o errexit
set -o pipefail

echo -e "\n===> Updated /etc/resolv.conf\n"
echo "nameserver 127.0.0.1
search minerva.net
" > /etc/resolv.conf

cat /etc/resolv.conf

echo -e "===> start supervisord\n"
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
