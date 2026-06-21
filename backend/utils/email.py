"""Service d'envoi d'e-mail simplifié.

- En développement (par défaut) : log le message dans la console.
- En production : peut être branché sur SMTP (Mailgun, Sendgrid, etc.)
  via les variables d'environnement EMAIL_* — non implémenté pour
  garder le déploiement zéro-dépendance.
"""

import logging
import os

logger = logging.getLogger("lasource.email")


def envoyer(destinataire: str, sujet: str, corps: str) -> bool:
    """Envoie un e-mail (mode dev : log uniquement).

    Retourne True quoi qu'il arrive : l'utilisateur ne doit jamais
    apprendre si l'e-mail existe vraiment (pour éviter l'énumération
    de comptes).
    """
    mode = os.getenv("EMAIL_MODE", "console").lower()
    if mode == "console":
        logger.info(
            "\n──────── E-MAIL (mode console) ────────\n"
            "À      : %s\n"
            "Sujet  : %s\n"
            "Corps  :\n%s\n"
            "───────────────────────────────────────",
            destinataire, sujet, corps,
        )
        return True

    # Hook pour SMTP futur. On échoue silencieusement plutôt que
    # de crasher si la config est incomplète.
    logger.warning("EMAIL_MODE=%s non implémenté, mail non envoyé à %s",
                   mode, destinataire)
    return False
