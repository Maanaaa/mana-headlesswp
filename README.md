# mana-headlesswp
# 🛠️ WP Dev Setup

Scripts pour créer et gérer des environnements WordPress Docker sur le serveur.

---

## `make-wp <projet>`

Crée un environnement WordPress complet from scratch.

```bash
make-wp monprojet
```

**Ce que ça fait :**
- Clone le repo de config Docker
- Lance les containers (MariaDB, WordPress, WP-CLI, phpMyAdmin)
- Installe WordPress automatiquement
- Configure Nginx + SSL (Certbot)


**Installation du script sur le VPS :**
```bash
cp scripts/make-wp.sh ~/bin/make-wp
chmod +x ~/bin/make-wp
```

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

**Installation du script sur le VPS :**
```bash
cp scripts/install-mu.sh ~/bin/install-mu
chmod +x ~/bin/install-mu
```

---

## Workflow complet

```bash
# 1. Créer le projet
make-wp monprojet

# 2. Installer le mu-plugin
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