# Feuille de route — suite de Pandemic Horizon

Date : 17 octobre 2026. État courant : prototype 0.18, lots A à E implémentés ; essais joueurs en attente, voir le [point 23](../suivi/23-contenu-enrichi.md). Base de la planification : prototype 0.13, commit `f252baf`.

Ce dossier organise le développement à venir à partir des captures fournies par le joueur. Les éléments marqués « proposé » ne sont pas encore développés. Les tâches terminées sont identifiées dans le backlog et reliées à leur point de suivi.

## Documents à lire

1. [Inspirations et direction](01-inspirations.md) : ce que les références apportent au projet.
2. [Lots et ordre de réalisation](02-lots.md) : périmètre, dépendances et conditions de livraison.
3. [Liste des tâches](03-backlog.md) : identifiants stables et état de chaque tâche.
4. [Validation et modèle de fiche](04-validation.md) : vérifier un lot et préparer le suivant.

Le [plan général](../plan-developpement.md) conserve les objectifs de la version 1.0. Ce dossier détaille la suite immédiate et les pistes ultérieures. Les [points de suivi](../suivi/00-index.md) enregistrent ce qui a réellement été décidé, développé, testé et publié. Le [point 18](../suivi/18-feuille-de-route.md) consigne la création de cette organisation.

## Priorité proposée

Les lots A à E sont implémentés et mesurés automatiquement. CNT-04 attend les essais joueurs. Le lot F prépare les réglages de confort et la distribution. Une sauvegarde vérifiée distincte est créée entre les étapes avec scripts/checkpoint.ps1.

Les étiquettes 0.14 et suivantes sont des versions candidates, sans date de livraison engagée. Un lot peut être fractionné s'il devient trop large.

## Règles de suivi

- Chaque tâche possède un identifiant, un statut et un critère de fin. Ne cocher qu'après vérification.
- Statuts : proposé → prêt → en cours → à vérifier → terminé. « Différé » conserve une idée hors du prochain lot.
- Un seul lot principal en cours. Mettre à jour le backlog et créer un point de suivi à chaque livraison.
- Garder l'interface française, les choix intégrés et les sauvegardes reconnues. Les changements de règles nécessitent leurs propres mesures.
- Les captures de référence inspirent les fonctions et l'ambiance ; les ressources visuelles du jeu doivent avoir leur propre provenance.
