# Lots proposés et dépendances

Tous les lots sont proposés. Aucun changement de simulation ou d'interface n'est livré par ce document.

## Lot A — Explorer la carte, candidat 0.14

Objectif : inspecter le monde et les foyers avec un zoom confortable.

- Zoom à la molette autour du pointeur ; déplacement par glisser ; bouton « Vue mondiale ».
- Commandes clavier équivalentes, limites de caméra et sélection correcte après transformation.
- Carte seule transformée : indicateurs, évolutions, décisions et commandes restent fixes et visibles.
- Tester les cas de carte zoomée pendant une décision, une pause, un redimensionnement et un retour depuis l'aide.

Terminé quand MON-01 à MON-03 sont validés aux trois tailles de référence, avec reprise des sauvegardes et sans changement de population ou de RNG dû à la caméra. Le choix du bouton de glisser doit éviter la confusion avec un clic de sélection.

## Lot B — Monde vivant et transports

Dépend du lot A pour placer et dimensionner correctement les éléments pendant le zoom.

- Marquer les points de transport avec une petite famille d'icônes cohérentes.
- Afficher avions et bateaux stylisés sur les échanges effectivement observés ; garder une lecture terrestre distincte.
- Montrer direction et type sans laisser croire que les véhicules sont une population simulée séparée.
- Réduire la surcharge quand de nombreuses liaisons sont actives ; proposer un filtre sans masquer les achats.
- Répartir plus naturellement les foyers sur les terres et tester une ambiance géographique plus riche.

Terminé quand MON-04 à MON-06 sont validés : aucune traversée d'une route fermée, pause respectée, fonctionnement après chargement expliqué, dessin stable aux différents zooms. Relever le temps de rendu avant/après sur une même scène tardive et le même matériel avant de fixer le budget acceptable.

## Lot C — Évolutions plus lisibles

Peut commencer après A ; ne dépend pas d'une nouvelle règle de simulation.

- Dessiner les relations de prérequis entre les six ou neuf évolutions existantes.
- Ajouter une icône originale et des états distincts : disponible, prérequis absent, points insuffisants, acquise, exclusion.
- Sélectionner une évolution affiche sa fiche détaillée ; acheter reste une action explicite distincte.
- Conserver l'ensemble de l'arbre, les coûts et les choix logistiques visibles dans le jeu à 1280 × 720.

Terminé quand EVO-01 à EVO-03 sont validés au clic et au clavier, sans achat accidentel ni changement de coût. Si dix-huit évolutions ne tiennent plus confortablement, proposer et valider une nouvelle composition avant d'étendre le catalogue.

## Lot D — Actualités et bilan explicatif

- Présenter un fil d'actualités compact : fait réel de la simulation, date et conséquence.
- Conserver les décisions sous la carte ; seules les confirmations qui le nécessitent interrompent l'action.
- Enregistrer un historique quotidien borné, puis afficher les courbes mondiales et les dates d'achats au bilan.
- Expliquer le remède et les fermetures avec les données réellement disponibles.

Dépendance : définir le stockage de l'historique avant les courbes. Les sauvegardes anciennes sans historique doivent rester lisibles ; ne pas inventer leur passé.

Terminé quand EVT-01, EVT-02, STA-01 et STA-02 sont validés, y compris après sauvegarde/chargement et sur une partie interrompue.

## Lot E — Contenu et équilibrage vers la 1.0

- Donner une identité visuelle au premier agent et améliorer les fiches Standard/Dégel.
- Proposer les évolutions supplémentaires et événements nécessaires aux objectifs du plan général.
- Mesurer les nouvelles stratégies sur les mêmes graines et difficultés, puis faire des essais joueurs.
- Si de nouveaux états de population sont souhaités, définir d'abord leur conservation, leurs indicateurs, leur fin de partie et leur migration.

Terminé quand CNT-01 à CNT-04 sont validés. Les ajouts de contenu ne sont pas un simple changement graphique : catalogues, sauvegardes, tutoriel et équilibrage doivent évoluer ensemble.

## Lot F — Finition et distribution

- Accessibilité : tailles de texte, contrastes, lecture sans couleur seule, contrôle de l'animation.
- Sons facultatifs et retour visuel cohérent.
- Essai physique clavier/souris, plein écran et second PC Windows.
- Archive distribuable, licences, guide à jour, export autonome vérifié et publication identifiée.

Terminé quand FIN-01 à FIN-03 sont validés et que la version réellement distribuée correspond au commit testé.

## Hors du prochain cycle

Tous les pays réels, plusieurs agents, graphismes 3D complexes, compétition et multijoueur restent différés. Leur intérêt sera réévalué après les essais du jeu solo. Aucun calendrier chiffré n'est fixé sans découpage et mesures supplémentaires.
