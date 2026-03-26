#!/bin/bash
cd /var/www/html

# 1. Téléchargement WordPress
if [ ! -f wp-settings.php ]; then
    echo "📥 Téléchargement de WordPress..."
    curl -L -O https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz --strip-components=1
    rm latest.tar.gz
fi

# 2. Config & Install
if [ ! -f wp-config.php ]; then
    echo "⚙️ WP-CLI : Création du config..."
    wp core config --dbhost=db --dbname=wordpress --dbuser=root --dbpass=$DB_ROOT_PASSWORD --allow-root
fi

echo "🚀 WP-CLI : Installation du site..."
wp core install --url="https://${PROJECT_NAME}.dev.theo-manya.fr" --title="${PROJECT_NAME}" --admin_user="admin" --admin_password="admin_password" --admin_email="manya.th@icloud.com" --allow-root

# 3. MU-Plugin
if [ ! -d "wp-content/mu-plugins/mana-core" ]; then
    echo "📦 Clonage du MU-Plugin Mana..."
    mkdir -p wp-content/mu-plugins
    git clone https://github.com/Maanaaa/mana-core.git wp-content/mu-plugins/mana-core
fi

echo "✅ Setup industriel terminé."