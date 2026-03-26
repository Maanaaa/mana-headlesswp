#!/bin/bash
set -e
cd /var/www/html

WP="/usr/local/bin/wp"

# 1. On attend que la DB réponde au login WP-CLI (Double sécurité)
echo "⏳ Vérification finale de la connexion SQL..."
until $WP db check --dbhost=db --dbname=wordpress --dbuser=root --dbpass="$DB_ROOT_PASSWORD" --allow-root &>/dev/null; do
  echo "🔄 MariaDB initialise les droits... on attend 3s..."
  sleep 3
done

# 2. Téléchargement WordPress (via TAR car plus léger en RAM)
if [ ! -f wp-settings.php ]; then
    echo "📥 Téléchargement de WordPress..."
    curl -L -o wordpress.tar.gz https://wordpress.org/latest.tar.gz
    tar -xzf wordpress.tar.gz --strip-components=1
    rm wordpress.tar.gz
fi

# 3. wp-config.php
if [ ! -f wp-config.php ]; then
    echo "⚙️ WP-CLI : Création du wp-config..."
    $WP core config --dbhost=db --dbname=wordpress --dbuser=root --dbpass="$DB_ROOT_PASSWORD" --allow-root --skip-check
fi

# 4. Installation
if ! $WP core is-installed --allow-root; then
    echo "🚀 WP-CLI : Installation du site..."
    $WP core install --url="https://${PROJECT_NAME}.dev.theo-manya.fr" --title="${PROJECT_NAME}" --admin_user="admin" --admin_password="admin_password" --admin_email="manya.th@icloud.com" --allow-root
fi

# 5. MU-Plugin
echo "📦 Gestion du MU-Plugin..."
mkdir -p wp-content/mu-plugins
git config --global --add safe.directory /var/www/html
if [ ! -d "wp-content/mu-plugins/mana-core" ]; then
    git clone https://github.com/Maanaaa/mana-core.git wp-content/mu-plugins/mana-core
fi

# 6. Droits finaux
chown -R www-data:www-data /var/www/html
echo "✨ SETUP INDUSTRIEL TERMINÉ !"