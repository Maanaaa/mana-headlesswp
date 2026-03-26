#!/bin/bash

# 1. Install des outils de déploiement
apt-get update && apt-get install -y git unzip mariadb-client

# 2. Install WP-CLI (si absent)
if ! [ -x "$(command -v wp)" ]; then
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

cd /var/www/html

# 3. Logique d'installation automatique
if [ ! -f wp-config.php ]; then
    echo "📥 WP-CLI : Téléchargement du core..."
    wp core download --allow-root

    echo "⚙️ WP-CLI : Création du config..."
    wp config create \
        --dbname=wordpress \
        --dbuser=root \
        --dbpass=$DB_ROOT_PASSWORD \
        --dbhost=db \
        --allow-root

    echo "🚀 WP-CLI : Install (admin/admin)..."
    wp core install \
        --url="https://localhost" \
        --title="Mana Portfolio" \
        --admin_user="admin" \
        --admin_password="admin" \
        --admin_email="admin@mana.fr" \
        --skip-email \
        --allow-root

    # 4. Ton MU-Plugin en direct depuis ton Repo
    echo "📦 Clonage du MU-Plugin Mana..."
    mkdir -p wp-content/mu-plugins
    git clone https://github.com/ton-username/mana-mu-plugin.git wp-content/mu-plugins/mana-core

    # 5. Configuration finale
    wp plugin install advanced-custom-fields --activate --allow-root
    wp rewrite structure '/%postname%/' --allow-root
    wp plugin delete hello akismet --allow-root
fi

# Fix des permissions pour FrankenPHP
chown -R www-data:www-data /var/www/html
echo "✅ Setup industriel terminé."