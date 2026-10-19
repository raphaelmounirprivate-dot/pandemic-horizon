# Points de reprise du développement

Lire ce fichier au début d'une session, puis le dernier point de contrôle. Conserver les résultats réels et distinguer prévu, implémenté, testé et publié.

- [Plan et besoins](../plan-developpement.md) : objectifs et tâches DEV-01 à DEV-16.
- [Point 01 — Prototype](01-prototype.md) : premier lot, validations et suite.
- [Point 02 — J3 réactions et événements](02-j3-reactions-evenements.md) : historique du prototype 0.2.
- [Point 03 — J4 Dégel et difficultés](03-j4-degel-difficultes.md) : historique du prototype 0.3.
- [Point 04 — J4 carte de 24 régions](04-j4-carte24.md) : historique du prototype 0.4.
- [Point 05 — J5 sauvegardes](05-j5-sauvegardes.md) : historique du prototype 0.5.
- [Point 06 — J5 tutoriel et aide](06-j5-tutoriel-aide.md) : historique du prototype 0.6.
- [Point 07 — Transports](07-transports.md) : historique du prototype 0.7.
- [Point 08 — Spécialisations](08-specialisations.md) : prototype 0.8, compatibilité 0.7 et première exploration d'équilibrage.
- [Point 09 — Ordres d'achat](09-ordres-achats.md) : comparaison appariée des stratégies et traces d'achats ; règles du jeu toujours en 0.8.
- [Point 10 — Objectif facultatif](10-objectif-facultatif.md) : prototype 0.9, Premiers relais et compatibilité des parties 0.7/0.8.
- [Point 11 — Analyse des objectifs](11-analyse-objectifs.md) : mesures par départ et stratégie, témoins sans objectif et matrice des deux résultats ; jeu toujours en 0.9.
- [Point 12 — Relais arctiques](12-relais-arctiques.md) : prototype 0.10, objectif Dégel sur les flux saisonniers et compatibilité 0.9.
- [Point 13 — Stratégies climatiques](13-strategies-climatiques.md) : ordres précoces, chronologie des achats et résultats appariés ; jeu toujours en 0.10.
- [Point 14 — Décision logistique](14-decision-logistique.md) : prototype 0.11, événement facultatif à choix explicites et compatibilité 0.10.
- [Point 15 — Analyse des décisions](15-analyse-decisions.md) : 1 080 parties, budgets et choix effectifs, contrastes des résultats et dates ; coefficients 0.11 conservés.
- [Point 16 — Paramètres logistiques](16-parametres-logistiques.md) : prototype 0.12, 1 620 parties et soutien réduit à 3 points ; profil historique 0.11 conservé.
- [Point 17 — Monde et interface](17-monde-et-interface.md) : prototype 0.13, carte géographique, propagation et flux animés, évolutions et choix intégrés sans défilement.
- [Point 18 — Feuille de route](18-feuille-de-route.md) : organisation documentaire des inspirations, six lots et vingt tâches proposées ; aucun changement du jeu.
- [Point 19 — Exploration de la carte](19-exploration-carte.md) : prototype 0.14, zoom, déplacement, retour monde, focus et écrans larges ; lot A.
- [Point 20 — Transports visibles](20-transports-visibles.md) : prototype 0.15, véhicules, filtres, terrain et comparaison de rendu ; sauvegarde distincte du lot B.
- [Point 21 — Évolutions intégrées](21-evolutions-integrees.md) : prototype 0.16, relations, fiche et achat explicite ; sauvegarde distincte du lot C.
- [Point 22 — Actualités et historique](22-actualites-historique.md) : prototype 0.17, courbes, achats datés, annonces et reprise des anciennes parties sans passé inventé.
- [Point 23 — Contenu enrichi](23-contenu-enrichi.md) : prototype 0.18, agent NACRE, fiches de scénarios, profil enrichi facultatif et sauvegarde format 5.
- [Point 24 — Confort et distribution](24-confort-distribution.md) : prototype 0.19, mouvements réduits, lecture agrandie, sons, candidat Windows ; essais humains restant à faire.
- [Point 25 — Aléas et résilience](25-aleas-resilience.md) : prototype 0.20, incidents tirés par graine, compétences de protection, Réseaux fragiles et format 6.
- [Point 26 — Repères des incidents](26-reperes-incidents.md) : prototype 0.21, aléas locaux situés sur la carte, F4/Local ; règles et formats inchangés.
- [Point 27 — Crises réactives et Double relais](27-crises-reactives.md) : prototype 0.22, ciblage au déclenchement, réponses à la panne, Double relais obligatoire et format 7.
- [Point 28 — Familles et validation après audit](28-familles-validation.md) : candidat 0.23, familles de compétences, fiches comparées, vues extraites, livraison et réserve AVG.
- [Point 29 — Dette technique, CI et rangement](29-dette-technique-ci.md) : candidat 0.23 inchangé pour le joueur ; start_with, main.gd à 810 lignes, typage strict de la simulation, CI allégée et gdlint, docs rangés, renommage du dépôt.

## Documents liés

- [Historique des versions](../../CHANGELOG.md) : résumé de chaque version.
- [Feuille de route](../roadmap/README.md) : backlog, audits et décisions ouvertes.
- [Règles effectives](../REGLES.md) · [Développement](../DEVELOPPEMENT.md) · [Architecture](../ARCHITECTURE.md) · [Guide joueur](../GUIDE-JOUEUR.md).

## État et priorités au 19 octobre 2026

Candidat 0.23 (point 28), plus des changements techniques sans effet sur les règles ni les sauvegardes (point 29 et section « Non publié » du [CHANGELOG](../../CHANGELOG.md)). Implémenté et testé automatiquement ; **aucun essai humain, aucun essai sur un second PC, aucune release publiée.**

1. Trois sessions joueurs exploratoires ([protocole](../tests-joueurs/README.md)) ; le registre `resultats.csv` est encore vide.
2. Recontrôle de la livraison avec AVG actif et signalement du faux positif ([ANTIVIRUS.md](../ANTIVIRUS.md)).
3. Après les sessions : intérêt des réponses de crise (sans effet sur les taux de victoire en 270 simulations), létalité, lisibilité des objectifs.
4. Avant la 1.0 : [décision sur les formats de sauvegarde](../roadmap/07-decision-formats-sauvegarde.md).

Pour chaque lot livré : créer `30-<lot>.md` (périmètre, fichiers principaux, tests exécutés, limites, prochaine action), puis mettre à jour cet index, le backlog et le CHANGELOG.
