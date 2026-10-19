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
| `main.gd` | Contrôleur : écrans, temps, achats, sauvegardes, raccourcis, smoke test de l'export. ~1 090 lignes. |
| `menu_view.gd`, `settings_view.gd`, `overview_view.gd` | Vues extraites en 0.23 (accèdent encore aux champs du contrôleur). |
| `region_map.gd` | Carte vectorielle (Natural Earth, `assets/maps/*.geojson`), zoom/déplacement, flux animés. |
| `evolution_tree.gd`, `evolution_node.gd`, `skill_presenter.gd`, `family_symbol.gd` | Arbre de compétences, fiches avant/après. |
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
| `.github/workflows/test.yml` | CI Windows : setup, import, tests, provenance, export, paquet, artefact. |

L'export (`export_presets.cfg`) exclut `docs/`, `tests/`, `build/`, les `.ps1`, `scripts/analysis/*` et **chaque** `scripts/balance*.gd` listé nommément : un nouvel outil `balance_*.gd` doit y être ajouté.
