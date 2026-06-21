# LaSource

> Plateforme de mentorat pour la jeunesse.
> Une question, une réponse, un acte de mentorat.

LaSource met en relation des étudiants en demande d'orientation
avec des mentors expérimentés. **Plus de mode démo** : tout est
réel, persistant et prêt à être mis en ligne.

---

## Démarrage en 3 commandes

**Prérequis** : Python 3.10+. **Aucune installation MySQL nécessaire.**

```bash
./demarrer.sh installer   # 1 fois : crée le venv + installe Flask
./demarrer.sh             # démarre le serveur sur http://localhost:5000
# Ouvrez http://localhost:5000 dans votre navigateur
```

Au tout premier lancement, **la base SQLite est créée automatiquement**
avec 15 utilisateurs, 10 questions et 14 réponses prêtes à explorer.
Aucun script à lancer manuellement.

## Comptes prêts à l'emploi

Tous avec le mot de passe **`Source2026!`** :

| Rôle | E-mail |
|---|---|
| Étudiant (visite guidée) | `demo@lasource.io` |
| Administrateur | `admin@lasource.io` |
| Mentor vérifié (tech) | `c.assogba@upmc.fr` |
| Mentor (éducation financière) | `o.dossou@invest-coach.com` |
| Étudiant lambda | `fadel.agbo@etu.uac.bj` |

Le bouton **« Tester en visite guidée »** sur la page d'accueil connecte
directement le compte démo.

---

## Authentification : e-mail, Google, LinkedIn

LaSource propose trois moyens de se connecter :

1. **E-mail + mot de passe** — toujours disponible
2. **Google** (optionnel) — activé via `GOOGLE_CLIENT_ID`
3. **LinkedIn** (optionnel) — activé via `LINKEDIN_CLIENT_ID/SECRET`

Si Google ou LinkedIn n'est pas configuré, le bouton correspondant est
automatiquement masqué côté frontend (UX honnête, pas de bouton mort).

### Configurer Google Sign-In

1. Allez sur [console.cloud.google.com](https://console.cloud.google.com/)
2. Créez un projet, puis **APIs & Services → Identifiants → Créer un ID client OAuth 2.0**
3. Type d'application : **Application Web**
4. Origines JavaScript autorisées : `http://localhost:5000` (dev) +
   `https://votredomaine.com` (prod)
5. Copiez le Client ID dans `backend/.env` → `GOOGLE_CLIENT_ID=`
6. Redémarrez : `./demarrer.sh`

### Configurer LinkedIn Sign-In

1. Allez sur [linkedin.com/developers/apps](https://www.linkedin.com/developers/apps)
2. Créez une app, activez **Sign In with LinkedIn using OpenID Connect**
3. Onglet **Auth** → ajoutez les URLs de redirection :
   - `http://localhost:5000/api/auth/linkedin/callback` (dev)
   - `https://votredomaine.com/api/auth/linkedin/callback` (prod)
4. Reportez `Client ID`, `Client Secret` et l'URI de redirection dans `backend/.env`
5. Redémarrez

### Vérification d'adresse e-mail

À l'inscription par e-mail, un message de vérification est envoyé
(visible dans la sortie console du serveur en dev).

Pour **rendre la vérification obligatoire** (compte inutilisable tant
que l'e-mail n'est pas confirmé) :

```env
VERIFICATION_EMAIL_OBLIGATOIRE=1
```

Le comportement par défaut (`=0`) laisse l'utilisateur se connecter
immédiatement après inscription, tout en envoyant le mail.

### Mot de passe oublié

Page `/reinitialiser.html?jeton=...` reçue par e-mail. Le jeton est
valable 1 heure et invalide toutes les sessions actives au changement.

---

## Mise en ligne (production)

Le projet est prêt pour être déployé.

### Option A — SQLite (le plus simple)

Conserve la configuration par défaut. Convient à un déploiement à
charge modérée (centaines à quelques milliers d'utilisateurs).
Recommandé pour un MVP en production.

```bash
# Sur le serveur
git clone <votre-repo> lasource
cd lasource
./demarrer.sh installer

# Lancement avec gunicorn (production)
.venv/bin/pip install gunicorn
cd backend
DB_TYPE=sqlite gunicorn -w 4 -b 0.0.0.0:8000 'app:creer_application()'
```

Mettez un reverse proxy (nginx) devant pour le HTTPS.

### Option B — MySQL (charge élevée / conformité brief IFRI)

Pour des dizaines de milliers d'utilisateurs ou si votre cahier des
charges exige un SGBD client-serveur.

```bash
# 1. Configurer
cp backend/.env.example backend/.env
# Éditez backend/.env :
#   DB_TYPE=mysql
#   DB_PASSWORD=<votre_mot_de_passe>

# 2. Initialiser le schéma + seed (1 fois)
mysql -u root -p < database/schema.sql
mysql -u root -p < database/migration_v2.sql
mysql -u root -p < database/seed.sql

# 3. Démarrer
./demarrer.sh mysql
```

### Variables d'environnement importantes

| Variable | Défaut | Effet |
|---|---|---|
| `DB_TYPE` | `sqlite` | `sqlite` ou `mysql` |
| `DB_PATH` | `./lasource.db` | Chemin du fichier SQLite |
| `SECRET_KEY` | non sécurisé par défaut | **À changer en production** |
| `FLASK_DEBUG` | `0` | `1` pour activer le debug (jamais en prod) |
| `EMAIL_MODE` | `console` | `console` (log) ; SMTP à implémenter |

---

## Stack technique

| Couche | Choix |
|---|---|
| Frontend | HTML / CSS / JavaScript (sans framework) |
| Backend | Python 3.10+ — Flask 3 |
| Base | **SQLite par défaut**, MySQL en option (`DB_TYPE=mysql`) |
| Auth | Sessions côté serveur, mots de passe bcrypt (12 tours) |

SQL écrit à la main (pas d'ORM) pour rester proche des compétences
évaluées (algèbre relationnelle / SQL, conception de bases).

## Structure

```
.
├── index.html                Application principale (SPA)
├── reinitialiser.html        Page de réinitialisation de mot de passe
├── script.js                 Logique applicative
├── api.js                    Wrapper d'appels au backend
├── styles.css                Feuille de style
├── demarrer.sh               Script de démarrage
├── assets/                   Logo (placeholder à remplacer)
│
├── backend/                  Serveur Flask
│   ├── app.py                Point d'entrée + handler global d'erreur
│   ├── config.py             Configuration (.env)
│   ├── requirements.txt      Flask, bcrypt, python-dotenv
│   ├── .env.example
│   ├── models/db.py          Connexion uniforme SQLite/MySQL
│   ├── utils/
│   │   ├── auth_helpers.py     bcrypt, sessions, décorateurs
│   │   ├── securite.py         politique mdp, anti-force-brute, en-têtes
│   │   ├── email.py            service email (mode dev = log console)
│   │   └── audit.py            journalisation actions admin
│   ├── routes/               43 routes HTTP
│   │   ├── auth.py             inscription, connexion, déconnexion,
│   │   │                       oubli-mdp, reinitialiser-mdp, changer-mdp
│   │   ├── profil.py           profil étudiant et mentor
│   │   ├── questions.py        publier, lister, marquages
│   │   ├── reponses.py         réponses
│   │   ├── mentors.py          annuaire + suivi
│   │   ├── messagerie.py       conversations privées
│   │   ├── notifications.py    liste, marquage
│   │   ├── recherche.py        recherche globale
│   │   └── admin.py            tableau de bord, CRUD users/secteurs,
│   │                           mentors à vérifier, signalements, audit
│   └── services/
│       └── suggestions.py      algorithme de suggestion mentors
│
└── database/
    ├── schema_sqlite.sql       Schéma SQLite (chargé auto au 1er boot)
    ├── seed_sqlite.sql         Données de démonstration SQLite
    ├── schema.sql              Schéma MySQL (option production)
    ├── migration_v2.sql        Migration v2 pour MySQL
    └── seed.sql                Données de démo MySQL
```

## Sécurité

- Mots de passe hachés avec **bcrypt** (12 tours)
- Politique de robustesse des mots de passe
- **Anti-force-brute** : 5 échecs / 15 min → 429 pendant 15 min
- **Réinitialisation de mot de passe** par jeton 1h
- **Journal d'audit** des actions admin (qui, quoi, quand, IP)
- En-têtes HTTP sécurisés (CSP, X-Frame-Options, nosniff…)
- Handler global d'erreur **sans fuite de stack trace**
- Échappement systématique de tout contenu utilisateur
- Sessions par jeton opaque (64 octets) en cookie HttpOnly + SameSite=Lax
- SQL **100% paramétré** (zéro concaténation)
- `DEBUG` derrière `FLASK_DEBUG` env var (jamais actif par défaut)
- **PRAGMA foreign_keys = ON** + **WAL mode** pour SQLite

## Rôles

| Rôle | Capacités |
|---|---|
| `visiteur` | Consulter le fil public |
| `etudiant` | + Publier questions, commenter, sauvegarder, suivre mentors |
| `mentor` | + Répondre aux questions, statut de vérification |
| `admin` | + Modération, suspension, validation mentors |
| `super_admin` | + Création d'autres admins, journal d'audit complet |

## Logo

Déposez `assets/lasource-logo.png` (logo complet) et
`assets/lasource-flamme.png` (flamme seule). Un placeholder neutre
s'affiche tant qu'ils sont absents. Mise à l'échelle
proportionnelle garantie (`object-fit: contain`).

## Documentation produit

- `AUDIT.md` — audit technique complet (700 lignes)
- `STRATEGIE.md` — vision et benchmark international
- `PLAN_PRODUIT.md` — roadmap 4 sprints
