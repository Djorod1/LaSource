#!/usr/bin/env bash
# =====================================================================
# LaSource — Script de démarrage en une commande
#
# Utilisation :
#   ./demarrer.sh            -> démarre tout (DB + backend)
#   ./demarrer.sh installer  -> installe les dépendances Python
#   ./demarrer.sh charger-db -> recharge le schéma + le seed
#   ./demarrer.sh aide       -> affiche l'aide
#
# Prérequis :
#   - Python 3.10+
#   - MySQL 8 (ou MariaDB 10.5+) accessible en local
#   - Avoir copié backend/.env.example en backend/.env et renseigné
#     DB_PASSWORD
# =====================================================================

set -euo pipefail

# ----- Couleurs (sans dépendre de tput) -----
VERT='\033[0;32m'; ROUGE='\033[0;31m'; JAUNE='\033[0;33m'; FIN='\033[0m'
ok()   { echo -e "${VERT}✓${FIN} $*"; }
err()  { echo -e "${ROUGE}✗${FIN} $*" >&2; }
info() { echo -e "${JAUNE}→${FIN} $*"; }

DOSSIER="$(cd "$(dirname "$0")" && pwd)"
cd "$DOSSIER"

VENV="$DOSSIER/.venv"
ENV_FILE="$DOSSIER/backend/.env"

# ----- Sous-commande : aide -----
afficher_aide() {
  cat <<'AIDE'
LaSource — démarrage en une commande

Sous-commandes :
  ./demarrer.sh            Démarre la base + le backend Flask
  ./demarrer.sh installer  Crée le venv et installe les dépendances Python
  ./demarrer.sh charger-db Recharge le schéma + données de démonstration
  ./demarrer.sh aide       Affiche cette aide

Au premier lancement, exécutez DANS L'ORDRE :
  1.  cp backend/.env.example backend/.env
      (puis éditez backend/.env pour renseigner DB_PASSWORD)
  2.  ./demarrer.sh installer
  3.  ./demarrer.sh charger-db
  4.  ./demarrer.sh

Une fois démarré, ouvrez :
  http://localhost:5000   (frontend + API)
  Compte démo : demo@lasource.io / Source2026!
AIDE
}

# ----- Sous-commande : installer -----
installer() {
  info "Création de l'environnement virtuel Python..."
  if [ ! -d "$VENV" ]; then
    python3 -m venv "$VENV"
    ok "venv créé dans $VENV"
  else
    info "venv déjà présent"
  fi
  info "Installation des dépendances..."
  "$VENV/bin/pip" install --quiet --upgrade pip
  "$VENV/bin/pip" install --quiet -r backend/requirements.txt
  ok "Dépendances installées"
}

# ----- Sous-commande : charger-db -----
charger_db() {
  if [ ! -f "$ENV_FILE" ]; then
    err "Fichier $ENV_FILE introuvable."
    err "Copiez d'abord : cp backend/.env.example backend/.env"
    exit 1
  fi
  set -a; . "$ENV_FILE"; set +a
  DB_HOST="${DB_HOST:-localhost}"
  DB_USER="${DB_USER:-root}"
  DB_PASSWORD="${DB_PASSWORD:-}"

  info "Chargement de schema.sql (création des tables)..."
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" < database/schema.sql
  ok "Schéma chargé"

  info "Application de migration_v2.sql (rôle super_admin, audit, mdp reset)..."
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" < database/migration_v2.sql
  ok "Migration v2 appliquée"

  info "Chargement des données de démonstration (10 mentors, 30 questions, etc.)..."
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" < database/seed.sql
  ok "Données chargées"

  echo
  echo "Comptes prêts :"
  echo "  • demo@lasource.io     / Source2026!  (étudiant — visite guidée)"
  echo "  • admin@lasource.io    / Source2026!  (administrateur)"
  echo "  • c.assogba@upmc.fr    / Source2026!  (mentor vérifié)"
  echo "  • o.dossou@invest-coach.com / Source2026!  (mentor éducation financière)"
}

# ----- Sous-commande : démarrer (par défaut) -----
demarrer() {
  if [ ! -d "$VENV" ]; then
    err "venv manquant. Exécutez d'abord : ./demarrer.sh installer"
    exit 1
  fi
  if [ ! -f "$ENV_FILE" ]; then
    err "Fichier $ENV_FILE manquant. Copiez backend/.env.example en backend/.env"
    exit 1
  fi
  info "Démarrage du backend Flask sur http://localhost:5000..."
  echo
  echo "──────────────────────────────────────────────────────────"
  echo " LaSource est en cours d'exécution."
  echo " Ouvrez votre navigateur sur : http://localhost:5000"
  echo " Compte démo : demo@lasource.io / Source2026!"
  echo " Arrêter : Ctrl+C"
  echo "──────────────────────────────────────────────────────────"
  echo
  cd "$DOSSIER/backend"
  exec "$VENV/bin/python" app.py
}

# ----- Dispatch -----
case "${1:-demarrer}" in
  installer)   installer ;;
  charger-db|chargerdb|db) charger_db ;;
  aide|--help|-h) afficher_aide ;;
  demarrer|"") demarrer ;;
  *)
    err "Sous-commande inconnue : $1"
    afficher_aide
    exit 1
    ;;
esac
