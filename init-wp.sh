#!/bin/bash
cd /var/www/html

# 1. WP Core
if [ ! -f wp-settings.php ]; then
    echo "📥 Téléchargement WordPress..."
    curl -L -O https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz --strip-components=1
    rm latest.tar.gz
fi

# 2. Config
if [ ! -f wp-config.php ]; then
    echo "⚙️ WP-CLI : Config..."
    /usr/local/bin/wp core config --dbhost=db --dbname=wordpress --dbuser=root --dbpass=$DB_ROOT_PASSWORD --allow-root
fi

# 3. Install
echo "🚀 WP-CLI : Install..."
/usr/local/bin/wp core install --url="https://${PROJECT_NAME}.dev.theo-manya.fr" --title="${PROJECT_NAME}" --admin_user="admin" --admin_password="admin_password" --admin_email="manya.th@icloud.com" --allow-root

# 4. MU-Plugin (Repo public = No login)
if [ ! -d "wp-content/mu-plugins/mana-core" ]; then
    echo "📦 MU-Plugin..."
    mkdir -p wp-content/mu-plugins
    git clone https://github.com/Maanaaa/mana-core.git wp-content/mu-plugins/mana-core
fi

echo "✅ Setup terminé !"