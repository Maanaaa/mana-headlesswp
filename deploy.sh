#!/bin/bash
set -euo pipefail

# 1. Outils
if ! command -v ss >/dev/null 2>&1; then
  sudo apt update && sudo apt install -y net-tools iproute2 certbot python3-certbot-nginx nginx -y
fi

# 2. .env check/créé (exemple si absent)
[ -f .env ] || cat > .env << EOF
PROJECT_NAME=monprojet
DB_ROOT_PASSWORD=$(openssl rand -base64 32)
WP_ADMIN_PASSWORD=$(openssl rand -base64 24)
EOF

# Load .env
set -a; source .env; set +a

# 3. Ports libres
find_port() {
  local p=$1; while ss -ltn | grep -q ":$p "; do ((p++)); done; echo $p
}
APP_PORT=$(find_port 8080)
PMA_PORT=$(find_port 9000)

sed -i "/^(APP_PORT|PMA_PORT|PMA_ABSOLUTE_URI)=/d" .env
echo "APP_PORT=$APP_PORT" >> .env
echo "PMA_PORT=$PMA_PORT" >> .env
export APP_PORT PMA_PORT

DOMAIN="${PROJECT_NAME}.dev.theo-manya.fr"

# 4. Nginx HTTP
CONF="/etc/nginx/sites-available/$PROJECT_NAME"
cat > "$CONF" << EOF
server {
  listen 80;
  server_name $DOMAIN;
  location / { proxy_pass http://127.0.0.1:$APP_PORT; proxy_set_header Host \$host; proxy_set_header X-Forwarded-Proto \$scheme; client_max_body_size 300M; }
  location /pma/ { proxy_pass http://127.0.0.1:$PMA_PORT/; proxy_set_header Host \$host; proxy_set_header X-Forwarded-Proto \$scheme; proxy_redirect off; }
}
EOF
ln -sf "$CONF" /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

# 5. Docker up
docker compose up -d --build

# 6. Wait WP
echo "⏳ WP ready..."
timeout 300 sh -c "until curl -sf http://127.0.0.1:$APP_PORT >/dev/null 2>&1; do sleep 2; done; echo OK"

# 7. Certbot
certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos -m manya.th@icloud.com --redirect

# 8. PMA HTTPS
echo "PMA_ABSOLUTE_URI=https://$DOMAIN/pma/" >> .env
docker compose restart pma

echo "✅ https://$DOMAIN | PMA: https://$DOMAIN/pma/"