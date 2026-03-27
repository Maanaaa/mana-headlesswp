# mana-headlesswp
# 🛠️ WP Dev Setup

Scripts pour créer et gérer des environnements WordPress Docker sur le serveur.

---

## Installation

### 1. Cloner le repo

```bash
git clone https://github.com/Maanaaa/mana-headlesswp.git
cd mana-headlesswp
```

### 2. Installer les scripts sur le VPS

```bash
cp scripts/make-wp.sh ~/bin/make-wp
chmod +x ~/bin/make-wp

cp scripts/install-mu.sh ~/bin/install-mu
chmod +x ~/bin/install-mu
```

---

## `make-wp <projet>`

Crée un environnement WordPress complet from scratch.

```bash
make-wp monprojet
```

**Ce que ça fait :**
- Clone le repo de config Docker
- Génère `.env` avec domaine par défaut : `monprojet.dev.theo-manya.fr`
- Lance les containers (MariaDB, WordPress, WP-CLI, phpMyAdmin)
- Installe WordPress automatiquement
- Configure Nginx + SSL (Certbot)

> **✏️ Personnalisation** : Édite `.env` avant `./deploy.sh` pour changer :
> - `WP_DOMAIN=monprojet.dev.theo-manya.fr`
> - `CERTBOT_EMAIL=manya.th@icloud.com`
> - `PMA_PORT=8080`

---

## `install-mu`

Clone le mu-plugin custom dans le projet courant.

```bash
cd ~/monprojet && install-mu
```

**Ce que ça fait :**
- Crée `./html/wp-content/mu-plugins/` si absent
- Clone `mana-wp-mu-plugin` depuis GitHub

> ⚠️ À lancer depuis la racine du projet après `make-wp`

---

## Workflow complet

```bash
# 1. Créer le projet
make-wp monprojet

# 2. Personnaliser (optionnel)
nano ~/monprojet/.env

# 3. Installer le mu-plugin
cd ~/monprojet && install-mu
```

---

## URLs

| Service    | URL                                           |
|------------|-----------------------------------------------|
| Site       | `https://<projet>.dev.theo-manya.fr`          |
| phpMyAdmin | `https://<projet>.dev.theo-manya.fr:8080`     |
| WP Admin   | `https://<projet>.dev.theo-manya.fr/wp-admin` |

---

## Supprimer un projet

```bash
cd ~ && docker compose -p monprojet down -v
rm -rf ~/monprojet
```

---

## Scripts

| Script | Emplacement | Description |
|--------|-------------|-------------|
| `make-wp.sh` | `scripts/make-wp.sh` | Crée un environnement WP complet |
| `install-mu.sh` | `scripts/install-mu.sh` | Clone le mu-plugin dans le projet |