# Point 35 — points et compétences achetables mis en évidence

Candidat 0.24.1 : l'écran Évolution montre les points disponibles en grand et fait ressortir les compétences achetables. Demande de l'auteur du 21 octobre 2026, après sa première partie sur l'exécutable 0.24.0 (capture de Réseaux fragiles au J35). C'est un retour de l'auteur, pas une session joueur au sens du protocole.

## Périmètre

- `scripts/ui/evolution_view.gd` : encadré des points dans la barre de titre (chiffre en 28 px, « points disponibles », « +3 au J40 ») ; onglets sur deux lignes avec « + N achetable(s) » ou « Aucune achetable » ; sous-titre « N compétences achetables maintenant : contour épais et marque + ». Le décompte tient compte de la restriction du tutoriel.
- `scripts/ui/evolution_node.gd` : état `available` (achetable maintenant) dessiné par un fond teinté, un contour de 2 px, le nom en couleur et une marque « + ». L'état reste écrit (« Disponible ») : l'information ne passe pas par la couleur seule.
- `scripts/simulation/world.gd` : constantes `POINT_INTERVAL` (5) et `POINT_GAIN` (3), utilisées par `step()` à la place des littéraux, et `next_points_day()` en lecture seule. Aucun changement de comportement ; aucun JSON de règles ni empreinte modifiés.
- Hauteurs : onglets de 52 à 56 px, encadré de 43 px. À 1280×720, une première version (onglets de 64 px, chiffre en 34 px) faisait déborder la fiche d'une spécialisation et décalait l'arbre pendant un clic ; le test existant « Le bouton reste immobile pendant un clic maintenu » l'a détecté.

## Vérifications réelles

- `dev.ps1 Test` : **6 491 contrôles réussis, zéro échec** (5 nouveaux dans `test_evolution_screen.gd` : points et prochain gain, mise en évidence limitée aux compétences achetables, décompte des onglets et du sous-titre, mise à jour après achat).
- Captures revues : 9 images (Réseaux fragiles J35, Standard au départ, onglet Discrétion) à 1280×720, 1920×1080 et 2395×1060, dans `.impeccable/review/evolution-35/` (hors Git).

## Limites

- Lisibilité jugée sur captures et par l'auteur seulement ; aucune session joueur.

## Livraison

Commit `12f7081` puis version 0.24.1 : voir [LIVRAISON-0.24](../versions/LIVRAISON-0.24.md).

Prochaine étape : poursuivre les essais de l'auteur, puis les trois sessions joueurs.
