# Exploration de l'équilibrage — version 0.4

Mesures du 15 octobre 2026, sur la carte de 24 régions, 38 connexions standards et 3 530 000 habitants fictifs. Dégel ajoute la route Boréale ↔ Orient.

## Méthode reproductible

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 Balance
```

Le script `scripts/balance.gd` joue 909 parties, sans interface : 864 dans le standard et 45 dans Dégel. Il utilise les trois difficultés et les graines 7, 42 et 2042. Le standard couvre les 24 départs ; Dégel conserve son départ imposé en Boréale.

Quatre politiques sont appliquées au standard : aucun achat ; Discrétion → Diffusion → Mobilité ; Diffusion → Discrétion → Mobilité ; Diffusion → Mobilité → Discrétion. Une cinquième s'ajoute à Dégel : Adaptation polaire → Diffusion → Discrétion → Mobilité saisonnière → Mobilité → Résilience. Le script attend les points nécessaires pour le prochain achat de la liste ; il ne distribue aucun point gratuit. Une partie est limitée à 500 jours.

Le détail de chaque partie est écrit dans `build/qa/balance.csv`, fichier généré et non versionné. Les tests de régression explorent d'autres graines et politiques, et ne sont pas additionnés à ce tableau.

## Ajustement retenu

Les coefficients de recherche du prototype à six régions (`1,3 + couverture × 0,8 + détections × 0,06`) ont produit des défaites avant couverture suffisante dans la première mesure sur la carte étendue. Un premier ajustement à `0,9 / 0,6 / 0,015` laissait 13 départs standards sans victoire observée en difficile avec ces politiques ; un second à `0,75 / 0,6 / 0,015` en laissait cinq.

Le réglage livré est **`0,6 + couverture × 0,6 + détections × 0,015`**, avant les facteurs de difficulté, scénario, événements et Discrétion. Les règles de croissance, les coûts, les points gagnés et les coefficients des trois difficultés sont conservés. Sur ce dernier passage, chaque départ autorisé et chaque difficulté ont au moins une victoire observée parmi les politiques testées.

## Résultats du dernier passage

| Scénario | Difficulté | Parties | Victoires | Défaites | Jours de simulation |
| --- | --- | --- | --- | --- | --- |
| Standard | Facile | 288 | 262 | 26 | 74 à 157 |
| Standard | Normale | 288 | 222 | 66 | 74 à 131 |
| Standard | Difficile | 288 | 216 | 72 | 75 à 119 |
| Dégel 2042 | Facile | 15 | 15 | 0 | 81 à 118 |
| Dégel 2042 | Normale | 15 | 12 | 3 | 81 à 110 |
| Dégel 2042 | Difficile | 15 | 12 | 3 | 81 à 96 |
| Total | — | 909 | 739 | 170 | 74 à 157 |

La politique sans achat gagne 46/72 parties standards en facile, 6/72 en normale et 0/72 en difficile. Dans Dégel, elle gagne 3/3 en facile et 0/3 aux deux autres difficultés. Les politiques avec les trois évolutions standards gagnent toutes les parties de cet échantillon final : le contenu actuel permet donc des stratégies fiables, sans que cela prouve une difficulté suffisante pour des joueurs expérimentés.

## Performance et limites

Dernier passage : 93 323 pas de simulation, moyenne observée **0,346 ms par pas**, maximum observé **1,347 ms** sur le poste de développement (Windows NT 10.0.26300.0, Godot 4.7.2 standard, Radeon RX 6650 XT). Cette mesure porte sur `world.step()` sans rendu ; elle ne mesure ni la fréquence d'affichage ni toutes les configurations Windows.

Ces résultats ne sont pas des taux de réussite attendus chez les joueurs. Les calendriers sont fixes, le nombre de graines reste limité et les politiques automatisées connaissent déjà les règles. Les essais humains, la variété des choix, le volume final d'évolutions/événements et la cible de durée de 15 à 30 minutes restent à travailler.
