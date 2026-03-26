#!/bin/bash
cd /var/www/html

# 1. Installation des dépendances système ET PHP
if ! command -v wp &> /dev/null; then
    echo "🛠 Installation des outils et extensions PHP..."
    # On installe mysqli qui manque à WP-CLI
    install-php-extensions mysqli
    
    apt-get update && apt-get install -y git tar curl mariadb-client
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

# 2. Téléchargement WordPress (TAR pour la mémoire)
if [ ! -f wp-settings.php ]; then
    echo "📥 Téléchargement de WordPress..."
    curl -L -O https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz --strip-components=1
    rm latest.tar.gz
fi

# 3. Config & Install
if [ ! -f wp-config.php ]; then
    echo "⚙️ WP-CLI : Création du config..."
    wp core config --dbhost=db --dbname=wordpress --dbuser=root --dbpass=$DB_ROOT_PASSWORD --allow-root
fi

echo "🚀 WP-CLI : Installation du site..."
wp core install --url="https://${PROJECT_NAME}.dev.theo-manya.fr" --title="${PROJECT_NAME}" --admin_user="admin" --admin_password="admin_password" --admin_email="manya.th@icloud.com" --allow-root

# 4. Plugin MU (HTTPS Direct)
if [ ! -d "wp-content/mu-plugins/mana-core" ]; then
    echo "📦 Clonage du MU-Plugin Mana..."
    mkdir -p wp-content/mu-plugins
    git clone https://github.com/Maanaaa/mana-core.git wp-content/mu-plugins/mana-core
fi

echo "✅ Setup industriel terminé."