"""Renforcement de la sécurité applicative.

Regroupe :
  - une politique de robustesse des mots de passe ;
  - une protection contre les attaques par force brute sur la connexion
    (limitation du nombre de tentatives par identifiant + adresse IP) ;
  - les en-têtes HTTP de sécurité appliqués à chaque réponse.

La mémoire des tentatives est volontairement en mémoire vive : suffisant
pour un déploiement à instance unique. Pour une mise à l'échelle
horizontale, on remplacerait ce magasin par Redis sans changer l'API.
"""

import re
import time
from threading import Lock

# --- Politique de mot de passe ------------------------------------------

LONGUEUR_MIN = 8


def mot_de_passe_valide(mdp: str):
    """Retourne (True, '') si le mot de passe respecte la politique,
    sinon (False, message d'explication)."""
    if not mdp or len(mdp) < LONGUEUR_MIN:
        return False, f"Le mot de passe doit comporter au moins {LONGUEUR_MIN} caractères."
    if mdp.isdigit() or mdp.isalpha():
        return False, "Le mot de passe doit mélanger lettres, chiffres et symboles."
    if not re.search(r"[A-Za-z]", mdp) or not re.search(r"\d", mdp):
        return False, "Le mot de passe doit contenir au moins une lettre et un chiffre."
    return True, ""


# --- Anti-force-brute ----------------------------------------------------

_MAX_TENTATIVES = 5          # échecs tolérés avant blocage
_FENETRE = 15 * 60           # fenêtre d'observation (secondes)
_DUREE_BLOCAGE = 15 * 60     # durée du blocage après dépassement (secondes)

_tentatives = {}             # clé -> liste d'horodatages d'échec
_verrou = Lock()


def _nettoyer(maintenant, horodatages):
    return [t for t in horodatages if maintenant - t < _FENETRE]


def est_bloque(cle: str) -> int:
    """Renvoie le nombre de secondes de blocage restantes (0 si non bloqué)."""
    maintenant = time.time()
    with _verrou:
        horodatages = _nettoyer(maintenant, _tentatives.get(cle, []))
        _tentatives[cle] = horodatages
        if len(horodatages) >= _MAX_TENTATIVES:
            reste = int(_DUREE_BLOCAGE - (maintenant - horodatages[-1]))
            return max(0, reste)
    return 0


def enregistrer_echec(cle: str) -> None:
    maintenant = time.time()
    with _verrou:
        horodatages = _nettoyer(maintenant, _tentatives.get(cle, []))
        horodatages.append(maintenant)
        _tentatives[cle] = horodatages


def reinitialiser(cle: str) -> None:
    """À appeler après une connexion réussie."""
    with _verrou:
        _tentatives.pop(cle, None)


# --- En-têtes HTTP de sécurité ------------------------------------------

def appliquer_entetes_securite(reponse):
    """Durcit chaque réponse contre le clickjacking, le sniffing MIME et
    les fuites de référent. La CSP autorise les polices Google et le style
    en ligne utilisé par le frontend statique."""
    reponse.headers["X-Content-Type-Options"] = "nosniff"
    reponse.headers["X-Frame-Options"] = "DENY"
    reponse.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
    reponse.headers["Permissions-Policy"] = "geolocation=(), microphone=(), camera=()"
    # Le frontend s'appuie sur des gestionnaires d'évènements en ligne
    # (onclick=...) ; 'unsafe-inline' est donc requis pour le script.
    # La CSP reste protectrice : pas de source de script externe, pas
    # d'inclusion dans une iframe, base-uri verrouillée. Étape de
    # durcissement future : externaliser les handlers pour retirer
    # 'unsafe-inline'.
    reponse.headers["Content-Security-Policy"] = (
        "default-src 'self'; "
        "img-src 'self' data:; "
        "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; "
        "font-src https://fonts.gstatic.com; "
        "script-src 'self' 'unsafe-inline'; "
        "object-src 'none'; "
        "base-uri 'self'; "
        "frame-ancestors 'none'"
    )
    return reponse
