# Décision à prendre — avenir des formats de sauvegarde

Statut : **à décider par l'auteur** (point 8 de l'[analyse du 19 octobre](06-analyse-2026-10-19.md)). Ce document propose ; il ne change ni code ni sauvegarde.

## Situation au candidat 0.23

- `save_store.gd` (252 lignes) lit sept formats : 1 à 3 pour les versions 0.7 à 0.11 (empreintes `LEGACY_*` figées et 32 fixtures dans `tests/fixtures/`), puis 4 à 7 pour les profils actuels (classique, enrichi, aléas, réactif).
- Les formats 4 à 7 n'ont **pas** de fixtures figées : ils sont validés contre l'empreinte des JSON actuels. Tout changement de règles les rend illisibles, d'où un nouveau format à chaque extension.
- Chaque format ajoute des branches dans `decode()` et des contrôles de reprise : la suite est passée de quelques centaines à plus de 6 000 contrôles, dont une bonne part de compatibilité.
- Précédent : les parties 0.6 et antérieures ne sont lisibles que par leurs exécutables archivés. Aucune sauvegarde de joueur externe n'existe à ce jour, puisqu'aucune session n'a eu lieu.

## Options

| Option | Principe | Avantages | Coûts |
| --- | --- | --- | --- |
| A. Poursuivre la chaîne | Chaque changement de règles = nouveau format + empreinte + fixtures | Aucune rupture ; méthode connue | `decode()` et les tests grossissent à chaque lot ; le point 3 (réponses de crise) créerait le format 8 |
| B. Rupture annoncée à la 1.0 | La 1.0 démarre un format unique ; les parties 0.x restent lisibles uniquement par leurs exécutables archivés (comme la 0.6) | Supprime les branches 1 à 7 et leurs fixtures du code livré ; aucun joueur externe pénalisé aujourd'hui | Un joueur 0.x devra finir sa partie avec l'ancienne version ; à annoncer dans les notes de version |
| C. Règles figées par version | La sauvegarde porte un identifiant de règles ; chaque version publiée embarque une copie figée de ses JSON (`data/rulesets/<id>/`) | Les anciennes parties restent jouables avec leurs propres règles, sans format nouveau à chaque lot | Données dupliquées dans l'exe ; le modèle doit accepter un jeu de règles injecté partout ; chantier transversal |

## Recommandation

**B à la 1.0, puis C uniquement pour les versions réellement publiées.** Tant que le jeu est un prototype sans joueurs externes, la chaîne protège surtout des parties de développement. Une rupture nette à la 1.0 allège le code livré et les tests. Ensuite, figer les règles seulement pour les versions publiées garde la promesse « une partie commencée reste jouable » sans créer un format à chaque lot interne.

En attendant la décision : ne pas créer de format 8 sans nécessité (le point 3 a été reporté après les sessions joueurs pour cette raison) et garder les fixtures historiques intactes.

## Ce qu'il faut trancher

1. Option retenue (A, B, C ou combinaison).
2. Si B : version de la rupture, texte d'annonce, archives d'exécutables à conserver.
3. Si C : périmètre (versions publiées seulement, ou chaque candidat).

## Lot 0.25 du 21 octobre 2026

Pour ce lot expérimental, l’option A est appliquée : nouveau format 8 et empreinte séparée, sans retirer les formats 1–7. Ce choix de mise en œuvre conserve les parties de l’auteur ; il ne tranche pas la politique générale de la 1.0. Reprise exacte et refus des registres invalides dans `tests/test_strategy.gd`. Aucun ancien JSON ni fixture historique modifié.
