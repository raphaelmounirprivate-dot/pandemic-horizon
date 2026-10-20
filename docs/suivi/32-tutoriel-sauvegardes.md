# Point 32 — tutoriel et sauvegardes extraits de main.gd

Candidat 0.23 inchangé pour le joueur : refactorisation sans effet sur les règles, les sauvegardes, les textes ni le rendu.

## Périmètre

- Nouveau `scripts/ui/tutorial_flow.gd` : `start()` (ancien corps de `start_tutorial`) met de côté la partie, les choix et le magasin de sauvegardes du joueur, puis ouvre l'entraînement dans son propre dossier ; `restore()` (ancien `_restore_tutorial_session`) les remet en place.
- `scripts/ui/saves_view.gd` : ajout de `save_manual()` et `load_slot()` (anciens corps de `save_manual` et `load_saved`). La règle est inchangée : la partie en mémoire n'est remplacée qu'après une lecture complète et valide.
- `main.gd` : 664 → **597 lignes** (comptées avec `Get-Content`). `start_tutorial()`, `_restore_tutorial_session()`, `save_manual()`, `load_saved()` et `show_saves()` restent comme points d'entrée (69 appels dans les tests et les vues) et délèguent.
- Suite de ANA-06 / AUD-07. Données, profils, empreintes et fixtures inchangés.

## Vérifications réelles

- `dev.ps1 Test` : **6 455 contrôles réussis, zéro échec**.
- Smoke test depuis les sources : `RUNTIME_SMOKE_OK`, code 0.
- Captures `capture.gd`, `capture_crises.gd`, `capture_decisions.gd` et `capture_evolutions.gd` générées avant (via `git stash`) et après : **80 images, toutes identiques octet par octet** (SHA-256).

## Limites

- `gdlint` non exécuté en local : contrôlé par la CI après push.
- Les vues accèdent toujours directement aux champs du contrôleur ; `main.gd` garde la navigation, le temps, les achats et les raccourcis.

## Livraison

Commit local. Push et CI : à faire séparément. Pas d'archive, pas de checkpoint, pas de changement de version.

Prochaine étape : trois sessions joueurs exploratoires selon `docs/tests-joueurs/README.md`.
