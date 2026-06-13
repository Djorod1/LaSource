"""Routes d'administration : tableau de bord, gestion signalements."""

from flask import Blueprint, jsonify, request

from models.db import recuperer_un, recuperer_tous, executer
from utils.auth_helpers import admin_requis

bp_admin = Blueprint("admin", __name__, url_prefix="/api/admin")


@bp_admin.get("/dashboard")
@admin_requis
def dashboard():
    """Indicateurs principaux pour le tableau de bord administrateur."""

    def n(sql, params=()):
        ligne = recuperer_un(sql, params)
        return ligne["n"] if ligne else 0

    return jsonify({
        "utilisateurs":     n("SELECT COUNT(*) AS n FROM utilisateur"),
        "mentors":          n("SELECT COUNT(*) AS n FROM utilisateur WHERE role='mentor'"),
        "etudiants":        n("SELECT COUNT(*) AS n FROM utilisateur WHERE role='etudiant'"),
        "questions":        n("SELECT COUNT(*) AS n FROM question"),
        "reponses":         n("SELECT COUNT(*) AS n FROM reponse"),
        "signalements_ouverts": n(
            "SELECT COUNT(*) AS n FROM signalement WHERE statut = 'ouvert'"
        ),
        "mentors_a_verifier": n(
            """SELECT COUNT(*) AS n FROM mentor_details
                WHERE est_verifie = FALSE"""
        ),
    })


@bp_admin.get("/signalements")
@admin_requis
def signalements_ouverts():
    statut = request.args.get("statut", "ouvert")
    if statut not in ("ouvert", "traite", "rejete"):
        statut = "ouvert"
    return jsonify(recuperer_tous(
        """SELECT s.id_signalement, s.type_contenu, s.id_contenu,
                  s.motif, s.cree_le,
                  u.id_utilisateur AS id_signaleur,
                  u.prenom, u.nom
             FROM signalement s
             JOIN utilisateur u ON u.id_utilisateur = s.id_signaleur
            WHERE s.statut = %s
         ORDER BY s.cree_le DESC
            LIMIT 100""",
        (statut,),
    ))


@bp_admin.post("/signalements/<int:id_sig>")
@admin_requis
def traiter_signalement(id_sig):
    d = request.get_json(silent=True) or {}
    decision = d.get("statut")
    if decision not in ("traite", "rejete"):
        return jsonify({"erreur": "Décision invalide."}), 400
    n = executer(
        "UPDATE signalement SET statut = %s WHERE id_signalement = %s",
        (decision, id_sig), commit=True,
    )
    if not n:
        return jsonify({"erreur": "Signalement introuvable."}), 404
    return jsonify({"ok": True})


@bp_admin.post("/mentors/<int:id_mentor>/verifier")
@admin_requis
def verifier_mentor(id_mentor):
    n = executer(
        "UPDATE mentor_details SET est_verifie = TRUE WHERE id_utilisateur = %s",
        (id_mentor,), commit=True,
    )
    if not n:
        return jsonify({"erreur": "Mentor introuvable."}), 404
    return jsonify({"ok": True})


@bp_admin.post("/utilisateurs/<int:id_user>/suspendre")
@admin_requis
def suspendre(id_user):
    n = executer(
        "UPDATE utilisateur SET est_actif = FALSE WHERE id_utilisateur = %s",
        (id_user,), commit=True,
    )
    if not n:
        return jsonify({"erreur": "Utilisateur introuvable."}), 404
    return jsonify({"ok": True})
