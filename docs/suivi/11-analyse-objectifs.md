# Point 11 — Analyse de Premiers relais

## Lot livré

Outillage d'équilibrage à partir du prototype `0cfdcec`. Le jeu reste en **0.9.0** : aucun coefficient, objectif, écran ou format de sauvegarde n'est modifié.

`dev.ps1 BalanceObjectives` rejoue chaque combinaison Standard avec puis sans Premiers relais. Les dix politiques d'achat sont partagées avec `Balance`, sans duplication des listes. Les tentatives, coûts et points restent ceux des parties réelles ; une politique ne reçoit aucun point supplémentaire.

Les deux modes sont appariés par scénario, difficulté, départ, graine et politique. Une empreinte des champs enregistrables compare populations, recherche exacte, points, achats, événements, phase, résultat et RNG. Seuls objectif, journal et date d'enregistrement sont exclus, car le suivi ajoute ses propres annonces. Résultat, durée, couverture, score et trace d'achats sont aussi comparés explicitement. Doublons, paires manquantes, objectifs non résolus et dérives font échouer la commande.

Le CSV conserve les achats et l'état facultatif de chaque partie, ainsi que son empreinte. Le rapport sépare les quatre combinaisons objectif/victoire, les taux observés et les dates des seules réussites. Le témoin sans objectif ne compte jamais comme un échec facultatif.

## Résultats du 16 octobre 2026

Godot 4.7.2, 24 départs Standard, trois difficultés, graines 7/42/2042 et dix politiques, deux modes : **4 320 parties, 2 160 paires, 407 830 pas, aucune dérive observée**. Le [rapport complet](../EQUILIBRAGE-0.9-OBJECTIFS.md) conserve les 30 groupes difficulté/politique et les 720 groupes difficulté/départ/politique, avec moteur et empreinte des données. Les fichiers détaillés `build/qa/balance-objectives.csv` et `.md` restent locaux et se régénèrent avec la commande.

Les résultats ci-dessous portent sur les **2 160 parties avec objectif**, chacune ayant son témoin :

| Difficulté | Parties | Objectif réussi | Deux succès | Objectif seul | Victoire seule | Deux échecs |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Facile | 720 | 695 | 692 | 3 | 13 | 12 |
| Normale | 720 | 694 | 648 | 46 | 6 | 20 |
| Difficile | 720 | 694 | 579 | 115 | 6 | 20 |
| Total | 2 160 | 2 083 | 1 919 | 164 | 25 | 52 |

Soit **96,4 %** de réussite facultative dans cet échantillon. Les réussites arrivent entre les jours **36 et 50**, au jour **40,02** en moyenne. Les 77 échecs facultatifs sont exclus de cette moyenne.

La politique Mobilité (Diffusion → Mobilité → Discrétion) et les six politiques avec spécialisation réussissent l'objectif dans toutes leurs combinaisons testées. Les échecs concernent l'attente sans achat (59), Discrétion → Diffusion → Mobilité (9), et Diffusion → Discrétion → Mobilité (9). Boréale compte 21 réussites sur 30 politiques/graines dans chaque difficulté ; les trois graines des deux derniers ordres y manquent aussi l'échéance, en plus des trois parties sans achat. Chaque départ/difficulté dispose néanmoins d'une réussite parmi les politiques testées.

En difficile, le taux facultatif reste élevé alors que 115 réussites accompagnent une défaite principale. L'objectif ne constitue donc pas une mesure de maîtrise de la partie complète. Dans les 648 parties des trois politiques avec Discrétion avant spécialisation, cette dernière est achetée après la résolution de l'objectif ; celui-ci distingue surtout les premiers achats et les départs, et non toutes les décisions de spécialisation.

## Vérifications

- Suite complète : **1 640 contrôles, zéro échec**, dont **53 contrôles ciblés** du nouveau comparateur et une garde d'exécution.
- Paires réelles sur plusieurs départs, difficultés et politiques ; politiques communes conservées, copies indépendantes et erreurs de choix propagées.
- Matrice synthétique des quatre combinaisons ; taux et moyennes avec leurs bons dénominateurs ; absence de date inventée sans réussite.
- Refus des doublons, témoins manquants, identités différentes, empreintes ou résultats divergents, modifications de durée/couverture/score/achats, états en cours, dates futures et réussites tardives.
- Import/export et exécutable autonome vérifiés : réussite/échec de l'objectif, persistance, Standard/Dégel, tutoriel, aide et lancement graphique depuis un chemin avec espaces et accents. Export local : `build/windows-0.9.0/PandemicHorizon.exe`, SHA-256 `6C8FC7AA7E51146B4ABECFB70214651EB6DCB57AE1EAEC55948F70D2870AE17F`.
- Les outils et modules d'analyse sont exclus de l'exécutable. Aucun changement visuel ne nécessite une nouvelle revue d'interface. Binaires et traces restent hors Git.
- `git diff --check` réussi. Le compte rendu de livraison confirme le commit, le push et GitHub Actions.

## Décision et limites

Conserver l'échéance de jour 50 et les coefficients actuels. Premiers relais sert d'objectif facultatif d'introduction dans cet échantillon ; une réussite ne garantit pas la victoire principale. Les observations pondèrent également les dix politiques, pas les habitudes de joueurs réels. Les trois graines ne rendent pas toutes ces observations indépendantes et plusieurs résultats se répètent. Aucun essai avec de nouveaux joueurs ou sur un second PC n'a été effectué ; aucun temps de simulation n'est présenté comme benchmark isolé.

## Prochaine action

Préparer un objectif facultatif Dégel lié à une phase ou aux routes saisonnières, pour demander une adaptation distincte de la simple couverture précoce. Définir les conditions visibles et vérifier d'abord les trajectoires possibles. Avant toute modification du catalogue d'objectifs, figer des références 0.9 et définir la compatibilité du format 2 ; conserver les anciennes parties sans activation rétroactive. Les essais physiques Windows et l'observation de joueurs restent à organiser.
