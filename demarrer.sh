#!/usr/bin/env bash
# =====================================================================
# LaSource — Script de démarrage
#
# Par défaut : SQLite local, zéro installation serveur requise.
# La base est créée et peuplée automatiquement au premier lancement.
#
# Sous-commandes :
#   ./demarrer.sh             Démarre le serveur (SQLite par défaut)
#   ./demarrer.sh installer   Crée le venv + installe les dépendances Python
#   ./demarrer.sh reset       Supprime la base SQLite et la recharge
#   ./demarrer.sh mysql       Démarre en mode MySQL (DB_TYPE=mysql)
#   ./demarrer.sh aide        Affiche cette aide
# =====================================================================

set -euo pipefail

VERT='\033[0;32m'; ROUGE='\033[0;31m'; JAUNE='\033[0;33m'; FIN='\033[0m'
ok()   { echo -e "${VERT}✓${FIN} $*"; }
err()  { echo -e "${ROUGE}✗${FIN} $*" >&2; }
info() { echo -e "${JAUNE}→${FIN} $*"; }

DOSSIER="$(cd "$(dirname "$0")" && pwd)"
cd "$DOSSIER"
VENV="$DOSSIER/.venv"
DB_FICHIER="$DOSSIER/lasource.db"

afficher_aide() {
  cat <<'AIDE'
LaSource — démarrage en quelques secondes

  ./demarrer.sh installer   (1 fois) crée le venv + installe Flask, etc.
  ./demarrer.sh             démarre le serveur sur http://localhost:5000
  ./demarrer.sh reset       supprime la base et la recrée (perte des données)
  ./demarrer.sh mysql       mode MySQL (nécessite serveur MySQL + .env configuré)
  ./demarrer.sh aide        affiche cette aide

Premier lancement (3 commandes suffisent) :
  1. ./demarrer.sh installer
  2. ./demarrer.sh
  3. Ouvrez http://localhost:5000

Comptes prêts à l'emploi (mot de passe = Source2026!) :
  demo@lasource.io                  étudiant — visite guidée
  admin@lasource.io                 administrateur
  c.assogba@upmc.fr                 mentor vérifié (tech)
  o.dossou@invest-coach.com         mentor (éducation financière)
  fadel.agbo@etu.uac.bj             étudiant lambda
AIDE
}

installer() {
  if ! command -v python3 >/dev/null; then
    err "python3 introuvable. Installez Python 3.10+."
    exit 1
  fi
  info "Création de l'environnement virtuel Python..."
  if [ ! -d "$VENV" ]; then
    python3 -m venv "$VENV"
    ok "venv créé"
  else
    info "venv déjà présent"
  fi
  info "Installation des dépendances..."
  "$VENV/bin/pip" install --quiet --upgrade pip
  "$VENV/bin/pip" install --quiet -r backend/requirements.txt
  ok "Dépendances installées"
  echo
  echo "Tout est prêt. Lancez maintenant : ./demarrer.sh"
}

reset_sqlite() {
  if [ -f "$DB_FICHIER" ]; then
    info "Suppression de la base : $DB_FICHIER"
    rm -f "$DB_FICHIER"
    ok "Base supprimée — sera recréée au prochain démarrage"
  else
    info "Aucune base à supprimer."
  fi
}

demarrer_sqlite() {
  if [ ! -d "$VENV" ]; then
    err "venv manquant. Lancez d'abord : ./demarrer.sh installer"
    exit 1
  fi

  # Copie automatique du .env.example si .env absent (config par défaut OK)
  if [ ! -f "backend/.env" ]; then
    info "Création de backend/.env (configuration par défaut SQLite)..."
    cp backend/.env.example backend/.env
    ok "backend/.env créé — la config par défaut SQLite est prête"
  fi

  echo
  echo "──────────────────────────────────────────────────────────"
  echo "  LaSource — serveur en cours de démarrage"
  echo "  → http://localhost:5000"
  echo "  Base : SQLite ($DB_FICHIER)"
  if [ ! -f "$DB_FICHIER" ]; then
    echo "  La base sera créée et peuplée automatiquement au boot"
  fi
  echo
  echo "  Compte démo : demo@lasource.io / Source2026!"
  echo "  Compte admin : admin@lasource.io / Source2026!"
  echo
  echo "  Arrêter : Ctrl+C"
  echo "──────────────────────────────────────────────────────────"
  echo
  cd "$DOSSIER/backend"
  export DB_TYPE=sqlite
  exec "$VENV/bin/python" app.py
}

demarrer_mysql() {
  if [ ! -f "backend/.env" ]; then
    err "backend/.env manquant. Copiez backend/.env.example, mettez DB_TYPE=mysql et configurez DB_PASSWORD."
    exit 1
  fi
  cd "$DOSSIER/backend"
  export DB_TYPE=mysql
  exec "$VENV/bin/python" app.py
}

case "${1:-demarrer}" in
  installer)       installer ;;
  reset|reset-db)  reset_sqlite ;;
  mysql)           demarrer_mysql ;;
  aide|--help|-h)  afficher_aide ;;
  demarrer|"")     demarrer_sqlite ;;
  *)
    err "Sous-commande inconnue : $1"
    afficher_aide; exit 1 ;;
esac
