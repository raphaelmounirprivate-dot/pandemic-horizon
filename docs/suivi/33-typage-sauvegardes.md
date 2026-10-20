# Point 33 — typage strict des sauvegardes

Candidat 0.23 inchangé pour le joueur : aucune règle, aucun format, aucune empreinte de contenu ni texte modifié.

## Périmètre

- `project.godot` : `res://scripts/persistence` retiré de `directory_rules`. `untyped_declaration` y est désormais une erreur, comme dans `scripts/simulation/` (étape 2 de `docs/ARCHITECTURE.md`, ANA-09).
- `scripts/persistence/save_store.gd` : 57 déclarations typées (variables, boucles `for`).
- Choix de types :
  - Types exacts pour les valeurs produites par le jeu (`String`, `bool`, `int`, `float`, `Dictionary`, `FileAccess`, `JSON`, `Error`).
  - `RefCounted` pour le monde reconstruit, comme le paramètre `world` existant.
  - **`Variant` conservé** pour tout ce qui vient du fichier avant validation (`state`, `effect`, `profile`, éléments de listes testés par `_strings`), afin qu'un fichier corrompu continue de produire « Fichier de sauvegarde invalide. » au lieu d'une erreur de type.
  - `String` seulement pour les identifiants déjà validés par `_strings()`.
- Aucun changement de logique.

## Vérifications réelles

- `--check-only` sur `save_store.gd` : code 0.
- `dev.ps1 Test` : **6 455 contrôles réussis, zéro échec**, dont `test_persistence.gd` (fichiers endommagés, anciens formats 1 à 7, copies de secours).
- Smoke test depuis les sources : `RUNTIME_SMOKE_OK`, code 0.
- Preuve de la règle : un fichier temporaire `scripts/persistence/zz_probe.gd` contenant `var x = 1` est refusé (`Parse Error: Variable "x" has no static type`), puis supprimé.

## Limites

- Les règles `unsafe_*` restent désactivées : les accès aux `Dictionary` issus du JSON ne sont pas vérifiés statiquement (étape 4).
- `gdlint` non exécuté en local : contrôlé par la CI après push.

## Livraison

Commit local. Push et CI : à faire séparément. Pas d'archive, pas de checkpoint, pas de changement de version.

Prochaine étape : typage de `scripts/gameplay/`, ou sessions joueurs.
