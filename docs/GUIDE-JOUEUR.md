# Jouer à Pandemic Horizon 0.5

Prototype Windows hors ligne. Lancer `PandemicHorizon.exe` dans `build/windows-0.5.0/`. Les anciens dossiers conservent leurs versions précédentes. Pour lancer depuis les sources, consulter le README du dépôt et `docs/DEVELOPPEMENT.md`.

1. Choisir Standard ou Dégel 2042, puis une difficulté et une région de départ. Dégel impose Boréale. Lancer « Nouvelle partie ».
2. Lire les objectifs. La partie commence en pause.
3. Cliquer sur une région pour consulter sa population et ses cas actifs.
4. Reprendre avec Espace, puis acheter des évolutions lorsque les points et prérequis le permettent. Mobilité exige d'abord Diffusion. Les effets et raisons d'indisponibilité sont affichés avant achat.
5. Atteindre 90 % de population touchée avant la fin du remède. Le bilan explique le résultat et présente le journal complet.

La carte schématique présente 24 régions fictives, organisées en quatre rangées de six. Elles sont toutes visibles sans déplacement de la carte. Cliquer sur un nom ou utiliser Tab puis Entrée pour afficher ses statistiques. Le compteur de détection indique le nombre de régions repérées sur 24. Les routes du standard relient l'ensemble de la carte, quel que soit le départ choisi.

| Commande | Effet |
| --- | --- |
| Espace | Pause / reprise pendant la partie |
| 1, 2, 4 | Choisir la vitesse |
| Échap | Menu et pause de la partie |
| Tab / Maj + Tab | Parcourir les contrôles |
| Entrée | Activer le contrôle sélectionné |
| Menu → Reprendre la partie | Retrouver la partie en mémoire, en pause |
| Sauvegardes | Enregistrer ou charger une partie sur ce PC |
| Recommencer / Nouvelle partie | Abandonner la partie courante et repartir du jour zéro |

« Retirés » signifie sortis de l'état actif. Le cumul touché additionne actifs et retirés, sans compter deux fois une personne. Les traits bleus indiquent les connexions ouvertes ; une croix et des pointillés ambre signalent une route fermée. Les barres indiquent la proportion touchée par région.

## Détection et réactions

Une région est détectée lorsque les cas actifs atteignent à la fois 500 personnes et 1,5 % de sa population. Son état apparaît dans les détails. La première détection lance la recherche du remède ; chaque région détectée renforce ensuite sa progression. Chaque région réagit une seule fois par une réduction temporaire de sa croissance locale de 20 % pendant huit jours.

## Événements et routes

Le panneau « Événements actifs » affiche les effets, leur cible et les jours restants. Il permet le défilement si nécessaire. Deux événements peuvent fermer la même route : l'expiration du premier ne suffit pas à la rouvrir. Une route fermée bloque les nouveaux cas importés par cette connexion ; les cas déjà présents continuent leur progression locale.

Le standard inclut une tempête, un contrôle des transports, des mesures locales de prudence et une mobilisation accélérant la recherche. Les effets et leur fin sont annoncés dans le journal ; le bilan présente l'historique complet. Si la liste des évolutions dépasse la hauteur disponible, faire défiler le panneau ou le parcourir avec Tab.

Les points augmentent tous les cinq jours. Chaque évolution ne peut être achetée qu'une fois. Les achats trop chers sont refusés avec un message. Le plein écran se règle dans les paramètres et ce réglage est conservé sur le PC.

## Dégel 2042

| Phase | Début | Changement |
| --- | --- | --- |
| Isolement | Jour 0 | Une seule sortie ouverte depuis Boréale ; croissance froide ×0,8 |
| Ouverture | Jour 12 | Routes Boréale ↔ Centrale et Boréale ↔ Orient disponibles ; froid ×0,95 |
| Instabilité | Jour 28 | Tempêtes et inspection ; froid ×0,75 et autres régions ×0,9 |
| Mobilisation | Jour 55 | Recherche ×1,35 ; froid ×0,9 et autres régions ×0,95 |

Les températures affichées sont fictives et changent par paliers. Le multiplicateur « Climat local » indique l'effet réel sur la région sélectionnée. Les événements actifs restent prioritaires sur l'ouverture saisonnière : Boréale ↔ Centrale est fermée du jour 28 au 38 inclus, et Boréale ↔ Orient du 30 au 35 inclus.

Trois évolutions supplémentaires se trouvent dans le panneau défilant : Adaptation polaire (9 points, croissance froide ×1,25), Mobilité saisonnière (10 points, échanges saisonniers ×2) et Résilience climatique (12 points, pénalités climatiques divisées par deux). Les deux dernières exigent Adaptation polaire. Faire défiler ou utiliser Tab pour les atteindre.

## Difficultés

| Difficulté | Recherche | Seuil de détection | Score |
| --- | --- | --- | --- |
| Facile | ×0,75 | ×1,25 | ×0,8 |
| Normale | ×1 | ×1 | ×1 |
| Difficile | ×1,3 | ×0,75 | ×1,25 |

Un seuil plus bas déclenche la détection et les réactions plus tôt. Le minimum de 500 actifs reste applicable. Le remède, les réactions et le climat se combinent ; les difficultés ne modifient pas directement la croissance de base. Reprendre conserve les choix de la partie en cours ; Recommencer les réutilise, même si les sélections du menu ont changé.

## Sauvegarder et reprendre

Ouvrir « Sauvegardes » depuis le menu, la partie ou le bilan. L'écran met le jeu en pause. Trois emplacements manuels proposent « Enregistrer ici » ; chaque ligne affiche le scénario, la difficulté, le jour et la date locale d'enregistrement. Remplacer un fichier existant demande confirmation. « Charger » demande confirmation si une partie est déjà en mémoire.

La sauvegarde automatique est actualisée tous les dix jours simulés, à la fin de partie, au retour au menu depuis le jeu ou le bilan, et à la fermeture normale de l'application. Une fermeture forcée ou une coupure ne déclenche pas de sauvegarde : les changements depuis le dernier enregistrement peuvent être perdus. Une erreur d'enregistrement est signalée ; si elle survient à la fermeture, le jeu propose d'annuler ou de quitter sans sauvegarder.

Le chargement conserve régions, détections, achats, points, remède, événements, phase, journal, région sélectionnée et vitesse. La partie reprend toujours en pause, au début de la journée affichée ; le temps d'affichage fractionnaire n'est pas conservé. Une partie terminée retrouve son bilan.

Après un remplacement réussi, le fichier `.bak` contient la version précédente. Si le fichier principal manque ou est illisible, un secours valide est chargé avec un avertissement. Il peut être plus ancien. Si les deux fichiers sont invalides, la partie en mémoire est conservée. Les versions de format, données ou moteur incompatibles sont refusées sans écrasement ; aucune migration automatique n'est proposée dans ce prototype.

Les fichiers restent locaux, dans `%APPDATA%/Godot/app_userdata/Pandemic Horizon/saves/` pour le jeu distribué. Ils ne sont pas synchronisés avec GitHub. Le lancement par `dev.ps1 Play` utilise un dossier isolé sous `.tools/user/`. Le tutoriel reste à développer ; les chiffres, le contenu et le rythme restent provisoires et doivent être éprouvés avec des joueurs.
