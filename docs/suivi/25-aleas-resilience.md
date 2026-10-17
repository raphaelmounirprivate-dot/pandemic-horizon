# Point 25 — Aléas, résilience et scénario, candidat 0.20

Date : 17 octobre 2026. Base : `74b2ebd`.

## Périmètre

Option « Aléas et résilience » désactivée par défaut sur Standard/Dégel, obligatoire dans le nouveau scénario Réseaux fragiles. Elle inclut le catalogue enrichi puis trois compétences : Liaisons de secours (10 points, exige Mobilité), Veille scientifique (11 points, exige Discrétion), Réserves régionales (9 points, exige Relais locaux). Les 21/24 compétences restent intégrées dans la grille, avec sélection, prérequis et achat explicite.

Les protections divisent respectivement par deux les pénalités de transport, accélérations du remède et pénalités de croissance des seuls aléas. Une pénalité de transport ×0,55 devient ×0,775 ; une accélération du remède ×1,35 devient ×1,175. Les effets favorables, anciens événements et fermetures sont préservés. Aucun achat n'ouvre une route fermée.

## Tirages et scénario

Huit types : tempête maritime (fermeture d'une vraie route), séisme (croissance régionale ×0,65), panne des communications aériennes (air ×0,55), mobilisation scientifique (remède ×1,35), reprise terrestre (terre ×1,35), panne de coordination de recherche (remède ×0,7), fenêtre maritime (mer ×1,4), flux régionaux rétablis (croissance ×1,25). Favorable/défavorable qualifie la diffusion, pas la catastrophe pour la population.

Douze tirages au lancement, sac de huit sans répétition, flux aléatoire indépendant de la propagation, dates ±2 jours et durées de quatre à huit jours selon le type. Graine éditable et bouton Autre, même graine au redémarrage ; calendrier futur caché, conséquences annoncées à activation avec cible et fin. Les incidents peuvent se chevaucher et utilisent le cumul/expiration existants.

Réseaux fragiles impose Centrale, incidents espacés d'environ six jours contre huit ailleurs, croissance ×0,95 jusqu'au J44, remède ×1,15 dès J45. Aucun nouvel état de population, aucune mortalité ni destruction économique simulée.

## Persistance et validation

`data/crises.json` séparé : aucun JSON historique modifié. Format 6 et `crises-0.20` liés à une empreinte comprenant les anciens profils ; reconstruction du calendrier à partir de la graine, sans tirage à la reprise. Les formats 4 et 5 restent reconnus. Les références des anciennes versions n'ont pas été régénérées.

174 contrôles ciblés : déterminisme, reprise JSON et disque, futur exact, profils historiques, corruption, validation avant mutation, prérequis, protections, cumul, double fermeture, expiration, graine/menu et commandes visibles. Suite complète finale : 3 315 contrôles réussis, zéro échec. Vingt et une captures natives exactes aux trois tailles ; revue indépendante `ship`. Exécutable autonome et démarrage graphique vérifiés ; SHA-256 : `35435016EC001A42300FA16F8CA6F15232F2ABD989C7228E3AE4377AC254A2B2`.

## Mesures et livraison

Le [rapport de 140 parties](../EQUILIBRAGE-0.20-ALEAS.md) compare cinq graines et deux difficultés. À politique mobilité identique, les aléas modifient légèrement les jours moyens dans cet échantillon, sans changer les cinq victoires par groupe. Les politiques de protection diffèrent aussi par l'ordre d'achat ; Réserves ne gagne qu'une partie Standard difficile sur cinq. Cela ne prouve ni un optimum ni un équilibrage humain. Coefficients conservés en attente d'essais joueurs.

Livraison : commit, sauvegarde bundle/sources vérifiés et archive Windows identifiée après les vérifications finales. Les anciens exports restent conservés. Essais physiques, auditifs, DPI, second PC et compréhension humaine non réalisés ; protocole TESTS-JOUEURS.md complété pour ce lot.
