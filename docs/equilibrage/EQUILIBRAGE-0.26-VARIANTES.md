# Équilibrage 0.26 — contrepartie de Mobilité et variantes de Discrétion

## Questions

1. Quelle contrepartie retire à Mobilité sa position de politique la plus sûre (358/360 dans [EQUILIBRAGE-0.26-SITUATIONS](EQUILIBRAGE-0.26-SITUATIONS.md)) sans la rendre inutile ?
2. Une variante de Discrétion donne-t-elle à VOILE un avantage propre, que les autres agents n’ont pas ?

## Protocole

- Variantes **hypothétiques** de `strategy-0.26`, appliquées en mémoire pendant un appel synchrone puis restaurées (`scripts/analysis/strategy_variants.gd`). Aucune partie hypothétique n’est sauvegardée. Le fichier `data/strategy-0.26.json` n’est pas modifié.
- Par variante : 3 agents × 3 contextes (Standard depuis Boréale, Dégel, Réseaux fragiles) × 2 difficultés × 5 graines (7, 42, 2042, 11113, 8675309) × 3 ordres d’achat × 2 réponses (1ʳᵉ réponse payante, conservation) = **540 parties**, appariées avec la base sur les mêmes clés. Deux familles de 5 variantes : 5 400 parties.
- Le paramètre facultatif `mobility_cure` (remède ×f tant que Mobilité est acquise) a été ajouté à `strategy.gd` pour cette mesure. Absent du profil, il est exactement neutre (contrôle dédié).
- Reproduction : `dev.ps1 BalanceMobility` et `dev.ps1 BalanceDiscretion` ; sorties `build/qa/strategy-variants-{mobility,discretion}.json` (hors Git). Moteur 4.7.2-stable (official), empreinte `857cb5b7d4ba7bb46a51733c539e9443406f92260cd8141cb01c1a7411990730`. Comparaisons appariées vérifiées : cohortes complètes, aucune paire absente ou dupliquée.

## Mobilité

Seul l’ordre d’achat Mobilité est touché (les deux autres n’achètent pas Mobilité et restent identiques à la base). Victoires en difficile, sur 90 :

| Variante | Mobilité | Croissance | Discrétion | Base seule | Variante seule | Doubles victoires : variante plus lente / plus rapide |
| --- | --- | --- | --- | --- | --- | --- |
| Base (facteur 0,55) | 88 | 38 | 52 | — | — | — |
| Facteur 0,45 | 81 | 38 | 52 | 7 | 0 | 171 / 0 |
| Facteur 0,35 | 69 | 38 | 52 | 19 | 0 | 159 / 0 |
| Remède ×1,15 | 69 | 38 | 52 | 19 | 0 | 5 / 7 |
| Facteur 0,45 + remède ×1,10 | 66 | 38 | 52 | 22 | 0 | 155 / 0 |

En normale, toutes les variantes gagnent 90/90 avec chaque ordre d’achat. Défaites par remède, toutes politiques confondues : 92 (base), 99, 111, 111, 114.

Lecture : baisser le facteur d’échanges affaiblit Mobilité en **ralentissant** ses victoires (jusqu’à 171 doubles victoires plus lentes). La contrepartie sur le remède (×1,15) produit la même baisse que le facteur 0,35 (69/90), sans changer la durée des victoires : Mobilité reste rapide mais attire la recherche. Dans toutes les variantes, Mobilité reste devant Discrétion (52) et Croissance (38) en difficile.

## Discrétion et VOILE

Victoires avec l’ordre d’achat Discrétion (sur 60, normale et difficile) et victoires par agent (sur 180, tous ordres) :

| Variante | NACRE | ONDE | VOILE | Agents N / O / V | Variante seule | Doubles victoires : variante plus rapide / plus lente |
| --- | --- | --- | --- | --- | --- | --- |
| Base (30 j, détection ×1,6, échanges ×0,85) | 52 | 46 | 44 | 151 / 145 / 152 | — | — |
| Détection ×2,2 | 56 | 47 | 46 | 155 / 146 / 154 | 7 | 74 / 6 |
| Détection ×2,2, échanges ×1 | 58 | 50 | 48 | 158 / 150 / 156 | 16 | 284 / 2 |
| 45 jours | 59 | 55 | 58 | 159 / 155 / 166 | 32 | 16 / 70 |
| 45 jours, détection ×2,2 | 59 | 57 | 58 | 159 / 157 / 166 | 34 | 72 / 50 |

Aucune variante ne fait perdre une partie gagnée par la base.

Lecture :

- **Aucune variante ne donne à VOILE un avantage propre.** Relever le seuil de détection profite à peu près autant à NACRE qu’à VOILE.
- La première détection de VOILE a lieu au **J11 (médiane) dans toutes les variantes**. Discrétion coûte 14 points et n’est achetable qu’au J10 au plus tôt : la région de départ est détectée presque aussitôt, quel que soit le seuil. Le levier « Discrétion retarde la détection » arrive trop tard pour la croissance ×1,45 de VOILE dans la région de départ.
- Allonger Discrétion à 45 jours renforce tous les agents (ordre Discrétion en difficile : 82/90 contre 52) et ramène Discrétion vers la dominance mesurée en 0.25.

## Recommandation (non appliquée)

- **Mobilité** : la contrepartie « remède ×1,15 tant que Mobilité est acquise » est la meilleure candidate. Elle réduit l’avance de Mobilité en difficile (88 → 69/90) sans allonger les parties, et garde son identité (vitesse contre visibilité). Elle ne suffit pas à mettre les trois ordres d’achat à égalité : Croissance reste la plus faible (38/90).
- **VOILE** : ne pas chercher l’avantage de VOILE dans Discrétion. Hypothèses à mesurer ensuite : un seuil de détection propre à VOILE dès le départ, ou une Discrétion moins chère pour VOILE. Garder Discrétion à 30 jours.
- Toute adoption modifie `strategy-0.26.json` et son empreinte. Le profil n’a jamais été commité ni publié : aucune sauvegarde de joueur n’est concernée, mais la décision revient à l’auteur.

## Décision de l’auteur et mesures suivantes

L’auteur a demandé d’appliquer la contrepartie et de mesurer les leviers propres à VOILE. `strategy-0.26.json` contient désormais `mobility_cure` = 1,15 et le texte adapté de Mobilité. Nouvelle empreinte : `aba29390b6c9c5e6f29b3399bbb07814f2a3795707243e19c9b43c8344e8e8cf`. Les mesures ci-dessus portent sur l’empreinte précédente `857cb5b7…`.

### Grille complète après contrepartie (2 520 parties, `dev.ps1 BalanceStrategy`)

| Ordre d’achat | Difficile avant | Difficile après |
| --- | --- | --- |
| Mobilité | 418/420 | 342/420 |
| Croissance | 269/420 | 269/420 |
| Discrétion | 283/420 | 283/420 |

En normale, toujours 420/420 pour chaque ordre. Sur le sous-ensemble apparié avec la grille 0.25 : Mobilité 309/360 (contre 358), Discrétion 272, Croissance 269. Agents : NACRE 725, ONDE 705, VOILE 724 sur 840. Réponses payantes : la 1ʳᵉ gagne seule dans 35 paires, la 2ᵉ dans 9. Défaites par remède : 366 (290 avant). Durées J63–J109. Mobilité reste en tête, mais l’écart avec les deux autres ordres passe de 135–149 à 59–73 victoires en difficile.

### Leviers propres à VOILE (`dev.ps1 BalanceVeil`)

Variantes hypothétiques appliquées à VOILE seul (NACRE et ONDE inchangés), sur la base avec contrepartie. 180 parties VOILE par variante, appariées avec la base. Référence : NACRE 144/180 (difficile 54/90), ONDE 137/180 (47/90).

| Variante | VOILE | Difficile | Ordre Mobilité / Croissance / Discrétion (sur 60) | Variante seule / base seule | 1ʳᵉ détection |
| --- | --- | --- | --- | --- | --- |
| Base | 148 | 58 | 56 / 48 / 44 | — | J11 |
| Discrétion à 10 points | 162 | 72 | 55 / 49 / 58 | 15 / 1 | J11 |
| Discrétion à 8 points | 159 | 69 | 54 / 52 / 53 | 13 / 2 | J11 |
| Seuil de détection ×1,5 | 168 | 78 | 60 / 51 / 57 | 20 / 0 | J13 |
| Seuil ×1,5 et Discrétion à 10 | 173 | 83 | 60 / 54 / 59 | 25 / 0 | J13 |
| Seuil ×2,0 | 174 | 84 | 60 / 57 / 57 | 26 / 0 | J14 |

Lecture :

- **Discrétion à 10 points pour VOILE** est le seul levier qui crée un lien propre entre VOILE et Discrétion : il fait passer l’ordre Discrétion de 44 à 58/60 sans changer l’ordre Mobilité (56 → 55). C’est l’effet recherché (« maîtriser sa visibilité »).
- Les seuils de détection propres à VOILE retardent la première détection (J13–J14), mais renforcent VOILE avec **tous** les ordres d’achat : c’est un gain de puissance général, pas un choix.
- Tous les leviers rendent VOILE plus fort que NACRE et ONDE (162 à 174 contre 144 et 137). Adopter Discrétion à 10 points demanderait une compensation à mesurer, par exemple une croissance cachée inférieure à ×1,45.

Recommandation : **Discrétion à 10 points pour VOILE**, accompagnée d’une compensation mesurée avant adoption. Rien n’est appliqué pour VOILE.

### Discrétion à 10 points avec compensation (`dev.ps1 BalanceVeilCompensation`)

Même protocole (180 parties VOILE par variante, appariées avec la base, empreinte `aba29390…`). Compensation sur les coefficients de VOILE : croissance avant détection (`hidden`, 1,45 de base) et après détection (`detected`, 0,85). Référence, ordres Mobilité / Croissance / Discrétion sur 60 : NACRE 52 / 40 / 52 (144/180, difficile 54/90) ; ONDE 51 / 40 / 46 (137/180, difficile 47/90).

| Variante VOILE | Victoires /180 | Difficile /90 | Mobilité / Croissance / Discrétion | Base seule / variante seule | Doubles victoires plus lentes |
| --- | --- | --- | --- | --- | --- |
| Base (14 pts, ×1,45 / ×0,85) | 148 | 58 | 56 / 48 / 44 | — | — |
| 10 pts | 162 | 72 | 55 / 49 / 58 | 1 / 15 | 20 |
| 10 pts, après détection ×0,80 | 156 | 66 | 54 / 47 / 55 | 4 / 12 | 82 |
| 10 pts, avant détection ×1,35 | 153 | 63 | 53 / 48 / 52 | 4 / 9 | 103 |
| 10 pts, ×1,35 et ×0,80 | 139 | 49 | 52 / 40 / 47 | 13 / 4 | 111 |
| 10 pts, avant détection ×1,30 | 145 | 55 | 51 / 46 / 48 | 8 / 5 | 115 |
| 10 pts, avant détection ×1,25 | 133 | 43 | 46 / 40 / 47 | 19 / 4 | 117 |

Lecture :

- **10 points avec ×1,30** ramène VOILE au niveau de NACRE (145 contre 144, difficile 55 contre 54). Mais l’ordre Discrétion de VOILE (48) passe alors sous celui de NACRE (52) : le lien propre entre VOILE et Discrétion disparaît. La compensation retire précisément la croissance cachée que Discrétion protège.
- **10 pts avec ×1,35** est le meilleur compromis mesuré : Discrétion (52) au niveau de Mobilité (53) pour VOILE, avec la meilleure Croissance des trois agents (48). VOILE reste toutefois au-dessus de NACRE (153 contre 144 ; difficile 63 contre 54).
- Toutes les compensations ralentissent les victoires (82 à 117 doubles victoires plus lentes).
- **Conclusion** : avec ces politiques automatiques, aucune variante n’obtient à la fois une force égale à NACRE et un lien propre VOILE–Discrétion. Les deux objectifs se contredisent dans ce modèle.

Recommandation : ne rien adopter sur la seule base de la simulation. Si l’auteur veut un VOILE plus distinct, le candidat est « Discrétion à 10 points, croissance avant détection ×1,35 », à vérifier par des sessions joueurs ; sinon, conserver VOILE tel quel.

## Limites

Trois ordres d’achat fixes et deux règles de réponse. La médiane de première détection ne décrit que la première région (en pratique, la région de départ), pas la détection des régions suivantes. Une seule région de départ en Standard (Boréale). Aucun essai humain.
