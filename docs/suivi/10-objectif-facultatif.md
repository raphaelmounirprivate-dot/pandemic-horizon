# Point 10 — Premiers relais

## Périmètre livré

Prototype **0.9.0**, à partir de `259da07`. Premier objectif facultatif en Standard, sans modifier la propagation, le remède, les points, le score ou l'état aléatoire. Les spécialisations et leurs coefficients restent ceux de 0.8.

Avant une nouvelle partie, « Premiers relais » demande trois régions ayant chacune au moins 10 % de population touchée, **à la fin du jour 50 au plus tard**. L'option est décochée par défaut ; Dégel la désactive et la décoche. Le jour limite est inclus. Les personnes touchées sont les actifs et retirés ; la comparaison utilise des entiers.

Le suivi apparaît sous les indicateurs mondiaux. Il est figé à la réussite, à l'échéance ou à une fin principale anticipée. Une annonce unique est ajoutée au journal et le bilan sépare le résultat facultatif de l'issue principale. Une réussite peut donc accompagner une défaite par remède. Aucun point ni bonus de score n'est accordé.

Le choix ne s'applique qu'à une nouvelle partie. Rejouer conserve son activation et réinitialise son état. Le tutoriel reste une session distincte sans objectif et restitue le suivi du joueur à la sortie. F1 explique les règles et affiche l'état courant.

## Fichiers principaux

- `data/objectives.json` et `scripts/gameplay/objectives.gd` : catalogue validé, comptage, résolution, texte et validation de l'état enregistré.
- `scripts/simulation/world.gd` : choix validé avant de remplacer un monde ; suivi après la résolution quotidienne principale, sans nouveau tirage aléatoire.
- `scripts/ui/main.gd` et `help.gd` : contrôle préalable, suivi, bilan, reprise, redémarrage, entraînement et aide.
- `scripts/persistence/save_store.gd` : format 2, empreinte des six JSON avec fins de ligne normalisées, objectif validé avant installation du monde chargé.
- `tests/test_objectives.gd`, `tests/capture_objectives.gd` et références 0.8 dans `tests/fixtures/` : limites, reprise et parcours.

## Compatibilité

Le répertoire `user://saves/transports-1` est conservé. Les formats 1 aux empreintes autorisées 0.7 et 0.8 se chargent en pause sans objectif ajouté rétroactivement. Les restrictions d'achats 0.7 restent contrôlées. Leur lecture ne réécrit pas les fichiers ; le premier enregistrement 0.9 conserve l'original en `.bak`, puis le secours tourne normalement. Format, contenu ou moteur inconnus restent refusés sans écrasement. Les anciennes sauvegardes 0.6 nécessitent toujours leur ancien exécutable.

Le format 2 enregistre identifiant, état, compteur figé, date et motif de résolution ; un objectif absent est un objet vide. Les états contradictoires, seuils hors bornes, scénario incompatible et résolutions dans le futur sont refusés. Les entiers JSON sont reconstruits comme entiers GDScript pour préserver les comparaisons exactes après lecture.

Les quatre références 0.8 ont été produites **avant les modifications**, avec le code `259da07`, aux jours 56 et 76, sur Standard et Dégel. Les références 0.7 restent inchangées. Les nouvelles sauvegardes 0.9 ne se chargent pas avec les exécutables 0.7/0.8. Ne pas régénérer ces fichiers de référence avec une nouvelle version pour masquer une régression.

## Vérifications

- Suite complète : **1 586 contrôles, zéro échec**, dont **82 contrôles ciblés** objectifs/compatibilité et une garde d'exécution.
- Seuil de 9 % refusé, 10 % accepté, deux régions insuffisantes, réussite au jour 50, échec figé malgré un progrès tardif, fin anticipée et réussite facultative simultanée à une défaite principale.
- Parties avec/sans objectif : populations, recherche, points, score, résultat et RNG identiques. Reprise de vingt journées identique, incluant les annonces ; états en cours, réussis et échoués enregistrés et restaurés.
- Références 0.8 : vingt journées suivantes comparées aux véritables états futurs, lecture sans écriture et premier secours identique à l'original. Les tests historiques 0.7 passent aussi.
- Activation au clavier, bascule à la souris, suivi et commandes dans la fenêtre à 1280 × 720 et 1920 × 1080, redémarrage, sortie du tutoriel et désactivation dans Dégel. Entrées synthétiques Godot ; aucun essai physique Windows revendiqué.
- Dix-huit captures rendues aux deux tailles via `dev.ps1 CaptureObjectives`. Revue indépendante : **ACCEPT** pour l'extension visuelle examinée, sans constat bloquant. Les vues 1920 sont une mise à l'échelle logique. PRODUCT.md et DESIGN.md documentent l'ajout local ; tokens et sidecar conservés.
- Import/export Windows, smoke test autonome avec réussite/échec/sauvegarde de l'objectif, et lancement graphique dans un chemin avec espaces et accents. L'exécutable et le guide sont dans `build/windows-0.9.0/`, hors Git. SHA-256 final : `82E75CB9C86BB27223D8FB950283310157097361CBD8CE841E69FAB90D43DAFA`.
- `git diff --check` réussi ; le compte rendu confirme le commit poussé et GitHub Actions.

## Mesure initiale et limites

Avec Boréale, graine 2042, difficulté normale, la politique Diffusion → Mobilité → Discrétion, achetée avec les points normalement gagnés, réussit au **jour 49**. Sans achat, le suivi échoue au jour 50 ; le seuil de trois régions est atteint plus tard au jour 59 et ne transforme pas cet échec. Une échéance de jour 70 aurait donc peu demandé sur ce départ. Le jour 50 est un premier paramètre de jeu, pas une difficulté finale validée.

Les essais ne couvrent pas encore la fréquence de réussite de l'objectif sur tous les départs et ordres d'achat. La validation des sauvegardes vérifie les bornes et les cohérences avec l'état courant ; elle ne rejoue pas toute l'histoire d'un fichier pour authentifier une date passée. Les parties ne sont pas compétitives et restent locales. Aucun essai avec de nouveaux joueurs ou sur un second PC n'a été réalisé dans ce lot.

## Prochaine action

Étendre l'outil d'analyse aux objectifs : mesurer taux de réussite, dates et paires « objectif réussi / victoire principale » pour tous les départs et difficultés. Préserver le mode sans objectif comme témoin. Utiliser ces mesures avant d'ajuster l'échéance ou de décliner un objectif dans Dégel. Les essais physiques et la validation du rythme avec des joueurs restent à organiser.
