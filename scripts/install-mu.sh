#!/bin/bash
set -euo pipefail

MU_DIR="./html/wp-content/mu-plugins/mana-wp-mu-plugin"

mkdir -p ./html/wp-content/mu-plugins

if [ -d "$MU_DIR" ]; then
  echo "✅ mu-plugin déjà présent"
else
  echo "📦 Clonage du mu-plugin..."
  git clone https://github.com/Maanaaa/mana-wp-mu-plugin.git "$MU_DIR"
  echo "✅ mu-plugin installé !"
fi