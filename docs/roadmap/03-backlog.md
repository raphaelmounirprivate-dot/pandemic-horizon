# Tâches à réaliser

P0 : prochain lot. P1 : suite du cycle. P2 : contenu et finition après les fondations. Effort relatif S/M/L : limité / plusieurs fichiers / changement transversal ; il ne correspond pas à une durée promise.

Au 17 octobre 2026 : MON, EVO, EVT et STA terminés. CNT-01 à CNT-03 implémentés et vérifiés en 0.18 ; CNT-04 : mesures faites, essais joueurs en attente. FIN-01/02 implémentés et vérifiés automatiquement en 0.19 ; FIN-03 partiel (archive et export vérifiés, essais physiques/joueurs à réaliser). Voir les points 19 à 24.

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

EVO-01, EVO-02 et EVO-03 sont terminés en 0.16, voir le [point 21](../suivi/21-evolutions-integrees.md). EVT-01, EVT-02, STA-01 et STA-02 constituent le lot suivant.

EVT-01, EVT-02, STA-01 et STA-02 sont terminés en 0.17, voir le [point 22](../suivi/22-actualites-historique.md). Les tâches de contenu CNT-01 à CNT-04 suivent ; les essais joueurs de CNT-04 restent distincts des mesures automatiques.

| Question | Quand | Choix provisoire |
| --- | --- | --- |
| Glisser au bouton central ou droit ? | Lot A | Tester la cohérence avec clic gauche de sélection |
| Rendu vectoriel enrichi ou texture de terrain ? | Lot B | Comparer lisibilité et coût ; conserver les contours existants |
| Forme des nœuds d'évolution ? | Lot C | Choisir selon les libellés et relations ; hexagones non imposés |
| Ajouter des décès et une létalité ? | Avant toute modification du modèle | Non inclus dans les lots visuels ; conception séparée nécessaire |
| Augmenter le nombre de régions ? | Après essais du cycle | Conserver les 24 régions actuelles |
| Ajouter plusieurs types d'agents ? | Après stabilisation de la 1.0 | Différé |

Pour démarrer une tâche, changer son statut explicitement et créer sa fiche avec le [modèle](04-validation.md). Une proposition ne devient pas une fonctionnalité livrée parce qu'elle figure ici.

État du lot E : [point 23](../suivi/23-contenu-enrichi.md). CNT-01/02/03 terminés ; CNT-04 à vérifier auprès de joueurs.

État du lot F : [point 24](../suivi/24-confort-distribution.md). Aucun essai humain déclaré terminé ; [protocole](../TESTS-JOUEURS.md).

## Extension 0.20 — implémentée

ALE-01 : option et graine reproductible ; ALE-02 : huit types d’incidents, cumul et expiration ; ALE-03 : trois compétences à prérequis et scénario Réseaux fragiles ; ALE-04 : format 6 et compatibilité des anciens profils ; ALE-05 : mesures et captures. Voir le [point 25](../suivi/25-aleas-resilience.md). ALE-06 : compréhension/équilibrage avec des joueurs, à réaliser.

## Audit du 18 octobre — état révisé

| ID | Tâche | État | Preuve / suite |
| --- | --- | --- | --- |
| AUD-01 | Clôture 0.21 et provenance | Terminé | 9018202, archive et checkpoint ; CI export/paquet validée en 0.22 |
| AUD-02 | Ciblage réactif régional | Terminé techniquement | 0.22, rapport apparié 48/76 → 0/76 |
| AUD-03 | Réponses à une crise | Implémenté, intérêt à vérifier | Détour/subir/occasion ; 270 simulations ; sessions attendues |
| AUD-04 | Familles, ascendance et coefficients | Implémenté en 0.23 | Point 28 ; compréhension à observer |
| AUD-05 | Double relais obligatoire | Implémenté et mesuré | 0.22 ; autres stratégies à explorer |
| AUD-06 | Humains / DPI / autre PC | À réaliser | Protocole et fiches prêts, aucun résultat humain |
| AUD-07 | Découpage progressif | Partiel | Trois vues extraites ; suite : compétences et sauvegardes |

## Analyse du 19 octobre — état

Voir l'[analyse](06-analyse-2026-10-19.md) et le [point 29](../suivi/29-dette-technique-ci.md).

| ID | Tâche | État | Preuve / suite |
| --- | --- | --- | --- |
| ANA-01 | Trois sessions joueurs | À réaliser | `resultats.csv` vide ; aucune fiche remplie |
| ANA-02 | Faux positif AVG | Partiel | Procédure testeur et `docs/ANTIVIRUS.md` ; signalement à l'éditeur et recontrôle AVG actif à faire par l'auteur |
| ANA-03 | Effet réel des réponses de crise | Différé | Décision de l'auteur : après les sessions ; éviterait un format 8 avant ANA-08 |
| ANA-04 | Renommer le dépôt | Terminé | `pandemic-horizon`, remote et liens mis à jour |
| ANA-05 | `World.start_with(options)` | Terminé | `test_start_options.gd` ; `start()` conservée |
| ANA-06 | Découper `main.gd` | Partiel | 811 lignes au point 29 ; 834 au [point 30](../suivi/30-ecrans-dedies.md) (Évolution, menu et bilan dans leurs vues, câblage ajouté au contrôleur) ; 664 au [point 31](../suivi/31-vue-de-jeu.md) (écran de jeu dans `game_view.gd`) ; 597 au [point 32](../suivi/32-tutoriel-sauvegardes.md) (tutoriel, chargement et enregistrement extraits) ; 446 au [point 34](../suivi/34-gameplay-type-aide.md) (aide, temps, raccourcis, préférences, flux Évolution extraits) ; reste : navigation entre écrans et démarrage de partie, volontairement gardés dans le contrôleur |
| ANA-07 | Export sûr pour les outils | Terminé | `scripts/analysis/*` par motif ; `test_export_filter.gd` |
| ANA-08 | Avenir des formats de sauvegarde | À décider | [Note de décision](07-decision-formats-sauvegarde.md) |
| ANA-09 | Typage GDScript | Partiel | `untyped_declaration` en erreur dans `scripts/simulation/`, `scripts/persistence/` ([point 33](../suivi/33-typage-sauvegardes.md)) et `scripts/gameplay/` ([point 34](../suivi/34-gameplay-type-aide.md)) ; `ui`, `tests`, `analysis` et `unsafe_*` à faire |
| ANA-20 | Aide F1 sans liste déroulante | Terminé | Invariant 7 ; `help_view.gd`, `test_help_view.gd` ([point 34](../suivi/34-gameplay-type-aide.md)) ; lecture par des joueurs à observer |
| ANA-10 | Source unique des skills | Terminé | `.claude/skills/` |
| ANA-11 à 14 | CI : chemins, concurrence, cache, rétention | Terminé | CI réussies au point 29 ; une seule exécution en attente par groupe |
| ANA-15 | `gdlint` en CI | Terminé | `gdlintrc` ; règles de style héritées assouplies |
| ANA-16/17 | README/CHANGELOG/index ; rangement de `docs/` | Terminé | `docs/equilibrage/`, `docs/versions/` |
| ANA-18 | `.gitignore` | Terminé | Lignes Python retirées, `.claude/settings.local.json` ignoré |
| ANA-19 | Conservation de `build/` | Règle proposée | Suppression laissée à l'auteur (`DEVELOPPEMENT.md`) |

## Lot stratégique 0.25 — demande du 21 octobre

| ID | Statut | Preuve / suite |
| --- | --- | --- |
| STR-01 — rythme | Implémenté et testé automatiquement | Profil facultatif 6 s/jour, pauses aux décisions et aux premiers achats ; durée humaine à mesurer |
| STR-02 — décisions contextuelles | Implémenté et mesuré | Crises J20 puis tous les 12 jours ; consolidation / expansion / budget ; rapport dédié |
| STR-03 — stratégies alternatives | Mesuré, équilibrage à poursuivre | Mobilité, croissance, discrétion ; comparaison appariée, aucune équivalence humaine affirmée |
| STR-04 — agents | Implémenté | NACRE (seuil de foyer), ONDE (cycle), VOILE (détection), sauvegarde format 8 |
| STR-05 — retours et bilan | Implémenté | Coefficients d’agent régionaux, conséquences des choix, explication de fin, ambiance facultative |
| STR-06 — essais | À réaliser | Tester compréhension, attente, choix et envie de rejouer ; aucun essai humain déduit des simulations |

Voir le [point 36](../suivi/36-profil-strategique.md). ANA-03 reste valable pour le profil historique tactics-0.22 ; le nouveau profil n’en réécrit pas les règles.

## Lot 0.26 — situations stratégiques (21 octobre)

Six pistes issues de l’analyse du profil 0.25 ; profil `strategy-0.26`, format 9. Statuts : voir le [point 37](../suivi/37-situations-strategiques.md) et [EQUILIBRAGE-0.26-SITUATIONS](../equilibrage/EQUILIBRAGE-0.26-SITUATIONS.md).

| ID | Statut | Preuve / suite |
| --- | --- | --- |
| STR-07 — Discrétion / Mobilité | Implémenté et mesuré | Contrepartie remède ×1,15 adoptée par l’auteur : Mobilité 342/420 en difficile (418 avant), Discrétion 283, Croissance 269 ([variantes](../equilibrage/EQUILIBRAGE-0.26-VARIANTES.md)) |
| STR-08 — VOILE | Mesuré, décision attendue | Variantes de Discrétion sans effet propre (détection au J11). Levier propre : Discrétion à 10 points pour VOILE (ordre Discrétion 44 → 58/60), mais VOILE devient le plus fort agent ; compensation à mesurer |
| STR-09 — ONDE | Implémenté et testé automatiquement | Cycle de 10 jours contre 12 pour les décisions ; poussée ou repli selon la crise |
| STR-10 — expansion | Implémenté et mesuré | Passage ouvert (région visée) ; chaque réponse payante a des victoires propres (11 / 7 paires) ; passage rare (350 occurrences) |
| STR-11 — crises liées au monde | Implémenté et mesuré | Cinq situations, 3 à 5 distinctes par partie ; « Région isolée » jamais atteinte, remplacée par Liaison interrompue |
| STR-12 — lisibilité | Implémenté, revu sur captures | Ligne « En cours » et détail des effets ; 12 captures aux trois résolutions ; compréhension à vérifier avec des joueurs |
| STR-06 — essais | À réaliser | Inchangé : aucun essai humain |
