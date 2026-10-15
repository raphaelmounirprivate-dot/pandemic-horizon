# Plan de développement — Pandemic Horizon

Date : 15 octobre 2026.

Dépôt : [raphaelmounirprivate-dot/plague-inc-evolved](https://github.com/raphaelmounirprivate-dot/plague-inc-evolved).

**État actuel :** présentation et scénario documentés ; moteur, interface et exécutable à développer. Ce document définit les travaux à réaliser et leurs critères de réussite.

## 1. Résultat à livrer

Un jeu original de stratégie en 2D pour Windows, jouable hors ligne, en français. Le joueur choisit une région de départ, gagne des points d'évolution, achète des améliorations et adapte sa stratégie aux réactions du monde. Chaque partie se termine par un résultat et un bilan compréhensibles.

La version 1.0 doit contenir une campagne standard et le scénario **Dégel 2042**, trois difficultés, une sauvegarde locale et un exécutable de lancement. L'interface, le code, les sons et les illustrations seront créés pour ce projet ou proviendront de ressources dont la licence autorise cet usage.

## 2. Périmètre de la première version

Les quantités suivantes sont des objectifs de départ à confirmer après le prototype :

| Élément | Cible pour la version 1.0 |
| --- | --- |
| Carte | 24 régions stylisées, reliées par routes terrestres, aériennes et maritimes |
| Agent jouable | 1 agent fictif avec plusieurs stratégies d'évolution |
| Évolutions | 18 améliorations de base, plus 3 propres à Dégel 2042 |
| Scénarios | Standard et Dégel 2042 |
| Difficultés | Facile, normale et difficile |
| Événements | Au moins 12 événements avec effets et durées explicites |
| Partie | Durée visée de 15 à 30 minutes à vitesse normale, à ajuster par les essais |
| Sauvegarde | 3 emplacements manuels et 1 sauvegarde automatique |
| Affichage | Fenêtre redimensionnable et plein écran ; contrôle dès 1280 × 720 |
| Distribution | Archive Windows contenant PandemicHorizon.exe et toutes ses dépendances |

Le multijoueur, une carte détaillée de tous les pays, un éditeur visuel de scénarios et de nouveaux types d'agents sont réservés à une version ultérieure. Cette limite donne un premier jeu complet dont les parties peuvent être testées et équilibrées.

## 3. Choix techniques proposés

- **Moteur : Godot, version stable à fixer au démarrage**, avec la même version pour les modèles d'export. Consigner cette version dans le dépôt pour reproduire les builds.
- **Code : GDScript**, avec un moteur de simulation séparé des scènes d'interface.
- **Affichage : 2D, rendu Compatibility**, à valider sur le PC cible. Les capacités nécessaires dépendent du matériel ; voir les [exigences officielles de Godot](https://docs.godotengine.org/en/stable/about/system_requirements.html).
- **Données : JSON** pour les régions, évolutions, événements et scénarios. Valider identifiants, coûts, références et bornes numériques avant de lancer une partie.
- **Sauvegardes : données versionnées dans le répertoire utilisateur**, écrites via un fichier temporaire puis remplacées après réussite, avec une copie de secours.
- **Export : Windows x86_64**, avec un test d'export dès le premier jalon. Godot dispose d'un [export Windows dédié](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_windows.html).
- **Suivi : GitHub**, avec une branche par fonctionnalité et des versions marquées aux jalons.

L'export peut embarquer les ressources dans l'exécutable ou les fournir dans un fichier `.pck`. Tester le mode retenu sur le PC cible ; si des fichiers annexes sont nécessaires, les distribuer ensemble. Les modèles d'export sont un prérequis, comme indiqué dans la [documentation d'export](https://docs.godotengine.org/en/stable/tutorials/export/exporting_projects.html).

## 4. Organisation du code prévue

```text
project.godot
export_presets.cfg
scenes/                 menus, carte, évolutions, bilan
scripts/simulation/     état du monde et progression quotidienne
scripts/gameplay/       achats, objectifs, événements et scénarios
scripts/ui/             affichage et commandes du joueur
scripts/persistence/    sauvegardes et paramètres
data/                   régions, connexions, évolutions et scénarios
assets/                 illustrations, sons, polices et leurs licences
tests/                  simulation, données et sauvegardes
docs/                   conception, compilation et notes de version
```

La simulation reçoit les commandes du joueur et produit un état du monde ainsi que des événements. L'interface affiche cet état sans calculer elle-même la propagation. Un pas fixe représente une journée ; la vitesse change le nombre de pas exécutés, et la pause les interrompt. Les événements aléatoires utilisent une graine et un état enregistrables afin de reproduire une partie.

## 5. Jalons de réalisation

| Jalon | Travaux | Livrable et validation |
| --- | --- | --- |
| J0 — Fondation | Créer le projet Godot, les dossiers, un menu, les paramètres de fenêtre et le profil d'export. Fixer les règles de victoire, défaite et score. | Un premier `.exe` ouvre le menu et se ferme correctement sur le PC cible. Version du moteur et procédure de compilation documentées. |
| J1 — Simulation | Construire les régions, populations, connexions, progression quotidienne, recherche du remède et états de fin. | Une partie simulée sans interface peut atteindre victoire ou défaite. Les valeurs restent bornées et les résultats sont reproductibles. |
| J2 — Partie de bout en bout | Relier le moteur à une carte de 6 régions, au choix du départ, aux statistiques, à la pause, aux vitesses et au bilan. | Un joueur peut lancer, terminer et recommencer une partie dans l'exécutable. Aucun écran de cette boucle ne reste bloquant. |
| J3 — Évolutions et réactions | Ajouter coûts, prérequis, effets, journal, détection, réactions régionales et événements temporaires. | Chaque achat applique une seule fois ses effets ; les compromis sont affichés avant achat et les réactions sont expliquées dans le journal. |
| J4 — Contenu et Dégel 2042 | Étendre la carte, ajouter les difficultés, la campagne standard, les événements climatiques et les évolutions du scénario. | Deux scénarios réellement différents sont jouables. Les routes arctiques s'ouvrent, se ferment temporairement et se rétablissent selon les règles. |
| J5 — Sauvegardes et confort | Ajouter chargement, sauvegarde automatique, paramètres, aide, tutoriel et navigation au clavier. | Après chargement, le monde, les achats, les événements et la suite de la simulation correspondent à la partie sauvegardée. |
| J6 — Équilibrage et finition | Mesurer plusieurs stratégies, ajuster les paramètres, soigner la carte, les sons, les textes et le bilan. | Les deux scénarios sont terminables ; les difficultés produisent des résultats distincts. Aucun blocage majeur ne subsiste dans les parcours testés. |
| J7 — Livraison 1.0 | Exporter, tester sur Windows, rédiger le guide, les crédits et les notes de version ; préparer la release GitHub. | Une archive complète permet de jouer hors ligne sans installer Godot. Son contenu, sa version et la machine de test sont consignés. |

Ordre de dépendance : **J0 → J1 → J2 → J3 → J4 → J5 → J6 → J7**. Conserver un exécutable jouable à chaque jalon à partir de J2. Ajouter la sauvegarde de l'état aléatoire au moteur dès J1, même si l'écran de sauvegarde arrive en J5.

## 6. Règles à fixer au jalon J0

Proposition initiale : gagner lorsque 90 % de la population a été touchée au cours de la partie, avant que le remède atteigne 100 %. Ces seuils seront ajustables dans les données du scénario et visibles avant le lancement. Une défaite survient si le remède est achevé ou si l'agent disparaît avant l'objectif.

Définir séparément personnes saines, actuellement touchées et sorties de cet état, afin de conserver la population totale. Le cumul des personnes touchées ne doit pas compter plusieurs fois une même personne. Définir aussi l'ordre de résolution lorsqu'une victoire et une défaite deviennent possibles durant la même journée ; le tester explicitement.

Le score doit combiner des éléments annoncés au joueur : jours écoulés, couverture atteinte et difficulté. Les achats ne doivent pas pouvoir rendre les points négatifs. Les vitesses de jeu ne doivent modifier ni les coûts ni les résultats d'une même séquence de décisions.

## 7. Dégel 2042 : travaux particuliers

Utiliser la [spécification du scénario](scenario-degel-2042.md) comme base, puis définir dans ses données : région initiale, calendrier des phases, routes concernées, durées des tempêtes et coefficients abstraits d'adaptation.

1. **Isolement :** démarrage arctique avec peu de connexions.
2. **Ouverture :** activation annoncée des routes maritimes saisonnières.
3. **Instabilité :** interruption temporaire de certaines routes et compte à rebours visible.
4. **Mobilisation :** accélération de la recherche mondiale, annoncée au joueur.

Les évolutions Adaptation polaire, Mobilité saisonnière et Résilience climatique devront avoir des effets mesurables. Chaque phase, route modifiée et événement actif doit être sauvegardé. Ajouter des tests spécifiques aux transitions et au rétablissement des routes.

## 8. Interface et améliorations prioritaires

- La carte occupe la zone centrale ; une sélection affiche les statistiques de la région.
- Le jour, les points d'évolution et la recherche du remède restent visibles pendant la partie.
- Chaque évolution affiche son coût, son effet et ses prérequis ; un achat indisponible explique pourquoi.
- Le journal distingue les événements nouveaux de ceux déjà consultés.
- Les statistiques utilisent des nombres et des libellés en plus de la couleur.
- La pause, les vitesses et les raccourcis sont visibles ; les fenêtres peuvent être fermées au clavier.
- Les réglages couvrent son, mode d'affichage et réduction des animations.
- Le bilan explique la cause du résultat et montre les principales décisions de la partie.

Priorité de réalisation : **boucle jouable → décisions compréhensibles → scénario → confort → finition visuelle**.

## 9. Vérifications nécessaires

| Domaine | Vérification |
| --- | --- |
| Simulation | Conservation de la population, bornes des valeurs, recherche bornée entre 0 et 100 %, propagation limitée aux connexions actives |
| Achats | Points insuffisants, prérequis manquant, double achat, application exacte des effets |
| Temps | Pause sans progression, reprise sans saut, mêmes résultats pour la même suite de pas et commandes à différentes vitesses |
| Événements | Activation, durée, expiration, absence de cumul accidentel et restauration après chargement |
| Sauvegardes | Aller-retour complet, état aléatoire préservé, fichier endommagé et version inconnue traités sans crash ni perte de la copie valide |
| Équilibrage | Plusieurs graines et stratégies ; mesurer durée, fréquence des victoires et choix peu utilisés, sans imposer un taux de victoire arbitraire |
| Interface | Parcours au clavier, textes français, redimensionnement, plein écran, paramètres conservés |
| Exécutable | Lancement depuis un chemin avec espaces et accents, hors ligne, sans éditeur Godot installé ; nouvelle partie, chargement et fermeture |

Pour la performance, viser une interface fluide à 60 images par seconde sur la machine de référence et une simulation accélérée qui ne bloque pas les commandes. Consigner la configuration et les mesures ; adapter l'objectif si le matériel ne le permet pas. Vérifier au minimum 1280 × 720 et 1920 × 1080.

## 10. Gestion des risques et livraison

| Risque concret | Réponse prévue |
| --- | --- |
| Le jeu ne s'exporte pas sur le PC cible | Exporter au J0 et après chaque jalon important |
| Le périmètre devient trop large | Stabiliser la partie de 6 régions avant d'étendre le contenu |
| Une stratégie domine toutes les autres | Comparer plusieurs stratégies et ajuster les effets dans les données |
| Le nouveau scénario reste seulement narratif | Tester ses modifications de routes, de phases et d'évolutions |
| Un chargement change la suite de la partie | Enregistrer état complet, version des données et état aléatoire |
| La carte devient illisible | Vérifier les régions, les valeurs et les contrôles à la résolution minimale |

Chaque fonctionnalité sera suivie par une tâche indiquant le résultat attendu, ses dépendances et son test d'acceptation. Un jalon est terminé lorsque son livrable a été exécuté et vérifié ; un commit seul ne suffit pas. Les tests automatisés du moteur pourront être ajoutés au dépôt, puis au processus GitHub Actions une fois la compilation locale reproductible. Les releases Windows seront publiées dans les releases du dépôt, avec notes de version et crédits.

Aucune date ferme n'est fixée avant J2. À ce stade, estimer le reste à partir du temps réellement passé et de la validation du prototype. Cela évite de présenter comme certaine une durée encore inconnue.

## 11. Première étape à entreprendre

**Commencer par J0 : un projet Godot minimal et un premier exécutable Windows.** Ensuite, construire une partie complète sur 6 régions avant de produire les illustrations et les 24 régions finales. Le prochain livrable sera donc un `.exe` de fondation, puis un prototype réellement jouable au J2.
