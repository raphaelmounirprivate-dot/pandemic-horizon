# Matrice de compatibilité des sauvegardes

Godot actuel : 4.7.2 stable, chaîne de version exacte vérifiée au chargement. Une autre version du moteur est refusée pour protéger la reproductibilité ; il n'existe pas encore de migration inter-moteurs.

| Format | Profil | Comportement |
| --- | --- | --- |
| 1–3 | 0.7 à 0.11, empreintes historiques autorisées | Lecture maintenue selon les fixtures historiques ; avertissement affiché |
| 4 | Classique | Aucun ajout rétroactif de contenu enrichi ni de crises |
| 5 | enriched-0.18 | Catalogue enrichi et événements fixes, sans crises aléatoires |
| 6 | crises-0.20 | Tirage par graine ; anciennes règles conservées |
| 7 | tactics-0.22 | Cibles résolues au déclenchement, réponse et Double relais sauvegardés |

Les métadonnées de présentation des familles ne modifient ni coefficients, coûts, prérequis ni empreintes des profils historiques. Une future modification de règles exige un profil et une empreinte distincts, ses fixtures et un test de reprise. Conserver les anciens exports et les checkpoints avant de changer Godot.

Les sauvegardes sont locales au PC. Le secours représente l'écriture précédente, pas un historique infini. Une sauvegarde incompatible n'est pas écrasée par une tentative d'enregistrement.
