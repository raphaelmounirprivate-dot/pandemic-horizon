# Tâches à réaliser

P0 : prochain lot. P1 : suite du cycle. P2 : contenu et finition après les fondations. Effort relatif S/M/L : limité / plusieurs fichiers / changement transversal ; il ne correspond pas à une durée promise.

Toutes les lignes sont au statut **proposé** au 17 octobre 2026.

| ID | Priorité | Tâche | Dépendance | Effort | Critère de fin |
| --- | --- | --- | --- | --- | --- |
| MON-01 | P0 | Zoom centré sur le pointeur | — | M | Un point visé reste stable au zoom ; bornes appliquées |
| MON-02 | P0 | Déplacement et retour monde | MON-01 | M | Aucun monde perdu hors champ ; retour immédiat à la vue initiale |
| MON-03 | P0 | Entrées et redimensionnement | MON-01, MON-02 | M | Clic/Tab sélectionnent la bonne région aux trois tailles et aux zooms limites |
| MON-04 | P1 | Icônes de transports et véhicules | MON-03 | M | Type et sens visibles ; flux seulement sur route ouverte ; pause respectée |
| MON-05 | P1 | Densité des foyers et filtre des flux | MON-03, MON-04 | M | Début et fin de partie lisibles ; filtre sans effet sur le modèle |
| MON-06 | P1 | Relief, océans et glaces | MON-03 | M | Ressources locales avec provenance, foyers contrastés, rendu comparé avant/après |
| EVO-01 | P1 | Relations de prérequis dessinées | MON-03 | M | Six/neuf évolutions visibles ; relation et exclusion compréhensibles |
| EVO-02 | P1 | Icônes et fiche d'évolution | EVO-01 | M | Coût, effet, prérequis et état lisibles ; sélectionner ne dépense rien |
| EVO-03 | P1 | Achat et focus clavier | EVO-02 | M | Achat explicite, focus stable, refus expliqué, choix logistiques visibles |
| EVT-01 | P1 | Fil d'actualités compact | MON-03 | M | Chaque fait vient du modèle et porte sa date ; aucune alerte fictive |
| EVT-02 | P1 | Présentation des événements | EVT-01 | M | Durée, cumul et fermeture prioritaire expliqués sans masquer les choix |
| STA-01 | P1 | Historique quotidien borné | — | L | Sauvegarde/reprise cohérentes ; ancien historique absent signalé sans reconstruction inventée |
| STA-02 | P1 | Courbes et chronologie d'achats | STA-01 | M | Valeurs reliées au journal réel ; axes et unités visibles ; deux issues distinguées |
| CNT-01 | P2 | Identité du premier agent | EVO-02 | M | Nom et visuel originaux, ressources documentées, aucun effet de règles implicite |
| CNT-02 | P2 | Fiches de scénarios | EVT-02 | S | Départ, objectifs, contraintes et différences visibles avant lancement |
| CNT-03 | P2 | Étendre évolutions/événements | EVO-03, EVT-02, STA-02 | L | JSON validés, prérequis cohérents, affichage complet, sauvegardes et tutoriel adaptés |
| CNT-04 | P2 | Mesures d'équilibrage | CNT-03 | L | Rapport apparié par graine/difficulté et essais joueurs ; compromis justifiés |
| FIN-01 | P1 | Accessibilité et maîtrise du mouvement | MON-04, EVO-03 | M | Informations sans couleur seule ; animation réductible ; navigation vérifiée |
| FIN-02 | P2 | Sons et retour d'action | EVT-02 | M | Volume et désactivation ; aucun son indispensable à la compréhension |
| FIN-03 | P2 | Validation joueurs et distribution | CNT-04, FIN-01, FIN-02 | L | Essais consignés, exécutable autonome vérifié, guide/licences/archive cohérents |

## Décisions à prendre au moment du lot concerné

| Question | Quand | Choix provisoire |
| --- | --- | --- |
| Glisser au bouton central ou droit ? | Lot A | Tester la cohérence avec clic gauche de sélection |
| Rendu vectoriel enrichi ou texture de terrain ? | Lot B | Comparer lisibilité et coût ; conserver les contours existants |
| Forme des nœuds d'évolution ? | Lot C | Choisir selon les libellés et relations ; hexagones non imposés |
| Ajouter des décès et une létalité ? | Avant toute modification du modèle | Non inclus dans les lots visuels ; conception séparée nécessaire |
| Augmenter le nombre de régions ? | Après essais du cycle | Conserver les 24 régions actuelles |
| Ajouter plusieurs types d'agents ? | Après stabilisation de la 1.0 | Différé |

Pour démarrer une tâche, changer son statut explicitement et créer sa fiche avec le [modèle](04-validation.md). Une proposition ne devient pas une fonctionnalité livrée parce qu'elle figure ici.
