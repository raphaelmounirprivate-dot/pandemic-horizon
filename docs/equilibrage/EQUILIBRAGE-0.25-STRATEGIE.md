# Équilibrage stratégique 0.25 — 21 octobre 2026

## Protocole réellement exécuté

1 080 parties : trois agents × trois scénarios × deux difficultés (normale/difficile) × cinq graines (7, 42, 2042, 11113, 8675309) × trois politiques d’achat × quatre politiques de réponse. Départ Boréale sauf Centrale pour Réseaux fragiles. Aucun objectif facultatif ni décision historique. Premier achat manquant tenté chaque jour ; aucun point offert. Réponse tentée avant achat, sinon conservation gratuite. Arrêt au résultat, limite J500 : aucune partie sans résultat. Le profil stratégique ne contient pas le Double relais obligatoire du profil historique réactif.

Politiques : mobilité = Diffusion → Mobilité → Discrétion ; croissance = Diffusion → Relais locaux → Foyers persistants → Maintien régional → Discrétion ; discrétion = Discrétion → Diffusion → Relais locaux → Cadence mesurée → Délai de recherche. Il s’agit d’ordres d’achat, pas de joueurs humains.

Réponses : toujours consolider (`anchor`), toujours forcer (`surge`), toujours conserver (`observe`), ou heuristique (`context`) : consolider si remède >45 % ou couverture >65 %, forcer sinon. Les frais peuvent décaler les achats ; le rapport compare donc des politiques complètes. L’heuristique ne constitue pas un conseil optimal.

La graine 2042 a servi aux comparaisons de paramètres. Les graines 11113 et 8675309 n’étaient pas dans les grilles précédentes ; leurs résultats sont inclus dans la validation finale, sans ajustement ultérieur des coefficients. Grille finale vérifiée : 270 groupes complets, quatre réponses chacun, aucune duplication de réponse dans un groupe.

Reproduction : Godot 4.7.2, `--headless --path . --script res://scripts/analysis/balance_strategy.gd`, avec APPDATA/LOCALAPPDATA isolés comme dans `dev.ps1`. Données brutes : `build/qa/strategy-balance.json` (hors Git). Moteur : 4.7.2-stable (official). Empreinte format 8 : `9a831e6f74aa2eb1f3dd0bf2a7b7de33d1875cd0b0d2c6b992ab00d8fb0c164a`.

## Résultats

| Politique d’achat | Normale | Difficile | Total |
| --- | ---: | ---: | ---: |
| mobilite | 180/180 | 172/180 | 352/360 |
| croissance | 175/180 | 82/180 | 257/360 |
| discretion | 180/180 | 180/180 | 360/360 |

| Réponse | Victoires |
| --- | ---: |
| anchor | 257/270 |
| surge | 214/270 |
| observe | 246/270 |
| context | 252/270 |

Comparaison appariée consolidation / expansion : **43 victoires propres à consolidation, zéro propre à expansion, 214 doubles victoires, 13 doubles défaites**. Sur les seules doubles victoires, expansion termine plus tôt dans 181 cas ; gain moyen de 3,81 jours sur l’ensemble de ces 214 paires. Ces journées représentent 22,9 secondes à ×1. Ne pas confondre gain de temps, marge de remède, score et taux de victoire.

Exemple reproductible : NACRE / Standard / normale / graine 2042 / achats croissance. Consolidation : victoire J94, remède 84,93 %, couverture 91,71 %. Expansion : victoire J83, remède 97,68 %, couverture 90,75 %. L’expansion finit onze jours plus tôt mais presque sans marge. Le choix contextuel donne J84, remède 88,97 %, couverture 91,03 %. Dans Dégel difficile avec les mêmes graine et achats, consolidation gagne J75 tandis qu’expansion perd J71. Les réponses ont donc une conséquence mesurable ; aucune inversion de victoire favorable à expansion n’est démontrée par cette grille.

Les parties finissent entre J63 et J109, soit **6,3 à 10,9 minutes de simulation à ×1**, hors pauses, ou 1,575 à 2,725 minutes à ×4. Quatre à huit décisions sont enregistrées. La cible de session 15–30 minutes n’est pas validée ; une mesure humaine doit inclure lecture, achats, pauses et vitesses.

## Choix de paramètres et limites

Une première grille de 1 080 parties utilisait échanges de base ×3 et consolidation échanges ×0,6 / remède ×0,78 : 1 069 victoires, réglage trop permissif. Deux grilles hypothétiques de 486 parties chacune ont comparé le réseau de base (×1 / ×1,5 / ×2), puis la contrepartie scientifique de consolidation (×0,9 / ×0,95 / ×1) avec des échanges de consolidation ×0,2 et une expansion à remède ×1,2. Ces mondes n’ont jamais été sauvegardés comme parties jouables.

Le candidat final conserve réseau ×1,5, consolidation échanges ×0,2 / remède ×0,95, expansion remède ×1,45. Il ne s’agit pas d’un optimum calculé. Les variantes comparaient des politiques entières ; la dernière combinaison est validée par la grille finale. Archives locales : `strategy-initial.json`, `strategy-parameters-exchange.json`, `strategy-parameters.json`. Le lanceur `strategy_parameters.gd` reproduit la seconde comparaison, en mémoire.

Les trois familles peuvent gagner en normale, mais **discrétion reste dominante en taux de victoire** dans les situations mesurées. Mobilité ne détient plus le monopole des stratégies viables ; l’équilibrage global n’est pas terminé. Consolider est plus sûr en victoire, expansion privilégie la vitesse ; aucune équivalence de qualité entre réponses n’est affirmée. Il faut élargir départs et politiques, observer les décisions humaines et rechercher des contraintes où les compromis changent. Aucun essai joueur, sonore ou DPI n’est déduit de ces simulations.
