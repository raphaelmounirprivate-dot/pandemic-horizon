# Historique des versions

Du plus récent au plus ancien. Toutes les versions sont des **candidats de prototype** : implémentées et testées automatiquement, jamais essayées par des joueurs externes, sans release binaire GitHub. Le détail de chaque lot est dans les [points de suivi](docs/suivi/00-index.md) ; les notes jointes aux archives sont dans `docs/versions/NOTES-VERSION-*.md`.

## 0.26.0 — situations stratégiques, 21 octobre 2026

Crises liées à l’état du monde (cinq situations à réponses propres), ONDE décalé des décisions, Discrétion temporaire qui retarde la détection, contrepartie de Mobilité (remède ×1,15), ligne « En cours » des effets actifs. Profil `strategy-0.26`, format 9 ; parties 0.25 conservées et protégées par six références figées. Voir le [point 37](docs/suivi/37-situations-strategiques.md). Aucun push ni nouvelle release par ce lot.

## 0.25.0 — candidat stratégique local, 21 octobre 2026

Profil facultatif avec trois agents, crises récurrentes, rythme ralenti, bilan descriptif et ambiance facultative. Format 8 séparé, formats 1–7 conservés. Voir le [point 36](docs/suivi/36-profil-strategique.md) pour les vérifications réellement exécutées et leurs limites. Aucun push ni nouvelle release par ce lot.

## 0.24.1 — points et compétences achetables mis en évidence (21 octobre 2026)

Écran Évolution : points en grand avec le prochain gain, compétences achetables à fond teinté, contour épais et marque « + », décompte par onglet. Règles et sauvegardes inchangées. [Point 35](docs/suivi/35-evolution-mise-en-evidence.md), 6 491 contrôles.

## 0.24 — écrans dédiés (19-21 octobre 2026)

Aucun changement de règles, de coefficients ni de format de sauvegarde ; une partie 0.23 se charge telle quelle. [Notes](docs/versions/NOTES-VERSION-0.24.md) · [Point 29](docs/suivi/29-dette-technique-ci.md) (technique) · [point 30](docs/suivi/30-ecrans-dedies.md) (écrans dédiés, 6 455 contrôles).

- Dépôt renommé `pandemic-horizon`.
- Kit joueurs : conduite à tenir en cas d'alerte antivirus ; procédure de signalement de faux positif ([ANTIVIRUS.md](docs/ANTIVIRUS.md)).
- `World.start_with(options)` : options nommées et validées ; `start()` conservée pour les tests historiques.
- `main.gd` ramené de 1 089 à 810 lignes : écran des sauvegardes et smoke test d'export extraits ; puis à 664 lignes avec l'écran de jeu dans `game_view.gd`, et à 597 lignes avec le tutoriel et le chargement extraits (rendu identique à l'octet près).
- Lanceurs d'équilibrage rangés dans `scripts/analysis/`, exclu de l'export par motif, avec un test de garde.
- Typage statique obligatoire dans `scripts/simulation/`, puis dans `scripts/persistence/` ; règles par dossier pour la suite.
- CI : pas d'exécution pour la documentation seule, exécutions dépassées annulées hors `main`, Godot en cache, artefacts conservés 14 jours, job `gdlint`.
- **Interface : écran Évolution dédié** (touche E) avec un onglet par famille, un arbre de gauche à droite à liens visibles, des nœuds au nom complet et à l'état écrit, une fiche en sections ; la carte récupère la place de l'ancienne grille. Aucune règle modifiée.
- **Interface : écran titre et « Nouvelle partie » en trois étapes** (scénario, difficulté et options, départ choisi sur la carte), cartes de choix à état écrit, plus aucune liste déroulante dans le menu. Aucune règle modifiée.
- **Interface : bilan de fin illustré** : issue en mots et en symbole, cartes jour / couverture / remède / score avec barres, courbe avec objectif 90 %, moments clés tirés du journal, boutons sur une rangée. Aucune règle modifiée.
- **Interface : aide F1 sans liste déroulante** : dix sujets en boutons, sujet affiché marqué en toutes lettres. Textes inchangés. `main.gd` ramené à 446 lignes (temps, raccourcis, préférences, flux Évolution extraits) ; typage statique obligatoire dans `scripts/gameplay/`. [Point 34](docs/suivi/34-gameplay-type-aide.md), 6 486 contrôles.
- Réponses aux crises : effet sur les issues reporté après les sessions joueurs ; [note de décision](docs/roadmap/07-decision-formats-sauvegarde.md) sur l'avenir des formats de sauvegarde.

## 0.23 — compétences lisibles et vues séparées

Familles Diffusion, Discrétion et Résilience ; légende commune ; ascendance complète dans le profil enrichi ; fiche avec coefficients avant/après et raison de refus. Menu, paramètres et bilan extraits de `main.gd`. Kit de sessions joueurs et matrice de compatibilité joints au ZIP. 6 061 contrôles réussis. [Point 28](docs/suivi/28-familles-validation.md) · [notes](docs/versions/NOTES-VERSION-0.23.md).

## 0.22 — crises réactives et Double relais

Profil facultatif `tactics-0.22`, sauvegarde 7. Les aléas régionaux ciblent au déclenchement un foyer actif avec des sains (48/76 incidents sans occasion de croissance avant, 0/76 après, en protocole apparié). Trois réponses à la première panne aérienne : détour, subir, occasion. Réseaux fragiles impose Double relais avant J60. [Point 27](docs/suivi/27-crises-reactives.md) · [notes](docs/versions/NOTES-VERSION-0.22.md) · [rapport](docs/equilibrage/EQUILIBRAGE-0.22-REACTIF.md).

## 0.21 — repères des incidents

Pictogrammes des aléas locaux sur la carte, survol et parcours F4/Local ; effets mondiaux signalés comme mondiaux sans localisation inventée. Règles et formats 4/5/6 inchangés. Clôturée au commit `9018202`. [Point 26](docs/suivi/26-reperes-incidents.md) · [notes](docs/versions/NOTES-VERSION-0.21.md).

## 0.20 — aléas et résilience

Option **Aléas et résilience** : 12 incidents tirés par graine parmi huit types, trois compétences de protection et le scénario **Réseaux fragiles**. Format 6 ; les anciennes parties conservent leurs règles. [Point 25](docs/suivi/25-aleas-resilience.md) · [140 parties comparées](docs/equilibrage/EQUILIBRAGE-0.20-ALEAS.md) · [notes](docs/versions/NOTES-VERSION-0.20.md).

## 0.19 — confort et distribution

Mouvements réduits, lecture agrandie et sons facultatifs avec volume. Candidat Windows et archive vérifiés. [Point 24](docs/suivi/24-confort-distribution.md) · [notes](docs/versions/NOTES-VERSION-0.19.md).

## 0.18 — contenu enrichi

Agent NACRE, fiches de scénarios et profil enrichi facultatif de 18/21 évolutions avec huit événements supplémentaires. Les parties classiques conservent leurs règles. [Point 23](docs/suivi/23-contenu-enrichi.md) · [240 comparaisons](docs/equilibrage/EQUILIBRAGE-0.18-ENRICHI.md).

## 0.17 — actualités et historique

« Monde [F3] » : courbes, achats datés, effets et actualités. Les anciennes parties restent lisibles et leur passé absent est signalé. [Point 22](docs/suivi/22-actualites-historique.md).

## 0.16 — évolutions intégrées

Consultation et achat séparés : prérequis reliés, sélection persistante, fiche complète et bouton Évoluer explicite. [Point 21](docs/suivi/21-evolutions-integrees.md).

## 0.15 — transports visibles

Avions, bateaux et véhicules terrestres sur les échanges observés, filtre de transport et terrain illustratif. [Point 20](docs/suivi/20-transports-visibles.md).

## 0.14 — exploration de la carte

Zoom à la molette, déplacement au bouton droit ou central, boutons − / + / Vue mondiale, clavier et recentrage au focus ; écrans larges exploités. [Point 19](docs/suivi/19-exploration-carte.md).

## 0.13 — monde et interface

Carte du monde nocturne : foyers et couverture en rouge, échanges animés dans le sens réel de propagation, routes fermées signalées. Évolutions et choix logistiques intégrés au même écran, sans défilement. Règles, tarifs et sauvegardes de la 0.12. [Point 17](docs/suivi/17-monde-et-interface.md).

## 0.12 — paramètres logistiques

Soutien des ports réduit à **3 points** pour les nouvelles parties ; à conditions identiques, cinq victoires de plus sans perte de Relais face au tarif 6 sur 135 cas appariés. Les sauvegardes 0.11 gardent leur tarif de 6 points ; format 4. [Point 16](docs/suivi/16-parametres-logistiques.md) · [1 620 parties](docs/equilibrage/EQUILIBRAGE-0.12-PARAMETRES.md).

## 0.11 — décision logistique

Décision facultative au jour 28 de Dégel : soutien des ports, limitation gratuite des échanges ou maintien neutre ; effets pendant douze jours ; F2 jusqu'au J30. Format 3. [Point 14](docs/suivi/14-decision-logistique.md). Analyse de 1 080 parties : [point 15](docs/suivi/15-analyse-decisions.md) · [rapport](docs/equilibrage/EQUILIBRAGE-0.11-DECISIONS.md).

## 0.10 — relais arctiques

Objectif facultatif « Relais arctiques » dans Dégel (1 000 unités sur chacune des deux routes saisonnières de Boréale avant la fin du J54) ; « Premiers relais » reste en Standard. Parties 0.7 à 0.9 compatibles ; les parties 0.6 exigent leur ancien exécutable. [Point 12](docs/suivi/12-relais-arctiques.md) · stratégies climatiques : [point 13](docs/suivi/13-strategies-climatiques.md), [rapport](docs/equilibrage/EQUILIBRAGE-0.10-CLIMATIQUE.md).

## 0.2 à 0.9 — fondations

Prototype, réactions et événements, Dégel 2042 et difficultés, carte de 24 régions, sauvegardes, tutoriel et aide, transports, spécialisations, ordres d'achat et objectif facultatif : [points 01 à 11](docs/suivi/00-index.md). Rapports : [0.4](docs/equilibrage/EQUILIBRAGE-0.4.md), [0.8 ordres d'achat](docs/equilibrage/EQUILIBRAGE-0.8-ORDRES.md), [0.9 objectifs](docs/equilibrage/EQUILIBRAGE-0.9-OBJECTIFS.md).
