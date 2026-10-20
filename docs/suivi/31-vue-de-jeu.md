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
- `tests/capture_crises.gd` échouait (code 1) **avant comme après** l'extraction : Réseaux fragiles impose un départ en Centrale (« Ce scénario impose un départ en centrale. »), mais le script partait de Boréale. Depuis l'écran titre (`7b16e77`), `show_menu()` n'applique plus `update_choices()`, qui fixe le départ imposé ; les états « menu-* » ne capturaient plus non plus que l'écran titre. **Corrigé dans un commit séparé** : le script passe par l'étape 2 (`show_new_game(2)`) et signale un démarrage refusé au lieu de planter. Résultat : 21 captures, code 0 ; deux relues à 1280×720 (options Réseaux fragiles, écran Évolution au J43).
- Les vues accèdent toujours directement aux champs du contrôleur.

## Livraison

Commit local. Push et CI : à faire séparément. Pas d'archive, pas de checkpoint, pas de changement de version.

Prochaine étape : poursuivre le découpage (tutoriel, sauvegardes) ou passer aux sessions joueurs.
