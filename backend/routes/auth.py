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


# --- Réinitialisation de mot de passe ----------------------------------------

@bp_auth.post("/oubli-mdp")
def demander_reinitialisation():
    """Demande de réinitialisation par e-mail.

    Renvoie toujours 200 (même si l'e-mail n'existe pas) pour empêcher
    l'énumération de comptes. Un vrai message est envoyé seulement si
    le compte existe et est actif.
    """
    import secrets
    from datetime import datetime, timedelta
    from utils.email import envoyer

    d = request.get_json(silent=True) or {}
    email = (d.get("email") or "").strip().lower()
    if not REGEX_EMAIL.match(email):
        return jsonify({"ok": True})  # 200 silencieux

    user = recuperer_un(
        "SELECT id_utilisateur, prenom FROM utilisateur "
        "WHERE email = %s AND est_actif = 1",
        (email,),
    )
    if user:
        jeton = secrets.token_hex(32)
        expire_le = datetime.utcnow() + timedelta(hours=1)
        try:
            executer(
                """INSERT INTO reinitialisation_mdp
                      (id_jeton, id_utilisateur, expire_le, ip_demande)
                   VALUES (%s, %s, %s, %s)""",
                (jeton, user["id_utilisateur"], expire_le,
                 request.remote_addr),
                commit=True,
            )
            lien = (request.host_url.rstrip("/")
                    + "/reinitialiser.html?jeton=" + jeton)
            envoyer(
                email,
                "Réinitialisation de votre mot de passe LaSource",
                f"Bonjour {user['prenom']},\n\n"
                f"Voici votre lien de réinitialisation (valable 1 heure) :\n"
                f"{lien}\n\n"
                f"Si vous n'avez pas demandé cette réinitialisation, "
                f"ignorez ce message.\n\n"
                f"— L'équipe LaSource",
            )
        except Exception:
            # On reste silencieux côté client (énumération)
            pass

    return jsonify({"ok": True})


@bp_auth.post("/reinitialiser-mdp")
def reinitialiser_mdp():
    """Définit un nouveau mot de passe à partir d'un jeton valide."""
    from datetime import datetime
    from utils.securite import mot_de_passe_valide

    d = request.get_json(silent=True) or {}
    jeton = (d.get("jeton") or "").strip()
    nouveau = d.get("nouveau_mot_de_passe") or ""

    if not jeton or len(jeton) != 64:
        return _erreur("Jeton invalide.", 400)
    ok, msg = mot_de_passe_valide(nouveau)
    if not ok:
        return _erreur(msg, 400)

    ligne = recuperer_un(
        """SELECT id_utilisateur, expire_le, utilise_le
             FROM reinitialisation_mdp WHERE id_jeton = %s""",
        (jeton,),
    )
    if not ligne or ligne["utilise_le"] is not None:
        return _erreur("Jeton invalide ou déjà utilisé.", 410)
    if ligne["expire_le"] < datetime.utcnow():
        return _erreur("Jeton expiré, demandez un nouveau lien.", 410)

    hache = hacher_mot_de_passe(nouveau)
    with curseur(commit=True) as cur:
        cur.execute(
            "UPDATE utilisateur SET mot_de_passe = %s WHERE id_utilisateur = %s",
            (hache, ligne["id_utilisateur"]),
        )
        cur.execute(
            "UPDATE reinitialisation_mdp SET utilise_le = NOW() WHERE id_jeton = %s",
            (jeton,),
        )
        # Invalide toutes les autres sessions actives de l'utilisateur
        cur.execute(
            "DELETE FROM session_web WHERE id_utilisateur = %s",
            (ligne["id_utilisateur"],),
        )
    return jsonify({"ok": True})


# --- Changement de mot de passe (utilisateur connecté) -----------------------

@bp_auth.post("/changer-mdp")
def changer_mdp():
    """Permet à un utilisateur connecté de changer son mot de passe.

    Exige le mot de passe actuel pour éviter le piratage par session
    laissée ouverte.
    """
    from utils.auth_helpers import utilisateur_depuis_jeton
    from utils.securite import mot_de_passe_valide

    token = request.cookies.get("ls_session") or request.headers.get("X-Auth-Token")
    user = utilisateur_depuis_jeton(token)
    if not user:
        return _erreur("Authentification requise.", 401)

    d = request.get_json(silent=True) or {}
    actuel = d.get("mot_de_passe_actuel") or ""
    nouveau = d.get("nouveau_mot_de_passe") or ""

    ligne = recuperer_un(
        "SELECT mot_de_passe FROM utilisateur WHERE id_utilisateur = %s",
        (user["id_utilisateur"],),
    )
    if not ligne or not verifier_mot_de_passe(actuel, ligne["mot_de_passe"]):
        return _erreur("Mot de passe actuel incorrect.", 401)
    ok, msg = mot_de_passe_valide(nouveau)
    if not ok:
        return _erreur(msg, 400)

    nouveau_hache = hacher_mot_de_passe(nouveau)
    executer(
        "UPDATE utilisateur SET mot_de_passe = %s WHERE id_utilisateur = %s",
        (nouveau_hache, user["id_utilisateur"]),
        commit=True,
    )
    return jsonify({"ok": True})


def _poser_cookie(reponse, token):
    reponse.set_cookie(
        "ls_session", token,
        httponly=True,
        samesite="Lax",
        path="/",
        max_age=60 * 60 * 24 * 14,
    )
