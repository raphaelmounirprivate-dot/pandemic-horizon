# Point 36 — profil stratégique expérimental

Candidat **0.25.0 local** : trois agents, décisions récurrentes et rythme ralenti, à la demande de l’auteur du 21 octobre 2026 après l’audit comparatif. Ce lot n’est pas une validation 1.0.

## Implémenté

- `strategy-0.25.json` et `gameplay/strategy.gd` : NACRE (exports après seuil de 40 %), ONDE (cycle de croissance), VOILE (avant/après détection), réseau ×1,5 et contrepartie supplémentaire de Mobilité ×0,55. Règles historiques inchangées.
- Crises J20 puis tous les 12 jours jusqu’au J128. Quatre jours pour choisir, huit jours d’effets dès demain. Consolidation et expansion coûtent 3 points et affectent croissance, échanges et remède ; conservation gratuite par défaut. Registre de choix et validation du budget.
- Journée de six secondes à ×1, vitesses conservées, pauses aux décisions et aux premiers achats ouverts par un gain. Le menu étape 2 propose les agents ; le profil est facultatif et remplace les anciennes décisions.
- Format 8 et empreinte séparée ; formats 1–7 et fixtures historiques conservés. `start_with` accepte `agent`, la signature historique de `start` n’est pas allongée.
- Coefficients d’agent dans la région, conséquences écrites des décisions, bilan descriptif (couverture manquante / marge de remède, registre stratégique), ambiance synthétique facultative coupée en pause/menu, appel de décision distinct.

## Vérifications réellement exécutées

- Import Godot 4.7.2 ; suite complète `dev.ps1 Test` : **6631 contrôles, zéro échec**. Inclut reprise JSON exacte et journées suivantes, agents et calendrier, corruption de registre/budget, pauses, écrans aux trois résolutions, son activable et coupure de l’ambiance.
- `gdlint` 4.5.0 sur tous les scripts : aucun problème.
- Provenance : `test-build-identity.ps1` : cinq contrôles réussis.
- Deux grilles complètes de 1 080 parties et deux comparaisons hypothétiques de 486 parties. Résultats finaux dans [EQUILIBRAGE-0.25-STRATEGIE](../equilibrage/EQUILIBRAGE-0.25-STRATEGIE.md).
- Captures : première revue de neuf images puis confirmation de neuf images, menu/choix/bilan, 1280×720, 1920×1080, 2395×1060. Confirmation produite dans une copie de rendu isolée après un échec de cache du pilote lors d’une tentative intermédiaire ; confirmation sans erreur. Aucun correctif de règle fondé sur les seules captures.

## Mesures et réserves

Grille finale : mobilité 352/360 victoires, croissance 257/360, discrétion 360/360. Consolidation gagne seule contre expansion dans 43 paires ; expansion gagne seule dans zéro. Expansion termine plus tôt dans 181 des 214 doubles victoires. Quatre à huit décisions, parties J63–109 : 6,3–10,9 minutes de simulation à ×1, hors pauses. La cible 15–30 minutes de session n’est pas validée.

Discrétion reste dominante en taux de victoire dans cette grille. Les trois politiques sont viables en normale, mais ce n’est pas un équilibre général ni une preuve d’intérêt pour des joueurs. Aucun essai humain, d’écoute, de DPI Windows ou de second PC. Le profil historique tactics-0.22 conserve ses trois réponses d’origine ; l’amélioration mesurée appartient au nouveau profil.

## Livraison

Changements locaux non commités ; aucun push, aucune CI distante de ce lot, aucun nouvel export Windows ni publication. Les exécutables 0.24 existants ne contiennent pas ce profil : lancer le projet 0.25 avec Godot. Patch de sauvegarde et bilan fournis dans les outputs du chat.

Prochaine étape : sessions joueurs sur le profil expérimental, en particulier choix consolidation/expansion, rythme et puissance de Discrétion, avant tout nouveau contenu.
