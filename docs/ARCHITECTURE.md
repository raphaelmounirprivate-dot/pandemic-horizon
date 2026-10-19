# Architecture — carte du code

Vue d'ensemble stable du dépôt, à jour pour le candidat **0.23**. `DEVELOPPEMENT.md` reste le journal chronologique des choix techniques ; ce document sert à se repérer rapidement.

## Couches

```
data/*.json  ──►  scripts/gameplay/*.gd  ──►  scripts/simulation/world.gd  ◄──  scripts/persistence/save_store.gd
 (règles)          (validation, logique)        (PandemicWorld : état)            (JSON, empreintes)
                                                        ▲
                                                        │ lecture + commandes (purchase, step…)
                                                scripts/ui/main.gd  ──►  vues extraites (scripts/ui/*_view.gd, region_map, help…)
```

- **Le modèle ne connaît pas l'interface.** `PandemicWorld` (`extends RefCounted`) n'importe aucune scène. L'UI lit l'état et appelle des méthodes publiques.
- **Tout est piloté par les données.** Coûts, effets, événements, phases, transports, objectifs et réponses aux crises sont dans `data/`. Chaque module `gameplay/` valide son catalogue avant la moindre mutation.
- **Déterminisme.** Un seul générateur : `world.rng`, initialisé par la graine passée à `start()`. Les tests rejouent des parties entières et comparent état, RNG, journal et remède.

## Simulation — `scripts/simulation/world.gd`

API utilisée partout (UI, tests, outils d'analyse) :

| Méthode | Rôle |
| --- | --- |
| `start_with({"start": …, "seed": …, "scenario": …, "difficulty": …, "objective": …, "decision": …, "expanded": …, "crises": …, "reactive": …})` | Nouvelle partie, **forme à utiliser dans le nouveau code**. Clés et valeurs par défaut dans `START_OPTIONS` ; seule `start` est obligatoire. Clé inconnue ou type incorrect refusés avant toute mutation. Retourne `""` ou un message d'erreur. |
| `start(start_id, seed, …, reactive)` | Ancienne signature à 15 paramètres positionnels, conservée pour les tests historiques ; `start_with()` y délègue. Les paramètres `*_source` permettent d'injecter des catalogues de test. |
| `step()` | Avance d'une journée : propagation par connexions, transports, climat, événements, détection, remède, points, résolution. |
| `purchase(id)` / `purchase_reason(id)` | Achat d'une évolution / motif de refus (prérequis, exclusion, points). Refus = aucune mutation. |
| `totals()`, `coverage()`, `score()`, `outcome`, `outcome_text()` | Indicateurs et issue. |
| `route_is_open(edge)`, `route_mode(edge)`, `transport_factor(edge)` | État des liaisons (fermetures prioritaires sur tout multiplicateur). |
| `upgrade_modifier(key)`, `event_modifier(kind, target)`, `climate_factor(region)` | Composition multiplicative des effets. |

Champs notables : `regions`, `connections`, `day`, `points`, `cure` (float, sérialisé en hexadécimal IEEE-754), `purchased`, `journal`, `active_events`, `history`, `purchase_history`, `objective`, `decision` / `decision_rules` / `decision_profile`, `tactics`, `latest_flows` (observation seulement, jamais sérialisée).

## Gameplay — `scripts/gameplay/`

| Module | Données | Rôle |
| --- | --- | --- |
| `content.gd` | `evolutions.json`, `events.json` | Validation références, bornes, cycles de prérequis. |
| `scenarios.gd` | `scenarios.json` | Standard, Dégel 2042, Réseaux fragiles : départ imposé, phases, routes saisonnières, difficultés. |
| `transports.gd` | `transports.json` | Profil terrestre/aérien/maritime de chaque liaison. |
| `objectives.gd` | `objectives.json` | Objectifs facultatifs (Premiers relais, Relais arctiques) et Double relais. |
| `decisions.gd` | `decisions.json`, `decisions-0.11.json` | Décision logistique J28 ; profil 0.11 (6 pts) figé, 0.12 (3 pts) courant. |
| `history.gd` | — | Historique quotidien borné et chronologie des achats. |
| `expanded_content.gd` | `expanded-content.json` | Profil `enriched-0.18` (18/21 évolutions, événements supplémentaires). |
| `crises.gd` | `crises.json` | Profil `crises-0.20` : aléas tirés par graine. |
| `tactics.gd` | `tactics.json` | Profil `tactics-0.22` : ciblage réactif, réponses détour/subir/occasion. |

Les régions et connexions (`regions.json`, 24 régions fictives) sont validées par `World.validate_data`. `skill-families.json` (familles Diffusion/Discrétion/Résilience) est **uniquement de la présentation**, lu par `ui/skill_presenter.gd`, hors empreinte.

## Sauvegardes — `scripts/persistence/save_store.gd`

- Emplacements `slot1..3` + `auto`, dossier `user://saves/transports-1`, 2 Mio max, écriture temporaire vérifiée puis renommage, copie `.bak` de l'écriture précédente.
- **Empreintes chaînées** (fins de ligne normalisées en LF) :
  - `content_hash` = 8 fichiers : regions, evolutions, events, scenarios, transports, objectives, decisions, decisions-0.11 ;
  - `expanded_hash` = content + `expanded-content.json` ;
  - `crises_hash` = expanded + `crises.json` ;
  - `tactics_hash` = crises + `tactics.json`.
- Formats : 1–3 historiques (empreintes `LEGACY_*` autorisées), 4 classique, 5 enrichi, 6 crises, 7 tactiques. Tableau complet : `COMPATIBILITE.md`.
- Conséquence : **éditer un JSON de la chaîne rend illisibles les sauvegardes des profils qui en dépendent.** Toute évolution de règles passe par un nouveau profil (voir skill `contenu-et-regles`).

## Interface — `scripts/ui/`

| Fichier | Rôle |
| --- | --- |
| `main.gd` | Contrôleur : écrans, temps, achats, sauvegardes, raccourcis. ~810 lignes. |
| `menu_view.gd`, `settings_view.gd`, `overview_view.gd`, `saves_view.gd` | Vues extraites (0.23, puis écran des sauvegardes) ; accèdent encore aux champs du contrôleur. |
| `runtime_smoke.gd` | Smoke test de l'export (`--smoke-test`), piloté par `main.gd` ; embarqué dans l'exe, vérifié par `verify-export.ps1`. |
| `region_map.gd` | Carte vectorielle (Natural Earth, `assets/maps/*.geojson`), zoom/déplacement, flux animés. |
| `evolution_view.gd` | Écran Évolution (E) : onglets par famille, fiche, achat explicite, partie en pause. |
| `skill_tree_view.gd`, `evolution_node.gd`, `skill_presenter.gd`, `family_symbol.gd` | Arbre d'une famille de gauche à droite (disposition pure `layout()`), nœud à état écrit, coefficients avant/après, symboles. |
| `incident_view.gd`, `crisis_response_view.gd` | Aléas et réponses aux crises. |
| `history_chart.gd`, `help.gd`, `tutorial.gd`, `audio_feedback.gd`, `agent_emblem.gd` | Courbes, aide F1, tutoriel, sons, emblème NACRE. |

Raccourcis (`main.gd::_input`) : F1 aide, F2 décision ou réponse de crise en attente, F3 « Monde » (courbes, actualités), F4 incidents (si aléas actifs), Espace pause, 1/2/4 vitesses, Échap retour. Jetons de couleurs, typographie et espacements : `DESIGN.md`.

## Tests — `tests/`

- `run_tests.gd` (`extends SceneTree`) : point d'entrée unique, compteur `checks`/`failures`, fin `RESULT: N checks, M failures`, code de sortie 1 en cas d'échec.
- Chaque suite expose `run(check)` ou `run(tree, check)` (asynchrone, `await`) et est chargée par `run_tests.gd`. Certaines sont protégées par un seuil minimal de contrôles (`checks - before >= N`) pour détecter une suite qui ne s'exécute plus.
- `fixtures/` : états générés par d'anciennes versions (0.7, 0.8…). **Ne jamais les régénérer.**
- `capture*.gd` : rendus réels aux résolutions natives, `benchmark_map.gd`, `input_journey.gd` (événements injectés).

## Outils et livraison

| Script | Rôle |
| --- | --- |
| `scripts/setup-godot.ps1` | Télécharge Godot 4.7.2 (+ modèles d'export) dans `.tools/`, vérifie SHA-512. |
| `scripts/dev.ps1` | Import, Test, Play, Export, Capture*, Balance*. |
| `scripts/verify-export.ps1` | Copie le binaire vers un chemin avec espaces/accents, smoke test + démarrage graphique. |
| `scripts/build-identity.ps1`, `test-build-identity.ps1` | Contrôle de provenance (commit, version, SHA-256). |
| `scripts/package-windows.ps1` | ZIP identifié par commit + kit joueurs + licences + notes de version. |
| `scripts/checkpoint.ps1` | Bundle Git + sources dans `build/checkpoints/<version>-<sha>`. |
| `.github/workflows/test.yml` | CI : job `lint` (Ubuntu, `gdlint` selon `gdlintrc`) et job Windows (Godot en cache, import, tests, provenance, export, paquet, artefact 14 jours). Ignorée pour la documentation seule, sauf fichiers du kit joueurs. |
| `gdlintrc` | Règles `gdlint` (gdtoolkit 4.5.0) : valeurs par défaut, sauf longueur de ligne, nombre de `return` et de méthodes publiques (style hérité) et 15 arguments pour `World.start()`. Localement : `pip install gdtoolkit==4.5.0` puis `gdlint <fichiers .gd>`. |

L'export (`export_presets.cfg`) exclut `docs/`, `tests/`, `build/`, les `.ps1` et `scripts/analysis/*` par motif. Tous les outils d'équilibrage, lanceurs `balance*.gd` compris, vivent dans `scripts/analysis/` ; `tests/test_export_filter.gd` échoue si un `.gd` est posé à la racine de `scripts/`.

## Typage GDScript progressif

`project.godot` traite l'avertissement `untyped_declaration` comme une **erreur** : toute variable, boucle `for` ou paramètre sans type statique fait échouer le chargement du script, donc `dev.ps1 Test`. Les dossiers pas encore migrés sont exclus nommément par `debug/gdscript/warnings/directory_rules` ; **un nouveau dossier est strict par défaut**.

| Étape | Périmètre | État |
| --- | --- | --- |
| 1 | `scripts/simulation/` (`world.gd`) — `untyped_declaration` | Fait |
| 2 | `scripts/persistence/`, puis `scripts/gameplay/` | À faire |
| 3 | `scripts/ui/`, `tests/`, `scripts/analysis/` | À faire |
| 4 | Règles `unsafe_property_access`, `unsafe_method_access`, `unsafe_call_argument`, `unsafe_cast`, dossier par dossier | À faire ; ~5 700 occurrences mesurées le 19 octobre 2026, surtout des accès à des `Dictionary` issus du JSON |

Migrer un dossier : retirer sa ligne de `directory_rules`, puis lancer `Godot --headless --path . --check-only --script res://<fichier>.gd` sur chaque script et corriger. Utiliser `:=` quand la valeur a un type connu, un type explicite pour les éléments validés (`for region: Dictionary in regions`) et `Variant` pour les données pas encore validées (ex. `validate_data`), afin qu'une entrée invalide produise toujours un message plutôt qu'une erreur d'exécution. Ne pas modifier les opérations : un type ne doit jamais introduire de conversion qui change un calcul (déterminisme). Finir par la régression complète.
