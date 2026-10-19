# Point 29 — dette technique, CI et rangement après l'analyse du 19 octobre

Candidat 0.23 inchangé pour le joueur : aucune règle, aucun coefficient, aucun format de sauvegarde ni texte du jeu modifié. Lot technique et documentaire tiré de l'[analyse du 19 octobre](../roadmap/06-analyse-2026-10-19.md), traité dans l'ordre de la liste, avec un commit poussé par étape (`01de861` → `a633a26`).

## Périmètre

- **P0.** Kit joueurs : conduite à tenir en cas d'alerte antivirus (`docs/tests-joueurs/README.md`, champ dans `fiche-session.md`) ; procédure de signalement de faux positif et pistes de signature dans `docs/ANTIVIRUS.md`. Dépôt GitHub renommé `pandemic-horizon` avec `gh repo rename`, remote et liens mis à jour.
- **P0 reporté.** Réponses aux crises : décision de l'auteur de reporter tout changement après les sessions joueurs, pour ne pas créer un format 8 avant la décision sur les formats.
- **P1 code.** `World.start_with(options)` : 15 options nommées (`START_OPTIONS`), clé inconnue ou type incorrect refusés avant mutation ; `start()` conservée, appels UI/sauvegardes/analyse migrés. `main.gd` : 1 089 → 810 lignes (`saves_view.gd`, `runtime_smoke.gd`). Lanceurs `balance*.gd` dans `scripts/analysis/`, filtre d'export par motif. Typage : `untyped_declaration` en erreur, `scripts/simulation/` migré, autres dossiers exclus nommément par `directory_rules`.
- **P1 décision.** [Note sur les formats de sauvegarde](../roadmap/07-decision-formats-sauvegarde.md) : options A/B/C et recommandation, **non tranchée**.
- **P1 outillage.** `.claude/skills/` source unique des skills. CI : filtre de chemins (documentation seule ignorée, fichiers du kit joueurs conservés), `concurrency`, cache de Godot extrait, artefacts 14 jours, job `gdlint` (gdtoolkit 4.5.0, `gdlintrc`). Défauts relevés par `gdlint` corrigés : ordre des déclarations, `elif` après `return`, chargements en double, BOM de `region_map.gd`.
- **P2.** README court et `CHANGELOG.md` ; index de suivi remis à jour ; rapports dans `docs/equilibrage/`, notes de version dans `docs/versions/` (`package-windows.ps1` suit) ; `.gitignore` nettoyé ; règle de conservation de `build/` proposée dans `DEVELOPPEMENT.md`, sans suppression.

## Vérifications réelles

- `dev.ps1 Test` après chaque étape de code : 6 107 puis **6 114 contrôles réussis, zéro échec** (6 061 en 0.23 ; nouvelles suites `test_start_options.gd` et `test_export_filter.gd`).
- Smoke test `--smoke-test` lancé depuis les sources après chaque changement de `main.gd`/`world.gd` : `RUNTIME_SMOKE_OK`, code 0.
- Captures `tests/capture.gd` à 1280×720 et 1920×1080 après extraction de l'écran des sauvegardes : écrans relus, rendu et focus conformes. 2395×1060 non capturé (ce script ne le couvre pas).
- Typage : une déclaration non typée ajoutée à `world.gd` est refusée (`SCRIPT ERROR`) ; les sept lanceurs déplacés passent `--check-only`.
- `gdlint` local sur tous les `.gd` : aucun problème. Liens relatifs des `.md` : aucun lien cassé.
- CI GitHub : réussites pour `abf0b20`, `2e8dfbb`, `9ed4cef`, `3ccfdb4`, `b0f885a`, `180f3a8`, `a47b92e` (cache créé, 145 Mio), `22d696c` (premier job `gdlint`, cache réutilisé) et `d0d5179` (empaquetage avec les notes lues dans `docs/versions/`). Exécutions de `3e939d1` et `0306600` annulées en attente : GitHub ne garde qu'une exécution en attente par groupe. Les commits purement documentaires n'ont pas lancé de CI, comme prévu.

## Limites

- Aucun essai humain, aucun second PC, aucune vérification avec AVG actif. Le faux positif n'est **pas** encore signalé à l'éditeur.
- Typage strict limité à `scripts/simulation/` et à la règle `untyped_declaration` ; ~5 700 occurrences `unsafe_*` mesurées restent à traiter (ordre dans `ARCHITECTURE.md`).
- `gdlint` tolère encore les lignes longues, les validateurs à nombreux `return` et les grandes classes.
- Les actions épinglées (`checkout`, `cache`, `upload-artifact`, `setup-python` en v4/v5) ciblent Node.js 20, déprécié : GitHub les force sur Node 24. Mise à jour des épingles à prévoir.
- Aucun nouvel export ni archive local : `dev.ps1 Export` n'a pas été relancé ; seule la CI a exporté et empaqueté.

## Livraison

Commits locaux poussés sur `main` à chaque étape. CI : voir ci-dessus. Pas d'archive locale, pas de checkpoint, pas de changement de version.

Prochaine étape : trois sessions joueurs exploratoires selon `docs/tests-joueurs/README.md`, après recontrôle de la livraison avec AVG actif.
