"""Outils d'authentification et de protection des routes."""

import secrets
from datetime import datetime, timedelta
from functools import wraps

import bcrypt
from flask import g, jsonify, request, current_app

from models.db import recuperer_un, executer


def hacher_mot_de_passe(mdp_clair: str) -> str:
    """Hash bcrypt (12 tours, salt aléatoire)."""
    if not mdp_clair or len(mdp_clair) < 8:
        raise ValueError("Le mot de passe doit comporter au moins 8 caractères.")
    sel = bcrypt.gensalt(rounds=12)
    return bcrypt.hashpw(mdp_clair.encode("utf-8"), sel).decode("utf-8")


def verifier_mot_de_passe(mdp_clair: str, hache: str) -> bool:
    try:
        return bcrypt.checkpw(mdp_clair.encode("utf-8"), hache.encode("utf-8"))
    except (ValueError, TypeError):
        return False


def creer_session(id_utilisateur: int, user_agent: str = None) -> str:
    """Crée un jeton de session opaque persisté en base."""
    token = secrets.token_hex(32)
    duree = current_app.config["DUREE_SESSION_JOURS"]
    expire_le = datetime.utcnow() + timedelta(days=duree)
    executer(
        """INSERT INTO session_web (id_token, id_utilisateur,
                                    expire_le, user_agent)
           VALUES (%s, %s, %s, %s)""",
        (token, id_utilisateur, expire_le, (user_agent or "")[:255]),
        commit=True,
    )
    return token


def detruire_session(token: str) -> None:
    if token:
        executer("DELETE FROM session_web WHERE id_token = %s",
                 (token,), commit=True)


def utilisateur_depuis_jeton(token):
    if not token:
        return None
    return recuperer_un(
        """SELECT u.id_utilisateur, u.prenom, u.nom, u.email,
                  u.role, u.est_admin
             FROM session_web s
             JOIN utilisateur u ON u.id_utilisateur = s.id_utilisateur
            WHERE s.id_token = %s
              AND s.expire_le > NOW()
              AND u.est_actif = 1""",
        (token,),
    )


def connexion_requise(fonction):
    """Refuse l'accès si aucun jeton de session valide n'est fourni."""

    @wraps(fonction)
    def emballe(*args, **kwargs):
        token = request.cookies.get("ls_session") \
                or request.headers.get("X-Auth-Token")
        utilisateur = utilisateur_depuis_jeton(token)
        if utilisateur is None:
            return jsonify({"erreur": "Authentification requise."}), 401
        g.utilisateur = utilisateur
        return fonction(*args, **kwargs)

    return emballe


def admin_requis(fonction):
    """Réservé aux comptes ``est_admin = TRUE``."""

    @wraps(fonction)
    @connexion_requise
    def emballe(*args, **kwargs):
        if not g.utilisateur.get("est_admin"):
            return jsonify({"erreur": "Accès réservé aux administrateurs."}), 403
        return fonction(*args, **kwargs)

    return emballe
