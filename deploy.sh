#!/bin/bash

# 1. Check netstat
if ! command -v netstat &> /dev/null; then
    sudo apt update && sudo apt install net-tools -y
fi

# 2. Charger les variables existantes
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

# 3. Trouver ports libres
PORT_WP=8080
while netstat -atn | grep -q ":$PORT_WP "; do PORT_WP=$((PORT_WP + 1)); done

PORT_PMA=9000
while netstat -atn | grep -q ":$PORT_PMA "; do PORT_PMA=$((PORT_PMA + 1)); done

# 4. Écrire dans le .env
sed -i "/APP_PORT=/d" .env && echo "APP_PORT=$PORT_WP" >> .env
sed -i "/PMA_PORT=/d" .env && echo "PMA_PORT=$PORT_PMA" >> .env

# IMPORTANT : On recharge les variables pour cette session de script
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
}
EON

ln -s $CONF_FILE /etc/nginx/sites-enabled/ 2>/dev/null
nginx -t && systemctl reload nginx

# 5.5 SSL avec Certbot
echo "🔒 Obtention du certificat SSL..."
certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m manya.th@icloud.com --redirect
echo "✅ Certificat SSL obtenu."

# 6. Lancement Docker (avec les variables exportées)
docker compose up -d --build

echo "🚀 C'est en ligne : http://$DOMAIN"
echo "🛠 PHPMyAdmin : http://$DOMAIN (Port interne: $PORT_PMA)"
EOF

chmod +x deploy.sh