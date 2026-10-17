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

## Références 0.10

Les huit fichiers `save-0.10-*` / `future-0.10-*` ont été générés avec le code `2505179`, avant toute modification 0.11 : format 2, empreinte `f62d5506dcce2d68eec5c590a3efaf3e7b0bf8ef4f406486451afcfd317d19db`, Godot 4.7.2, Boréale, graine 2042, difficulté normale, date fixe `2026-10-16T00:00:00`. Dégel avec Relais arctiques est figé en cours au J35, réussi au J55, échoué au J55 ; Standard sans objectif est figé au J35. Chaque futur correspond à trente pas supplémentaires.

Avant chaque pas, tentative du premier achat manquant Diffusion → Mobilité → Discrétion, sauf `arctic-failed` sans achat. La même politique continue pendant les trente jours futurs. Les tests vérifient l'absence de décision rétroactive, le suivi d'objectif conservé, la continuation exacte, la lecture sans écriture et le premier secours strictement identique au texte original. Ne pas régénérer ces références pour contourner une régression.

## Références 0.11

Les huit fichiers `save-0.11-*` / `future-0.11-*` ont été figés avec les règles du commit `8428f28`, avant toute expérience du lot 16 : format 3, contenu `4a65420bb3bcc4320c2925410f3c125ca40c4070260e55349df6328639ac93e6`, Godot 4.7.2, Boréale, Dégel, difficulté normale, graine 2042, Relais et décision activés. Soutien d'origine à 6 points, mer ×1,50 et remède ×1,15 ; date fixe `2026-10-17T00:00:00`.

Aucun achat avant le J28. `pending` est figé au J28 sans choisir ; `active` au J35 et `expired` au J45 après soutien choisi au J28 ; `neutral` au J31 après maintien choisi au J28. Après le choix ou dès le J28 pour la variante en attente, tenter avant chaque pas le premier achat manquant Diffusion → Mobilité → Discrétion. Chaque futur poursuit cette même politique trente journées, sans nouvelle décision manuelle : l'attente expire donc au J31. Les tests comparent l'état complet, le choix et les annonces, puis la lecture sans réécriture et le premier secours identique. Ces références sont des parties fictives produites avec les règles distribuées, pas avec les paramètres hypothétiques. Ne pas les régénérer pour faire passer une régression.
