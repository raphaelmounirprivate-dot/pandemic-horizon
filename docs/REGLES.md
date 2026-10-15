# Règles du prototype 0.2

Ces règles sont provisoires et abstraites. Elles ne représentent aucun modèle biologique réel.

- Six régions fictives, population constante de 920 000 personnes, connexions bidirectionnelles pouvant être fermées temporairement.
- 200 cas actifs au départ ; chaque personne passe de saine à active puis retirée, sans réinfection. Le cumul touché est actif + retiré.
- Une journée expire les effets terminés, active les événements planifiés et vérifie les seuils de détection. Ensuite elle lit un instantané commun des six régions : échanges par routes ouvertes, progression locale, retrait, puis remède, points et fin de partie. Aucun transfert de population lors des échanges : les connexions produisent des cas locaux. La détection utilise les actifs de la veille, avant la progression du jour.
- Progression locale de base : 22 % des actifs, modulée par un tirage entre 0,92 et 1,08. Retrait : 2,5 % des actifs, au moins un lorsque des cas existent. Les entiers sont tronqués et les nouveaux cas bornés par la population saine.
- Une connexion reçoit 0,1 % des actifs de la source, au moins un, si la source compte au moins 1 000 actifs.
- Graine par défaut : 2042. L'état aléatoire est conservé dans le moteur en mémoire. Aucune sauvegarde de partie sur disque n'est encore proposée.
- 8 points au départ, puis 3 tous les cinq jours. Trois achats uniques définis dans `data/evolutions.json` : Diffusion (12 points, +8 points de croissance), Mobilité (10 points, échanges ×3, exige Diffusion), Discrétion (14 points, remède ×0,7). Coûts, effets et prérequis sont validés avant le lancement ; les cycles de prérequis sont refusés.
- Détection régionale lorsque les actifs atteignent au moins 500 personnes ET 1,5 % de la population régionale. Une détection reste acquise jusqu'à la fin de la partie ; elle provoque une seule réaction locale de huit jours, multipliant la croissance locale par 0,8.
- Le remède commence dès la première détection. Gain quotidien en points de pourcentage : `1,3 + couverture × 0,8 + nombre de régions détectées × 0,06`, multiplié par les modificateurs de Discrétion et des événements. La couverture est comprise entre 0 et 1. Les règles de détection et de recherche sont dans `data/events.json`.
- Victoire lorsque le cumul touché atteint 90 %. Défaite si remède à 100 % ou disparition des actifs. Priorité le même jour : remède, victoire, extinction.
- Score : `max(0, arrondi(couverture × 10 000) − jours × 10)`.
- Une journée dure 0,5 seconde à vitesse ×1 ; ×2 et ×4 exécutent les mêmes pas. Pause sans progression. La durée des parties n'est pas encore équilibrée pour la cible finale de 15 à 30 minutes.

Le prototype démarre en pause pour laisser le temps de lire et de choisir. Changer le départ ou recommencer réinitialise entièrement le monde. Le menu pendant une partie conserve le monde en mémoire ; quitter l'application le perd.

## Événements temporaires

Les événements du standard sont déterministes, à des jours fixes, et définis dans `data/events.json`. Il ne s'agit pas encore des phases climatiques de Dégel 2042.

| Événement | Jours d'application inclus | Effet |
| --- | --- | --- |
| Tempête boréale | 18 à 25 | Ferme Boréale ↔ Centrale |
| Contrôle des transports | 22 à 31 | Ferme la même route indépendamment de la tempête |
| Mesures de prudence | 35 à 41 | Croissance de Centrale ×0,65 |
| Mobilisation scientifique | 44 à 51 | Gain de remède ×1,35 |

Un effet de durée huit jours activé au jour 18 possède une borne de fin exclusive au jour 26. Le panneau indique le nombre de pas quotidiens restant avant cette expiration. La pause suspend ce compte à rebours.

Chaque cause de fermeture conserve son propre délai. La route est fermée dès qu'au moins une cause est active : elle ne se rouvre ici qu'au jour 32. Les multiplicateurs ayant la même cible se multiplient ; par exemple une réaction ×0,8 et des mesures ×0,65 donnent ×0,52. Ils sont recalculés depuis les effets actifs, sans altérer les coefficients de base. Leur expiration ne retire donc pas un autre effet encore actif.

Le journal annonce activation, conséquence, fin et rétablissement réel des routes. Les événements et réactions se déclenchent une seule fois chacun. L'état des effets est conservé en mémoire, mais aucune sérialisation sur disque n'est encore livrée.
