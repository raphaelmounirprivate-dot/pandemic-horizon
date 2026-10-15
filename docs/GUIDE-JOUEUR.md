# Jouer à Pandemic Horizon 0.2

Prototype Windows hors ligne. Lancer `PandemicHorizon.exe`. Pour lancer depuis les sources, consulter le README du dépôt et `docs/DEVELOPPEMENT.md`.

1. Choisir une région de départ, puis « Nouvelle partie ».
2. Lire les objectifs. La partie commence en pause.
3. Cliquer sur une région pour consulter sa population et ses cas actifs.
4. Reprendre avec Espace, puis acheter des évolutions lorsque les points et prérequis le permettent. Mobilité exige d'abord Diffusion. Les effets et raisons d'indisponibilité sont affichés avant achat.
5. Atteindre 90 % de population touchée avant la fin du remède. Le bilan explique le résultat et présente le journal complet.

| Commande | Effet |
| --- | --- |
| Espace | Pause / reprise pendant la partie |
| 1, 2, 4 | Choisir la vitesse |
| Échap | Menu et pause de la partie |
| Tab / Maj + Tab | Parcourir les contrôles |
| Entrée | Activer le contrôle sélectionné |
| Menu → Reprendre la partie | Retrouver la partie en mémoire, en pause |
| Recommencer / Nouvelle partie | Abandonner la partie courante et repartir du jour zéro |

« Retirés » signifie sortis de l'état actif. Le cumul touché additionne actifs et retirés, sans compter deux fois une personne. Les traits bleus indiquent les connexions ouvertes ; une croix et des pointillés ambre signalent une route fermée. Les barres indiquent la proportion touchée par région.

## Détection et réactions

Une région est détectée lorsque les cas actifs atteignent à la fois 500 personnes et 1,5 % de sa population. Son état apparaît dans les détails. La première détection lance la recherche du remède ; chaque région détectée renforce ensuite sa progression. Chaque région réagit une seule fois par une réduction temporaire de sa croissance locale de 20 % pendant huit jours.

## Événements et routes

Le panneau « Événements actifs » affiche les effets, leur cible et les jours restants. Il permet le défilement si nécessaire. Deux événements peuvent fermer la même route : l'expiration du premier ne suffit pas à la rouvrir. Une route fermée bloque les nouveaux cas importés par cette connexion ; les cas déjà présents continuent leur progression locale.

Le standard inclut une tempête, un contrôle des transports, des mesures locales de prudence et une mobilisation accélérant la recherche. Les effets et leur fin sont annoncés dans le journal ; le bilan présente l'historique complet. Si la liste des évolutions dépasse la hauteur disponible, faire défiler le panneau ou le parcourir avec Tab.

Les points augmentent tous les cinq jours. Chaque évolution ne peut être achetée qu'une fois. Les achats trop chers sont refusés avec un message. Le plein écran se règle dans les paramètres et ce réglage est conservé sur le PC.

**Quitter l'application perd la partie.** Les sauvegardes, Dégel 2042, les trois difficultés et la carte finale sont encore à développer. Les chiffres et le rythme sont provisoires.
