#!/bin/bash
cd /var/www/html

# 1. On définit le chemin de WP-CLI en variable pour être sûr
WP="/usr/local/bin/wp"

# 2. Fix des droits
chown -R www-data:www-data /var/www/html

# 3. Attendre MariaDB (via TCP, pas de login requis)
echo "⏳ Attente de MariaDB..."
while ! timeout 1s bash -c "echo > /dev/tcp/db/3306" 2>/dev/null; do
    sleep 2
done
echo "✅ MariaDB contactée."

# On laisse 5s de plus pour que MariaDB finisse d'écrire ses droits root
sleep 5

# 4. Téléchargement WordPress (via CURL)
if [ ! -f wp-settings.php ]; then
    echo "📥 Téléchargement WordPress..."
    curl -L -O https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz --strip-components=1
    rm latest.tar.gz
fi

# 5. Création du wp-config.php (C'est ICI que ça foirait)
# On utilise --skip-check pour ne pas tester la DB tout de suite si elle est en train de reboot
if [ ! -f wp-config.php ]; then
    echo "⚙️ WP-CLI : Création du config..."
    $WP core config --dbhost=db --dbname=wordpress --dbuser=root --dbpass="$DB_ROOT_PASSWORD" --allow-root --skip-check
fi

# 6. Installation
# On boucle l'install jusqu'à ce que la DB accepte enfin la connexion (Max 30s)
echo "🚀 WP-CLI : Tentative d'installation..."
for i in {1..10}; do
    if $WP core install --url="https://${PROJECT_NAME}.dev.theo-manya.fr" --title="${PROJECT_NAME}" --admin_user="admin" --admin_password="admin_password" --admin_email="manya.th@icloud.com" --allow-root; then
        echo "✅ WordPress installé !"
        break
    fi
    echo "🔄 DB pas encore prête pour le login... nouvelle tentative dans 3s..."
    sleep 3
done

# 7. MU-Plugin (On configure Git pour éviter les erreurs de username)
if [ ! -d "wp-content/mu-plugins/mana-core" ]; then
    echo "📦 Clonage MU-Plugin..."
    mkdir -p wp-content/mu-plugins
    git config --global --add safe.directory /var/www/html
    git clone https://github.com/Maanaaa/mana-core.git wp-content/mu-plugins/mana-core
fi

chown -R www-data:www-data /var/www/html
echo "✅ SETUP TERMINÉ !"