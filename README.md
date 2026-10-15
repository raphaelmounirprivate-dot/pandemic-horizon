# Pandemic Horizon

Projet de jeu de stratégie original pour PC Windows, inspiré du genre de la simulation de pandémie. Le dépôt porte le nom de travail `plague-inc-evolved` choisi pour le projet ; le jeu sera intitulé **Pandemic Horizon**.

## État du projet

**Cadrage initial.** Ce dépôt décrit le jeu à construire. Aucun jeu complet ni exécutable Windows n'est encore livré. Les éléments ci-dessous sont des fonctionnalités prévues, pas des fonctionnalités déjà implémentées.

## Concept

Piloter l'évolution d'un agent fictif dans un monde stylisé, gérer les points d'évolution et adapter sa stratégie aux réactions des régions. Une partie alterne propagation, décisions d'évolution et événements mondiaux, jusqu'à une victoire ou une défaite clairement expliquée.

Le jeu utilisera un code, une interface, des textes et des ressources graphiques originaux. Il sera autonome et ne nécessitera pas d'installation de Plague Inc: Evolved.

## Première version jouable prévue

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

## Étapes de réalisation

1. Construire et tester le moteur de simulation.
2. Ajouter la carte, les contrôles et les évolutions.
3. Implémenter le scénario standard et Dégel 2042.
4. Ajouter sauvegardes, tutoriel et bilan de partie.
5. Vérifier l'équilibrage et les parcours de jeu.
6. Générer et tester l'exécutable Windows.

La technologie et les instructions de compilation seront documentées lorsque la première version sera implémentée. Aucune commande de lancement n'est disponible à ce stade.
