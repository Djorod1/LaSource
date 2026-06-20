"""Point d'entrée du backend LaSource.

Lance un serveur Flask servant à la fois l'API JSON (préfixe ``/api``)
et le frontend statique (index.html, script.js, styles.css à la racine
du dépôt). En production, on placerait un serveur WSGI (gunicorn,
uWSGI) derrière un reverse proxy.
"""

import logging
import os
import traceback

from flask import Flask, jsonify, send_from_directory
from werkzeug.exceptions import HTTPException

from config import Config
from models.db import fermer_connexion
from utils.securite import appliquer_entetes_securite

from routes.auth          import bp_auth
from routes.profil        import bp_profil
from routes.questions     import bp_questions
from routes.reponses      import bp_reponses
from routes.mentors       import bp_mentors
from routes.messagerie    import bp_messagerie
from routes.notifications import bp_notifications
from routes.recherche     import bp_recherche
from routes.admin         import bp_admin

logger = logging.getLogger("lasource")


def _configurer_logs():
    """Logs structurés : un seul flux, format compact, pas de doublon."""
    if logger.handlers:
        return
    handler = logging.StreamHandler()
    handler.setFormatter(logging.Formatter(
        "%(asctime)s [%(levelname)s] %(name)s — %(message)s",
        "%Y-%m-%d %H:%M:%S",
    ))
    logger.addHandler(handler)
    logger.setLevel(logging.INFO)


def creer_application():
    _configurer_logs()
    dossier_front = Config.DOSSIER_FRONTEND
    app = Flask(__name__,
                static_folder=str(dossier_front),
                static_url_path="")
    app.config.from_object(Config)

    for bp in (bp_auth, bp_profil, bp_questions, bp_reponses,
               bp_mentors, bp_messagerie, bp_notifications,
               bp_recherche, bp_admin):
        app.register_blueprint(bp)

    app.teardown_appcontext(fermer_connexion)
    app.after_request(appliquer_entetes_securite)

    # ---- Gestion globale des erreurs : jamais de pile en réponse client ----

    @app.errorhandler(HTTPException)
    def _erreur_http(exc):
        # 404, 405, 413... renvoyés en JSON propre
        return jsonify({"erreur": exc.description}), exc.code

    @app.errorhandler(Exception)
    def _erreur_inattendue(exc):
        # Log côté serveur (avec pile) mais réponse anonyme côté client
        logger.error("Exception non gérée : %s\n%s",
                     exc, traceback.format_exc())
        return jsonify({
            "erreur": "Une erreur interne est survenue. "
                      "Si le problème persiste, contactez l'administrateur."
        }), 500

    @app.errorhandler(404)
    def _non_trouve(_):
        return jsonify({"erreur": "Ressource introuvable."}), 404

    # ---- Service du frontend statique ----

    @app.get("/")
    def racine():
        return send_from_directory(dossier_front, "index.html")

    @app.get("/api/sante")
    def sante():
        return {"statut": "ok"}, 200

    return app


if __name__ == "__main__":
    # DEBUG dépend d'une variable d'env, jamais activé par défaut en prod
    debug = os.getenv("FLASK_DEBUG", "0") == "1"
    creer_application().run(host="0.0.0.0", port=5000, debug=debug)
