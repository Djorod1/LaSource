# Logo LaSource — déposer ici votre fichier officiel

Cette plateforme **réserve la place** pour votre logo sans plus
tenter de le reproduire (la précédente recréation SVG s'affichait
déformée).

## Comment installer votre logo

1. Récupérez votre fichier de logo (PNG ou SVG de bonne qualité).
2. Renommez-le **exactement** `lasource-logo.png` ou `lasource-logo.svg`.
3. Déposez-le dans ce dossier `assets/` (remplace le placeholder).
4. Si vous disposez d'une version « flamme seule » (sans le nom),
   nommez-la `lasource-flamme.png` ou `lasource-flamme.svg` — elle
   sera utilisée pour le favicon et la navbar compacte.
5. Rechargez la page. Aucune autre modification n'est nécessaire.

## Pourquoi votre logo s'affichera correctement

- Le HTML réserve un **conteneur à ratio fixe** :
  - 140 × 40 px pour la navbar
  - 200 × 260 px pour les pages d'authentification
- L'image est insérée avec `object-fit: contain` :
  votre logo sera **mis à l'échelle proportionnellement**,
  jamais déformé.
- Si le fichier est absent, le placeholder neutre s'affiche
  automatiquement et la page reste lisible.

## Couleurs officielles à respecter dans votre logo

| Rôle | Couleur | Code |
|---|---|---|
| Vert principal | Vert flamme | `#16A34A` |
| Rouge accent | Rouge flamme | `#B91C1C` |
| Noir | Noir flamme | `#1A1A1A` |
| Fond | Crème clair | `#F5F4F0` |

Ces couleurs sont alignées avec celles de la plateforme
(`styles.css`, variables `--vert`, `--rouge`, `--noir`, `--fond`).

## Formats recommandés

- **Logo complet** (flamme + nom) : 200 × 260 px minimum, fond
  transparent. SVG préférable (vectoriel, parfait à toute taille).
- **Flamme seule** : 64 × 64 px minimum, fond transparent.
  Idéal en SVG.
