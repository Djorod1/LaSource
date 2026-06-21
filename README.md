# LaSource

> Plateforme de mentorat pour la jeunesse. Une question, une réponse,
> un acte de mentorat.

LaSource met en relation des étudiants en demande d'orientation
(élèves du secondaire, étudiants du supérieur, jeunes en reconversion)
avec des mentors expérimentés issus de différents secteurs.

---

## Démarrage rapide (en 1 commande)

**Prérequis** : Python 3.10+, MySQL 8 (ou MariaDB 10.5+) accessible en local.

```bash
# 1. Configurer le mot de passe MySQL
cp backend/.env.example backend/.env
# (éditez backend/.env pour renseigner DB_PASSWORD)

# 2. Installer les dépendances Python (une seule fois)
./demarrer.sh installer

# 3. Charger le schéma + données de démonstration (une seule fois)
./demarrer.sh charger-db

# 4. Démarrer le serveur
./demarrer.sh
```

Ouvrez `http://localhost:5000` dans votre navigateur. Sans configuration
serveur, vous pouvez aussi ouvrir directement `index.html` : LaSource
basculera automatiquement en **mode démo** (données fictives, rien n'est
sauvegardé — bandeau d'alerte visible).

## Comptes de démonstration

| Rôle | E-mail | Mot de passe |
|---|---|---|
| Visite guidée (étudiant) | `demo@lasource.io` | `Source2026!` |
| Administrateur | `admin@lasource.io` | `Source2026!` |
| Mentor vérifié (tech) | `c.assogba@upmc.fr` | `Source2026!` |
| Mentor (éducation financière) | `o.dossou@invest-coach.com` | `Source2026!` |
| Étudiant | `fadel.agbo@etu.uac.bj` | `Source2026!` |

Le bouton **« Tester en visite guidée »** sur la page d'accueil
connecte automatiquement le compte étudiant `demo@lasource.io`.

---

## Stack technique

| Couche | Choix |
|---|---|
| Frontend | HTML / CSS / JavaScript (sans framework) |
| Backend | Python 3.11 — Flask 3 |
| Base | MySQL 8 |
| Auth | Sessions côté serveur, mots de passe bcrypt (12 tours) |

Pas de framework JS, pas d'ORM : SQL écrit à la main pour rester
proche des compétences évaluées (algèbre relationnelle / SQL,
conception de bases de données).

## Structure du dépôt

```
.
├── index.html              Application principale (SPA)
├── script.js               Logique applicative
├── api.js                  Wrapper d'appels au backend
├── styles.css              Feuille de style
├── reinitialiser.html      Page de réinitialisation de mot de passe
├── demarrer.sh             Script de démarrage en une commande
├── assets/                 Logo (placeholder à remplacer)
│
├── backend/                Serveur d'API Python / Flask
│   ├── app.py              Point d'entrée + handler global d'erreur
│   ├── config.py           Configuration (.env)
│   ├── requirements.txt
│   ├── .env.example
│   ├── models/db.py        Connexion MySQL + helpers SQL
│   ├── utils/
│   │   ├── auth_helpers.py Bcrypt, sessions, décorateurs
│   │   ├── securite.py     Politique mdp, anti-force-brute, en-têtes
│   │   ├── email.py        Service e-mail (mode dev : log console)
│   │   └── audit.py        Journalisation des actions admin
│   ├── routes/             Blueprints HTTP (43 routes)
│   │   ├── auth.py           connexion/inscription/déconnexion +
│   │   │                     oubli-mdp + reinitialiser + changer-mdp
│   │   ├── profil.py         Profil étudiant et mentor
│   │   ├── questions.py      Publication, lecture, tri, marquages
│   │   ├── reponses.py       Réponses
│   │   ├── mentors.py        Annuaire + suivi
│   │   ├── messagerie.py     Conversations privées
│   │   ├── notifications.py  Liste, comptage, marquage
│   │   ├── recherche.py      Recherche globale
│   │   └── admin.py          Tableau de bord, CRUD utilisateurs,
│   │                         CRUD secteurs, mentors à vérifier,
│   │                         signalements, journal d'audit, rôles
│   └── services/
│       └── suggestions.py    Algorithme de suggestion mentors
│
└── database/
    ├── schema.sql          Schéma complet MySQL (18 tables)
    ├── migration_v2.sql    Rôle super_admin, audit, reinit mdp
    └── seed.sql            10 mentors africains + 30 questions +
                            réponses + sauvegardes + signalement démo
```

## Endpoints API

Préfixe : `/api`

| Préfixe | Routes |
|---|---|
| `/auth/*` | inscription, connexion, déconnexion, **oubli-mdp**, **reinitialiser-mdp**, **changer-mdp** |
| `/profil/*` | moi, profil public, modifier, référentiels (secteurs+pays) |
| `/questions/*` | publier, lister, détail, supprimer, utile, sauvegarder, signaler |
| `/reponses/*` | publier, supprimer, marquer utile |
| `/mentors/*` | lister, suivre, mes suivis |
| `/messagerie/*` | conversations, messages, ouvrir |
| `/notifications/*` | lister, comptage non-lues, tout-lu |
| `/recherche` | globale (mentors + questions + secteurs) |
| `/admin/*` | dashboard, **CRUD utilisateurs**, suspendre, réactiver, supprimer, changer-rôle, **CRUD secteurs**, mentors-a-verifier, vérifier, refuser, signalements, traiter, **journal d'audit** |

## Sécurité

- Mots de passe hachés avec **bcrypt** (12 tours)
- **Politique de robustesse** des mots de passe (longueur + mélange)
- **Anti-force-brute** : 5 échecs / 15 min → 429 pendant 15 min
- **Réinitialisation de mot de passe** par jeton à durée limitée (1 h)
- **Journal d'audit** des actions admin (qui, quoi, quand, depuis quelle IP)
- En-têtes HTTP sécurisés (CSP, X-Frame-Options, nosniff…)
- Handler global d'erreur **sans fuite de stack trace**
- Échappement systématique de tout contenu utilisateur côté frontend
- Sessions par jeton opaque (64 octets) en cookie `HttpOnly` + `SameSite=Lax`
- SQL **100% paramétré** (zéro concaténation)
- Mode `DEBUG` derrière la variable d'env `FLASK_DEBUG` (jamais actif par défaut)

## Rôles disponibles

| Rôle | Capacités |
|---|---|
| `visiteur` | Consulter le fil public (lecture seule) |
| `etudiant` | + Publier questions, commenter, sauvegarder, suivre mentors |
| `mentor` | + Répondre aux questions, statut de vérification |
| `admin` | + Tableau de bord, modération, suspension, validation mentors |
| `super_admin` | + Création d'autres admins, journal d'audit complet |

Le rôle `super_admin` est attribué manuellement en base (UPDATE direct
sur `utilisateur.role`).

## Logo

Le dossier `assets/` réserve la **zone d'affichage du logo** à des
dimensions verrouillées. Déposez vos fichiers :

- `assets/lasource-logo.png` — logo complet (200 × 260 ou ratio similaire)
- `assets/lasource-flamme.png` — flamme seule (carré, pour favicon)

Sans ces fichiers, un placeholder neutre s'affiche automatiquement.
Aucune autre modification de code n'est nécessaire — la mise à
l'échelle est gérée par `object-fit: contain`, votre image ne sera
jamais déformée.

## Mode démo (sans backend)

Si le backend n'est pas démarré, le frontend bascule automatiquement en
mode démo :

- Un **bandeau rouge** en haut de la page prévient explicitement
- Les boutons fonctionnent visuellement avec des données fictives
- **Rien n'est sauvegardé** (refresh = tout perdu)

Pour une démo réelle, lancez `./demarrer.sh` (instructions ci-dessus).

## État du produit et roadmap

Voir :
- `AUDIT.md` — audit technique complet (700 lignes, 7 missions)
- `STRATEGIE.md` — vision produit et benchmark international
- `PLAN_PRODUIT.md` — roadmap 4 sprints + fichiers à modifier

## Documentation utilisateur

Pour modifier votre profil, consulter vos sauvegardes ou changer votre
mot de passe : connectez-vous, cliquez sur votre avatar en haut à
droite, puis « Mon profil » ou « Paramètres ».

Le panneau **Sécurité** dans les paramètres permet de changer son mot
de passe (le mot de passe actuel est demandé pour confirmer).
