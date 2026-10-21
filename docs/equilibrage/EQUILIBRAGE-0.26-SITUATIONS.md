# Équilibrage 0.26 — situations stratégiques

## Question

Le profil `strategy-0.26` corrige-t-il les limites mesurées en 0.25 (point 36) ?

1. Discrétion gagnait 360 parties sur 360 en ralentissant le remède sans contrepartie.
2. VOILE ne pouvait pas agir sur sa détection.
3. Le cycle d'ONDE et les décisions revenaient tous les 12 jours, toujours au même moment du cycle.
4. Forcer les relais (expansion) n'obtenait aucune victoire propre face à Consolider.
5. Les mêmes trois réponses revenaient à dates fixes.

## Règles mesurées

- ONDE : cycle de 10 jours (poussée ×1,65 pendant 4 jours, puis ×0,7) ; les décisions restent tous les 12 jours.
- Discrétion : effet limité à 30 jours après l'achat ; pendant ce temps, remède ×0,7, seuil de détection ×1,6 et échanges ×0,85. Ensuite, aucun effet.
- Crises : au J20 puis tous les 12 jours, la situation est lue dans l'état du monde, avec cette priorité : liaison interrompue, pression scientifique (remède ≥ 35 %), foyer développé (région touchée à 60 %), passage ouvert (foyer d'au moins 1 000 actifs relié par une liaison ouverte à une région épargnée), sinon crise de coordination. Une situation autre que la coordination ne revient jamais deux fois de suite. Chaque situation propose deux réponses payantes et « Garder ses points ».

## Protocole

- Grille 0.26 : 3 agents × (Standard avec 5 départs : Boréale, Centrale, Méridien, Savane, Orient ; Dégel ; Réseaux fragiles) × 2 difficultés (normale, difficile) × 5 graines (7, 42, 2042, 11113, 8675309) × 3 ordres d'achat × 4 réponses = **2 520 parties**.
- Réponses : 1ʳᵉ réponse payante de la situation, 2ᵉ réponse payante, conservation, ou contexte (1ʳᵉ si remède ≤ 45 % et couverture ≤ 65 %, sinon 2ᵉ). En 0.25 : Consolider, Forcer, conservation, contexte.
- Référence 0.25 : même script avec `--legacy`, 1 080 parties. Elle reproduit exactement les chiffres du point 36.
- Comparaison appariée : sous-ensemble 0.26 restreint aux situations de la grille 0.25 (Boréale en Standard, Dégel, Réseaux fragiles), soit 1 080 parties de mêmes agent, scénario, départ, difficulté, graine et ordre d'achat.
- Reproduction : `dev.ps1 BalanceStrategy` (sortie `build/qa/strategy-0.26-balance.json`) et `dev.ps1 BalanceStrategyLegacy` (`build/qa/strategy-0.25-balance.json`), hors Git. Moteur 4.7.2-stable. Empreinte 0.26 : `857cb5b7d4ba7bb46a51733c539e9443406f92260cd8141cb01c1a7411990730`. Empreinte 0.25 : `9a831e6f74aa2eb1f3dd0bf2a7b7de33d1875cd0b0d2c6b992ab00d8fb0c164a`.
- Aucune partie sans résultat avant le J500.

## Résultats appariés (1 080 parties de chaque côté)

| Ordre d'achat | 0.25 normale | 0.25 difficile | 0.26 normale | 0.26 difficile |
| --- | --- | --- | --- | --- |
| Mobilité | 180/180 | 172/180 | 180/180 | 178/180 |
| Croissance | 175/180 | 82/180 | 180/180 | 89/180 |
| Discrétion | 180/180 | 180/180 | 180/180 | 92/180 |

- Discrétion n'est plus dominante : 272/360 contre 360/360. En difficile, elle passe de 180 à 92 victoires.
- **Mobilité devient la politique la plus sûre** : 358/360 contre 352/360. La dominance s'est déplacée, elle n'a pas disparu.
- Réponses payantes : la 1ʳᵉ gagne seule dans 11 paires, la 2ᵉ dans 7, et 219 paires sont des doubles victoires (la 2ᵉ plus rapide dans 182). En 0.25 : Consolider seule 43, Forcer seule 0. Chaque réponse a désormais des victoires propres, mais les écarts restent faibles.
- VOILE avec Discrétion : 85/120 victoires, contre 97/120 pour NACRE et 90/120 pour ONDE avec le même ordre d'achat. Le retard de détection **ne se traduit pas** par un avantage mesurable pour VOILE avec ces politiques automatiques.
- Durées : J66 à J109 sur ce sous-ensemble (J63 à J109 en 0.25).

## Grille complète 0.26 (2 520 parties)

- Victoires : Mobilité 838/840, Croissance 689/840, Discrétion 703/840. Agents : NACRE 748, ONDE 738, VOILE 744 sur 840.
- Départs en Standard : Centrale, Méridien et Savane 360/360 ; Orient 251/360 ; Boréale 244/360. Les départs comptent davantage que l'agent.
- Situations proposées : foyer développé 4 383, liaison interrompue 3 303, pression scientifique 3 040, coordination 2 775, passage ouvert 350. Chaque partie rencontre de 3 à 5 situations distinctes ; 4 à 8 décisions par partie.
- Défaites : 290, toutes par remède.

Une première version de la grille, avec « Région isolée » (toutes les liaisons d'une région touchée fermées), n'a proposé **aucune** fois cette situation en 2 520 parties. Elle a été remplacée par « Liaison interrompue » (au moins une liaison fermée) avant la mesure finale ci-dessus.

## Décision

Les règles 0.26 sont conservées comme candidat expérimental, sans nouvel ajustement de coefficient fondé sur cette seule grille. Points provisoires :

- Mobilité est trop sûre ; une contrepartie (coût ou effet de Mobilité dans le profil) est à mesurer avant tout changement.
- Le bénéfice de Discrétion pour VOILE n'est pas démontré ; une durée plus longue ou un seuil de détection plus élevé sont des variantes à comparer.
- « Passage ouvert » reste rare (350 occurrences) : son seuil de 1 000 actifs est à examiner.

## Mise à jour

Après ce rapport, l’auteur a adopté une contrepartie pour Mobilité (remède ×1,15). Les chiffres ci-dessus restent ceux de l’empreinte `857cb5b7…`. Grille du profil courant (`aba29390…`) : voir [EQUILIBRAGE-0.26-VARIANTES](EQUILIBRAGE-0.26-VARIANTES.md).

## Limites

Trois ordres d'achat fixes et quatre règles de réponse ne représentent pas toutes les stratégies. Les politiques automatiques ne lisent pas les situations comme un joueur. Aucun essai humain : ni la compréhension des situations, ni l'intérêt des choix, ni la durée réelle des sessions ne sont établis.
