# Notes de version 0.24 — écrans dédiés, candidat pour les sessions joueurs

Aucune règle, aucun coefficient ni format de sauvegarde modifié depuis la 0.23 : une partie 0.23 se charge telle quelle (même moteur 4.7.2, mêmes empreintes de contenu).

- Écran Évolution dédié (touche E) : un onglet par famille, arbre de gauche à droite à liens visibles, fiche en sections ; la carte récupère la place de l'ancienne grille.
- Écran titre et « Nouvelle partie » en trois étapes : scénario, difficulté et options, départ choisi sur la carte. Cartes de choix à état écrit.
- Bilan de fin illustré : issue en mots et en symbole, cartes jour / couverture / remède / score, courbe, moments clés tirés du journal.
- Aide F1 : dix sujets en boutons au lieu d'une liste déroulante ; le sujet affiché est marqué « ● ».
- Interne : contrôleur d'interface découpé (446 lignes), typage statique obligatoire de la simulation, des sauvegardes et du gameplay, CI allégée avec `gdlint`.

Ces écrans n'ont été essayés par aucun joueur. Les tests physiques, DPI, audition et second PC restent à réaliser. La version reste candidate, pas une 1.0.

Validation : 6 486 contrôles réussis, zéro échec ; smoke test depuis les sources. Détails : points de suivi 29 à 34.
