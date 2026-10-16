# Point 12 — Relais arctiques

## Périmètre livré

Prototype **0.10.0**, à partir de `188dc64`. Dégel 2042 propose désormais son propre objectif facultatif, désactivé par défaut. Standard conserve Premiers relais. Changer de scénario décoche le choix ; activer le nouvel objectif est explicite. Rejouer conserve le choix et remet les compteurs à zéro. Le tutoriel utilise sa session séparée et restitue le suivi du joueur.

Relais arctiques demande **1 000 unités d'échange sur chacune des deux liaisons sortant de Boréale** :

| Destination | Fenêtre incluse | Condition d'ouverture |
| --- | --- | --- |
| Orient | J36 à J54 | Fin de la tempête orientale |
| Centrale | J39 à J54 | Fin de la dernière fermeture, inspection comprise |

Les fenêtres se situent dans Instabilité, avant la mobilisation du jour 55. Le sens inverse, les autres routes, les fermetures et les jours hors fenêtre ne comptent pas. Les quotas sont plafonnés ; les deux sont nécessaires. Le suivi se fige à la réussite, à l'échéance ou à la fin principale, avec une annonce unique et un bilan indépendant. Aucun bonus de points ou de score.

Les unités sont le flux abstrait calculé par la simulation sur une liaison ouverte, avant la progression locale et la borne des nouveaux cas par les habitants sains. Elles ne représentent ni des personnes transportées ni le nombre de nouveaux touchés. Le même flux est toujours ajouté aux entrées régionales ; l'objectif observe cette valeur sans la consommer et sans modifier populations, recherche, points, score ou RNG.

## Implémentation et sauvegardes

- `data/objectives.json` distingue couverture et flux saisonniers. Les références sont validées contre le scénario, les routes, la phase et la fin des fermetures planifiées.
- `world.gd` transmet les unités du calcul existant à l'observateur d'objectif. L'ordre des opérations de propagation est conservé.
- `objectives.gd` tient les compteurs séparés, la progression 0/2 à 2/2 et l'état résolu. Le catalogue est mis en mémoire ; les appelants reçoivent une copie pour ne pas modifier ses définitions.
- Menu, suivi sous les indicateurs, bilan et aide F1 reprennent les composants existants. Les unités abstraites sont expliquées dans l'aide et le guide.
- Le format reste **2**, dans `user://saves/transports-1`, avec une nouvelle empreinte des six JSON. Les anciennes empreintes 0.7 et 0.8 restent acceptées sans objectif. L'empreinte 0.9 accepte Premiers relais ou un état vide et conserve exactement son suivi ; elle refuse un nouveau relais arctique injecté dans un ancien en-tête.
- La lecture reconstruit et valide les compteurs entiers, leur progression, les bornes et les dates avant installation du monde. Aucun objectif n'est ajouté rétroactivement. Pas de réécriture à la lecture ; le premier enregistrement conserve l'original en `.bak`. Les nouvelles sauvegardes ne se chargent pas avec les exécutables 0.7 à 0.9.

Huit références 0.9 ont été produites avant modification avec le code `188dc64` : Standard en cours/réussi/échoué et Dégel sans objectif, puis trente journées futures pour chacun. Les références 0.7/0.8 restent inchangées. Ne pas régénérer ces états avec une nouvelle version pour masquer une régression.

## Vérifications

- **1 822 contrôles, zéro échec**, dont 181 ciblés sur les relais, la compatibilité 0.9 et le parcours de l'interface ; garde d'exécution incluse dans la suite principale.
- Fenêtres, sens, autre liaison, fermeture cumulée, flux nul, plafonds, réussite au jour 54 inclus, résolution figée et annonce unique.
- Sauvegardes aux jours 0/35/36/38/39/45/54/55/90 : compteurs exacts après lecture et vingt journées suivantes identiques. Compteurs négatifs, excessifs, absents, progrès contradictoires et dates invalides refusés.
- Trente véritables journées 0.9 identiques aux états futurs de référence ; lecture sans écriture et premier secours identique à l'ancien fichier. Les suites historiques 0.7 et 0.8 passent aussi.
- Clavier, suivi et commandes dans la fenêtre à 1280 × 720 et 1920 × 1080 ; reprise du tutoriel, redémarrage et changement de scénario. Entrées synthétiques Godot, pas un essai physique Windows.
- 22 captures ciblées, dont la progression au jour 41, via `dev.ps1 CaptureArctic`. La revue indépendante n'a signalé aucun défaut visuel matériel et a demandé une mise à jour de PRODUCT.md/DESIGN.md. Ce correctif documentaire est résolu ; verdict **ship**, limité à ce correctif. Les tokens, l'identité et le sidecar sont conservés. Les vues 1920 mettent à l'échelle la composition logique.
- Import/export, smoke test autonome des flux arctiques et de leur sauvegarde, puis lancement graphique depuis un chemin avec espaces et accents réussis. Export local `build/windows-0.10.0/PandemicHorizon.exe`, SHA-256 `EB4D134F04866051E3D483DB437784C7EB3064965B31971D15C6A3822621C745`.
- `git diff --check` réussi ; le compte rendu de livraison confirme commit, push et GitHub Actions. Binaires et captures restent hors Git.

## Exploration de trajectoires

Trois difficultés, graines 7/42/2042 et onze politiques du catalogue : **99 paires avec/sans objectif, aucune dérive de l'état de simulation observée**, 81 réussites facultatives. Les neuf cas par politique regroupent les trois difficultés et les trois graines.

| Politique | Réussites | Jour de réussite |
| --- | ---: | --- |
| Attente sans achat | 0/9 | — |
| Discrétion → Diffusion → Mobilité | 9/9 | 52 |
| Diffusion → Discrétion → Mobilité | 9/9 | 53 |
| Diffusion → Mobilité → Discrétion | 9/9 | 45 |
| Polaire historique | 0/9 | — |
| Spécialisation terrestre avant Discrétion | 9/9 | 45 |
| Spécialisation aérienne avant Discrétion | 9/9 | 45 |
| Spécialisation maritime avant Discrétion | 9/9 | 42 |
| Trois spécialisations après Discrétion | 27/27 | 45 |

Les politiques sont définies dans `scripts/analysis/strategy_comparison.gd` ; Polaire historique place Discrétion avant Mobilité saisonnière. L'ordre est important : les coefficients seuls n'expliquent pas les résultats. En normale, graine 2042, l'attente atteint 902 unités vers Orient et 863 vers Centrale à J54, sous le quota. Une exploration préalable avec Adaptation polaire puis Mobilité saisonnière précoces dépassait 1 000 sur les deux routes ; cet ordre supplémentaire ne fait pas partie des 99 paires.

## Limites et prochaine action

Les échantillons ne représentent pas des joueurs humains ; trois graines peuvent répéter les mêmes résultats. La validation d'un fichier contrôle les bornes et les cohérences disponibles, sans rejouer toute son histoire pour authentifier un compteur passé. Aucun essai sur un second PC ou avec de nouveaux joueurs n'a été réalisé.

Mesurer les ordres climatiques précoces dans l'outil d'analyse, avec dates d'achat et matrice objectif/victoire principale. Garder le mode sans objectif comme témoin avant d'ajuster quotas ou fenêtres. Préparer ensuite davantage de décisions de jeu et les essais physiques Windows, plutôt que d'assimiler une réussite facultative à l'équilibrage final.
