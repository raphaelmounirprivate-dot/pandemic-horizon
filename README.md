# Pandemic Horizon

Projet de jeu de stratégie original pour PC Windows, inspiré du genre de la simulation de pandémie. Le dépôt porte le nom de travail `plague-inc-evolved` choisi pour le projet ; le jeu sera intitulé **Pandemic Horizon**.

## État du projet

La 0.19 ajoute mouvements réduits, lecture agrandie et sons facultatifs avec volume. Le candidat Windows et son archive sont vérifiés ; les essais joueurs, auditifs et sur un second PC restent à faire. Voir le [point 24](docs/suivi/24-confort-distribution.md) et le [protocole joueurs](docs/TESTS-JOUEURS.md). Les sauvegardes de chaque étape se trouvent dans build/checkpoints/.

La 0.18 ajoute NACRE, les fiches de scénarios et un profil enrichi facultatif de 18/21 évolutions avec huit événements supplémentaires. Voir le [point 23](docs/suivi/23-contenu-enrichi.md) et les [240 comparaisons](docs/EQUILIBRAGE-0.18-ENRICHI.md). Les parties classiques conservent leurs règles.

La 0.17 ajoute « Monde [F3] » : courbes, achats datés, effets et actualités. Le nouvel historique reste compatible avec la lecture des anciennes parties, dont le passé absent est signalé. Voir le [point 22](docs/suivi/22-actualites-historique.md).

La 0.16 sépare la consultation et l'achat d'une évolution : prérequis reliés, sélection persistante et fiche complète, puis bouton Évoluer explicite. Le [point 21](docs/suivi/21-evolutions-integrees.md) consigne la vérification et la sauvegarde de cette étape.

La 0.15 ajoute les avions, bateaux et véhicules terrestres sur les échanges observés, avec filtre de transport et terrain illustratif enrichi. Voir le [point 20](docs/suivi/20-transports-visibles.md).

La 0.14 ajoute l'exploration de la carte : zoom à la molette, déplacement au bouton droit ou central, boutons − / + / Vue mondiale, clavier et recentrage des régions au focus. Les achats et choix restent fixes. Les écrans larges utilisent tout l'espace disponible. Voir le [point 19](docs/suivi/19-exploration-carte.md).

**Candidat 0.19 développé.** Deux scénarios sont jouables sur **24 régions** sous Godot 4.7.2 : Standard et Dégel 2042. Le réseau fictif contient 38 connexions, plus une route arctique propre à Dégel, et 3,53 millions d'habitants fictifs. Le menu propose trois difficultés avec leurs effets affichés. Dégel impose le départ en Boréale et ajoute quatre phases, des routes saisonnières, des tempêtes et trois évolutions climatiques. Détection, réactions, événements, remède, pause, vitesses, journal et bilan sont implémentés. Trois sauvegardes manuelles et une automatique permettent de reprendre en pause, avec récupération de la copie précédente si le fichier principal est endommagé. Un tutoriel facultatif de six exercices et l'aide F1 accompagnent la découverte du jeu.

L'exécutable actuel se trouve dans `build/windows-0.19.0/PandemicHorizon.exe`, hors de Git. Les exports sont séparés par version ; les anciens dossiers conservent leurs versions précédentes. Aucune release binaire GitHub n'est publiée à ce stade.

## Lancer et développer le prototype

La 0.13 remplace la grille par une carte du monde nocturne : foyers et couverture en rouge, échanges animés dans le sens réel de propagation, routes fermées signalées. Les six ou neuf évolutions et les choix logistiques sont intégrés au même écran, sans défilement des achats. La pause fige les déplacements. Les règles, tarifs et sauvegardes restent ceux de la 0.12. Voir le [point 17](docs/suivi/17-monde-et-interface.md).

La version 0.12 réduit le soutien des ports à **3 points** pour les nouvelles parties. À mer, remède et calendrier identiques, ce tarif gagne cinq victoires sans perdre de Relais face au tarif 6 dans les 135 cas appariés avec réserve. Les sauvegardes 0.11 gardent exactement leur tarif de 6 points ; le format 4 conserve ce profil. Voir le [point 16](docs/suivi/16-parametres-logistiques.md) et le [rapport de 1 620 parties](docs/EQUILIBRAGE-0.12-PARAMETRES.md). Les autres effets restent inchangés et l'équilibrage humain reste à éprouver.

La version 0.11 ajoute une décision logistique facultative dans Dégel, désactivée par défaut. Au jour 28, choisir un soutien des ports à 6 points, une limitation gratuite des échanges ou le maintien neutre. Les effets maritimes et sur le remède durent douze journées à partir du lendemain. Les coûts et contreparties sont présentés avant validation ; F2 permet de revenir au choix jusqu'au J30 inclus. Le format 3 conserve cette décision ; les parties reconnues 0.7 à 0.10 restent compatibles, sans nouvel événement rétroactif. Voir le [point 14](docs/suivi/14-decision-logistique.md).

Le [point 15](docs/suivi/15-analyse-decisions.md) compare 1 080 parties : quatre variantes de décision, avec achats habituels ou réserve commune de 6 points. Le [rapport](docs/EQUILIBRAGE-0.11-DECISIONS.md) sépare victoires, Relais, progression du remède et dates des achats. Le maintien reste identique à la désactivation. Le soutien peut accélérer les Relais mais son coût retarde les achats et réduit les réussites dans cet échantillon ; les coefficients restent provisoires et conservés. Reproduction : `dev.ps1 BalanceDecisions`. Aucun essai humain d'équilibrage n'est revendiqué.

La version 0.10 ajoute « Relais arctiques » dans Dégel : après les tempêtes, cumuler 1 000 unités d'échange sur chacune des deux routes saisonnières sortant de Boréale avant la fin du jour 54. « Premiers relais » reste disponible en Standard. Ces objectifs sont désactivés par défaut, sans bonus de points ou de score, suivis en partie et conservés en sauvegarde. Les parties 0.7 à 0.9 sont compatibles ; les objectifs 0.9 restent conservés sans ajout rétroactif du nouveau. Les parties 0.6 nécessitent toujours leur ancien exécutable. Voir le [point 12](docs/suivi/12-relais-arctiques.md).

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

Le suivi des spécialisations figure dans [le point de contrôle 08](docs/suivi/08-specialisations.md). Le [point 09](docs/suivi/09-ordres-achats.md) et le [rapport des ordres d'achat](docs/EQUILIBRAGE-0.8-ORDRES.md) approfondissent leur équilibrage. Les mesures de la carte 0.4 restent dans [le rapport historique](docs/EQUILIBRAGE-0.4.md). Le contenu final et les essais avec des joueurs restent à réaliser.

Le [point 11](docs/suivi/11-analyse-objectifs.md) et le [rapport Premiers relais](docs/EQUILIBRAGE-0.9-OBJECTIFS.md) comparent l'objectif et la victoire principale selon les départs, difficultés et stratégies, avec des témoins sans objectif. L'outil se lance avec `dev.ps1 BalanceObjectives`.

Le [point 13](docs/suivi/13-strategies-climatiques.md) et le [rapport climatique](docs/EQUILIBRAGE-0.10-CLIMATIQUE.md) approfondissent les ordres d'achat de Dégel et leurs dates, via `dev.ps1 BalanceArctic`. Les règles restent celles du prototype 0.10.
