---
name: equilibrage
description: Mesurer l'équilibrage de Pandemic Horizon par simulations appariées (même graine, difficulté, départ) avant d'ajuster un coefficient, et rédiger un rapport EQUILIBRAGE-x.y-THEME.md honnête sur ses limites.
---

# Équilibrage par mesures appariées

## Principe

On ne change pas un coefficient « au ressenti » ni « pour gagner plus de victoires ». On compare deux variantes **à scénario, difficulté, départ, graine et politique d'achat identiques**, on lit les contreparties, puis on décide. Les mesures automatiques ne remplacent pas les essais joueurs : le dire dans chaque rapport.

## Outils existants

| Commande `dev.ps1` | Script | Mesure |
| --- | --- | --- |
| `Balance` | `analysis/balance.gd` + `analysis/strategy_comparison.gd` | Ordres d'achat, 675 paires |
| `BalanceObjectives` | `analysis/balance_objectives.gd` + `analysis/objective_comparison.gd` | Avec/sans objectif facultatif |
| `BalanceArctic` | `analysis/balance_arctic.gd` + `analysis/arctic_analysis.gd` | Stratégies climatiques Dégel |
| `BalanceDecisions` | `analysis/balance_decisions.gd` + `analysis/decision_comparison.gd` | Décision logistique J28 |
| `BalanceParameters` | `analysis/balance_parameters.gd` + `analysis/logistics_parameters.gd` | Grille coût × remède |
| — | Godot `--headless --path . --script res://scripts/analysis/reactive_balance.gd` | Réponses aux crises / scénarios |
| — | `.../reactive_event_audit.gd` (puis `-- --reactive`) | Ciblage des aléas |
| — | `scripts/analysis/balance_crises.gd`, `balance_expanded.gd` | Aléas, profil enrichi |

Pour les lancements directs, reproduire l'isolation de `dev.ps1` (`APPDATA`/`LOCALAPPDATA` dans `.tools/user/`). Sorties dans `build/qa/` (CSV/JSONL + `.md`), hors Git.

## Écrire une nouvelle mesure

1. Module **et lanceur** dans `scripts/analysis/` (exclu de l'export par motif ; `tests/test_export_filter.gd` refuse tout `.gd` à la racine de `scripts/`). Ajouter une action dans `dev.ps1` si besoin.
2. Réutiliser les politiques de `analysis/strategy_comparison.gd`. Une politique inconnue, répétée ou sans prérequis est refusée ; une partie sans résultat à la limite de jours est une **erreur**, pas une défaite.
3. Pour tester un paramètre hypothétique : remplacer le catalogue **en mémoire** pendant un appel synchrone et restaurer ensuite (voir `logistics_parameters.gd`) ; pas d'`await` ni de retour anticipé dans cette section. **Ne jamais sauvegarder un monde hypothétique comme partie jouable.**
4. Vérifier l'appariement : groupes complets, aucune paire dupliquée, état identique avant le point de divergence ; échouer sinon.
5. Enregistrer dans chaque observation : moteur, empreinte du contenu, paramètres.
6. Ajouter `tests/test_<thème>_comparison.gd` (cohortes incohérentes refusées, calculs du rapport).

## Rapport `docs/equilibrage/EQUILIBRAGE-<version>-<THÈME>.md`

- Question posée, protocole (scénarios, difficultés, graines, politiques, nombre de parties/paires), commande de reproduction et empreinte.
- Résultats séparés : victoires propres à A, propres à B, doubles victoires, doubles défaites ; durées comparées **sur les doubles victoires seulement** ; dates d'achats réels.
- Décision prise et contreparties ; ce qui reste provisoire.
- Limites : grille de politiques automatiques ≠ toutes les stratégies ; aucun essai humain déduit.

Une modification de règle retenue suit ensuite la skill `contenu-et-regles` (nouveau profil).
