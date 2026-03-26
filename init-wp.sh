#!/bin/bash
set -e
cd /var/www/html

WP="/usr/local/bin/wp"

# 1. Fix Permissions & Git
chown -R www-data:www-data /var/www/html
git config --global --add safe.directory /var/www/html

# 2. Attendre la DB proprement
echo "⏳ Vérification SQL..."
until $WP db check --dbhost=db --dbname=wordpress --dbuser=root --dbpass="$DB_ROOT_PASSWORD" --allow-root &>/dev/null; do
  echo "🔄 MariaDB pas encore prête... attente 3s..."
  sleep 3
done
echo "✅ DB Connectée !"

# 3. Téléchargement WordPress (Si vide)
if [ ! -f wp-settings.php ]; then
    echo "📥 Téléchargement WordPress..."
    curl -L -o wordpress.tar.gz https://wordpress.org/latest.tar.gz
    tar -xzf wordpress.tar.gz --strip-components=1
    rm wordpress.tar.gz
fi

# 4. Config & Install
if [ ! -f wp-config.php ]; then
    echo "⚙️ Création wp-config..."
    $WP core config --dbhost=db --dbname=wordpress --dbuser=root --dbpass="$DB_ROOT_PASSWORD" --allow-root --skip-check
fi

if ! $WP core is-installed --allow-root; then
    echo "🚀 Installation WordPress..."
    $WP core install --url="https://${PROJECT_NAME}.dev.theo-manya.fr" --title="${PROJECT_NAME}" --admin_user="admin" --admin_password="admin_password" --admin_email="manya.th@icloud.com" --allow-root
fi

# 5. Plugin MU
if [ ! -d "wp-content/mu-plugins/mana-core" ]; then
    echo "📦 Clonage MU-Plugin..."
    mkdir -p wp-content/mu-plugins
    git clone https://github.com/Maanaaa/mana-core.git wp-content/mu-plugins/mana-core
fi

chown -R www-data:www-data /var/www/html
echo "✨ SETUP TERMINÉ !"