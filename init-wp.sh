#!/bin/bash
set -uo pipefail

WP="/usr/local/bin/wp"
WP_DIR="/var/www/html"
cd "$WP_DIR"

echo "⏳ Attente MariaDB..."
until mariadb-admin ping -h"db" -u"root" -p"${DB_ROOT_PASSWORD}" --silent 2>/dev/null || true; do
  echo "🔄 DB pas prête (sleep 5s)..."
  sleep 5
done
echo "✅ MariaDB prête !"

if [ ! -f wp-settings.php ]; then
  echo "📥 WordPress..."
  curl -fsSL -o /tmp/wp.tar.gz https://wordpress.org/latest.tar.gz
  tar -xzf /tmp/wp.tar.gz --strip-components=1
  rm /tmp/wp.tar.gz
fi

chown -R www-data:www-data "$WP_DIR"

if [ ! -f wp-config.php ]; then
  echo "⚙️ wp-config..."
  $WP config create --dbhost=db --dbname=wordpress --dbuser=root --dbpass="${DB_ROOT_PASSWORD}" --allow-root
  $WP config set WP_HOME "https://${WP_DOMAIN}" --allow-root --raw
  $WP config set WP_SITEURL "https://${WP_DOMAIN}" --allow-root --raw
fi

if ! $WP core is-installed --allow-root; then
  echo "🚀 Installation WP..."
  $WP core install --url="https://${WP_DOMAIN}" --title="${PROJECT_NAME}" \
    --admin_user=admin --admin_password="${WP_ADMIN_PASSWORD:-admin123}" \
    --admin_email="manya.th@icloud.com" --allow-root
fi

MU_DIR="$WP_DIR/wp-content/mu-plugins/mana-core"
if [ ! -d "$MU_DIR" ]; then
  echo "📦 mana-core..."
  mkdir -p wp-content/mu-plugins
  git config --global safe.directory "$WP_DIR"
  git clone https://github.com/Maanaaa/mana-core.git "$MU_DIR"
  chown -R www-data:www-data wp-content
fi

chown -R www-data:www-data "$WP_DIR"
echo "✅ Init terminé !"