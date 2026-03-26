#!/bin/bash

# 1. Charger le nom du projet depuis le .env (ou le passer en argument)
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else 
    echo "❌ Fichier .env manquant."
    exit 1
fi

# 2. Trouver le premier port libre à partir de 8080
PORT=8080
while netstat -atn | grep -q ":$PORT "; do
    echo "⚠️ Port $PORT déjà pris, on check le suivant..."
    PORT=$((PORT + 1))
done

echo "✅ Port libre trouvé : $PORT"

# 3. Mettre à jour le port dans le .env pour Docker
if grep -q "APP_PORT=" .env; then
    sed -i "s/APP_PORT=.*/APP_PORT=$PORT/" .env
else
    echo "APP_PORT=$PORT" >> .env
fi

# 4. Config Nginx sur l'hôte
DOMAIN="${PROJECT_NAME}.theo-manya.fr"
CONF_FILE="/etc/nginx/sites-available/${PROJECT_NAME}"

cat <<EOF > $CONF_FILE
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://127.0.0.1:$PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        client_max_body_size 300M;
    }
}
EOF

# 5. Activation et Reload Nginx
ln -s $CONF_FILE /etc/nginx/sites-enabled/ 2>/dev/null
nginx -t && systemctl reload nginx

# 6. Lancement du projet avec ton init-wp.sh
docker-compose up -d --build

echo "🚀 Projet ${PROJECT_NAME} en ligne sur http://$DOMAIN (Port interne: $PORT)"