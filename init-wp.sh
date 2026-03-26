#!/bin/bash
cd /var/www/html

# 1. Fix des permissions immédiat
chown -R www-data:www-data /var/www/html

# 2. Attendre que MariaDB soit prête
echo "⏳ Attente de la base de données..."
until mariadb-admin ping -h"db" --silent; do
    sleep 2
    echo "..."
done
echo "✅ Base de données prête !"

# 3. WP Core
if [ ! -f wp-settings.php ]; then
    echo "📥 Téléchargement WordPress..."
    curl -L -O https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz --strip-components=1
    rm latest.tar.gz
fi

# 4. Config (On force root car WP-CLI tourne en root dans le container)
if [ ! -f wp-config.php ]; then
    echo "⚙️ WP-CLI : Config..."
    /usr/local/bin/wp core config --dbhost=db --dbname=wordpress --dbuser=root --dbpass="$DB_ROOT_PASSWORD" --allow-root
fi

# 5. Install (On vérifie si déjà installé pour éviter l'erreur)
if ! /usr/local/bin/wp core is-installed --allow-root; then
    echo "🚀 WP-CLI : Install..."
    /usr/local/bin/wp core install --url="https://${PROJECT_NAME}.dev.theo-manya.fr" --title="${PROJECT_NAME}" --admin_user="admin" --admin_password="admin_password" --admin_email="manya.th@icloud.com" --allow-root
fi

# 6. MU-Plugin (HTTPS Public - On force les droits avant)
if [ ! -d "wp-content/mu-plugins/mana-core" ]; then
    echo "📦 MU-Plugin..."
    mkdir -p wp-content/mu-plugins
    git clone https://github.com/Maanaaa/mana-core.git wp-content/mu-plugins/mana-core
fi

# 7. Fix final des droits pour FrankenPHP
chown -R www-data:www-data /var/www/html

echo "✅ Setup terminé avec succès !"