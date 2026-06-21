"""Paramètres de configuration du backend.

Les valeurs sensibles sont lues depuis l'environnement. Un fichier
``.env`` à la racine du dossier ``backend`` est chargé au démarrage.
"""

import os
from pathlib import Path
from dotenv import load_dotenv

DOSSIER_BACKEND = Path(__file__).resolve().parent
load_dotenv(DOSSIER_BACKEND / ".env")


class Config:
    SECRET_KEY = os.getenv("SECRET_KEY", "changez-moi-en-production")

    DB_HOST = os.getenv("DB_HOST", "localhost")
    DB_PORT = int(os.getenv("DB_PORT", "3306"))
    DB_USER = os.getenv("DB_USER", "root")
    DB_PASSWORD = os.getenv("DB_PASSWORD", "")
    DB_NAME = os.getenv("DB_NAME", "lasource")

    DUREE_SESSION_JOURS = int(os.getenv("DUREE_SESSION_JOURS", "14"))

    # Dossier du frontend (la racine du dépôt). Le backend sert aussi
    # les fichiers statiques pour faciliter le développement local.
    DOSSIER_FRONTEND = DOSSIER_BACKEND.parent.resolve()
