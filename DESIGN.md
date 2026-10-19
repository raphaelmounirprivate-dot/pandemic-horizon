---
name: Pandemic Horizon
description: Monde en crise, commandes intégrées et familles de compétences de la candidate Godot 0.23
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
  terrain-green: "#263f3b"
  terrain-earth: "#41443c"
  terrain-polar: "#90aaa9"
  terrain-coast: "#557374"
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
  game-vertical: "4px"
  sidebar: "2px"
  horizontal: "16px"
  upgrade-grid: "8px"
  upgrade-group: "2px"
  upgrade-row: "6px"
  upgrade-row-enriched: "4px"
  upgrade-graph-top: "4px"
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
    padding: "4px 8px 4px 28px"
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
- Carte, évolutions des profils classique et enrichi et choix logistiques dans la même vue.
- Animation observatrice, figée en pause et indépendante du hasard du modèle.
- Historique observé et actualités en lecture séparée, sans déplacer les achats.

## Colors

L’extension 0.15 conserve les primitives existantes. Les teintes `terrain-green`, `terrain-earth` et `terrain-polar` sont interpolées par sommet selon la latitude ; `terrain-coast` dessine les contours actuels. Le jeton `coast` historique reste conservé. Ce terrain est illustratif, sans relief mesuré ni climat réel. Les symboles d’infrastructures utilisent le neutre `muted` ; les véhicules utilisent le corail `crisis`.

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

La 0.23 conserve le monde visuel, les couleurs, les angles et les cibles de 44 px. La grille enrichie a six colonnes séparées de 8 px horizontalement et de 4 px verticalement, avec une marge supérieure de 4 px. La séparation verticale principale vaut 4 px ; la colonne droite et les groupes de nœuds espacent leurs éléments de 2 px. La fiche complète utilise le 12 px existant. Le classique garde trois colonnes et 6 px entre rangées. Jusqu’à 24 nœuds restent simultanément visibles sans défilement. Les notices logistiques et réactives vides sont masquées jusqu’à une erreur. Ces valeurs courantes remplacent les espacements historiques décrits ci-dessous.

Les 27 captures finales `.impeccable/review/skills-{classic,enriched,exclusive,resilience,menu,settings,overview,classic-goal,pending}-{1280,1920,2395}.png` couvrent 1280 × 720, 1920 × 1080 et 2395 × 1060. Après les deux premières corrections, des contrôles ont révélé deux débordements dans des états supplémentaires : neuf compétences classiques avec objectif au J45 et 24 compétences avec objectif et décision au J28, Liaisons de secours sélectionnée. La revue indépendante a rouvert les 27 captures, confirmé les corrections et conclu à la livraison sur ce périmètre de débordement et d’états revus. Les 2 972 contrôles ciblés passent ; la suite finale compte 6 061 contrôles réussis sans échec, complétés par cinq contrôles PowerShell d’identité. Les tests réactifs comparent le futur original au futur restauré sur 45 trajectoires, aux bornes de choix et d’expiration et tous les dix jours ; le décompte historique quotidien de la 0.22 reste une preuve séparée. Validation humaine, DPI Windows et second PC restent à réaliser.

Les douze captures 0.22 `.impeccable/review/tactics-{menu,pending,active,fragile}-{1280,1920,2395}.png` ont été vues aux dimensions 1280 × 720, 1920 × 1080 et 2395 × 1060. La revue indépendante de finition conclut à la livraison sans correction requise sur le périmètre interface/code ; 15 978 contrôles réactifs et 3 444 contrôles de non-régression passent. Ces preuves ne constituent pas une validation avec des joueurs, de l'écoute physique, du DPI Windows, d'un second PC ou d'une publication de binaire. Cette extension native conserve le monde, les jetons et les compositions existants : aucun raster ni nouvelle composition de référence ; le détecteur web ne s'applique pas.

Les 24 captures 0.21 `.impeccable/review/incidents-{none,pending,storm,earthquake,communications,favorable,focused,overview}-{1280,1920,2395}.png` couvrent absence d’incident, choix en attente, tempête, séisme, communications mondiales, effet favorable, localisation et Monde, aux dimensions 1280 × 720, 1920 × 1080 et 2395 × 1060. La revue conclut à la livraison sans correction requise ; 3 444 contrôles passent, dont 129 ciblés. Ces preuves ne valident pas les essais humains, l’écoute physique, le DPI Windows ou un second PC. Palette, typographie, angles et grille des achats sont conservés.

Les 21 captures 0.20 `.impeccable/review/crises-{menu-classic,menu-crises,menu-fragile,skills,incident,fragile,loaded}-{1280,1920,2395}.png` documentent les menus, les évolutions, un incident, Réseaux fragiles et un chargement aux dimensions 1280 × 720, 1920 × 1080 et 2395 × 1060. La revue conclut à la livraison sans correction requise ; essais humains, physiques et DPI Windows restent à réaliser. Le menu sépare la rangée Catalogue enrichi/Aléas de la rangée tutoriel/aide/graine/Autre. Les six colonnes compactes gardent tous les achats visibles : 21 nœuds Standard/Réseaux fragiles et 24 Dégel avec aléas. Aucun jeton de palette, typographie ou angle n’est ajouté.

Les douze captures 0.19 `.impeccable/review/comfort-{settings,help-large,overview-large,reduced-game}-{1280,1920,2395}.png` documentent Paramètres, l’aide et Monde en lecture agrandie et le jeu avec mouvements réduits, à 1280 × 720, 1920 × 1080 et 2395 × 1060. Les 3 141 contrôles automatisés réussissent sans échec, dont 44 contrôles de confort ; la revue de finition conclut à la livraison sans correction. Ces preuves ne constituent ni un essai humain ou une écoute physique, ni un essai sur second PC ou une validation DPI Windows. L’archive Windows reste une candidate prévue, sans publication de binaire GitHub établie.
L’extension 0.18 conserve la palette, la police Godot et les angles de 6 px. Le classique garde trois colonnes, six ou neuf nœuds, avec leurs états courts. Le profil enrichi affiche 18 ou 21 nœuds sur six colonnes, séparées de 8 px horizontalement et de 10 px verticalement, sans défilement des achats. Les libellés courts d’au plus huit caractères utilisent le jeton existant de 12 px ; les cibles gardent au moins 44 px de hauteur. Les marges internes du bouton enrichi réservent 26 px à gauche au symbole et 12 px à droite. Seuls les prérequis directs de la sélection sont reliés, via un corridor situé 4 px à droite de la grille et des segments 5 px au-dessus des nœuds. La fiche complète et le bouton séparé restent sous la grille.

Les 24 captures 0.18 `.impeccable/review/expanded-{menu-classic,menu-enriched,standard,degel,available,prerequisite,loaded-classic,loaded-enriched}-{1280,1920,2395}.png` mesurent réellement 1280 × 720, 1920 × 1080 et 2395 × 1060. La revue de livraison conclut à la livraison sans correction ; ces captures et les 3 097 contrôles automatisés ne constituent pas des essais humains. L’exploration de 240 parties est documentée dans `docs/equilibrage/EQUILIBRAGE-0.18-ENRICHI.md`.

Les captures 0.17 `.impeccable/review/history-{start,ongoing,pending,victory,defeat,legacy}-{1280,1920,2395}.png` couvrent six états aux dimensions 1280 × 720, 1920 × 1080 et 2395 × 1060. Elles documentent le développement ; elles ne prouvent aucun essai physique Windows ni essai avec des joueurs. La vue Monde place la situation et une courbe de hauteur minimale 190 px avant trois colonnes extensibles séparées de 16 px. Chaque texte riche focalisable a une hauteur minimale de 130 px et son propre défilement. Les achats et décisions restent dans le jeu.

Les captures 0.16 `.impeccable/review/evolution-{insufficient,prerequisite,available,acquired,excluded,pending,arctic,tutorial}-{1280,1920,2395}.png` couvrent huit états aux dimensions 1280 × 720, 1920 × 1080 et 2395 × 1060. Elles documentent la composition de développement ; elles ne prouvent aucun essai physique Windows ni essai avec des joueurs. Le suivi est dans `docs/suivi/21-evolutions-integrees.md`.

La 0.16 conserve les trois colonnes et les six ou neuf nœuds sans défilement. Les colonnes sont séparées de 8 px, les rangées de 14 px ; chaque groupe espace le nœud et son état de 3 px. Une fiche unique sous la grille affiche l’effet complet et le motif précis, puis le bouton séparé « Évoluer ». Les liens de prérequis sont redessinés après le tri des enfants du `GridContainer`, par appel différé, pour suivre leurs positions finales.

Les captures 0.15 `.impeccable/review/transport-{pending,all,land,air,sea,zoom,motion}-{1280,1920,2395}.png` sont vérifiées aux dimensions exactes 1280 × 720, 1920 × 1080 et 2395 × 1060. Elles documentent les états du filtre, le choix en attente, le zoom et un état du mouvement ; elles ne constituent pas une vidéo ni un essai avec des joueurs.

La composition logique de référence est 1280 × 720, avec `canvas_items` et, depuis la 0.14, `window/stretch/aspect="expand"` dans `project.godot`. À 1920 × 1080, le même rapport 16:9 met cette composition à l’échelle. Une fenêtre plus large étend l’espace logique et la carte extensible. Les captures 0.14 dans `.impeccable/review/camera-{world,zoom,edge,keyboard,reset}-{1280,1920,2395}.png` mesurent respectivement 1280 × 720, 1920 × 1080 et 2395 × 1060. Les anciennes captures annoncées à la largeur 2395, dont `user-2395.png`, mesuraient en réalité 1884 × 1060 : elles documentent le rendu 16:9 antérieur, sans prouver la disposition à pleine largeur 2395.

En jeu, les marges sont de 16 px et la séparation verticale principale de 6 px. Les indicateurs et le suivi facultatif précèdent la zone centrale : carte extensible à gauche, détails régionaux et évolutions à droite. La carte demande au minimum 640 × 220 px ; la colonne droite demande 500 px. Les six évolutions Standard ou neuf Dégel du profil classique occupent trois colonnes, sans `ScrollContainer`. Chaque groupe rassemble le nœud et son état court ; la fiche complète et le bouton séparé suivent la grille.

Les trois choix logistiques en attente sont côte à côte sous la carte. Leur apparition réduit la hauteur disponible pour la carte ; les évolutions restent visibles. Les événements actifs de 48 px minimum sont masqués pendant ce choix et restent consultables dans l’aide. Le statut, la dernière entrée du journal et les commandes restent au bas du jeu. Hors jeu, les marges sont de 24 px. L’aide et les sauvegardes restent des écrans distincts, avec leurs propres besoins de lecture.

## Elevation & Depth

Les surfaces reposent sur des aplats sombres, des contours et des superpositions dessinées, sans ombres décoratives ajoutées. Les halos rouges expriment la couverture autour des foyers ; ils ne simulent pas une élévation des contrôles. Les courbes du réseau sont dessinées avant les hubs et les mouvements.

## Shapes

En 0.15, le terrain vectoriel utilise un maillage triangulé construit une fois par carte. Les côtes projetées sont mises en cache pour la vue courante et recalculées lorsque celle-ci change. Ce choix évite ces recalculs à chaque image, sans promettre une performance universelle.

Les boutons généraux ont un rayon de 6 px, un focus transparent bordé de turquoise sur 2 px et une hauteur minimale de 44 px. Les hubs sont des cibles circulaires de 44 × 44 px, rayon de style 22 px, avec un disque dessiné plus petit et un numéro. Un ajustement de leurs positions évite les recouvrements ; ces positions ne changent pas les connexions du modèle.

Le fond local Natural Earth `assets/maps/world-land.geojson` dessine continents et contours vectoriels. Les routes sont courbes ; une fermeture ajoute des segments et une croix ambre au milieu. Aucun raster n’est livré par cette réalisation.

## Components

**Familles et inspection (0.23).** `skill_presenter.gd` lit `data/skill-families.json` : Diffusion, Discrétion et Résilience couvrent les 24 compétences une seule fois au total. L’ordre de présentation est distinct de l’ordre des achats. `family_symbol.gd` dessine réseau, bouclier et anneau avec croix dans la légende et dans les nœuds, avec le neutre existant ; la légende emploie des icônes de 20 × 20 px et du texte de 16 px. En enrichi, `evolution_tree.gd` trace l’ascendance transitive de la sélection dans le corridor existant, au lieu des seuls liens directs ; le classique garde l’arbre complet. Liens acquis turquoise, autres liens neutres et sélection bordée turquoise conservent leur sens.

La fiche de 12 px expose nom complet et famille, effet rédigé, comparaison avant/après et état précis : disponible, refus motivé ou acquise. « Hors climat/aléas » qualifie ces coefficients issus des seuls achats ; l’infobulle porte la même qualification. Les valeurs restent identiques après acquisition. L’effet rédigé reste nécessaire pour comprendre les restrictions que les coefficients seuls n’expliquent pas. Le bouton d’achat séparé garde son texte de 13 px et sa cible de 44 px. Aucun coût, prérequis, format de sauvegarde ou comportement de simulation n’est modifié par ces métadonnées.

**Construction des écrans (0.23).** `menu_view.gd`, `settings_view.gd` et `overview_view.gd` construisent menu, paramètres et Monde. `main.gd`, de 1 089 lignes, conserve ses points d’entrée, rappels et orchestration. Ce découpage réemploie le thème natif et les commandes existantes ; il ne crée ni nouveau composant HTML ni nouvelle identité graphique. Cette extension est guidée par le code, sans nouveau raster ou composition de référence approuvée.

**Crises réactives (0.22).** La case « Crises réactives », facultative et décochée par défaut, implique catalogue enrichi et aléas. Son infobulle annonce le ciblage des foyers actifs, la réponse à la première panne aérienne et Double relais obligatoire dans Réseaux fragiles. Les profils précédents restent disponibles. Le ciblage au déclenchement utilise uniquement les régions ayant actifs et sains ; les repères existants lisent la cible réelle résolue, sauvegardée dans le profil `tactics-0.22`, format 7.

**Réponse intégrée (0.22).** `crisis_response_view.gd` place le résumé ambre et trois colonnes de choix sous la carte, avec séparation de 8 px. Les boutons existants conservent leur cible minimale de 44 px et leur style ; boutons et détails utilisent 13 px, le rappel final 12 px. Chaque colonne expose nom, coût, coefficients air/remède, durée et motif de blocage. Financer un détour coûte 3 points (air ×1,35), Subir la panne est gratuit et neutre, Exploiter une ouverture coûte 1 point (air ×1,70 et remède ×1,18). Le texte précise le choix irréversible, les six jours dès le lendemain et les routes fermées conservées. La pause et F2 ramènent à cette composition ; la décision logistique reste prioritaire. La fenêtre de trois journées et le choix neutre automatique sans réponse sont explicites ; les résumés gardent les dates des effets après le choix.

**Double relais (0.22).** Dans Réseaux fragiles réactif, le menu, le suivi en partie et le bilan nomment l'objectif obligatoire, les deux destinations de Centrale, les compteurs `/6000`, J60 inclus et l'état. L'issue exige cet objectif et 90 % de couverture ; l'échéance manquée produit une défaite réseau explicite. Les textes distinguent ces unités abstraites des personnes et cet objectif des objectifs facultatifs. La palette, les marqueurs géographiques, la grille des achats et les préférences de confort sont conservés.

**Incidents localisés et mondiaux (0.21).** `incident_view.gd` lit exclusivement les aléas actifs, avec portée, effet réel, durée restante et fin ; aucune définition future n’est présentée. Séisme et rétablissement régional utilisent un repère près du hub ; la tempête occupe le milieu de la courbe effectivement dessinée de sa liaison. Les effets mondiaux de transport et de recherche restent dans les textes et Monde, sans repère géographique fictif. Les compteurs locaux/mondiaux complètent les symboles et les aléas actifs précèdent les autres effets dans les listes et F3. Les repères défavorables sont ambre, les favorables turquoise ; la focalisation ajoute un anneau extérieur clair issu de la palette existante.

**Localisation (0.21).** Le bouton fixe « Local [F4] », désactivé sans incident local, parcourt uniquement les incidents locaux actifs. Il sélectionne la région ou une extrémité de liaison, utilise un zoom d’au moins ×1,8 dans les limites existantes et déplace la caméra bornée. Les cibles régionales de 44 px restent disponibles ; un clic dans le rayon de 16 px du repère de tempête offre un accès direct, complété par F4. L’infobulle nomme portée, effet et fin. Caméra et identifiant focalisé survivent en mémoire au passage par Monde, sans sérialisation. Aucune modification des JSON, règles ou formats de sauvegarde n’est introduite.

**Aléas et résilience (0.20).** La case « Aléas et résilience (+3) », facultative et décochée par défaut, implique Catalogue enrichi ; Réseaux fragiles l’impose avec un départ visible désactivé sur Centrale. La graine numérique et « Autre » rendent le renouvellement du tirage explicite avant lancement ; recommencer conserve cette graine. La fiche du scénario affiche les comptes propres au profil. Les trois compétences de résilience reprennent les nœuds vectoriels, liens directs de la sélection et fiche complète de la grille enrichie, sans changer sa palette ni l’achat séparé. Les incidents affichent leur effet favorable/défavorable du point de vue de la diffusion du virus fictif, leurs cibles et durées dans les effets, le journal et Monde. Une fermeture conserve son signal ambre et n’est jamais annulée par un bonus. Les textes gardent priorité sur la couleur. Le calendrier déterministe est lié au profil de sauvegarde 6 `crises-0.20` ; profils 4/5 et confort 0.19 sont conservés.

**Paramètres et confort (0.19).** Les options « Réduire les mouvements », « Agrandir le texte de lecture (aide, actualités et bilan) » et « Activer les sons de retour » sont désactivées par défaut. `ConfigFile` conserve leurs valeurs et le volume dans `user://settings.cfg`, séparément des parties, en préservant les clés inconnues. Le volume vaut 35 % par défaut, est borné de 0 à 100 % et zéro coupe le son. La lecture agrandie passe le texte de l’aide de 20 à 24 px, les colonnes Monde de 14 à 18 px et le journal de bilan de 16 à 20 px, sans agrandir les évolutions compactes ni les autres commandes. Réduire les mouvements fige `visual_time`, véhicules et pulsations, sans suspendre le modèle. Trois sons PCM synthétiques originaux d’environ 150 ms signalent achat, alerte et issue après activation explicite ; ils n’ajoutent aucune ressource externe ni tirage de simulation. La palette, les angles et les profils 0.18 sont conservés.

**Courbes (0.19).** La série corail des touchés utilise un trait continu ; la série turquoise du remède utilise des tirets de 6 px séparés de 6 px. La légende nomme ces deux styles. Cette distinction complète la couleur, sans modifier les échantillons observés ni reconstruire les historiques absents.
**Identité et profils (0.18).** NACRE utilise un emblème vectoriel abstrait original de 72 × 72 px, dessiné dans `agent_emblem.gd` : centre corail, six relais turquoise, liens `terrain-coast` et arc `muted`. Il reprend la palette existante sans nouvelle famille graphique ni symbole biologique. Le menu présente cette identité et une fiche de scénario dont les comptes suivent le profil. La case « Contenu enrichi · 18 à 21 évolutions » est facultative et décochée par défaut : Standard compte 18 évolutions et 14 événements programmés, Dégel 21 évolutions et 12 événements programmés. Le classique garde six ou neuf évolutions. Le catalogue enrichi validé ajoute douze évolutions et huit événements.

**Évolutions enrichies (0.18).** La grille compacte à six colonnes conserve les symboles vectoriels, la sélection persistante turquoise, les acquisitions textuelles et les cibles de 44 px. Le titre « Évolutions · liens de la sélection » annonce que seuls les prérequis directs du nœud sélectionné sont tracés ; les liens passent par le corridor extérieur, neutres ou turquoise selon l’acquisition. Les libellés courts à 12 px remplacent les noms longs dans ces seuls nœuds ; les états sous chaque nœud sont masqués. Nom complet, effet et motif précis restent dans la fiche et l’infobulle. L’inspection reste gratuite et « Évoluer » reste l’unique achat explicite. Le classique conserve son titre « arbre complet », ses trois colonnes et ses états entiers. Les sauvegardes enrichies utilisent le format 5 et `rules_profile="enriched-0.18"`, avec empreinte distincte dans `content` ; le classique garde le format 4. Monde F3, l’historique, la carte et les choix intégrés conservent leur fonctionnement.

**Monde, historique et actualités (0.17).** F3, le bouton du bas de partie et la dernière actualité cliquable ouvrent « Monde · Actualités et bilan » hors tutoriel ; le bilan possède aussi un accès. La simulation est mise en pause. La situation actuelle et l’objectif éventuel précèdent les courbes, puis trois colonnes présentent les achats datés, les effets en cours et le journal réel inversé, plus récent en haut. Le résumé de décision n’est pas répété s’il figure déjà parmi les effets. Le graphique vectoriel emploie le corail pour la proportion cumulée touchée et le turquoise pour le remède, avec légende textuelle, repères de 0 à 100 % et jours extrêmes ; un seul échantillon apparaît comme un point. L’absence d’historique et les dates d’achats antérieures manquantes sont explicitement signalées, sans passé inventé. Les colonnes utilisent les textes secondaires de 14 px, leurs titres 16 px et la légende 13 px. Retour, F3 ou Échap ramènent à la partie en pause ou au bilan ; le focus initial vise Retour. F1 ouvre l’aide puis revient à Monde. Les achats et les choix logistiques restent dans leur composition intégrée. Aucun nouveau jeton visuel n’est introduit.

**Transports et filtre (0.15).** Cette extension conserve le système de carte et ses commandes. Véhicules terrestres, avions et bateaux sont des silhouettes vectorielles rouge corail orientées dans le sens des échanges observés. Les petits symboles aériens et maritimes neutres près des hubs indiquent la présence de liaisons, même temporairement fermées ; les comptes ouverts/total restent dans le détail régional. Le bouton fixe « Flux : tous » parcourt tous, terre, air et mer sans menu déroulant. Il filtre uniquement les mouvements ; routes et croix de fermeture restent visibles. Le filtre suit la caméra en mémoire entre les écrans de la même partie ; nouvelle partie et chargement réussi rétablissent tous. Il n’est pas sérialisé ; les règles et le format 4 restent inchangés.

**Carte du monde.** Les 24 hubs numérotés se sélectionnent au clic ou par navigation clavier. Le nom sélectionné apparaît sur la carte ; noms, populations et états exacts sont dans la colonne régionale et les infobulles. Les points terrestres et halos illustrent la fraction cumulée touchée, actifs et retirés ; ils ne localisent pas des personnes. Le compteur de foyers compte les régions ayant des actifs.

**Caméra de carte (0.14).** Cette extension conserve le monde et les primitives de la 0.13. Le zoom va de ×1 à ×4. La molette zoome autour du pointeur ; le glisser droit ou central déplace la carte dans ses limites. Les commandes « − », « + » et « Vue mondiale » restent fixes en haut à droite, avec des cibles minimales de 44 × 44 px ; les hubs gardent leurs cibles de 44 × 44 px à tous les niveaux de zoom. Quand la carte a le focus, +/− zooment autour du centre, les flèches déplacent la vue et Origine (Home) revient au monde entier. Le focus clavier sur un hub hors champ le révèle. La caméra est conservée en mémoire pendant les passages par l’aide, les menus et les sauvegardes de la même partie ; une nouvelle partie ou un chargement réussi la réinitialise. Elle n’est pas sérialisée : le modèle et le format de sauvegarde 4 restent inchangés.

**Flux.** Les véhicules rouges orientés utilisent uniquement `latest_flows` : échanges effectivement ajoutés aux imports pour le jour courant, sur une route encore ouverte. Le temps de dessin anime leur position, sans modifier la simulation ni son RNG. La pause fige cette horloge ; après chargement, les véhicules attendent le prochain jour simulé, car les observations ne sont pas sérialisées. Les courbes ne représentent pas des trajets géographiques réels.

**Évolutions (0.16).** Toute la grille reste visible. Chaque nœud porte un symbole vectoriel, le nom et le coût, puis « acquise » après achat. Les liens de prérequis sont neutres, puis turquoise lorsque le prérequis est acquis. Une bordure turquoise persistante de 2 px, rayon 6 px, marque la sélection ; le texte turquoise et « Acquise » indiquent les acquisitions sans leur donner cette bordure. La marge gauche de 28 px réserve la place du symbole. Un état court entier sous chaque nœud indique la disponibilité, l’acquisition, le prérequis manquant, l’incompatibilité, la restriction d’exercice ou le manque de points. La fiche unique présente l’effet complet et le motif précis, aussi accessibles dans l’infobulle. Sélectionner ou focaliser consulte sans dépense ; même acquis ou bloqué, un nœud reste consultable en partie ordinaire. Le bouton séparé « Évoluer : nom · coût » est la seule commande d’achat et devient indisponible selon la raison réelle. Entrée sur un nœud disponible focalise ce bouton ; une activation distincte achète. Le tutoriel guide cette séquence sur Diffusion et désactive les autres nœuds selon l’exercice. Après Mobilité, une seule spécialisation peut être acquise ; le rappel reste au-dessus de la grille. Coûts, règles et format 4 sont conservés.

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

**Écran Évolution (après 0.23, décision du 19 octobre 2026).** Les compétences quittent le panneau latéral pour un écran dédié, ouvert par E ou par le bouton « Évolution [E] · N pts » (64 px de haut, 22 px) à droite de la carte ; le panneau latéral passe de 500 à 380 px et la carte récupère la largeur. L'écran garde la palette, les angles de 6 px et les marges de 24 px.

- Onglets de famille : 220 × 52 px minimum, symbole vectoriel à 10 px du bord, texte 18 px « Famille · acquises/total ». L'onglet actif a le fond `button-hover` **et** un soulignement `accent` de 4 px.
- Arbre (`skill_tree_view.gd`) : colonnes = profondeur du prérequis dans la famille, lignes = ordre des feuilles, parent centré sur ses enfants. Nœuds jusqu'à 250 × 64 px, jamais moins de 44 px de haut ; écart horizontal 40 px (24 px sous 1 100 px de large), vertical 10 px. Liens coudés : 1,5 px `muted`, 3 px `accent` quand le prérequis est acquis, point d'arrivée de 3 px.
- Nœud (`evolution_node.gd`) : symbole de famille à 17 px du bord, nom complet 15 px, ligne « coût · état » 13 px (`accent` si acquise ou disponible, `amber` sinon) ; acquise = contour `accent` 1 px, sélection = contour `accent` 3 px, blocage = losange `amber`. L'état est toujours écrit.
- Fiche : 360 px de large sous 1 600 px, 480 px au-delà ; titre 24 px, texte 15 px en sections EFFET / AVANT → APRÈS / PRÉREQUIS, règle de spécialisation 14 px `amber`, bouton Évoluer 56 px, 20 px.
- Pied : « Retour à la carte [Échap] » (320 px) et rappel des touches 15 px `muted`.

Captures : `tests/capture_evolution_screen.gd` (7 états × 3 résolutions, `.impeccable/review/evolution-*.png`).

**Écran titre et Nouvelle partie (après 0.23, décision du 19 octobre 2026).** Plus aucune liste déroulante dans le menu.

- Écran titre : à gauche, emblème NACRE 96 px à côté de « NACRE / Chaque région compte. » (30 px) et d'un texte d'accroche 18 px `muted` ; à droite, colonne de 420 px de boutons de 56 px (22 px) : Reprendre la partie (si une partie existe, alors ciblé), Nouvelle partie, Tutoriel guidé, Sauvegardes, Paramètres, Aide, Quitter.
- Nouvelle partie : titre « Nouvelle partie · Étape n / 3 · … », résumé des choix en sous-titre, trois pastilles d'étape cliquables (260 px, même style que les onglets d'Évolution : fond clair et soulignement `accent` 4 px pour l'étape en cours), contenu, puis « Retour » (260 px) et « Suivant : … » / « Lancer la partie » (360 px, ciblé).
- Cartes de choix (`choice_card.gd`) : titre 24 px, texte 15 px `muted`, état écrit « Choisi » (`accent`) ou « Choisir », contour `accent` 3 px pour la carte choisie ; scénarios 150 px de haut minimum, difficultés 140 px.
- Étape 2 : deux colonnes « RÈGLES DE LA PARTIE » et « OBJECTIFS ET TIRAGE » (titres 15 px `muted`), interrupteurs de 44 px, graine et « Autre graine ».
- Étape 3 : carte du monde sans bandeau de crise, panneau de 380 px : départ, population, liaisons, raison d'un départ imposé, résumé.

Captures : `tests/capture_menu.gd` (7 états × 3 résolutions, `.impeccable/review/menu-*.png`).
