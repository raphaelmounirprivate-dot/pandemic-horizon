# Point 13 — Stratégies climatiques précoces

## Livré

Lot d'analyse à partir de `8a29970`, sans changement des règles, de l'interface ou du format de sauvegarde. Le jeu reste en **0.10.0**.

`dev.ps1 BalanceArctic` mesure les onze politiques historiques et quatre nouveaux ordres climatiques, définis dans `scripts/analysis/arctic_analysis.gd`. Le comparateur commun accepte maintenant le type d'objectif et les politiques autorisées ; ses contrôles historiques Standard restent testés. Pour Dégel, il valide aussi compteurs, fenêtres, quotas et résolution avant de comparer les témoins.

Le rapport fournit les quatre combinaisons objectif/victoire, les dates des seules réussites et les achats réels : acquis, acquis au plus tard à J54, dates min–max. Un achat après l'échéance reste distingué d'un achat jamais effectué. Les outils sont exclus de l'exécutable.

## Mesures du 16 octobre 2026

Godot 4.7.2, Boréale, trois difficultés, graines 7/42/2042, quinze politiques, deux modes : **270 parties, 135 paires sans dérive observée, 23 822 pas**. Les empreintes excluent objectif, journal et date d'enregistrement ; résultat, durée, couverture, score et achats sont aussi comparés explicitement. Le rapport conserve moteur, empreinte du contenu et ordres utilisés.

Sur les **135 parties avec objectif** :

| Résultat | Parties |
| --- | ---: |
| Objectif et victoire principale | 112 |
| Objectif seul | 5 |
| Victoire principale seule | 12 |
| Deux échecs | 6 |

**117 réussites facultatives, soit 86,7 %**, entre J42 et J53, moyenne J47 sur les seules réussites. Les quatre nouveaux ordres réussissent l'objectif dans leurs 36 cas, mais ne gagnent la partie principale que dans 31 cas.

| Ordre | Réussites de l'objectif | Victoires principales | Jour de réussite | Mobilité saisonnière acquise |
| --- | ---: | ---: | ---: | ---: |
| Polaire historique | 0/9 | 9/9 | — | J65 |
| Polaire → Saisonnière → Diffusion → Mobilité → Discrétion | 9/9 | 9/9 | 48 | J20 |
| Polaire → Diffusion → Saisonnière → Mobilité → Discrétion | 9/9 | 7/9 | 49 | J40 |
| Polaire → Résilience → Saisonnière → Diffusion → Mobilité → Discrétion | 9/9 | 6/9 | 49 | J40 |
| Polaire → Saisonnière → Discrétion → Diffusion → Mobilité | 9/9 | 9/9 | 48 | J20 |

Polaire historique achète Discrétion à J45 puis Mobilité saisonnière à J65, après la fenêtre de l'objectif. Dans l'ordre avec Résilience précoce, Diffusion arrive à J60 et Discrétion n'est jamais acquise avant la fin des parties observées. Cela montre l'intérêt de distinguer absence, retard et achat à temps.

Les cinq défaites nouvelles sont toutes en difficile : deux pour `polaire_diffusion` (graines 7 et 2042), trois pour `resilience_precoce`. Elles accompagnent toutes une réussite facultative. L'ordre d'achat change simultanément budget, dates et effets : ces observations ne prouvent pas l'effet causal isolé d'une évolution.

Le [rapport complet](../equilibrage/EQUILIBRAGE-0.10-CLIMATIQUE.md) conserve 45 groupes difficulté/politique et 270 lignes de dates d'achat. Les fichiers `build/qa/balance-arctic.csv` et `.md` sont générés localement et restent hors Git. Les anciennes politiques du lot 12 conservent leurs résultats dans cet échantillon.

## Vérifications

- **1 856 contrôles, zéro échec**, dont 33 nouveaux contrôles ciblés et une garde d'exécution.
- Nouveaux ordres exécutés avec l'économie légale, paires exactes, distinction de l'achat tardif, J54 inclus/J55 tardif, achat absent exclu des dates.
- Refus des routes manquantes/supplémentaires, compteurs négatifs/excessifs, progression contradictoire, réussite précoce, état en cours, scénario erroné, empreinte divergente, doublon, témoin absent et politique inconnue.
- Les suites historiques des objectifs et des sauvegardes passent. Aucun changement de données ni nouvelle compatibilité à déclarer.
- Import/export, smoke test autonome et lancement graphique réussis depuis un chemin avec espaces et accents. Export local : `build/windows-0.10.0/PandemicHorizon.exe`, SHA-256 `D30565CA81882786EA76C13DA823031E4D8FC64EEAE3D7088BC1F94F595F597B`.
- `git diff --check` réussi. Le compte rendu de livraison confirme commit, push et GitHub Actions.

## Décision et suite

Conserver quotas, fenêtres et coefficients. Les taux décrivent quinze politiques de même poids et seulement trois graines ; ce n'est pas un taux de réussite humain. Plusieurs dates se répètent. Les compteurs sont plafonnés et figés, donc impropres à une mesure du trafic total après résolution. Aucun essai physique Windows ni essai avec de nouveaux joueurs dans ce lot.

Préparer un premier événement à choix explicites dans Dégel : conditions, coût, contrepartie et durée visibles avant décision. Définir l'état sauvegardé et les trajectoires possibles avant de l'intégrer. Le résultat facultatif doit rester distinct de la victoire principale ; préserver les références de compatibilité 0.7 à 0.9 et figer une référence 0.10 avant de modifier les données.
