"""Connexion à la base de données : SQLite par défaut, MySQL en option.

La variable d'environnement ``DB_TYPE`` choisit le backend :
  - ``sqlite`` (défaut) : fichier local ``lasource.db``, aucune
    installation serveur requise. Idéal pour le développement, les
    tests, et même la mise en ligne en charge modérée.
  - ``mysql``  : serveur MySQL classique. Activer pour la production
    haute charge ou pour respecter un cahier des charges qui l'exige.

Les requêtes SQL utilisent uniformément le paramètre ``%s`` (style
MySQL). Pour SQLite, ce paramètre est traduit en ``?`` à la volée par
la classe ``CurseurAdapte``. Aucune route n'a à se soucier du backend.
"""

import os
import re
import sqlite3
from contextlib import contextmanager
from pathlib import Path

from flask import g, current_app

# ----- Détection du backend ----------------------------------------------

def _type_db():
    return (os.getenv("DB_TYPE", "sqlite") or "sqlite").lower()


# ----- Import MySQL uniquement si nécessaire (évite la dépendance) -------

def _import_pymysql():
    import pymysql, pymysql.cursors
    return pymysql, pymysql.cursors


# ----- Conversion du dialecte « %s » → « ? » pour SQLite -----------------

_RE_PARAM = re.compile(r"%s")

def _convertir_pour_sqlite(sql):
    """Remplace les placeholders %s par ?.

    On garde une seule version des requêtes (style MySQL) dans le code
    métier. SQLite reçoit la forme avec ?.
    """
    return _RE_PARAM.sub("?", sql)


# ----- Adaptateur curseur uniforme ---------------------------------------

class CurseurAdapte:
    """Encapsule un curseur DB pour exposer une API uniforme :
    - ``execute(sql, params)`` accepte du SQL style MySQL.
    - ``fetchone()`` / ``fetchall()`` retournent des dicts.
    - ``lastrowid`` disponible quel que soit le moteur.
    """

    def __init__(self, curseur_natif, is_sqlite):
        self._cur = curseur_natif
        self._sqlite = is_sqlite

    def execute(self, sql, params=()):
        if self._sqlite:
            sql = _convertir_pour_sqlite(sql)
        # SQLite n'autorise pas execute(..., None)
        return self._cur.execute(sql, params or ())

    def executemany(self, sql, seq_params):
        if self._sqlite:
            sql = _convertir_pour_sqlite(sql)
        return self._cur.executemany(sql, seq_params)

    def fetchone(self):
        row = self._cur.fetchone()
        if row is None:
            return None
        if self._sqlite:
            # sqlite3.Row -> dict
            return {k: row[k] for k in row.keys()}
        return row

    def fetchall(self):
        rows = self._cur.fetchall()
        if self._sqlite:
            return [{k: r[k] for k in r.keys()} for r in rows]
        return rows

    @property
    def lastrowid(self):
        return self._cur.lastrowid

    @property
    def rowcount(self):
        return self._cur.rowcount

    def close(self):
        return self._cur.close()


# ----- Connexion native --------------------------------------------------

def _ouvrir_connexion():
    cfg = current_app.config
    type_db = cfg.get("DB_TYPE", _type_db())

    if type_db == "sqlite":
        chemin = Path(cfg.get("DB_PATH", "lasource.db")).resolve()
        # Crée le dossier parent si besoin
        chemin.parent.mkdir(parents=True, exist_ok=True)
        conn = sqlite3.connect(str(chemin), isolation_level="DEFERRED")
        conn.row_factory = sqlite3.Row
        # FK désactivées par défaut en SQLite : on les active explicitement
        conn.execute("PRAGMA foreign_keys = ON")
        conn.execute("PRAGMA journal_mode = WAL")  # meilleure concurrence
        return conn, True

    pymysql, _curs = _import_pymysql()
    conn = pymysql.connect(
        host=cfg["DB_HOST"],
        port=cfg["DB_PORT"],
        user=cfg["DB_USER"],
        password=cfg["DB_PASSWORD"],
        database=cfg["DB_NAME"],
        charset="utf8mb4",
        cursorclass=_curs.DictCursor,
        autocommit=False,
    )
    return conn, False


# ----- API publique ------------------------------------------------------

def obtenir_connexion():
    if "db_conn" not in g:
        g.db_conn, g.db_is_sqlite = _ouvrir_connexion()
    return g.db_conn


def fermer_connexion(_=None):
    conn = g.pop("db_conn", None)
    g.pop("db_is_sqlite", None)
    if conn is not None:
        conn.close()


@contextmanager
def curseur(commit=False):
    conn = obtenir_connexion()
    is_sqlite = g.get("db_is_sqlite", False)
    cur_natif = conn.cursor()
    cur = CurseurAdapte(cur_natif, is_sqlite)
    try:
        yield cur
        if commit:
            conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        cur.close()


def executer(sql, params=None, commit=False):
    with curseur(commit=commit) as cur:
        cur.execute(sql, params or ())
        return cur.rowcount


def recuperer_un(sql, params=None):
    with curseur() as cur:
        cur.execute(sql, params or ())
        return cur.fetchone()


def recuperer_tous(sql, params=None):
    with curseur() as cur:
        cur.execute(sql, params or ())
        return cur.fetchall()


# ----- Initialisation auto au premier lancement (SQLite uniquement) ------

def initialiser_si_necessaire(app):
    """En mode SQLite : crée le fichier DB + charge schema + seed si absent.
    En mode MySQL : ne fait rien (l'admin charge le schema manuellement)."""
    type_db = app.config.get("DB_TYPE", _type_db())
    if type_db != "sqlite":
        return

    chemin = Path(app.config.get("DB_PATH", "lasource.db")).resolve()
    if chemin.exists() and chemin.stat().st_size > 0:
        return   # déjà initialisée

    racine = Path(__file__).resolve().parent.parent.parent
    schema = racine / "database" / "schema_sqlite.sql"
    seed   = racine / "database" / "seed_sqlite.sql"
    if not schema.exists():
        return   # pas de schema SQLite disponible

    chemin.parent.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(str(chemin))
    try:
        conn.executescript(schema.read_text(encoding="utf-8"))
        if seed.exists():
            conn.executescript(seed.read_text(encoding="utf-8"))
        conn.commit()
    finally:
        conn.close()
