# Feuille de route — suite de Pandemic Horizon

Date : 18 octobre 2026. Candidat courant 0.23 : familles, fiches et vues extraites. La 0.22 est clôturée au commit 2b65f07 et sa CI est réussie. Essais humains à réaliser. Voir audit et point 28.

Ce dossier organise le développement à venir à partir des captures fournies par le joueur. Les éléments marqués « proposé » ne sont pas encore développés. Les tâches terminées sont identifiées dans le backlog et reliées à leur point de suivi.

## Documents à lire

1. [Inspirations et direction](01-inspirations.md) : ce que les références apportent au projet.
2. [Lots et ordre de réalisation](02-lots.md) : périmètre, dépendances et conditions de livraison.
3. [Liste des tâches](03-backlog.md) : identifiants stables et état de chaque tâche.
4. [Validation et modèle de fiche](04-validation.md) : vérifier un lot et préparer le suivant.
5. [Analyse du 18 octobre 2026](05-audit-2026-10-18.md) : état local/publié, mesures des aléas et améliorations classées par priorité.
6. [Analyse du 19 octobre 2026](06-analyse-2026-10-19.md) : lecture extérieure du dépôt, risques P0 à P2.
7. [Décision à prendre : formats de sauvegarde](07-decision-formats-sauvegarde.md) : options avant la 1.0, recommandation, non tranché.

Le [plan général](../plan-developpement.md) conserve les objectifs de la version 1.0. Ce dossier détaille la suite immédiate et les pistes ultérieures. Les [points de suivi](../suivi/00-index.md) enregistrent ce qui a réellement été décidé, développé, testé et publié. Le [point 18](../suivi/18-feuille-de-route.md) consigne la création de cette organisation.

## Priorité proposée

Les lots A à F sont implémentés techniquement et vérifiés automatiquement. CNT-04 et FIN-03 restent partiels : essais physiques, auditifs et joueurs à consigner dans TESTS-JOUEURS.md. La version 0.23 reste candidate : essais humains à consigner. Une sauvegarde vérifiée distincte est créée entre les étapes avec scripts/checkpoint.ps1.

Les étiquettes 0.14 et suivantes sont des versions candidates, sans date de livraison engagée. Un lot peut être fractionné s'il devient trop large.

## Règles de suivi

- Chaque tâche possède un identifiant, un statut et un critère de fin. Ne cocher qu'après vérification.
- Statuts : proposé → prêt → en cours → à vérifier → terminé. « Différé » conserve une idée hors du prochain lot.
- Un seul lot principal en cours. Mettre à jour le backlog et créer un point de suivi à chaque livraison.
- Garder l'interface française, les choix intégrés et les sauvegardes reconnues. Les changements de règles nécessitent leurs propres mesures.
- Les captures de référence inspirent les fonctions et l'ambiance ; les ressources visuelles du jeu doivent avoir leur propre provenance.

## Extension demandée : aléas et résilience

La 0.20 ajoute trois compétences, Réseaux fragiles et douze incidents variables de huit types, avec graine et format 6. Implémentation et mesures : [point 26](../suivi/26-reperes-incidents.md). Essais humains toujours en attente.

## Suite de l'audit du 18 octobre

0.21 clôturée (9018202). 0.22 : ciblage réactif, réponses intégrées, Double relais obligatoire et sauvegarde 7 ; voir [point 27](../suivi/27-crises-reactives.md). Lot 0.23 développé : familles, effets comparés, contrôleur découpé. Prochaine étape : sessions physiques et corrections observées. Les essais physiques ne sont pas réalisés.
