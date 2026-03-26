#!/bin/bash

# 1. Charger les variables
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "❌ Pas de fichier .env trouvé."
    exit 1
fi

# 2. Trouver un port libre pour WordPress (dès 8080)
PORT_WP=8080
while netstat -atn | grep -q ":$PORT_WP "; do
    PORT_WP=$((PORT_WP + 1))
done

# 3. Trouver un port libre pour PHPMyAdmin (dès 9000 pour éviter les collisions)
PORT_PMA=9000
while netstat -atn | grep -q ":$PORT_PMA "; do
    PORT_PMA=$((PORT_PMA + 1))
done

# 4. Injecter les ports dans le .env
sed -i "s/APP_PORT=.*/APP_PORT=$PORT_WP/" .env || echo "APP_PORT=$PORT_WP" >> .env
sed -i "s/PMA_PORT=.*/PMA_PORT=$PORT_PMA/" .env || echo "PMA_PORT=$PORT_PMA" >> .env

echo "✅ Ports attribués : WP->$PORT_WP | PMA->$PORT_PMA"

# 5. Config Nginx Hôte
DOMAIN="${PROJECT_NAME}.tondomaine.com"
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

# 6. LANCEMENT DOCKER
docker compose up -d --build

echo "🚀 C'est en ligne : http://$DOMAIN"
EOF

chmod +x deploy.sh