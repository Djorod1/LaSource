"""Point d'entrée du backend LaSource.

Lance un serveur Flask servant à la fois l'API JSON (préfixe ``/api``)
et le frontend statique (index.html, script.js, styles.css à la racine
du dépôt). En production, on placerait un serveur WSGI (gunicorn,
uWSGI) derrière un reverse proxy.
"""

from flask import Flask, send_from_directory, abort

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


def creer_application():
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

    @app.get("/")
    def racine():
        return send_from_directory(dossier_front, "index.html")

    @app.get("/api/sante")
    def sante():
        return {"statut": "ok"}, 200

    return app


if __name__ == "__main__":
    creer_application().run(host="0.0.0.0", port=5000, debug=True)
