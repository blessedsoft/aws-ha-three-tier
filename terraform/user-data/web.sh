#!/bin/bash
set -euo pipefail

exec > >(tee -a /var/log/web-bootstrap.log | logger -t web-bootstrap -s 2>/dev/console) 2>&1

dnf update -y
dnf install -y nginx

cat >/etc/nginx/conf.d/app.conf <<'NGINX'
server {
    listen 80 default_server;
    server_name _;

    location = /health {
        default_type application/json;
        return 200 '{"status":"ok","service":"nginx-web"}';
    }

    location / {
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_pass http://${app_internal_dns}:3000;
    }
}
NGINX

rm -f /etc/nginx/conf.d/default.conf || true
nginx -t
systemctl enable --now nginx
systemctl restart nginx
