"""Paramètres de configuration du backend.

DB_TYPE détermine le backend de base de données :
  - "sqlite" (défaut) : fichier local, zéro installation
  - "mysql"           : serveur MySQL classique
"""

import os
from pathlib import Path
from dotenv import load_dotenv

DOSSIER_BACKEND = Path(__file__).resolve().parent
load_dotenv(DOSSIER_BACKEND / ".env")


class Config:
    SECRET_KEY = os.getenv("SECRET_KEY", "changez-moi-en-production")

    # Backend BD
    DB_TYPE = (os.getenv("DB_TYPE", "sqlite") or "sqlite").lower()

    # SQLite — chemin du fichier (relatif au dépôt par défaut)
    DB_PATH = os.getenv(
        "DB_PATH",
        str((DOSSIER_BACKEND.parent / "lasource.db").resolve()),
    )

    # MySQL (utilisé uniquement si DB_TYPE=mysql)
    DB_HOST = os.getenv("DB_HOST", "localhost")
    DB_PORT = int(os.getenv("DB_PORT", "3306"))
    DB_USER = os.getenv("DB_USER", "root")
    DB_PASSWORD = os.getenv("DB_PASSWORD", "")
    DB_NAME = os.getenv("DB_NAME", "lasource")

    DUREE_SESSION_JOURS = int(os.getenv("DUREE_SESSION_JOURS", "14"))

    # Dossier du frontend (la racine du dépôt)
    DOSSIER_FRONTEND = DOSSIER_BACKEND.parent.resolve()
