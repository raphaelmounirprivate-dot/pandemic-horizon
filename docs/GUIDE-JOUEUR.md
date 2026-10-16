# Jouer à Pandemic Horizon 0.10

Prototype Windows hors ligne. Lancer `PandemicHorizon.exe` dans `build/windows-0.10.0/`. Les anciens dossiers conservent leurs versions précédentes. Pour lancer depuis les sources, consulter le README du dépôt et `docs/DEVELOPPEMENT.md`.

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
| F1 | Ouvrir ou fermer l'aide, en pause |
| Échap | Menu et pause de la partie |
| Tab / Maj + Tab | Parcourir les contrôles |
| Entrée | Activer le contrôle sélectionné |
| Menu → Reprendre la partie | Retrouver la partie en mémoire, en pause |
| Sauvegardes | Enregistrer ou charger une partie sur ce PC |
| Recommencer / Nouvelle partie | Abandonner la partie courante et repartir du jour zéro |

« Retirés » signifie sortis de l'état actif. Le cumul touché additionne actifs et retirés, sans compter deux fois une personne. Les traits bleus indiquent les connexions ouvertes ; une croix et des pointillés ambre signalent une route fermée. Les barres indiquent la proportion touchée par région.

## Objectif facultatif : Premiers relais

Avant une nouvelle partie Standard, activer « Objectif facultatif : Premiers relais » au menu. Ce choix est désactivé par défaut ; Dégel propose son propre objectif décrit ci-dessous. Premiers relais demande **trois régions ayant chacune au moins 10 % de population touchée, au plus tard à la fin du jour 50**. « Touchée » compte actifs et retirés ; les mêmes trois régions ne sont pas imposées.

Le suivi sous les compteurs mondiaux indique la progression et l'échéance. Il se fige à la réussite, au jour limite ou à la fin de partie. Atteindre le seuil exactement au jour 50 réussit ; l'atteindre plus tard ne transforme pas un objectif manqué. Une fin de partie anticipée clôt le suivi. Le journal et le bilan gardent le résultat et sa date.

Cet objectif ne rapporte aucun point ni bonus de score et ne remplace pas la victoire principale à 90 %. Une réussite facultative peut accompagner une défaite principale. « Rejouer avec les mêmes choix » conserve son activation et remet son suivi à zéro. Les anciennes parties sont chargées sans objectif facultatif ; le tutoriel conserve une session distincte.

## Objectif facultatif Dégel : Relais arctiques

Avant une nouvelle partie Dégel 2042, activer « Objectif facultatif : Relais arctiques ». Après les tempêtes, atteindre **1 000 unités d'échange sur chacune des deux routes**, dans le sens sortant de Boréale : vers Orient du jour **36 au 54 inclus**, vers Centrale du jour **39 au 54 inclus**. L'inspection maintient Centrale fermée après la fin de la tempête ; seule sa dernière réouverture permet de compter.

Les unités sont les échanges abstraits calculés par les routes ouvertes, même vers une région déjà touchée. Elles ne représentent pas des personnes transportées ou le nombre de nouveaux touchés. Mobilité, les effets saisonniers et la spécialisation maritime peuvent modifier ces flux. Une autre route, le sens inverse ou un échange hors fenêtre ne compte pas.

Le suivi affiche un compteur par destination, plafonné à 1 000. Les deux doivent atteindre leur quota avant la mobilisation du jour 55 ; une réussite au jour 54 est valide. Le résultat se fige ensuite, même si les routes continuent à fonctionner. Aucun bonus de points ou de score ; l'objectif principal reste inchangé. Changer de scénario décoche le choix et demande une nouvelle activation. Rejouer conserve le choix et réinitialise les compteurs.

## Tutoriel et aide

« Tutoriel guidé », au menu, propose six exercices facultatifs avec les vrais contrôles et les vraies règles :

1. Reprendre le temps avec Espace ; une journée passe, puis le jeu se remet en pause.
2. Sélectionner Centrale pour lire ses statistiques.
3. Au jour 10, acheter Diffusion avec les points normalement gagnés et observer le prérequis de Mobilité.
4. Au jour 23, sélectionner Boréale et lire son état détecté.
5. Reprendre jusqu'au jour 26, puis jusqu'au 32 : la fin de la tempête ne suffit pas à rouvrir une route encore fermée par une inspection.
6. Ouvrir les sauvegardes d'essai, enregistrer dans un emplacement manuel puis le charger. Confirmer le chargement, puis choisir « Terminer ».

Le focus clavier suit l'action demandée ; Entrée active le contrôle et Tab permet d'explorer les autres commandes. « Continuer » se débloque après l'action réussie. Le temps avance automatiquement entre certains exercices pour montrer les événements ; les valeurs ne sont pas truquées. Certaines actions sont réservées à la partie libre.

L'entraînement conserve une partie et des fichiers séparés, dans `user://training`. Il ne remplace ni la partie en mémoire ni les sauvegardes du joueur. Les fichiers d'essai sont réinitialisés au prochain lancement du tutoriel. « Terminer », « Quitter l'entraînement » ou Échap restituent la session précédente en pause. Depuis l'aide ou les sauvegardes, un premier Échap ferme cet écran ; un second quitte l'entraînement. Fermer normalement l'application pendant l'entraînement sauvegarde la partie du joueur, si elle existe.

« Aide [F1] » est accessible au menu, en partie et au bilan. F1 fonctionne aussi depuis les paramètres et les sauvegardes. « Situation actuelle » résume le scénario, la région sélectionnée, les raisons d'indisponibilité des évolutions et les effets actifs. Le sélecteur propose également huit sujets : commandes, régions, évolutions, détection, événements, sauvegardes, Dégel et transports. Faire défiler le texte, ou le focaliser avec Tab et utiliser les flèches. F1, Échap ou « Retour » ramènent à l'écran précédent, en pause.

## Transports

Chaque liaison a un seul type : terrestre (trait plein, coefficient ×1), aérien (tirets, ×1,2) ou maritime (points, ×0,8). Les valeurs sont des paramètres fictifs du jeu. Une route fermée porte toujours des pointillés et une croix ambre, quel que soit son type.

Le détail régional affiche les liaisons ouvertes sur leur total : T pour terrestre, A pour aérien, M pour maritime. Par exemple M 0/2 signifie deux routes maritimes présentes et toutes deux fermées ; A 0/0 signifie aucune route aérienne. Dans F1 → Transports, consulter les destinations, le type, l'ouverture et le coefficient de transport actuel. Ce coefficient n'inclut pas Mobilité ni le bonus saisonnier, qui se multiplient séparément.

Le Standard subit des contrôles aériens du jour 40 au 47 inclus (échanges aériens ×0,6), puis des retards portuaires du 45 au 51 inclus (maritimes ×0,7). Dans Dégel, la congestion des ports réduit les échanges maritimes de moitié du 34 au 39 inclus. Un ralentissement ne rouvre jamais une route fermée. Les autres types de transport restent inchangés par cet événement.

## Spécialisations de transport

Après Diffusion puis Mobilité, vous pouvez choisir une seule spécialisation pour toute la partie. Ce choix est facultatif, irréversible, et ne peut être acheté qu'une fois. Les deux autres choix deviennent incompatibles, même si vous disposez de leurs points.

| Choix | Coût | Avantage sur les échanges | Contrepartie sur la vitesse du remède |
| --- | --- | --- | --- |
| Réseau terrestre | 9 pts | Terrestres ×1,8 | ×1,08, soit +8 % |
| Pont aérien | 10 pts | Aériens ×3 | ×1,18, soit +18 % |
| Logistique maritime | 10 pts | Maritimes ×2,5 | ×1,12, soit +12 % |

Le bonus ne touche que le transport choisi ; il ne rouvre aucune route. L'accélération du remède est permanente après achat et se multiplie avec Discrétion, la difficulté et les événements. Le coût retarde aussi les autres achats : une spécialisation peut être moins intéressante qu'un achat plus précoce de Discrétion.

Le panneau droit comporte six évolutions dans Standard et neuf dans Dégel. Faire défiler ou utiliser Tab/Maj + Tab : le bouton, son effet et son état sont ramenés ensemble dans le champ visible. Lire les contreparties avant Entrée. F1 → Évolutions explique les choix ; F1 → Transports indique le coefficient courant, spécialisation comprise, hors Mobilité et bonus saisonnier.

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

Les fichiers 0.7 à 0.10 restent locaux, dans `%APPDATA%/Godot/app_userdata/Pandemic Horizon/saves/transports-1/`. Les sauvegardes reconnues sont signalées, chargées en pause et vérifiées avant utilisation. Les parties 0.7/0.8 restent sans objectif ; les parties 0.9 conservent leur suivi de Premiers relais ou l'absence d'objectif dans Dégel. Relais arctiques n'est jamais ajouté rétroactivement. La lecture ne réécrit pas le fichier. Au premier enregistrement 0.10, le fichier ancien devient la copie de secours précédente ; les sauvegardes suivantes font tourner ce secours normalement. Les règles de propagation et le remède restent identiques.

Une partie enregistrée en 0.10 utilise toujours le format 2, avec une nouvelle empreinte de contenu ; elle n'est pas compatible avec les exécutables 0.7 à 0.9. Les anciennes sauvegardes 0.6 restent dans le dossier `saves/` et nécessitent leur ancien exécutable. Les versions et empreintes inconnues restent refusées, sans écrasement automatique. Les fichiers ne sont pas synchronisés avec GitHub. `dev.ps1 Play` utilise un dossier isolé sous `.tools/user/`. Le rythme et le contenu restent provisoires et doivent être éprouvés avec des joueurs.
