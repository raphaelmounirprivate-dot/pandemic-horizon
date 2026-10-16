# Références de sauvegarde 0.7

Ces quatre fichiers ont été générés avec le code du commit `3d89d6b`, avant les changements de la version 0.8, sous Godot 4.7.2. Ils contiennent uniquement des parties fictives créées pour les tests.

Paramètres : Boréale, graine 2042, difficulté normale, scénarios Standard et Dégel. Avant chaque journée, tenter le premier achat manquant de la liste Diffusion → Mobilité → Discrétion, avec les points normalement gagnés. Enregistrer après 56 journées ; poursuivre vingt journées sans achat et enregistrer le résultat à 76. La date est fixée à `2026-10-16T00:00:00` pour stabiliser les fichiers.

`save-0.7-*` vérifie le chargement, l'absence de réécriture à la lecture et la sauvegarde de l'original en secours. `future-0.7-*` vérifie la suite exacte de simulation, pas seulement un aller-retour du sérialiseur actuel.

Les trois empreintes autorisées correspondent au contenu 0.7 distribué et aux variantes LF/CRLF du dépôt. La version 0.8 normalise les fins de ligne avant calcul de sa propre empreinte. Cette compatibilité doit être réévaluée si les règles anciennes changent ; ne pas réécrire ces références avec une nouvelle version pour faire passer un test.
