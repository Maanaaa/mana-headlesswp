#!/bin/bash
cd /var/www/html

# 1. On télécharge WordPress via CURL (beaucoup plus stable)
if [ ! -f wp-settings.php ]; then
    echo "📥 Téléchargement de WordPress via CURL..."
    curl -L -O https://wordpress.org/latest.tar.gz
    
    echo "📦 Extraction via TAR (Zero Memory Issue)..."
    tar -xzf latest.tar.gz --strip-components=1
    rm latest.tar.gz
fi

# 2. Config & Install (On utilise WP-CLI uniquement pour les commandes SQL/Config)
if [ ! -f wp-config.php ]; then
    echo "⚙️ WP-CLI : Création du config..."
    wp core config --dbhost=db --dbname=wordpress --dbuser=root --dbpass=$DB_ROOT_PASSWORD --allow-root
    
    echo "🚀 WP-CLI : Installation..."
    wp core install --url="https://${PROJECT_NAME}.dev.theo-manya.fr" --title="${PROJECT_NAME}" --admin_user="admin" --admin_password="admin_password" --admin_email="manya.th@icloud.com" --allow-root
fi

# 3. Clonage du MU-Plugin
if [ ! -d "wp-content/mu-plugins/mana-core" ]; then
    echo "📦 Clonage du MU-Plugin Mana..."
    mkdir -p wp-content/mu-plugins
    git clone https://github.com/Maanaaa/mana-core.git wp-content/mu-plugins/mana-core
fi

echo "✅ Setup industriel terminé."