# Point 09 — Comparaison des ordres d'achat

## Périmètre livré

Lot d'outillage J6, sur les règles et l'interface 0.8 issues de `ba5dc74`. Les spécialisations et les sauvegardes gardent leur comportement. Le numéro de version du jeu reste 0.8.0.

Le lot 08 comparait une spécialisation achetée avant Discrétion aux anciennes politiques. La contrepartie du transport, son coût et le retard de Discrétion changeaient ensemble. Le nouvel outil ajoute les trois ordres inverses pour comparer des politiques sur les mêmes scénario, difficulté, départ et graine.

- `scripts/analysis/strategy_comparison.gd` exécute les achats légaux et conserve identifiant, jour et points avant/après. Une seule tentative du premier achat manquant par journée, avant la simulation, comme dans la boucle précédente.
- Les identifiants inconnus, doublons, prérequis manquants et choix incompatibles sont refusés. Une partie sans résultat à 500 jours fait échouer la commande.
- L'appariement utilise les identités complètes et refuse doublons ou paires incomplètes. Il ne rapproche jamais deux régions ou graines différentes.
- `scripts/balance.gd` garde les anciennes politiques et ajoute `terrestre_discretion_avant`, `aerien_discretion_avant`, `maritime_discretion_avant`. Les neuf colonnes CSV précédentes sont conservées ; `purchases_json` est ajoutée.
- Le Markdown distingue A seul gagnant, B seul gagnant, deux victoires, deux défaites, acquisitions réelles et durée des doubles victoires. Synthèse et détail par départ sont produits ensemble.
- L'outil et le module d'analyse sont exclus de l'exécutable ; aucun écran du jeu n'est modifié.

## Résultats du 16 octobre 2026

Commande : `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 Balance`, Godot 4.7.2. Trois graines (7, 42, 2042), trois difficultés, 24 départs Standard et Boréale pour Dégel. **2 259 parties, 212 480 pas, 2 037 victoires, 222 défaites par remède**. Les trois nouveaux ordres ajoutent 675 parties aux 1 584 précédentes. Chaque départ/difficulté conserve une victoire observée parmi les politiques testées.

**675 paires**, 18 groupes scénario/difficulté/spécialisation et 225 groupes détaillés par départ. Le [rapport complet](../equilibrage/EQUILIBRAGE-0.8-ORDRES.md) est une copie du Markdown généré dans `build/qa/balance-comparison.md`. Le CSV détaillé reste local dans `build/qa/balance.csv` et se régénère avec la même commande.

En Standard difficile, sur 72 parties par ordre et par spécialisation :

| Choix | A : spécialisation puis Discrétion | B : Discrétion puis spécialisation | B seul gagne | Δ jours B − A, doubles victoires |
| --- | ---: | ---: | ---: | ---: |
| Terrestre | 69 victoires | 72 victoires | 3 | +2,65 |
| Aérien | 49 victoires | 66 victoires | 17 | +2,20 |
| Maritime | 47 victoires | 66 victoires | 19 | +0,38 |

A ne gagne seul dans aucune paire de cet échantillon. Tous les choix prévus sont effectivement acquis dans les 675 paires. Les six défaites restantes par choix aérien/maritime avec B concernent Pacifique et Littoral pour l'air, Pacifique et Atlantide pour la mer, sur les trois graines. Les traces confirment Diffusion au jour 10, Mobilité au jour 25, Discrétion au jour 50 et spécialisation au jour 65 pour ces défaites. La politique témoin Mobilité puis Discrétion sans spécialisation gagne ses 72 parties Standard difficiles ; le choix reste donc facultatif.

En facile et normal Standard, les deux ordres gagnent toutes les paires. Dans Dégel, toutes les paires gagnent aussi. Les doubles victoires avec B sont en moyenne plus tardives ; les valeurs sont descriptives et non une mesure de durée jouée.

## Vérifications

- Suite complète : **1 503 contrôles, zéro échec**, dont 40 tests d'analyse et leur garde d'exécution. La compatibilité 0.7 reste couverte par les références historiques.
- Les tests comparent la nouvelle exécution à une boucle indépendante conservant l'ancien ordre des commandes, sur les deux scénarios et plusieurs politiques. Résultat, jour, couverture, score, achats et points correspondent ; le rejeu est exact hors mesures de temps.
- Tests synthétiques des quatre issues appariées, du signe/dénominateur de durée, des acquisitions absentes, des doublons, des paires manquantes et des départs distincts.
- Import/export, smoke test autonome et lancement graphique réussis depuis un chemin avec espaces et accents. SHA-256 de `build/windows-0.8.0/PandemicHorizon.exe` pour cet export : `A2FE072359B0AE1BCCCD5148568B6020AF4EB9DA019D0223C359384324656EBF`.
- `git diff --check` réussi. Commit, push et résultat GitHub Actions sont confirmés dans le compte rendu de livraison. Binaires et traces restent hors de Git.

## Décision et limites

Conserver les coefficients actuels pour ce lot. L'ordre d'achat est une explication concrète d'une partie des défaites, mais les comparaisons mélangent toujours budget, calendrier, bonus et contrepartie. Trois graines ne prouvent pas l'équilibrage général ; plusieurs issues se répètent sur ces graines. Les mesures de performance ont été faites pendant d'autres contrôles et ne constituent pas un benchmark isolé. Aucun essai avec des joueurs humains ou sur un second PC n'a été effectué ici.

## Prochain lot

Préparer des objectifs facultatifs et visibles avant le départ, par exemple une couverture régionale à atteindre avant une échéance, sans remplacer la victoire principale. Définir d'abord leurs conditions, le feedback de progression et la compatibilité des sauvegardes ; limiter le premier lot à un objectif sur Standard. Les événements et routes de Dégel pourront ensuite employer le même suivi. Les tests physiques et l'essai sur un autre PC restent à organiser.
