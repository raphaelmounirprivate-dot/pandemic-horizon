# Références de sauvegarde 0.7

Ces quatre fichiers ont été générés avec le code du commit `3d89d6b`, avant les changements de la version 0.8, sous Godot 4.7.2. Ils contiennent uniquement des parties fictives créées pour les tests.

Paramètres : Boréale, graine 2042, difficulté normale, scénarios Standard et Dégel. Avant chaque journée, tenter le premier achat manquant de la liste Diffusion → Mobilité → Discrétion, avec les points normalement gagnés. Enregistrer après 56 journées ; poursuivre vingt journées sans achat et enregistrer le résultat à 76. La date est fixée à `2026-10-16T00:00:00` pour stabiliser les fichiers.

`save-0.7-*` vérifie le chargement, l'absence de réécriture à la lecture et la sauvegarde de l'original en secours. `future-0.7-*` vérifie la suite exacte de simulation, pas seulement un aller-retour du sérialiseur actuel.

Les trois empreintes autorisées correspondent au contenu 0.7 distribué et aux variantes LF/CRLF du dépôt. La version 0.8 normalise les fins de ligne avant calcul de sa propre empreinte. Cette compatibilité doit être réévaluée si les règles anciennes changent ; ne pas réécrire ces références avec une nouvelle version pour faire passer un test.

## Références 0.8

`save-0.8-*` et `future-0.8-*` ont été générés avant toute modification des règles ou du sérialiseur 0.9, avec le commit `259da07`, moteur 4.7.2, graine 2042, Boréale et difficulté normale, sur Standard et Dégel. Avant chaque pas jusqu'au jour 56, tentative du premier achat manquant dans l'ordre Diffusion, Mobilité, Réseau terrestre, Discrétion, avec les points légalement gagnés. Les états futurs correspondent à vingt pas supplémentaires sans achat, au jour 76. Date fixe : `2026-10-16T00:00:00`.

Leur véritable format 1 et empreinte 0.8 vérifient l'absence d'objectif rétroactif, la reprise exacte, l'absence d'écriture à la lecture et la conservation de l'original au premier enregistrement 0.9. Ne pas les régénérer pour contourner une régression.

## Références 0.9

Les huit fichiers `save-0.9-*` / `future-0.9-*` ont été générés avec le code `188dc64`, avant modification du catalogue ou du moteur 0.10 : format 2, Godot 4.7.2, graine 2042, Boréale, difficulté normale et date fixe `2026-10-16T00:00:00`. Standard avec Premiers relais est figé en cours au jour 35, réussi au jour 60, échoué au jour 60 ; Dégel sans objectif est figé au jour 35. Chaque futur correspond à trente pas supplémentaires.

À chaque journée, tentative du premier achat manquant dans l'ordre Diffusion, Mobilité, Discrétion, sauf le cas Standard échoué, qui ne fait aucun achat. Cet ordre continue pendant les trente journées futures. Les fichiers vérifient le suivi 0.9 conservé, l'absence de nouveau relais arctique rétroactif, la reprise exacte, la lecture sans écriture et le premier secours identique à l'original. Ne pas les régénérer avec une nouvelle version pour faire passer les tests.
