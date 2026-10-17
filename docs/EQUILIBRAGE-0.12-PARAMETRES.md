# Coût du soutien et contrepartie du remède — analyse 0.12.0

Commande : `dev.ps1 BalanceParameters`. Moteur `4.7.2-stable (official)` ; contenu distribué inchangé `8bc437ed25fef13c8ba9d02bd0a6eb07ac05da41ad2216a66775ba35669779af`.

Dégel, Boréale, Relais activés, quinze politiques, trois difficultés, graines 7/42/2042. Douze modèles par groupe : trois témoins et neuf soutiens (coûts 0/3/6 × remède 1/1,075/1,15). Mer ×1,50, durée 12 jours, décision au J28. Même réserve de 6 points pour TOUS les modèles du J20 au J27 ; elle ne dépend pas du prix candidat. Aucun point offert ; le coût nul est un témoin diagnostique. Arrêt au résultat, limite 500 jours.

Seuls coût et facteur remède du catalogue en mémoire changent, le temps d'un appel synchrone d'analyse, puis le catalogue original est restauré, y compris après erreur. Aucun JSON du jeu ni fichier joueur n'est modifié. Chaque observation porte ses paramètres et l'empreinte du modèle ; les états hypothétiques ne sont jamais enregistrés comme sauvegardes jouables. Les empreintes d'état permettent les comparaisons internes, elles ne prouvent pas la compatibilité des modèles hypothétiques.

Budget et tentatives reconstruits sous les paramètres de chaque candidat. Tous les soutiens doivent être appliqués au J28 ; douze états préalables identiques ; maintien et désactivation strictement identiques hors décision/journal. Une différence de prix peut changer les achats après J28 : c'est une conséquence mesurée de la politique, pas un effet maritime isolé. À coût fixe, la variation du remède mesure la conséquence simulée de ce facteur. Comparer deux facteurs simultanément n'isole pas l'un d'eux.

## Modèles et résultats

| Série / variante | Parties | Victoires | Relais réussis | Deux succès | Relais seuls | Victoire seule | Deux échecs | Choix demandé appliqué | Remède final moyen | Jour final moyen |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| disabled | 135 | 126 | 117 | 114 | 3 | 12 | 6 | — | 70.59 | 89.01 |
| observe | 135 | 126 | 117 | 114 | 3 | 12 | 6 | 135 | 70.59 | 89.01 |
| limit | 135 | 126 | 117 | 114 | 3 | 12 | 6 | 135 | 69.83 | 89.38 |
| support_c0_r1000 | 135 | 124 | 117 | 112 | 5 | 12 | 6 | 135 | 70.45 | 88.76 |
| support_c0_r1075 | 135 | 120 | 117 | 108 | 9 | 12 | 6 | 135 | 70.94 | 88.74 |
| support_c0_r1150 | 135 | 120 | 117 | 108 | 9 | 12 | 6 | 135 | 71.42 | 88.71 |
| support_c3_r1000 | 135 | 117 | 99 | 87 | 12 | 30 | 6 | 135 | 72.38 | 89.82 |
| support_c3_r1075 | 135 | 117 | 99 | 87 | 12 | 30 | 6 | 135 | 72.85 | 89.74 |
| support_c3_r1150 | 135 | 117 | 99 | 87 | 12 | 30 | 6 | 135 | 73.31 | 89.72 |
| support_c6_r1000 | 135 | 114 | 99 | 84 | 15 | 30 | 6 | 135 | 74.11 | 90.65 |
| support_c6_r1075 | 135 | 114 | 99 | 84 | 15 | 30 | 6 | 135 | 74.57 | 90.56 |
| support_c6_r1150 | 135 | 112 | 99 | 82 | 17 | 30 | 6 | 135 | 75.02 | 90.55 |

## Par difficulté

| Série / variante | Parties | Victoires | Relais réussis | Deux succès | Relais seuls | Victoire seule | Deux échecs | Choix demandé appliqué | Remède final moyen | Jour final moyen |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| easy / disabled | 45 | 45 | 39 | 39 | 0 | 6 | 0 | — | 52.63 | 89.76 |
| easy / observe | 45 | 45 | 39 | 39 | 0 | 6 | 0 | 45 | 52.63 | 89.76 |
| easy / limit | 45 | 45 | 39 | 39 | 0 | 6 | 0 | 45 | 52.14 | 90.16 |
| easy / support_c0_r1000 | 45 | 45 | 39 | 39 | 0 | 6 | 0 | 45 | 52.53 | 89.49 |
| easy / support_c0_r1075 | 45 | 45 | 39 | 39 | 0 | 6 | 0 | 45 | 52.94 | 89.49 |
| easy / support_c0_r1150 | 45 | 45 | 39 | 39 | 0 | 6 | 0 | 45 | 53.35 | 89.49 |
| easy / support_c3_r1000 | 45 | 45 | 33 | 33 | 0 | 12 | 0 | 45 | 54.16 | 90.67 |
| easy / support_c3_r1075 | 45 | 45 | 33 | 33 | 0 | 12 | 0 | 45 | 54.57 | 90.67 |
| easy / support_c3_r1150 | 45 | 45 | 33 | 33 | 0 | 12 | 0 | 45 | 54.99 | 90.67 |
| easy / support_c6_r1000 | 45 | 45 | 33 | 33 | 0 | 12 | 0 | 45 | 55.80 | 91.71 |
| easy / support_c6_r1075 | 45 | 45 | 33 | 33 | 0 | 12 | 0 | 45 | 56.22 | 91.71 |
| easy / support_c6_r1150 | 45 | 45 | 33 | 33 | 0 | 12 | 0 | 45 | 56.64 | 91.71 |
| normal / disabled | 45 | 42 | 39 | 39 | 0 | 3 | 3 | — | 69.98 | 89.29 |
| normal / observe | 45 | 42 | 39 | 39 | 0 | 3 | 3 | 45 | 69.98 | 89.29 |
| normal / limit | 45 | 42 | 39 | 39 | 0 | 3 | 3 | 45 | 69.18 | 89.60 |
| normal / support_c0_r1000 | 45 | 42 | 39 | 39 | 0 | 3 | 3 | 45 | 69.82 | 89.02 |
| normal / support_c0_r1075 | 45 | 42 | 39 | 39 | 0 | 3 | 3 | 45 | 70.33 | 89.00 |
| normal / support_c0_r1150 | 45 | 42 | 39 | 39 | 0 | 3 | 3 | 45 | 70.85 | 89.00 |
| normal / support_c3_r1000 | 45 | 42 | 33 | 33 | 0 | 9 | 3 | 45 | 72.08 | 90.22 |
| normal / support_c3_r1075 | 45 | 42 | 33 | 33 | 0 | 9 | 3 | 45 | 72.60 | 90.20 |
| normal / support_c3_r1150 | 45 | 42 | 33 | 33 | 0 | 9 | 3 | 45 | 73.11 | 90.20 |
| normal / support_c6_r1000 | 45 | 42 | 33 | 33 | 0 | 9 | 3 | 45 | 74.20 | 91.22 |
| normal / support_c6_r1075 | 45 | 42 | 33 | 33 | 0 | 9 | 3 | 45 | 74.72 | 91.20 |
| normal / support_c6_r1150 | 45 | 42 | 33 | 33 | 0 | 9 | 3 | 45 | 75.24 | 91.20 |
| hard / disabled | 45 | 39 | 39 | 36 | 3 | 3 | 3 | — | 89.17 | 88.00 |
| hard / observe | 45 | 39 | 39 | 36 | 3 | 3 | 3 | 45 | 89.17 | 88.00 |
| hard / limit | 45 | 39 | 39 | 36 | 3 | 3 | 3 | 45 | 88.17 | 88.38 |
| hard / support_c0_r1000 | 45 | 37 | 39 | 34 | 5 | 3 | 3 | 45 | 89.01 | 87.78 |
| hard / support_c0_r1075 | 45 | 33 | 39 | 30 | 9 | 3 | 3 | 45 | 89.55 | 87.73 |
| hard / support_c0_r1150 | 45 | 33 | 39 | 30 | 9 | 3 | 3 | 45 | 90.07 | 87.64 |
| hard / support_c3_r1000 | 45 | 30 | 33 | 21 | 12 | 9 | 3 | 45 | 90.89 | 88.58 |
| hard / support_c3_r1075 | 45 | 30 | 33 | 21 | 12 | 9 | 3 | 45 | 91.37 | 88.36 |
| hard / support_c3_r1150 | 45 | 30 | 33 | 21 | 12 | 9 | 3 | 45 | 91.84 | 88.29 |
| hard / support_c6_r1000 | 45 | 27 | 33 | 18 | 15 | 9 | 3 | 45 | 92.33 | 89.02 |
| hard / support_c6_r1075 | 45 | 27 | 33 | 18 | 15 | 9 | 3 | 45 | 92.76 | 88.78 |
| hard / support_c6_r1150 | 45 | 25 | 33 | 16 | 17 | 9 | 3 | 45 | 93.19 | 88.73 |

## Contrastes à un paramètre

Δ jours de victoire uniquement sur les paires à deux victoires ; Δ Relais uniquement sur celles à deux Relais réussis. Gains/pertes restent affichés séparément. Les achats retard/tôt/absents/ajouts comptent des acquisitions, pas des parties.

| Candidat / référence | Groupes | Victoires gagnées/perdues | Relais gagnés/perdus | Deux victoires | Δ jours victoire | Deux Relais | Relais tôt/tard | Δ jours Relais | Achats retard/tôt/absents/ajouts |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| support_c6_r1150 / disabled | 135 | 0/14 | 0/18 | 112 | 1.87 | 99 | 72/27 | 0.36 | 390/0/6/0 |
| support_c0_r1150 / support_c6_r1150 | 135 | 8/0 | 18/0 | 112 | -2.14 | 99 | 27/0 | -1.27 | 0/390/0/6 |
| support_c3_r1150 / support_c6_r1150 | 135 | 5/0 | 0/0 | 112 | -0.97 | 99 | 18/0 | -0.55 | 0/390/0/6 |
| support_c0_r1000 / support_c0_r1150 | 135 | 4/0 | 0/0 | 120 | 0.00 | 117 | 0/0 | 0.00 | 0/0/0/0 |
| support_c0_r1075 / support_c0_r1150 | 135 | 0/0 | 0/0 | 120 | 0.00 | 117 | 0/0 | 0.00 | 0/0/0/0 |
| support_c3_r1000 / support_c3_r1150 | 135 | 0/0 | 0/0 | 117 | 0.00 | 99 | 0/0 | 0.00 | 0/0/0/0 |
| support_c3_r1075 / support_c3_r1150 | 135 | 0/0 | 0/0 | 117 | 0.00 | 99 | 0/0 | 0.00 | 0/0/0/0 |
| support_c6_r1000 / support_c6_r1150 | 135 | 2/0 | 0/0 | 112 | 0.00 | 99 | 0/0 | 0.00 | 0/0/0/0 |
| support_c6_r1075 / support_c6_r1150 | 135 | 2/0 | 0/0 | 112 | 0.00 | 99 | 0/0 | 0.00 | 0/0/0/0 |

## Remède à dates fixes

Chaque cellule donne la moyenne et le dénominateur observé. Les parties finies ne sont pas prolongées ; le remède final du premier tableau correspond à des jours différents.

| Modèle | Jour | Observations | Remède moyen (%) |
| --- | ---: | ---: | ---: |
| disabled | 0 | 135 | 0.00 |
| disabled | 28 | 135 | 9.33 |
| disabled | 31 | 135 | 11.18 |
| disabled | 40 | 135 | 16.79 |
| disabled | 43 | 135 | 18.79 |
| disabled | 54 | 135 | 26.16 |
| observe | 0 | 135 | 0.00 |
| observe | 28 | 135 | 9.33 |
| observe | 31 | 135 | 11.18 |
| observe | 40 | 135 | 16.79 |
| observe | 43 | 135 | 18.79 |
| observe | 54 | 135 | 26.16 |
| limit | 0 | 135 | 0.00 |
| limit | 28 | 135 | 9.33 |
| limit | 31 | 135 | 10.90 |
| limit | 40 | 135 | 15.67 |
| limit | 43 | 135 | 17.66 |
| limit | 54 | 135 | 25.01 |
| support_c0_r1000 | 0 | 135 | 0.00 |
| support_c0_r1000 | 28 | 135 | 9.33 |
| support_c0_r1000 | 31 | 135 | 11.18 |
| support_c0_r1000 | 40 | 135 | 16.79 |
| support_c0_r1000 | 43 | 135 | 18.80 |
| support_c0_r1000 | 54 | 135 | 26.19 |
| support_c0_r1075 | 0 | 135 | 0.00 |
| support_c0_r1075 | 28 | 135 | 9.33 |
| support_c0_r1075 | 31 | 135 | 11.32 |
| support_c0_r1075 | 40 | 135 | 17.35 |
| support_c0_r1075 | 43 | 135 | 19.36 |
| support_c0_r1075 | 54 | 135 | 26.75 |
| support_c0_r1150 | 0 | 135 | 0.00 |
| support_c0_r1150 | 28 | 135 | 9.33 |
| support_c0_r1150 | 31 | 135 | 11.46 |
| support_c0_r1150 | 40 | 135 | 17.91 |
| support_c0_r1150 | 43 | 135 | 19.92 |
| support_c0_r1150 | 54 | 135 | 27.31 |
| support_c3_r1000 | 0 | 135 | 0.00 |
| support_c3_r1000 | 28 | 135 | 9.33 |
| support_c3_r1000 | 31 | 135 | 11.19 |
| support_c3_r1000 | 40 | 135 | 16.85 |
| support_c3_r1000 | 43 | 135 | 18.79 |
| support_c3_r1000 | 54 | 135 | 26.49 |
| support_c3_r1075 | 0 | 135 | 0.00 |
| support_c3_r1075 | 28 | 135 | 9.33 |
| support_c3_r1075 | 31 | 135 | 11.33 |
| support_c3_r1075 | 40 | 135 | 17.41 |
| support_c3_r1075 | 43 | 135 | 19.36 |
| support_c3_r1075 | 54 | 135 | 27.05 |
| support_c3_r1150 | 0 | 135 | 0.00 |
| support_c3_r1150 | 28 | 135 | 9.33 |
| support_c3_r1150 | 31 | 135 | 11.47 |
| support_c3_r1150 | 40 | 135 | 17.97 |
| support_c3_r1150 | 43 | 135 | 19.92 |
| support_c3_r1150 | 54 | 135 | 27.62 |
| support_c6_r1000 | 0 | 135 | 0.00 |
| support_c6_r1000 | 28 | 135 | 9.33 |
| support_c6_r1000 | 31 | 135 | 11.19 |
| support_c6_r1000 | 40 | 135 | 16.90 |
| support_c6_r1000 | 43 | 135 | 18.84 |
| support_c6_r1000 | 54 | 135 | 26.49 |
| support_c6_r1075 | 0 | 135 | 0.00 |
| support_c6_r1075 | 28 | 135 | 9.33 |
| support_c6_r1075 | 31 | 135 | 11.33 |
| support_c6_r1075 | 40 | 135 | 17.47 |
| support_c6_r1075 | 43 | 135 | 19.41 |
| support_c6_r1075 | 54 | 135 | 27.06 |
| support_c6_r1150 | 0 | 135 | 0.00 |
| support_c6_r1150 | 28 | 135 | 9.33 |
| support_c6_r1150 | 31 | 135 | 11.47 |
| support_c6_r1150 | 40 | 135 | 18.03 |
| support_c6_r1150 | 43 | 135 | 19.97 |
| support_c6_r1150 | 54 | 135 | 27.63 |

## Paramètres exacts et empreintes

| Modèle | Coût soutien | Facteur remède soutien | Empreinte catalogue hypothétique |
| --- | ---: | ---: | --- |
| disabled | 6 | 1.150 | `b75f08182352bfc2f71d5d3dfe403eaf73402b8fc67fbddd6147254057669494` |
| observe | 6 | 1.150 | `b75f08182352bfc2f71d5d3dfe403eaf73402b8fc67fbddd6147254057669494` |
| limit | 6 | 1.150 | `b75f08182352bfc2f71d5d3dfe403eaf73402b8fc67fbddd6147254057669494` |
| support_c0_r1000 | 0 | 1.000 | `8ef76006637dc487d8d150175c685038c0b66483e28388676e9a8efa1b6dddd1` |
| support_c0_r1075 | 0 | 1.075 | `94f75efbef98dc84e9e52fd2599067ac6c94483acab747f9ce734239a0a7a2a1` |
| support_c0_r1150 | 0 | 1.150 | `38f444139522d3fd277d82fc203f8541510187dc47f4445c01a2c06a0ec39576` |
| support_c3_r1000 | 3 | 1.000 | `6a268da5d3708718a469f99eeeca95f93df88cb966f1865f1cdd2261aff2315f` |
| support_c3_r1075 | 3 | 1.075 | `40250c8cc96bc9c45227ba8dc29d2805183a5fb9357de9d045edd6b4d124824b` |
| support_c3_r1150 | 3 | 1.150 | `4a349b13a2785f34ab901db564d5f5a65f18ef66f82aaeccfc49210b422dc60a` |
| support_c6_r1000 | 6 | 1.000 | `891a7f892f3e7a4440f40190c2c4d0a988a73a8e9540b30e7d8e9e3f5420b9fe` |
| support_c6_r1075 | 6 | 1.075 | `171bd9efc89f59a479f88b30edec9b205e8ee5d7fad5436b07c0f2a98a8a6c6b` |
| support_c6_r1150 | 6 | 1.150 | `b75f08182352bfc2f71d5d3dfe403eaf73402b8fc67fbddd6147254057669494` |

Les modèles témoins conservent les paramètres 6/1,15 du soutien, mais ne choisissent pas ce soutien. Les politiques et traces complètes (achats, refus, points, choix, relevés) sont dans le JSON local. Trois graines et des politiques automatiques de même poids ne constituent pas une validation humaine. Les Relais sont plafonnés et figés. Décision d'ajustement et limites au point de reprise 16.
