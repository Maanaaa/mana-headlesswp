
#!/bin/bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <projet>"
  exit 1
fi

PROJET="$1"
REPO="https://github.com/Maanaaa/mana-headlesswp.git"

echo "🚀 Création du projet $PROJET..."

git clone "$REPO" "$PROJET"
cd "$PROJET"

mkdir -p html

DB_ROOT_PASSWORD=$(openssl rand -hex 32)
WP_ADMIN_PASSWORD=$(openssl rand -hex 24)

cat > .env << EOF
PROJECT_NAME=$PROJET
DB_ROOT_PASSWORD=$DB_ROOT_PASSWORD
WP_ADMIN_PASSWORD=$WP_ADMIN_PASSWORD
EOF

echo "✅ Admin pass: $WP_ADMIN_PASSWORD"

chmod +x deploy.sh init-wp.sh 2>/dev/null || true
./deploy.sh

echo ""
echo "🎉 Done !"
echo "   → https://$PROJET.dev.theo-manya.fr/wp-admin"
echo "   → user: admin"
echo "   → pass: $WP_ADMIN_PASSWORD"