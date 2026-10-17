# Point 17 — Monde en crise et interface intégrée, prototype 0.13

Date : 17 octobre 2026. Base : `648ca81`, branche `main`.

## Demande et réalisation

Remplacer la carte austère en grille par un monde évoquant une crise globale, montrer la propagation et ses déplacements, intégrer toutes les évolutions et décisions sans défilement des achats.

Fond géographique vectoriel Natural Earth : continents lisibles sur fond nocturne, foyers rouges, couverture illustrée par des points terrestres et halos, marqueur sélectionné turquoise, routes fermées ambre. Les 24 régions, leurs noms, populations et liaisons restent fictifs. Les coordonnées graphiques ne changent pas le réseau du modèle.

Les six évolutions Standard ou neuf Dégel sont affichées ensemble à droite, dans une grille de trois colonnes. Coût, effet et état sont visibles avant achat. Les trois options logistiques apparaissent directement sous la carte au J28 ; la partie se met en pause sans ouvrir un écran séparé. F2 revient à cet écran de jeu. Les effets, le tarif historique et l'échéance sont conservés. Les pages d'aide et de sauvegardes restent distinctes ; seuls les achats et choix en partie perdent leur panneau défilant.

## Direction de cette surface

THESIS : observer une crise qui progresse sur un monde reconnaissable et agir sans chercher un achat hors champ.

OWN-WORLD : terre nocturne bleu ardoise, foyers et flux rouge corail, sélection turquoise, fermetures et refus ambre. Contours vectoriels géographiques, contrôles Godot cohérents avec l'existant.

STORY : voir les premiers foyers, suivre leur diffusion, consulter une région, comparer toutes les évolutions et choisir en gardant la carte visible.

FIRST VIEWPORT : indicateurs en haut, monde à gauche, grille complète à droite, décision sous la carte quand elle est disponible, commandes permanentes en bas.

FORM : carte opératoire et arbre d'achats intégré, structure imposée par la demande du joueur ; pas de tournoi de concepts ni de comp approuvée.

FINISH : unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, DESIGN.md, and every shipping raster carrying its provenance.

## Exactitude des mouvements

Chaque échange effectivement ajouté aux imports produit une observation `latest_flows` : direction, unités, type et jour. Les flèches lisent seulement ces observations, sur routes encore ouvertes. Aucune flèche n'est inventée au départ. L'horloge de dessin est séparée du temps du modèle et de son RNG ; pause = mouvement figé. Après chargement, les foyers sont visibles mais les flux attendent le prochain jour simulé, car ces observations ne sont pas sérialisées. Les points rouges ne représentent pas des personnes localisées et les courbes ne sont pas des trajets réels.

## Fichiers principaux

- `scripts/ui/main.gd`, `region_map.gd`, `help.gd` : grille, choix intégrés, géographie, animation et explications.
- `scripts/simulation/world.gd` : observation des échanges, sans changement des calculs ou du RNG.
- `assets/maps/world-land.geojson`, `docs/licences/Natural-Earth.txt` : source vectorielle et provenance, sans raster généré.
- `tests/test_world_presentation.gd` et suites adaptées : nouveaux invariants d'interface, navigation et mouvements.
- `tests/capture_decisions.gd` : états du jeu, phases d'animation et largeur du joueur.

## Vérifications

- Suite complète : **2 401 contrôles, zéro échec**. Invariants du modèle, sauvegardes historiques, objectifs, tutoriel, navigation synthétique, grille et choix visibles à 1280 × 720, 1920 × 1080 et 2395 × 1060.
- 35 captures natives Godot sur GPU : états de décision, tarifs 3/6, propagation tardive, deux phases de déplacement et format large du joueur. Revue Impeccable : carte, évolutions et choix conformes ; consigne F2 de l'aide corrigée puis vérifiée, verdict `ship`.
- Export `build/windows-0.13.0/PandemicHorizon.exe` : smoke test autonome dans un chemin avec espaces et accents, puis démarrage graphique OpenGL, sans erreur. SHA-256 : `8D686F47EA1D45A3259D3928577A6967CE8F4D216842C1A0427CDD49E4D72610`.
- `git diff --check` sans anomalie ; aucune modification des catalogues de simulation ou du format de sauvegarde.

## Limites et suite

Contrôles d'entrée synthétiques Godot, pas d'essai physique Windows ou avec un joueur débutant. Les captures d'animation figent deux phases d'un même jour ; elles ne constituent pas un enregistrement vidéo d'entrées physiques. La carte présente des régions fictives sur une géographie réelle, sans simulation sanitaire territoriale fine. Les détails d'événements restent consultables via F1 pendant un choix.

Prochain lot : essai joueur de la lecture des foyers et des achats intégrés, puis réglage de densité et vitesse des flux selon les observations d'utilisation.
