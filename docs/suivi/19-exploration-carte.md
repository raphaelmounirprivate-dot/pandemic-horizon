# Point 19 — Explorer la carte, prototype 0.14

Date : 17 octobre 2026. Base : `37f10d3`, branche `main`.

Statut : terminé. Lot A ; tâches MON-01, MON-02 et MON-03.

## Résultat

Zoom de ×1 à ×4 à la molette, autour du pointeur et dans les limites du monde. Glisser au bouton droit ou central pour déplacer la vue. Trois boutons fixes en haut de la carte : −, + et Vue mondiale. Les achats, les choix logistiques et les commandes de simulation restent fixes.

Au clavier, focaliser la carte avec Tab : + ou − pour zoomer, flèches pour déplacer, Origine pour retrouver le monde entier. Tab sur une région hors champ ramène sa cible dans la vue ; Entrée ou clic la sélectionne. Les marqueurs conservent leurs cibles de 44 × 44 pixels. La zone des boutons de caméra reste dégagée en vue mondiale.

La caméra conserve son centre au redimensionnement et pendant un aller-retour dans l'aide, les sauvegardes ou le menu. Une nouvelle partie et un chargement repartent en vue mondiale. La caméra est un état d'interface en mémoire, absent des sauvegardes ; le format 4 et les règles restent inchangés. L'exploration fonctionne en pause sans faire avancer la simulation.

## Réalisation

- `scripts/ui/region_map.gd` : transformation des coordonnées, limites, entrées, focus et commandes fixes.
- `scripts/ui/main.gd` : conservation temporaire de caméra entre écrans et réinitialisation aux nouvelles sessions.
- `scripts/ui/help.gd` et guide : commandes de carte.
- `tests/test_map_camera.gd` : entrées synthétiques, sélection, focus, limites, centre, retour d'aide et invariance du monde aux trois tailles.
- `tests/capture_camera.gd` : quinze captures, monde, zoom, bord, focus clavier et retour monde, aux trois tailles de référence.

## Vérifications

- Suite complète : **2 528 contrôles, zéro échec**, dont 126 contrôles ciblés de caméra et leur garde d'exécution.
- Quinze captures natives GPU et revue Impeccable complète : `ship`. Monde, zoom, limite, focus et retour monde aux trois tailles ; neuf évolutions, trois choix et commandes visibles.
- Correction d'une limite de preuve : les anciennes captures nommées 2395 rendaient en réalité un intérieur 16:9 de 1884 × 1060. Le réglage `expand` de la 0.14 et le contrôle des dimensions dans le script produisent de véritables PNG 2395 × 1060, ainsi que 1280 × 720 et 1920 × 1080.
- Export autonome `build/windows-0.14.0/PandemicHorizon.exe` testé dans un chemin avec espaces et accents, smoke test puis démarrage graphique OpenGL sans erreur. SHA-256 : `C222987495D432759B2BA315486B9DE37569EF1D57F505A9E179DB2F07E2A944`.
- PRODUCT, DESIGN, aide, guide, roadmap et index mis à jour ; aucune modification des catalogues ou du modèle de simulation.

## Limites et prochaine action

Entrées synthétiques Godot et captures GPU natives ; pas d'essai physique avec un joueur. Les flux sont toujours des observations du jour et les régions fictives. Les avions, bateaux, nouvelles textures, nouveaux achats et changements d'équilibrage appartiennent aux lots suivants.

Prochain lot proposé : MON-04 à MON-06, commencer par des transports reconnaissables et orientés selon les échanges réels, puis densité des foyers et ambiance géographique.
