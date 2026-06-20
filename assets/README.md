# Identité visuelle LaSource

Ce dossier contient les ressources graphiques de la marque.

## Fichiers

| Fichier | Usage |
|---|---|
| `lasource-logo.svg` | Logo complet (flamme + nom). Pour les pages d'authentification, le pied de page, les supports imprimés. |
| `lasource-flamme.svg` | Flamme seule, sans le nom. Pour les en-têtes compacts, le favicon, l'application connectée. |

## Couleurs officielles

| Rôle | Couleur | Code |
|---|---|---|
| Vert principal | Vert flamme | `#16A34A` |
| Rouge accent | Rouge flamme | `#B91C1C` |
| Noir | Noir flamme | `#1A1A1A` |
| Fond | Crème clair | `#F5F4F0` |

Ces tokens sont définis comme variables CSS dans `styles.css` :
`--vert`, `--rouge`, `--noir`, `--fond`.

## Remplacer la version SVG par votre PNG original

Si vous disposez du logo en PNG haute définition, déposez-le ici sous
les noms `lasource-logo.png` et/ou `lasource-flamme.png`, puis dans
`index.html` remplacez les références `.svg` par `.png` dans les
balises `<img>` correspondantes.

Aucune autre modification n'est nécessaire.
