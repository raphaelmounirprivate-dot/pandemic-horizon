# Point 37 — situations stratégiques

Candidat **0.26.0 local** : les crises stratégiques dépendent maintenant de l’état du monde, ONDE se décale des décisions, Discrétion devient temporaire et les effets en cours restent lisibles. Lot repris le 21 octobre 2026 à partir des six pistes de l’analyse du profil 0.25 (Codex avait annoncé le plan sans rien écrire). Ce lot n’est pas une validation 1.0.

## Avant le lot

Le lot 0.25, jusque-là non commité, a été commité tel quel : `803208f` (local).

## Implémenté

- Nouveau profil `data/strategy-0.26.json`, format 9, proposé aux nouvelles parties stratégiques. `strategy-0.25.json` n’est pas modifié ; ses parties se chargent et se poursuivent avec leurs règles.
- `gameplay/strategy.gd` gère les deux profils (`rules(profile)`, `rules_of(world)`, `modern(world)`). Option `strategy` de `start_with` ; `save_store.strategy_hash(profile)` ; format 9 dans `encode`/`decode`.
- Situations lues dans l’état de la veille, sans aléa : liaison interrompue, pression scientifique, foyer développé, passage ouvert, sinon coordination. Pas deux fois de suite la même (hors coordination). Réponses propres, dont deux à effet ciblé sur une région. Crise ouverte et registre (situation, région visée) sauvegardés et validés.
- ONDE : cycle de 10 jours contre 12 pour les décisions. Discrétion (0.26 seulement) : 30 jours, remède ×0,7, seuil de détection ×1,6, échanges ×0,85 ; `evolutions.json` inchangé, le profil compense l’effet permanent.
- Lisibilité : ligne « En cours » sous le statut stratégique, détail des effets en tête des événements actifs (jours restants, région visée, prochaine phase d’ONDE), texte « Situation : », fiche de Discrétion adaptée dans Évolution, aide F1.
- Outils : `balance_strategy.gd` paramétré par profil, cinq départs en Standard, réponses par position ; actions `dev.ps1 BalanceStrategy` et `BalanceStrategyLegacy`.
- Version 0.26.0 (`project.godot`, `export_presets.cfg`).

## Vérifications réellement exécutées

- `dev.ps1 Test` : **6812 contrôles, zéro échec** (6631 au point 36). Nouveaux contrôles : validation du profil 0.26, reprise exacte et futur identique (y compris pendant une crise ouverte), refus des états corrompus (crise effacée, situation ou cible inconnue, réponse étrangère, répétition, profil ou format incohérent), détection de chaque situation, effet ciblé, Discrétion temporaire, phases d’ONDE, ligne « En cours ».
- **Références 0.25** : six fichiers `tests/fixtures/*-0.25-*`, générés dans un worktree temporaire du commit `803208f` avant tout changement. Chargés par le nouveau code, ils se poursuivent jusqu’au J70 avec un état identique à celui produit par le code 0.25.
- Grille de référence 0.25 relancée : chiffres du point 36 retrouvés à l’identique (352/257/360 victoires sur 360 ; 43 contre 0 paires).
- Grille 0.26 : 2 520 parties, aucune sans résultat. Rapport : [EQUILIBRAGE-0.26-SITUATIONS](../equilibrage/EQUILIBRAGE-0.26-SITUATIONS.md).
- Captures `tests/capture_strategy.gd` : 12 images (menu, décision, effets en cours, bilan) en 1280×720, 1920×1080, 2395×1060. Revues : à 1280×720, la zone des événements actifs n’affichait que deux lignes ; la ligne « En cours » a été ajoutée, puis vérifiée sur une nouvelle capture à 1280 et 2395.
- `gdlint` n’est pas installé sur ce poste : non exécuté pour ce lot.

## Mesures et réserves

Sur 1 080 parties appariées avec la grille 0.25 : Discrétion passe de 360/360 à 272/360 victoires, mais Mobilité devient la politique la plus sûre (358/360). Les deux réponses payantes ont des victoires propres (11 et 7 paires, contre 43 et 0). VOILE avec Discrétion : 85/120, sous NACRE (97) et ONDE (90) ; le bénéfice attendu du retard de détection n’apparaît pas avec ces politiques. « Région isolée » (toutes les liaisons fermées) n’est jamais survenue en 2 520 parties : elle a été remplacée par « Liaison interrompue » avant la mesure finale. « Passage ouvert » reste rare (350 occurrences).

Aucun coefficient n’a été ajusté sur la base de ces seules simulations. Aucun essai humain, d’écoute, de DPI Windows ou de second PC.

## Mesures complémentaires : Mobilité et Discrétion

Demandées par l’auteur après ce point. Dix variantes hypothétiques, 5 400 parties appariées, aucune sauvegardée, profil inchangé : [EQUILIBRAGE-0.26-VARIANTES](../equilibrage/EQUILIBRAGE-0.26-VARIANTES.md). Outils : `analysis/strategy_variants.gd`, `dev.ps1 BalanceMobility` / `BalanceDiscretion`, paramètre facultatif et neutre `mobility_cure`, suite `tests/test_strategy_variants.gd`. Suite complète après ajout : **6825 contrôles, zéro échec**.

- Mobilité : remède ×1,15 tant qu’elle est acquise ramène ses victoires en difficile de 88 à 69/90 sans allonger les parties ; baisser le facteur d’échanges produit la même baisse en ralentissant les victoires. Mobilité reste devant Discrétion (52) et Croissance (38).
- Discrétion : aucune variante ne donne à VOILE un avantage propre. La première détection a lieu au J11 (médiane) dans toutes les variantes, alors que Discrétion n’est achetable qu’au J10. Allonger Discrétion à 45 jours la rend de nouveau dominante (82/90 en difficile).
- Recommandation : contrepartie remède ×1,15 pour Mobilité ; chercher l’avantage de VOILE ailleurs que dans Discrétion.

**Décision de l’auteur, appliquée** : `mobility_cure` = 1,15 dans `strategy-0.26.json` (empreinte `aba29390…`), texte de Mobilité adapté, aide et règles mises à jour. Grille complète relancée (2 520 parties) : Mobilité 342/420 en difficile (418 avant), Discrétion 283, Croissance 269.

**Leviers propres à VOILE**, mesurés et non appliqués (`dev.ps1 BalanceVeil`, paramètres facultatifs `agents.veil.detection` et `agents.veil.discretion_cost`) : Discrétion à 10 points pour VOILE fait passer l’ordre Discrétion de 44 à 58/60 sans toucher l’ordre Mobilité. C’est le seul levier qui lie VOILE et Discrétion. Il rend toutefois VOILE plus fort que NACRE et ONDE (162 contre 144 et 137 sur 180) : une compensation reste à mesurer. Suite complète : **6830 contrôles, zéro échec**.

## Livraison

Lot commité en local à la demande de l’auteur (commit suivant `803208f`) ; aucun push, aucune CI distante, aucun export Windows ni publication. Les exécutables 0.24 ne contiennent ni le profil 0.25 ni le profil 0.26.

Prochaine étape : sessions joueurs sur le profil 0.26 (compréhension des situations, lecture de la ligne « En cours », intérêt des choix), puis mesure d’une contrepartie à Mobilité et de variantes de Discrétion pour VOILE.
