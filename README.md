# LaSource

> Plateforme de mentorat pour la jeunesse. Chaque publication est
> une question, chaque réponse est un acte de mentorat.

LaSource met en relation des **étudiants en demande d'orientation**
(élèves du secondaire, étudiants du supérieur, jeunes en reconversion)
avec des **mentors expérimentés** issus de différents secteurs. La
plateforme reprend les codes des réseaux sociaux professionnels mais
avec une vocation unique : **demander conseil et y répondre**.

## Public visé

- Lycéens et étudiants en quête d'orientation
- Jeunes diplômés ou actifs en reconversion
- Professionnels souhaitant transmettre leur expérience

LaSource est volontairement **ouverte à toutes les filières, tous les
établissements et tous les pays** francophones — aucune restriction
géographique ou académique n'est codée en dur.

## Structure du dépôt

```
.
├── index.html              Page d'accueil + application connectée (SPA)
├── script.js               Logique applicative (vanilla JS)
├── styles.css              Feuille de style
│
├── backend/                Serveur d'API Python / Flask
│   ├── app.py              Point d'entrée
│   ├── config.py           Configuration (.env)
│   ├── requirements.txt
│   ├── .env.example
│   ├── models/db.py        Connexion MySQL + helpers SQL
│   ├── utils/              Auth, décorateurs, bcrypt
│   ├── routes/             Blueprints HTTP
│   │   ├── auth.py            Inscription, connexion, déconnexion
│   │   ├── profil.py          Profil étudiant et mentor
│   │   ├── questions.py       Publication, lecture, tri, marquages
│   │   ├── reponses.py        Réponses et sous-réponses
│   │   ├── mentors.py         Annuaire et système de suivi
│   │   ├── messagerie.py      Conversations privées
│   │   ├── notifications.py   Liste et marquage
│   │   ├── recherche.py       Recherche globale
│   │   └── admin.py           Tableau de bord, modération
│   └── services/
│       └── suggestions.py  Algorithme de suggestion mentors
│
└── database/
    └── schema.sql          Schéma complet MySQL + données de référence
```

## Lancer le frontend

Le frontend est statique. Ouvrir simplement `index.html` dans un
navigateur — ou le déployer sur **GitHub Pages** en activant Pages
depuis la racine du dépôt (branche par défaut, dossier `/`).

## Lancer le backend en local

### 1. Base de données

```bash
mysql -u root -p < database/schema.sql
```

Cela crée la base `lasource`, son schéma complet (15 tables + 2 vues)
et les données de référence (12 secteurs d'expertise, 17 pays
francophones).

### 2. Serveur Flask

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

cp .env.example .env
# Éditez .env : DB_PASSWORD, SECRET_KEY

python app.py
```

L'API est servie sur `http://localhost:5000`, et le serveur expose
aussi le frontend (`index.html`) sur la racine pour faciliter les
appels API en développement (même origine).

## Architecture

### Modèle de données

| Domaine                  | Tables clés                                          |
|--------------------------|------------------------------------------------------|
| Utilisateurs et profils  | `utilisateur`, `mentor_details`, `experience`        |
| Référentiels             | `secteur`, `pays`, `utilisateur_secteur`             |
| Publications             | `question`, `reponse` (arborescente)                 |
| Interactions             | `marquage_question`, `marquage_reponse`, `sauvegarde`, `suivi_mentor` |
| Modération               | `signalement`                                        |
| Messagerie               | `conversation`, `conversation_participant`, `message`|
| Notifications            | `notification`                                       |
| Authentification         | `session_web`                                        |

Deux vues SQL (`v_question_stats`, `v_mentor_carte`) regroupent les
agrégats les plus utilisés pour simplifier les requêtes côté API.

### API HTTP

| Préfixe                       | Rôle                                           |
|-------------------------------|------------------------------------------------|
| `/api/auth/*`                 | Inscription, connexion, déconnexion            |
| `/api/profil/*`               | Mon profil, profil public, référentiels        |
| `/api/questions/*`            | Fil, détail, marquage utile, sauvegarde        |
| `/api/reponses/*`             | Publication et marquage des réponses           |
| `/api/mentors/*`              | Annuaire, suivi, mes suivis                    |
| `/api/messagerie/*`           | Conversations 1-1, historique, envoi           |
| `/api/notifications/*`        | Liste, comptage non lues, marquage             |
| `/api/recherche?q=…`          | Recherche globale (mentors, questions, secteurs)|
| `/api/admin/*`                | Tableau de bord, signalements, modération      |

### Algorithme de suggestion mentors

Pour un étudiant donné, le service `services/suggestions.py` calcule
un score sur 100 pour chaque mentor candidat :

```
score = 0.55 × recouvrement_secteurs
      + 0.20 × proximite_pays
      + 0.25 × qualite_mentor   (note moyenne, bonus si vérifié)
```

## Sécurité

- Mots de passe hachés avec **bcrypt** (12 tours, salt aléatoire).
- **Politique de robustesse** : longueur minimale et mélange
  lettres/chiffres/symboles imposés à l'inscription
  (`utils/securite.py`), avec indicateur visuel côté frontend.
- **Protection contre la force brute** : au-delà de 5 échecs de
  connexion par e-mail et adresse IP sur 15 minutes, l'accès est
  temporairement bloqué (réponse HTTP 429).
- **En-têtes HTTP de sécurité** sur chaque réponse : `X-Frame-Options`,
  `X-Content-Type-Options`, `Referrer-Policy`, `Permissions-Policy`
  et une `Content-Security-Policy` restrictive.
- **Échappement systématique** de tout contenu utilisateur avant
  insertion dans le DOM côté frontend (`echapper`), pour neutraliser
  les tentatives d'injection (XSS).
- Sessions identifiées par un jeton opaque de 64 octets (table
  `session_web`), posé en cookie `HttpOnly` + `SameSite=Lax`.
- Toutes les requêtes SQL sont **paramétrées** (aucune concaténation
  de chaîne) — protection contre l'injection.
- Contrainte d'unicité sur les e-mails au niveau base.
- Rôles `etudiant` / `mentor` séparés ; `est_admin` réservé aux
  modérateurs (décorateur `admin_requis`).

## Espaces par rôle

L'application sépare clairement trois expériences :

- **Étudiant** — pose des questions, suit des mentors, sauvegarde des
  publications, consulte son profil et ses statistiques.
- **Mentor** — dispose en plus d'un **espace mentor dédié** (statut de
  vérification, statistiques d'activité, file des questions sans réponse
  dans ses secteurs d'expertise) et peut répondre aux questions.
- **Administrateur** — accède au tableau de bord de modération
  (indicateurs clés, gestion des utilisateurs, validation des mentors,
  traitement des signalements, gestion des catégories).

## Identité visuelle

Palette « source » naturelle — **teal profond `#14776A`** et
**terre cuite `#C26A3D`** sur fond parchemin — en rupture avec les
codes génériques. Typographie éditoriale DM Serif Display (titres) +
DM Sans (texte). **Aucun emoji** : l'interface repose exclusivement sur
un jeu d'icônes vectorielles en ligne (`stroke: currentColor`), pour un
rendu net et cohérent à toute taille.

## Intégration frontend ↔ backend

Le frontend (`script.js`) fonctionne **autonome** avec des données de
démonstration (mentors, questions, notifications), ce qui permet de
le déployer immédiatement sur GitHub Pages pour démonstration.

Pour le faire pointer vers le backend en environnement de production
ou de soutenance, remplacer les tableaux statiques par des appels
`fetch` vers les endpoints ci-dessus (l'API utilise les cookies de
session, aucun token à transmettre manuellement). L'ordre d'attaque
recommandé :

1. `/api/profil/referentiels` → secteurs et pays pour les sélecteurs
2. `/api/auth/connexion` → bascule `etat.utilisateur`
3. `/api/questions?tri=recent` → fil principal
4. `/api/mentors` → colonne des mentors suivis
5. `/api/notifications` → cloche
6. `/api/messagerie/conversations` → liste de discussions
