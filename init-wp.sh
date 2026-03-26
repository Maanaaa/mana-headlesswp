#!/bin/bash
cd /var/www/html

# 1. On s'assure que les outils sont là (Crucial pour l'automatisation)
if ! command -v wp &> /dev/null || ! command -v git &> /dev/null; then
    echo "🛠 Installation des outils (git, wp-cli, tar)..."
    apt-get update && apt-get install -y git tar curl mariadb-client
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

# 2. Téléchargement WordPress (via TAR)
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
    
    echo "🚀 WP-CLI : Installation..."
    wp core install --url="https://${PROJECT_NAME}.dev.theo-manya.fr" --title="${PROJECT_NAME}" --admin_user="admin" --admin_password="admin_password" --admin_email="manya.th@icloud.com" --allow-root
fi

# 4. Clonage du MU-Plugin
if [ ! -d "wp-content/mu-plugins/mana-core" ]; then
    echo "📦 Clonage du MU-Plugin Mana..."
    mkdir -p wp-content/mu-plugins
    git clone https://github.com/Maanaaa/mana-core.git wp-content/mu-plugins/mana-core
fi

echo "✅ Setup industriel terminé."