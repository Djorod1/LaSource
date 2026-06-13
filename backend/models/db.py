"""Connexion à la base de données MySQL.

L'application utilise PyMySQL et un curseur retournant des
dictionnaires pour faciliter la sérialisation JSON dans les routes.
Une connexion par requête HTTP est créée puis fermée — suffisant pour
la charge attendue, et évite les complications d'un pool global en
environnement de développement.
"""

from contextlib import contextmanager

import pymysql
import pymysql.cursors
from flask import g, current_app


def _ouvrir_connexion():
    cfg = current_app.config
    return pymysql.connect(
        host=cfg["DB_HOST"],
        port=cfg["DB_PORT"],
        user=cfg["DB_USER"],
        password=cfg["DB_PASSWORD"],
        database=cfg["DB_NAME"],
        charset="utf8mb4",
        cursorclass=pymysql.cursors.DictCursor,
        autocommit=False,
    )


def obtenir_connexion():
    """Retourne la connexion liée à la requête HTTP courante."""
    if "db_conn" not in g:
        g.db_conn = _ouvrir_connexion()
    return g.db_conn


def fermer_connexion(_=None):
    conn = g.pop("db_conn", None)
    if conn is not None:
        conn.close()


@contextmanager
def curseur(commit: bool = False):
    """Curseur prêt à l'emploi avec gestion d'erreur uniforme."""
    conn = obtenir_connexion()
    cur = conn.cursor()
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
