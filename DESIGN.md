---
name: Pandemic Horizon
description: Monde en crise et commandes intégrées du prototype Godot 0.13
colors:
  ink: "#e1eee9"
  muted: "#a7c4c9"
  accent: "#69d6bd"
  amber: "#efbc70"
  crisis: "#ff766d"
  ocean: "#0a161d"
  graticule: "#11232c"
  land: "#233b40"
  coast: "#3d5659"
  button: "#16333e"
  button-hover: "#254954"
  active-hub: "#8f302f"
  quiet-hub: "#20363e"
typography:
  screen-title:
    fontSize: "30px"
  game-title:
    fontSize: "22px"
  metric:
    fontSize: "20px"
  body:
    fontSize: "18px"
  secondary:
    fontSize: "16px"
  region:
    fontSize: "14px"
  compact:
    fontSize: "13px"
  map-label:
    fontSize: "12px"
rounded:
  button: "6px"
  hub: "22px"
spacing:
  outer: "24px"
  game-outer: "16px"
  vertical: "8px"
  game-vertical: "6px"
  sidebar: "4px"
  horizontal: "16px"
  upgrade-grid: "8px"
  upgrade-group: "3px"
components:
  button:
    backgroundColor: "{colors.button}"
    textColor: "{colors.ink}"
    rounded: "{rounded.button}"
    padding: "10px 16px"
  button-hover:
    backgroundColor: "{colors.button-hover}"
    textColor: "{colors.ink}"
    rounded: "{rounded.button}"
  upgrade-button:
    backgroundColor: "{colors.button}"
    textColor: "{colors.ink}"
    typography: "{typography.compact}"
    rounded: "{rounded.button}"
    padding: "4px 8px"
  region-hub:
    rounded: "{rounded.hub}"
    width: "44px"
    height: "44px"
---

# Design System: Pandemic Horizon

## Overview

**Creative North Star: « Monde en crise »**

Le joueur a demandé une carte du monde sombre où la propagation et ses mouvements sont visibles, avec toutes les évolutions et les choix intégrés sans défilement des achats. La 0.13 traduit cette direction dans une interface de bureau Windows/Godot : continents reconnaissables, foyers rouges et commandes compactes constamment accessibles.

Le fond géographique est réel ; les 24 régions, leurs populations et leurs liaisons restent fictives. Le dessin exprime une situation calculée par le jeu et accompagne les chiffres. Il ne constitue pas une carte sanitaire réelle.

**Key Characteristics:**

- Monde nocturne vectoriel, foyers et flux rouge corail.
- Sélection turquoise ; fermetures et blocages ambre.
- Carte, arbre complet des évolutions et choix logistiques dans la même vue.
- Animation observatrice, figée en pause et indépendante du hasard du modèle.

## Colors

Le bleu sombre et les terres ardoise portent la carte ; le corail rend la crise visible. Les valeurs normatives sont dans le frontmatter.

- **Crise :** foyers, points cumulés, flèches et compteur des foyers actifs. Les halos et arcs emploient aussi des rouges translucides calculés dans `region_map.gd`.
- **Turquoise :** sélection, focus, indicateurs, états « Disponible » et « Acquise ».
- **Ambre :** fermetures, événements, décisions et motifs de refus.
- **Neutres :** texte clair, texte secondaire, océan, graticule, terres et contours. Les routes ouvertes sont discrètes et translucides.

La couleur complète les libellés, les nombres, les flèches et les croix de fermeture.

## Typography

La police est celle fournie par défaut par Godot ; aucune famille ni graisse personnalisée ne doit être inventée. Le dessin cartographique utilise `ThemeDB.fallback_font`.

Les titres des écrans utilisent 30 px, celui du jeu 22 px, les indicateurs et le titre des évolutions 20 px. Le corps général est à 18 px, le secondaire à 16 px. Le détail régional, le statut et le journal sont à 14 px ; les achats, effets, états, légendes et décisions à 13 px. Les numéros des hubs et mentions cartographiques utilisent 12 px ; le nom de la région sélectionnée utilise 14 px. L’aide utilise 20 px pour son texte riche. Les effets et motifs d’achat reviennent à la ligne.

## Layout

La composition logique de référence est 1280 × 720, avec `canvas_items` dans `project.godot`. Les captures à 1920 × 1080 mettent à l’échelle cette composition ; elles ne démontrent pas une disposition recomposée indépendamment. Les contrôles de développement incluent aussi une capture à la largeur du joueur dans `.impeccable/review/user-2395.png`.

En jeu, les marges sont de 16 px et la séparation verticale principale de 6 px. Les indicateurs et le suivi facultatif précèdent la zone centrale : carte extensible à gauche, détails régionaux et évolutions à droite. La carte demande au minimum 640 × 220 px ; la colonne droite demande 500 px. Les six évolutions Standard ou neuf Dégel occupent trois colonnes, sans `ScrollContainer`. Chaque groupe rassemble bouton, effet et état.

Les trois choix logistiques en attente sont côte à côte sous la carte. Leur apparition réduit la hauteur disponible pour la carte ; les évolutions restent visibles. Les événements actifs de 48 px minimum sont masqués pendant ce choix et restent consultables dans l’aide. Le statut, la dernière entrée du journal et les commandes restent au bas du jeu. Hors jeu, les marges sont de 24 px. L’aide et les sauvegardes restent des écrans distincts, avec leurs propres besoins de lecture.

## Elevation & Depth

Les surfaces reposent sur des aplats sombres, des contours et des superpositions dessinées, sans ombres décoratives ajoutées. Les halos rouges expriment la couverture autour des foyers ; ils ne simulent pas une élévation des contrôles. Les courbes du réseau sont dessinées avant les hubs et les mouvements.

## Shapes

Les boutons généraux ont un rayon de 6 px, un focus transparent bordé de turquoise sur 2 px et une hauteur minimale de 44 px. Les hubs sont des cibles circulaires de 44 × 44 px, rayon de style 22 px, avec un disque dessiné plus petit et un numéro. Un ajustement de leurs positions évite les recouvrements ; ces positions ne changent pas les connexions du modèle.

Le fond local Natural Earth `assets/maps/world-land.geojson` dessine continents et contours vectoriels. Les routes sont courbes ; une fermeture ajoute des segments et une croix ambre au milieu. Aucun raster n’est livré par cette réalisation.

## Components

**Carte du monde.** Les 24 hubs numérotés se sélectionnent au clic ou par navigation clavier. Le nom sélectionné apparaît sur la carte ; noms, populations et états exacts sont dans la colonne régionale et les infobulles. Les points terrestres et halos illustrent la fraction cumulée touchée, actifs et retirés ; ils ne localisent pas des personnes. Le compteur de foyers compte les régions ayant des actifs.

**Flux.** Les flèches rouges orientées utilisent uniquement `latest_flows` : échanges effectivement ajoutés aux imports pour le jour courant, sur une route encore ouverte. Le temps de dessin anime leur position, sans modifier la simulation ni son RNG. La pause fige cette horloge ; après chargement, les flèches attendent le prochain jour simulé, car les observations ne sont pas sérialisées. Les courbes ne représentent pas des trajets géographiques réels.

**Évolutions.** Toute la grille reste visible. Chaque bouton porte le nom et le coût, puis « acquise » après achat ; un effet compact et un état l’accompagnent. Le motif complet et l’effet sont aussi dans l’infobulle. Les achats acquis sont désactivés. Les achats bloqués restent focalisables afin de lire la raison ; le tutoriel désactive les achats hors exercice. Après Mobilité, une seule des trois spécialisations facultatives peut être acquise. Le rappel du choix et le nom acquis restent au-dessus de la grille.

**Décision logistique.** Au J28, si activée dans Dégel, la partie se met en pause et les trois choix apparaissent sous la carte. Coût, effet, durée et raison de blocage sont visibles. Soutenir les ports conserve le tarif courant de 3 points depuis la 0.12 ; un profil historique 0.11 garde 6 points et son libellé. Les règles et le format de sauvegarde 4 ne changent pas. F2, depuis le jeu, met en pause et ramène à cette vue intégrée ; le choix reste possible jusqu’au J30 inclus, puis le maintien neutre est automatique au J31.

**Temps et aide.** La partie commence en pause ; la vitesse choisie reste visible. Espace bascule la pause, 1/2/4 changent la vitesse. F1 ouvre ou ferme l’aide ; Échap ferme aussi l’aide. Tout retour au jeu se fait en pause. Les dix thèmes expliquent les règles et l’état de la session. Un écran distinct présente le bilan et le journal complet.

**Menu et sauvegardes.** Les sélecteurs du menu ont une hauteur minimale de 44 px ; Dégel impose Boréale avec un sélecteur visible désactivé. Les objectifs et décisions facultatifs se choisissent avant le lancement. Les trois emplacements manuels et l’automatique gardent leur parcours de confirmation, avec Annuler au focus initial.

## Do's and Don'ts

### Do

- **Do** conserver la géographie lisible, les foyers rouges, le focus turquoise et les fermetures ambre.
- **Do** maintenir toutes les évolutions et les choix en attente visibles dans la vue du jeu.
- **Do** lire les chiffres du modèle et les échanges observés ; figer les mouvements en pause.
- **Do** distinguer les tests synthétiques et captures des essais physiques Windows et essais avec des joueurs.

### Don'ts

- **Don't** réintroduire la carte de régions en grille ni le défilement des achats.
- **Don't** ouvrir un écran séparé pour la décision logistique.
- **Don't** inventer des échanges animés, des personnes localisées ou une correspondance sanitaire des régions fictives.
- **Don't** présenter les captures comme une validation avec des joueurs ou comme une vidéo des déplacements.
