"""Inscription, connexion et déconnexion."""

import re

from flask import Blueprint, request, jsonify, make_response

from models.db import recuperer_un, executer, curseur
from utils.auth_helpers import (
    hacher_mot_de_passe,
    verifier_mot_de_passe,
    creer_session,
    detruire_session,
)
from utils.securite import (
    mot_de_passe_valide,
    est_bloque,
    enregistrer_echec,
    reinitialiser,
)

bp_auth = Blueprint("auth", __name__, url_prefix="/api/auth")

REGEX_EMAIL = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")
ROLES_AUTORISES = {"etudiant", "mentor"}


def _erreur(message, code=400):
    return jsonify({"erreur": message}), code


@bp_auth.post("/inscription")
def inscription():
    d = request.get_json(silent=True) or {}
    prenom = (d.get("prenom") or "").strip()
    nom    = (d.get("nom") or "").strip()
    email  = (d.get("email") or "").strip().lower()
    mdp    = d.get("mot_de_passe") or ""
    role   = d.get("role") or "etudiant"

    if not (prenom and nom):
        return _erreur("Prénom et nom obligatoires.")
    if not REGEX_EMAIL.match(email):
        return _erreur("Adresse e-mail invalide.")
    if role not in ROLES_AUTORISES:
        return _erreur("Rôle invalide (étudiant ou mentor).")
    ok, message = mot_de_passe_valide(mdp)
    if not ok:
        return _erreur(message)

    if recuperer_un("SELECT 1 FROM utilisateur WHERE email = %s LIMIT 1",
                    (email,)):
        return _erreur("Cette adresse e-mail est déjà utilisée.", 409)

    hache = hacher_mot_de_passe(mdp)
    with curseur(commit=True) as cur:
        cur.execute(
            """INSERT INTO utilisateur
                  (prenom, nom, email, mot_de_passe, role)
               VALUES (%s, %s, %s, %s, %s)""",
            (prenom, nom, email, hache, role),
        )
        id_user = cur.lastrowid
        # Les mentors ont une ligne associée pour leurs détails publics.
        if role == "mentor":
            cur.execute(
                "INSERT INTO mentor_details (id_utilisateur) VALUES (%s)",
                (id_user,),
            )

    token = creer_session(id_user, request.headers.get("User-Agent"))
    reponse = jsonify({"id_utilisateur": id_user, "role": role})
    _poser_cookie(reponse, token)
    return reponse, 201


@bp_auth.post("/connexion")
def connexion():
    d = request.get_json(silent=True) or {}
    email = (d.get("email") or "").strip().lower()
    mdp   = d.get("mot_de_passe") or ""

    if not email or not mdp:
        return _erreur("E-mail et mot de passe requis.")

    # Protection contre la force brute : clé = e-mail + adresse IP
    cle_throttle = f"{email}|{request.remote_addr}"
    reste = est_bloque(cle_throttle)
    if reste:
        minutes = max(1, reste // 60)
        return _erreur(
            f"Trop de tentatives. Réessayez dans environ {minutes} minute(s).",
            429,
        )

    user = recuperer_un(
        """SELECT id_utilisateur, mot_de_passe, role, est_actif
             FROM utilisateur WHERE email = %s""",
        (email,),
    )
    if not user or not verifier_mot_de_passe(mdp, user["mot_de_passe"]):
        enregistrer_echec(cle_throttle)
        return _erreur("Identifiants incorrects.", 401)
    if not user["est_actif"]:
        return _erreur("Compte désactivé.", 403)

    reinitialiser(cle_throttle)   # connexion réussie : on efface le compteur

    executer(
        "UPDATE utilisateur SET derniere_co = NOW() WHERE id_utilisateur = %s",
        (user["id_utilisateur"],),
        commit=True,
    )

    token = creer_session(user["id_utilisateur"],
                          request.headers.get("User-Agent"))
    reponse = jsonify({
        "id_utilisateur": user["id_utilisateur"],
        "role": user["role"],
    })
    _poser_cookie(reponse, token)
    return reponse


@bp_auth.post("/deconnexion")
def deconnexion():
    detruire_session(request.cookies.get("ls_session"))
    reponse = make_response(jsonify({"ok": True}))
    reponse.delete_cookie("ls_session", path="/")
    return reponse


def _poser_cookie(reponse, token):
    reponse.set_cookie(
        "ls_session", token,
        httponly=True,
        samesite="Lax",
        path="/",
        max_age=60 * 60 * 24 * 14,
    )
