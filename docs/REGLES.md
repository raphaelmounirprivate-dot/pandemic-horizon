# Règles du prototype 0.1

Ces règles sont provisoires et abstraites. Elles ne représentent aucun modèle biologique réel.

- Six régions fictives, population constante de 920 000 personnes, connexions bidirectionnelles fixes.
- 200 cas actifs au départ ; chaque personne passe de saine à active puis retirée, sans réinfection. Le cumul touché est actif + retiré.
- Une journée lit un instantané commun des six régions : échanges, progression locale, retrait, puis remède, points et fin de partie. Aucun transfert de population lors des échanges : les connexions produisent des cas locaux.
- Progression locale de base : 22 % des actifs, modulée par un tirage entre 0,92 et 1,08. Retrait : 2,5 % des actifs, au moins un lorsque des cas existent. Les entiers sont tronqués et les nouveaux cas bornés par la population saine.
- Une connexion reçoit 0,1 % des actifs de la source, au moins un, si la source compte au moins 1 000 actifs.
- Graine par défaut : 2042. L'état aléatoire est conservé dans le moteur en mémoire. Aucune sauvegarde de partie sur disque n'est encore proposée.
- 8 points au départ, puis 3 tous les cinq jours. Trois achats uniques : Diffusion (12 points, +8 points de croissance), Mobilité (10 points, échanges ×3), Discrétion (14 points, remède ×0,7). Aucun prérequis autre que les points disponibles.
- Remède à partir du jour 26 : gain quotidien de `1,6 + couverture × 0,8` points de pourcentage, avant l'effet de Discrétion.
- Victoire lorsque le cumul touché atteint 90 %. Défaite si remède à 100 % ou disparition des actifs. Priorité le même jour : remède, victoire, extinction.
- Score : `max(0, arrondi(couverture × 10 000) − jours × 10)`.
- Une journée dure 0,5 seconde à vitesse ×1 ; ×2 et ×4 exécutent les mêmes pas. Pause sans progression. La durée des parties n'est pas encore équilibrée pour la cible finale de 15 à 30 minutes.

Le prototype démarre en pause pour laisser le temps de lire et de choisir. Changer le départ ou recommencer réinitialise entièrement le monde. Le menu pendant une partie conserve le monde en mémoire ; quitter l'application le perd.
