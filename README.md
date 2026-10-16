# Pandemic Horizon

Projet de jeu de stratégie original pour PC Windows, inspiré du genre de la simulation de pandémie. Le dépôt porte le nom de travail `plague-inc-evolved` choisi pour le projet ; le jeu sera intitulé **Pandemic Horizon**.

## État du projet

**Prototype 0.7 développé.** Deux scénarios sont jouables sur **24 régions** sous Godot 4.7.2 : Standard et Dégel 2042. La carte schématique contient 38 connexions, plus une route arctique propre à Dégel, et 3,53 millions d'habitants fictifs. Le menu propose trois difficultés avec leurs effets affichés. Dégel impose le départ en Boréale et ajoute quatre phases, des routes saisonnières, des tempêtes et trois évolutions climatiques. Détection, réactions, événements, remède, pause, vitesses, journal et bilan sont implémentés. Trois sauvegardes manuelles et une automatique permettent de reprendre en pause, avec récupération de la copie précédente si le fichier principal est endommagé. Un tutoriel facultatif de six exercices et l'aide F1 accompagnent la découverte du jeu.

L'exécutable actuel se trouve dans `build/windows-0.7.0/PandemicHorizon.exe`, hors de Git. Les exports sont séparés par version ; les anciens dossiers conservent leurs versions précédentes. Aucune release binaire GitHub n'est publiée à ce stade.

## Lancer et développer le prototype

La version 0.7 différencie les liaisons terrestres, aériennes et maritimes, leurs coefficients et leurs ralentissements temporaires. La carte, les compteurs régionaux et F1 → Transports expliquent les destinations et les états. Les sauvegardes 0.7 sont séparées : les anciennes parties 0.6 restent accessibles avec l'ancien exécutable, sans migration automatique.

Sous Windows, depuis la racine du dépôt :

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/setup-godot.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 Import
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 Test
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 Play
```

Le script télécharge l'éditeur officiel et vérifie son empreinte SHA512. Pour compiler un exécutable autonome, voir [les instructions de développement](docs/DEVELOPPEMENT.md).

- [Guide joueur](docs/GUIDE-JOUEUR.md) : commandes et limites du prototype.
- [Points de reprise](docs/suivi/00-index.md) : état réel, validations et prochains travaux.
- [Règles du prototype](docs/REGLES.md) : paramètres actuellement implémentés.

## Concept

Piloter l'évolution d'un agent fictif dans un monde stylisé, gérer les points d'évolution et adapter sa stratégie aux réactions des régions. Une partie alterne propagation, décisions d'évolution et événements mondiaux, jusqu'à une victoire ou une défaite clairement expliquée.

Le jeu utilisera un code, une interface, des textes et des ressources graphiques originaux. Il sera autonome et ne nécessitera pas d'installation de Plague Inc: Evolved.

## Périmètre prévu pour la version 1.0

- Carte mondiale interactive organisée en régions, avec des statistiques lisibles.
- Choix de la région de départ et de la difficulté.
- Simulation abstraite de propagation, de transports et de réponse sanitaire.
- Points d'évolution et améliorations réparties entre transmission, adaptation et symptômes fictifs.
- Recherche d'un remède, réactions régionales et événements.
- Pause, vitesses de simulation, aide et redémarrage.
- Sauvegarde et chargement locaux.
- Fin de partie avec résultat, score et bilan.
- Interface et explications en français.
- Exécutable Windows pouvant fonctionner hors ligne.

## Nouveau scénario : Dégel 2042

Un agent fictif apparaît dans une région arctique après un dégel exceptionnel. Les températures évoluent au fil de la partie, les routes maritimes changent et les infrastructures de santé subissent des tensions.

Ce scénario doit modifier réellement les paramètres et les événements de la simulation :

1. Départ dans une région froide et isolée.
2. Réchauffement progressif, influençant les régions et les déplacements.
3. Ouverture de routes maritimes arctiques.
4. Événements de tempête et d'interruption des transports.
5. Arbitrages entre adaptation au froid, mobilité et discrétion.

Le détail figure dans [docs/scenario-degel-2042.md](docs/scenario-degel-2042.md).

## Améliorations prévues

- Afficher les effets, les coûts et les compromis de chaque évolution avant achat.
- Journal chronologique expliquant les événements majeurs.
- Statistiques régionales et mondiales, avec légende et valeurs chiffrées.
- Conditions de victoire et de défaite visibles dès le début.
- Commandes au clavier et interface adaptée à plusieurs tailles de fenêtre.
- Scénarios décrits dans des fichiers de données pour faciliter leur ajout.

## Plan détaillé

Le [plan de développement](docs/plan-developpement.md) définit le périmètre de la version 1.0, les choix techniques proposés, les jalons et leurs critères de validation. Il prévoit Godot pour le jeu 2D et un premier export Windows dès la fondation.

## Étapes de réalisation

1. Construire et tester le moteur de simulation.
2. Ajouter la carte, les contrôles et les évolutions.
3. Implémenter le scénario standard et Dégel 2042.
4. Ajouter sauvegardes, tutoriel et bilan de partie.
5. Vérifier l'équilibrage et les parcours de jeu.
6. Générer et tester l'exécutable Windows.

Le suivi des transports figure dans [le point de contrôle 07](docs/suivi/07-transports.md) et les mesures de la carte dans [le rapport d'équilibrage](docs/EQUILIBRAGE-0.4.md). Le contenu final et les essais avec des joueurs restent à réaliser.
