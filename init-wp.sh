#!/bin/bash
cd /var/www/html

# 1. Fix des permissions
chown -R www-data:www-data /var/www/html

# 2. Attendre que le PORT de la DB soit ouvert (plus fiable que le ping root)
echo "⏳ Attente de MariaDB sur le port 3306..."
while ! timeout 1s bash -c "echo > /dev/tcp/db/3306" 2>/dev/null; do
    sleep 2
    echo "..."
done
echo "✅ MariaDB est joignable !"

# Un petit sleep de sécurité pour laisser MariaDB finir son init interne
sleep 5

# 3. WP Core
if [ ! -f wp-settings.php ]; then
    echo "📥 Téléchargement WordPress..."
    curl -L -O https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz --strip-components=1
    rm latest.tar.gz
fi

# 4. Config & Install
if [ ! -f wp-config.php ]; then
    echo "⚙️ WP-CLI : Config..."
    /usr/local/bin/wp core config --dbhost=db --dbname=wordpress --dbuser=root --dbpass="$DB_ROOT_PASSWORD" --allow-root
fi

if ! /usr/local/bin/wp core is-installed --allow-root; then
    echo "🚀 WP-CLI : Install..."
    /usr/local/bin/wp core install --url="https://${PROJECT_NAME}.dev.theo-manya.fr" --title="${PROJECT_NAME}" --admin_user="admin" --admin_password="admin_password" --admin_email="manya.th@icloud.com" --allow-root
fi

# 5. MU-Plugin
if [ ! -d "wp-content/mu-plugins/mana-core" ]; then
    echo "📦 MU-Plugin..."
    mkdir -p wp-content/mu-plugins
    git clone https://github.com/Maanaaa/mana-core.git wp-content/mu-plugins/mana-core
fi

chown -R www-data:www-data /var/www/html
echo "✅ Setup terminé !"