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
- [Règles effectives](../REGLES.md) : paramètres du code actuel.
- [Développement](../DEVELOPPEMENT.md) : préparation, tests et export.
- [Guide joueur](../GUIDE-JOUEUR.md) : parcours et limites.

## Priorités après la carte étendue

1. Compléter l'essai physique souris/clavier, plein écran et défilement du journal ; organiser un essai sur un autre PC Windows. Le parcours synthétique Godot est testé.
2. Éprouver le tutoriel et l'aide contextuelle auprès de joueurs débutants. Les fonctionnalités de J5 sont implémentées : sauvegardes en 0.5, tutoriel facultatif et aide F1 en 0.6 ; la compréhension et le confort réels restent à valider.
3. Mesurer les trois options logistiques par des simulations appariées avec témoin sans décision : achats identiques tentés, coûts réels et dates conservés, objectifs et victoire séparés. La décision 0.11 reste facultative et ses coefficients provisoires. Conserver les références 0.7 à 0.10 ; ne pas confondre mesures automatiques et compréhension humaine.
4. J6/J7 : finition et release distribuable.

Créer `15-<lot>.md` pour la prochaine livraison. Y noter périmètre, fichiers principaux, tests exécutés, limites et prochaine action. Mettre à jour cet index à chaque lot livré.
