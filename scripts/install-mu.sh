#!/bin/bash
set -euo pipefail

MU_PLUGINS_DIR="./html/wp-content/mu-plugins"

mkdir -p "$MU_PLUGINS_DIR"

if [ -f "$MU_PLUGINS_DIR/mana-wp-mu-plugin.php" ]; then
  echo "✅ mu-plugin déjà présent"
else
  echo "📦 Clonage du mu-plugin..."
  git clone https://github.com/Maanaaa/mana-wp-mu-plugin.git "$MU_PLUGINS_DIR/."
  echo "✅ mu-plugin installé !"
fi