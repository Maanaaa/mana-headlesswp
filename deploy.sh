#!/bin/bash

# 1. Check outils
if ! command -v netstat &> /dev/null; then
    sudo apt update && sudo apt install net-tools certbot python3-certbot-nginx -y
fi

# 2. Charger les variables
if [ -f .env ]; then export $(grep -v '^#' .env | xargs); fi

# 3. Trouver ports libres
PORT_WP=8080
while netstat -atn | grep -q ":$PORT_WP "; do PORT_WP=$((PORT_WP + 1)); done
PORT_PMA=9000
while netstat -atn | grep -q ":$PORT_PMA "; do PORT_PMA=$((PORT_PMA + 1)); done

# 4. Écrire et Exporter
sed -i "/APP_PORT=/d" .env && echo "APP_PORT=$PORT_WP" >> .env
sed -i "/PMA_PORT=/d" .env && echo "PMA_PORT=$PORT_PMA" >> .env
export APP_PORT=$PORT_WP
export PMA_PORT=$PORT_PMA

# 5. Config Nginx
DOMAIN="dev.${PROJECT_NAME}.theo-manya.fr"
CONF_FILE="/etc/nginx/sites-available/${PROJECT_NAME}"

cat <<EON > $CONF_FILE
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://127.0.0.1:$PORT_WP;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        client_max_body_size 300M;
    }

    location /pma/ {
        proxy_pass http://127.0.0.1:$PORT_PMA/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_redirect off;
    }
}
EON

ln -s $CONF_FILE /etc/nginx/sites-enabled/ 2>/dev/null
nginx -t && systemctl reload nginx

# 6. SSL avec Certbot
echo "🔒 Activation du HTTPS..."
certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m manya.th@icloud.com --redirect

# 7. Lancement Docker
docker compose up -d --build

echo "✨ Terminé !"
echo "🚀 WordPress : https://$DOMAIN"
echo "🛠 PHPMyAdmin : https://$DOMAIN/pma/"