# Point 18 — Inspirations et organisation de la suite

Date : 17 octobre 2026. Base : prototype 0.13, commit `f252baf`, branche `main`.

## Demande

Organiser les inspirations fournies en captures et les développements à réaliser dans un dossier structuré. Un point Markdown est utile pour retrouver cette décision ; la liste vivante des tâches appartient à un dossier séparé.

## Réalisation documentaire

Création de [docs/roadmap](../roadmap/README.md) : index, inspirations, six lots, vingt tâches identifiées et méthode de validation. Liens ajoutés au plan général et à l'index de suivi.

Ordre proposé : exploration de la carte ; transports et foyers ; évolutions ; événements et statistiques ; contenu/équilibrage ; finition/distribution. Premier lot conseillé : MON-01 à MON-03, zoom, déplacement et sélection de carte, candidat 0.14. Aucun développement de ce lot n'est commencé par ce point.

Les références alimentent l'ambiance et les fonctions. Les évolutions et choix restent intégrés. Le passage à des pays réels, aux décès, à plusieurs agents ou au multijoueur n'est pas décidé. Aucun asset provenant des captures n'est ajouté au jeu.

## Vérification et état

Livraison documentaire uniquement : 38 liens Markdown locaux valides, vingt identifiants de tâche uniques et `git diff --check` sans anomalie. Les fichiers modifiés sont limités à la documentation. Le code, la version, les règles et l'exécutable 0.13 ne changent pas ; leurs validations restent consignées au point 17. La suite du jeu et l'export ne sont pas relancés pour ce lot documentaire.

## Prochaine action

Préparer la fiche du lot A et développer MON-01, MON-02 et MON-03, puis vérifier la carte zoomée sans déplacer les commandes ni masquer les achats ou les choix.
