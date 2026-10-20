# Point 30 — écrans dédiés : Évolution, nouvelle partie et bilan

Candidat 0.23 : les compétences, le lancement d'une partie et le bilan de fin ont chacun un écran dédié ; aucune règle, aucun coefficient, aucun JSON de règles ni format de sauvegarde n'est modifié.

## Périmètre

Quatre commits d'interface sur `main`, décidés par l'auteur le 19 octobre 2026 (invariant 7 de `CLAUDE.md`) :

- `0edf596` — **écran Évolution** (touche E ou bouton « Évolution ») : un onglet par famille avec le nombre de compétences acquises, arbre de gauche à droite à liens de prérequis visibles, nœuds au nom complet avec coût et état écrit, fiche en sections effet / avant-après / prérequis. La partie est en pause sur cet écran et reprend son état antérieur. Fichiers : `scripts/ui/evolution_view.gd`, `skill_tree_view.gd`, `evolution_node.gd` ; `evolution_tree.gd` et `family_symbol.gd` supprimés.
- `7b16e77` — **écran titre et « Nouvelle partie » en trois étapes** : cartes de scénario, cartes de difficulté avec options groupées et graine, puis région de départ choisie sur la carte (ou imposée par le scénario, raison affichée). Retour et Échap reculent d'une étape ; plus aucune liste déroulante dans le menu. Fichiers : `scripts/ui/menu_view.gd`, `choice_card.gd`.
- `32bde4a` — **bilan de fin illustré** : issue en mots et en symbole, cartes jour / population touchée / remède / score avec formule, courbe avec ligne d'objectif 90 %, jusqu'à dix moments clés lus dans le journal. Observation seule. Fichiers : `scripts/ui/result_view.gd`, `stat_card.gd`, `progress_meter.gd`.
- `9a29f68` — **effet principal sur chaque nœud** : trois lignes nom / effet / coût · état ; l'effet est dérivé des modificateurs (`skill_presenter.gd`). Marges réduites et fiche de 300 px sous 1 600 px de large.

`main.gd` passe de 811 à 834 lignes (comptées avec `Get-Content`, lignes vides incluses) : les nouveaux écrans sont dans leurs propres vues, mais leur câblage s'ajoute au contrôleur. `PRODUCT.md`, `DESIGN.md`, `docs/GUIDE-JOUEUR.md`, `docs/ARCHITECTURE.md` et l'aide en jeu ont été mis à jour dans les commits eux-mêmes. Empreintes de contenu, profils et fixtures inchangés.

## Vérifications réelles

- Commits : 6 200 (`0edf596`), 6 343 (`7b16e77`), 6 453 (`32bde4a`) contrôles réussis, zéro échec, selon leurs messages. Nouvelles suites : `test_evolution_screen.gd`, `test_menu_flow.gd`, `test_result_view.gd`.
- Relance le 20 octobre 2026 sur un clone neuf de `9a29f68` (Godot 4.7.2 installé par `setup-godot.ps1`, SHA-512 vérifié) : `dev.ps1 Test` → **6 455 contrôles réussis, zéro échec**.
- Smoke test depuis les sources (`--smoke-test`) : `RUNTIME_SMOKE_OK`, code 0.
- Captures `capture_menu.gd`, `capture_evolution_screen.gd`, `capture_result.gd` : **57 images** (19 situations × 1280×720, 1920×1080, 2395×1060), aucune erreur Godot. Échantillon relu : Évolution à 1280 et 2395, options et départ imposé à 1280, bilan enrichi à 1280. Textes non coupés, cibles visibles, état toujours écrit en plus de la couleur.
- CI GitHub « Godot tests » : réussie pour `0edf596`, `7b16e77`, `32bde4a` et `9a29f68`.

## Limites

- Aucune des 57 captures n'a été relue en totalité ; seules six l'ont été lors de ce point.
- À 2395×1060, les trois lignes d'un nœud d'Évolution occupent toute sa hauteur : lisible, mais sans marge visible en haut et en bas.
- Aucun essai humain de ces écrans : compréhension de l'arbre, du parcours en trois étapes et du bilan à observer pendant les sessions.
- Aucun nouvel export ni archive local ; la version reste 0.23.

## Livraison

Commits poussés sur `main` ; CI réussie pour chacun (voir ci-dessus). Pas d'archive, pas de checkpoint, pas de changement de version. Ce point est un ajout documentaire.

Prochaine étape : trois sessions joueurs exploratoires selon `docs/tests-joueurs/README.md`, en observant les trois nouveaux écrans.
