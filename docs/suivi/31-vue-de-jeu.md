# Point 31 — écran de jeu extrait de main.gd

Candidat 0.23 inchangé pour le joueur : refactorisation sans effet sur les règles, les sauvegardes, les textes ni le rendu.

## Périmètre

- Nouveau `scripts/ui/game_view.gd` (191 lignes) : `build()` (ancien `show_game`), `refresh()` (ancien `_refresh`), `build_decision()` (ancien `build_inline_decision`) et `decision_signature()`. Code déplacé tel quel ; les membres implicites deviennent `ui.…`, comme dans les autres vues.
- `main.gd` : 834 → **664 lignes** (comptées avec `Get-Content`). `show_game()` et `_refresh()` restent comme points d'entrée et délèguent à la vue ; `build_inline_decision()` disparaît (aucun autre appelant). La constante `MapView` passe dans la vue ; `Incidents` reste dans le contrôleur, utilisée par `overview_view.gd`.
- Avancement de ANA-06 / AUD-07. Données, profils, empreintes et fixtures inchangés.

## Vérifications réelles

- `dev.ps1 Test` : **6 455 contrôles réussis, zéro échec** (identique au point 30).
- Smoke test depuis les sources : `RUNTIME_SMOKE_OK`, code 0.
- Captures `capture.gd` et `capture_decisions.gd` générées avant (via `git stash`) et après l'extraction : **35 images, toutes identiques octet par octet** (SHA-256).

## Limites

- `gdlint` non exécuté en local (pas de Python sur ce poste) : contrôlé seulement par la CI après push.
- `tests/capture_crises.gd` échoue (code 1) **avant comme après** ce changement : la combinaison Dégel 2042 + crises + décision + objectif qu'il demande est refusée par `start_game`, le monde reste vide et `show_game` échoue sur `world.scenario.name`. Défaut antérieur de l'outil de capture, non corrigé ici.
- Les vues accèdent toujours directement aux champs du contrôleur.

## Livraison

Commit local. Push et CI : à faire séparément. Pas d'archive, pas de checkpoint, pas de changement de version.

Prochaine étape : corriger `capture_crises.gd`, puis poursuivre le découpage (tutoriel, sauvegardes) ou passer aux sessions joueurs.
