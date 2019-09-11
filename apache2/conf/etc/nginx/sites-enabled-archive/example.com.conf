
proxy_cache_path /tmp/cacheapi levels=1:2 keys_zone=microcacheapi:100m max_size=1g inactive=1d use_temp_path=off;
server {
    listen 443 ssl http2 default_server;
    listen [::]:443 ssl http2 default_server;
    server_name example.com;

    location /api/ {
        # Rate Limiting
        limit_req zone=reqlimit burst=20; # Max burst of request
        limit_req_status 460; # Status to send
        # Connections Limiting
        limit_conn connlimit 20; # Number ofdownloads per IP        
        
        # Bandwidth Limiting
        limit_rate 4096k; # Speed limit (here is on kb/s)

        # Micro caching
        proxy_cache microcacheapi;
        proxy_cache_valid 200 1s;
        proxy_cache_use_stale updating;
        proxy_cache_background_update on;
        proxy_cache_lock on;

        proxy_pass http://localhost:8080;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_set_header X-NginX-Proxy true;

    }
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location ~* \.(jpg|jpeg|png|gif|ico)$ {
       expires 30d;
    }
    location ~* \.(css|js)$ {
       expires 7d;
    }

    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem; # managed by Certbot

    # Pagespeed Module
    pagespeed on;
    pagespeed FileCachePath /var/cache/ngx_pagespeed_cache;
    location ~ "\.pagespeed\.([a-z]\.)?[a-z]{2}\.[^.]{10}\.[^.]+" {
    add_header "" "";
    }
    location ~ "^/pagespeed_static/" { }
    location ~ "^/ngx_pagespeed_beacon$" { }
    pagespeed RewriteLevel PassThrough;
    pagespeed EnableCachePurge on;
    pagespeed PurgeMethod PURGE;
    pagespeed EnableFilters prioritize_critical_css;
}
server {
    listen 80;
    listen [::]:80;
    server_name example.com;
    return 301 https://$server_name$request_uri;
}
server {
    listen 80;
    listen [::]:80;
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name www.example.com;
    return 301 https://example.com$request_uri;
    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem; # managed by Certbot
}