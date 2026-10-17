# Point 16 — Paramètres du soutien logistique

Date : 17 octobre 2026. Base : `8428f28`, branche `main`. Prototype livré : 0.12.0.

## Méthode

Tester séparément le coût et la contrepartie du remède, à partir du constat du lot 15. Douze modèles : désactivation, maintien, limitation, et neuf soutiens combinant coût 0/3/6 et remède ×1/×1,075/×1,15. Mer ×1,50 et durée douze journées constantes. Le coût nul est un témoin diagnostique, pas une nouvelle règle annoncée.

Même réserve de 6 points du J20 au J27 pour tous les modèles ; le plan de financement ne dépend pas du coût candidat. Tous les soutiens sont donc achetés au J28. Décision avant tentative du premier achat manquant, puis pas journalier. Les variations de prix peuvent décaler les acquisitions après le choix ; ces changements sont mesurés, pas neutralisés par des points gratuits.

Dégel, départ Boréale, Relais activés ; trois difficultés, graines 7/42/2042, quinze politiques ; 1 620 parties et 135 groupes de douze. Arrêt au résultat, au plus 500 jours. Empreintes avant décision identiques, maintien et désactivation strictement identiques hors décision/journal. Budget et tentatives reconstruits sous les paramètres de chaque modèle ; aucun choix manquant ou tardif accepté dans la cohorte.

Les paramètres expérimentaux remplacent le catalogue uniquement en mémoire, le temps d'un appel synchrone, puis sa valeur exacte précédente est restaurée. Aucun fichier du jeu ou joueur n'est modifié. Les observations portent paramètres et empreinte du catalogue hypothétique ; elles ne constituent pas des sauvegardes jouables compatibles. Les simulations et validations restent séquentielles à l'intérieur d'un processus, sans `await` dans la section qui modifie le catalogue.

## Sauvegardes figées avant expérience

Huit véritables références 0.11 produites avec les règles `8428f28`, avant toute expérience : décision en attente J28, soutien actif J35, expiré J45 et maintien J31, plus trente jours futurs pour chacun. Format 3 et contenu d'origine, coût 6 et remède ×1,15. Lecture sans écriture, secours identique au texte original et poursuite exacte avec choix/journal. Provenance dans `tests/fixtures/README.md`. Ne pas régénérer ces fichiers avec un modèle candidat.

## Résultats et décision

La cohorte complète est validée, avec mêmes résultats après intégration de la 0.12. Le [rapport généré](../EQUILIBRAGE-0.12-PARAMETRES.md) contient résultats séparés, contrastes à un paramètre, remède daté et empreintes exactes.

| Modèle | Parties | Victoires | Relais réussis |
| --- | ---: | ---: | ---: |
| Désactivation / maintien | 135 chacun | 126 | 117 |
| Soutien coût 6, remède ×1,15 | 135 | 112 | 99 |
| Soutien coût 3, remède ×1,15 | 135 | 117 | 99 |
| Soutien coût 3, remède ×1 ou ×1,075 | 135 chacun | 117 | 99 |
| Soutien gratuit, remède ×1,15 | 135 | 120 | 117 |
| Soutien gratuit, remède ×1 | 135 | 124 | 117 |

**Appliquer coût 3 aux nouvelles parties 0.12.** Par rapport au tarif 6, les mêmes 135 groupes donnent cinq victoires supplémentaires, aucune victoire perdue, aucun Relais gagné ou perdu. Les 390 acquisitions qui étaient retardées par le prix 6 sont plus précoces avec le prix 3 ; six acquisitions absentes à la fin réapparaissent. Parmi les 112 paires à deux victoires, victoire plus tôt de 0,97 jour en moyenne ; parmi les 99 paires à deux Relais réussis, 18 sont plus précoces, aucune plus tardive, moyenne −0,55 jour.

Conserver mer ×1,50, remède ×1,15 et durée douze jours. À coût 3 fixe, réduire le facteur remède ne gagne aucune victoire ni aucun Relais dans cette cohorte. Le coût nul diagnostique supprime les 18 pertes de Relais face au soutien à 6 points, mais supprime aussi la dépense ; il n'est pas retenu comme tarif de jeu. Même gratuit et sans accélération du remède, le soutien ne gagne pas de victoire face au témoin et en perd deux dans ces politiques : le facteur maritime ne garantit pas une amélioration de tous les résultats.

L'ajustement 3 est une amélioration mesurée par rapport à 6, pas un prix optimal validé auprès de joueurs. Le témoin sans événement conserve neuf victoires et 18 Relais de plus que le soutien à 3 points ; les effets sur le calendrier et la valeur du soutien restent à éprouver. Ne pas confondre ce compromis avec un bonus automatique à choisir dans chaque partie.

## Intégration 0.12 et compatibilité

Le monde fige son catalogue de décision lors du démarrage ou du chargement. Les nouvelles parties utilisent le profil 0.12 à 3 points. Les sauvegardes reconnues 0.11 sont chargées avec le catalogue historique `data/decisions-0.11.json`, à 6 points : aucun remboursement, décision en attente conservée au même tarif, futurs exacts. Le format 4 sauvegarde `decision_profile` ; son empreinte inclut huit JSON. Le prix affiché et l'aide suivent le profil de la partie, avec mention explicite du tarif historique. Recommencer crée une nouvelle partie 0.12.

## Fichiers et reproduction

- `scripts/analysis/logistics_parameters.gd`, `scripts/balance_parameters.gd`, `dev.ps1 BalanceParameters` : modèles, contrôles et rapport.
- `scripts/analysis/decision_comparison.gd` : seuil de réserve explicite, indépendant du coût candidat, avec comportement historique conservé par défaut.
- `tests/test_logistics_parameters.gd`, huit références `tests/fixtures/*0.11*` : restauration du catalogue, budgets, erreurs, témoins, chronologie et persistance.
- Sorties locales hors Git : `build/qa/balance-parameters.jsonl` et `.md`. Rapport conservé : `docs/EQUILIBRAGE-0.12-PARAMETRES.md`.
- `data/decisions.json`, catalogue historique, `scripts/gameplay/decisions.gd`, monde, persistance, aide et écran : coût et profils par partie. Outils expérimentaux exclus du binaire.

## Vérifications

- Import Godot 4.7.2 réussi ; cohorte finale `BalanceParameters` : **1 620 parties, 135 groupes complets**, tous les soutiens au J28, catalogue restauré, témoins sans dérive. Même bilan avant et après intégration du coût 3.
- Suite complète : **2 315 contrôles, zéro échec**, dont 131 nouveaux contrôles de paramètres, profils et références 0.11. Tous les parcours et références antérieurs continuent de passer.
- Export autonome `build/windows-0.12.0/PandemicHorizon.exe`, ressources embarquées. `verify-export.ps1` : copie seule vers un chemin avec espaces et accents, `RUNTIME_SMOKE_OK` incluant les profils 3/6, puis démarrage graphique OpenGL sur AMD Radeon RX 6650 XT.
- SHA256 exécutable final : `A6732E692DFC565DEF9777204F3DD7390A6992DA427F690D2285413F01B02A9A`.
- Rapport conservé identique au généré : SHA256 `C7F24613CB914C4727476D0CB2C684F7696D3298DAFF42DAE380FDE4FA41A0EB`. JSONL brut local : `63ED11506ACC7A69EB77254F99BEF9AEC882141BF69818F4726FE0E7A1E26ECE`.
- Revue indépendante Impeccable : disposition `ship`, 28 captures natives valides à 1280 × 720 et 1920 × 1080, prix courant/historique lisibles avant choix, refus expliqué et retour en pause focalisé. Documentation indépendante terminée : PRODUCT actualisé, DESIGN et sidecar conservés. Pas de détecteur HTML/CSS ni de raster livré ; aucune validation physique souris/clavier revendiquée.
- `git diff --check` réussi. Le compte rendu de livraison confirme commit, push et conclusion GitHub Actions.

## Limites

Trois graines et des politiques automatiques de même poids, aucune validation humaine. Les dates des seules réussites excluent les échecs, qui restent affichés séparément. Le remède final se mesure à des dates différentes ; utiliser les relevés aux mêmes jours pour la progression. Les Relais sont plafonnés et figés. Une modification de coût change le calendrier d'achat : elle mesure une politique complète sous le modèle, pas l'effet isolé d'un transport sur des joueurs humains.

Prochaine étape : essai joueur du tarif 3 et du choix historique clairement indiqué ; ensuite examiner la valeur du soutien pendant les fenêtres de routes ouvertes, avant d'enrichir le contenu. Conserver toutes les références 0.7 à 0.11 et figer la 0.12 avant un nouveau changement de règles.
