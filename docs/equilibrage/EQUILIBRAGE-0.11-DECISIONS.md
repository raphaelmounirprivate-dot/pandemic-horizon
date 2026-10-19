# Décision logistique — analyse du prototype 0.11.0

Moteur : `4.7.2-stable (official)`. Empreinte du contenu : `4a65420bb3bcc4320c2925410f3c125ca40c4070260e55349df6328639ac93e6`.

Commande : `dev.ps1 BalanceDecisions`. Dégel, Boréale, Relais arctiques activés ; trois difficultés, graines 7/42/2042, quinze ordres historiques. Quatre variantes par groupe : désactivée (`disabled`), maintien (`observe`), soutien (`support`), limitation (`limit`). Arrêt au résultat principal, limite 500 jours.

Deux séries : `ordinary`, achats habituels ; `reserve`, même restriction dans les quatre variantes du J20 au J27 : ne pas acheter si le solde passerait sous 6 points. Aucun point offert. Au début de chaque journée : tenter le choix demandé s'il est en attente, puis le premier achat manquant de l'ordre, puis simuler. Choix au J28 si abordable, sinon nouvelle tentative J29/J30 ; au J31, maintien automatique. Une intention de soutien n'est pas un soutien appliqué. La réserve peut modifier les dates avant J28 ; comparer les variantes à l'intérieur de leur série.

Les empreintes avant choix doivent être identiques pour les quatre variantes. Maintien et désactivation doivent avoir les mêmes états complets, résultats, achats et échantillons, hors décision et journal. Les autres variantes peuvent changer budget, achats, propagation, objectifs et fin. Groupes manquants/dupliqués et dérives font échouer la commande. Le CSV conserve tentatives, refus, achats et points avant/après, choix réellement appliqué, relevés datés, RNG inclus dans les empreintes.

## Ensemble

| Série / variante | Parties | Victoires | Relais réussis | Deux succès | Relais seuls | Victoire seule | Deux échecs | Choix demandé appliqué | Remède final moyen | Jour final moyen |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| ordinary / disabled | 135 | 124 | 117 | 112 | 5 | 12 | 6 | — | 70.06 | 88.23 |
| ordinary / observe | 135 | 124 | 117 | 112 | 5 | 12 | 6 | 135 | 70.06 | 88.23 |
| ordinary / support | 135 | 118 | 99 | 88 | 11 | 30 | 6 | 45 | 71.43 | 88.96 |
| ordinary / limit | 135 | 126 | 117 | 114 | 3 | 12 | 6 | 135 | 69.23 | 88.50 |
| reserve / disabled | 135 | 126 | 117 | 114 | 3 | 12 | 6 | — | 70.59 | 89.01 |
| reserve / observe | 135 | 126 | 117 | 114 | 3 | 12 | 6 | 135 | 70.59 | 89.01 |
| reserve / support | 135 | 112 | 99 | 82 | 17 | 30 | 6 | 135 | 75.02 | 90.55 |
| reserve / limit | 135 | 126 | 117 | 114 | 3 | 12 | 6 | 135 | 69.83 | 89.38 |

## Par difficulté

| Série / variante | Parties | Victoires | Relais réussis | Deux succès | Relais seuls | Victoire seule | Deux échecs | Choix demandé appliqué | Remède final moyen | Jour final moyen |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| ordinary / easy / disabled | 45 | 45 | 39 | 39 | 0 | 6 | 0 | — | 52.31 | 89.02 |
| ordinary / easy / observe | 45 | 45 | 39 | 39 | 0 | 6 | 0 | 45 | 52.31 | 89.02 |
| ordinary / easy / support | 45 | 45 | 33 | 33 | 0 | 12 | 0 | 15 | 53.56 | 89.89 |
| ordinary / easy / limit | 45 | 45 | 39 | 39 | 0 | 6 | 0 | 45 | 51.61 | 89.22 |
| ordinary / normal / disabled | 45 | 42 | 39 | 39 | 0 | 3 | 3 | — | 69.44 | 88.49 |
| ordinary / normal / observe | 45 | 42 | 39 | 39 | 0 | 3 | 3 | 45 | 69.44 | 88.49 |
| ordinary / normal / support | 45 | 42 | 33 | 33 | 0 | 9 | 3 | 15 | 71.11 | 89.38 |
| ordinary / normal / limit | 45 | 42 | 39 | 39 | 0 | 3 | 3 | 45 | 68.62 | 88.76 |
| ordinary / hard / disabled | 45 | 37 | 39 | 34 | 5 | 3 | 3 | — | 88.43 | 87.18 |
| ordinary / hard / observe | 45 | 37 | 39 | 34 | 5 | 3 | 3 | 45 | 88.43 | 87.18 |
| ordinary / hard / support | 45 | 31 | 33 | 22 | 11 | 9 | 3 | 15 | 89.61 | 87.60 |
| ordinary / hard / limit | 45 | 39 | 39 | 36 | 3 | 3 | 3 | 45 | 87.45 | 87.53 |
| reserve / easy / disabled | 45 | 45 | 39 | 39 | 0 | 6 | 0 | — | 52.63 | 89.76 |
| reserve / easy / observe | 45 | 45 | 39 | 39 | 0 | 6 | 0 | 45 | 52.63 | 89.76 |
| reserve / easy / support | 45 | 45 | 33 | 33 | 0 | 12 | 0 | 45 | 56.64 | 91.71 |
| reserve / easy / limit | 45 | 45 | 39 | 39 | 0 | 6 | 0 | 45 | 52.14 | 90.16 |
| reserve / normal / disabled | 45 | 42 | 39 | 39 | 0 | 3 | 3 | — | 69.98 | 89.29 |
| reserve / normal / observe | 45 | 42 | 39 | 39 | 0 | 3 | 3 | 45 | 69.98 | 89.29 |
| reserve / normal / support | 45 | 42 | 33 | 33 | 0 | 9 | 3 | 45 | 75.24 | 91.20 |
| reserve / normal / limit | 45 | 42 | 39 | 39 | 0 | 3 | 3 | 45 | 69.18 | 89.60 |
| reserve / hard / disabled | 45 | 39 | 39 | 36 | 3 | 3 | 3 | — | 89.17 | 88.00 |
| reserve / hard / observe | 45 | 39 | 39 | 36 | 3 | 3 | 3 | 45 | 89.17 | 88.00 |
| reserve / hard / support | 45 | 25 | 33 | 16 | 17 | 9 | 3 | 45 | 93.19 | 88.73 |
| reserve / hard / limit | 45 | 39 | 39 | 36 | 3 | 3 | 3 | 45 | 88.17 | 88.38 |

## Par politique

| Série / variante | Parties | Victoires | Relais réussis | Deux succès | Relais seuls | Victoire seule | Deux échecs | Choix demandé appliqué | Remède final moyen | Jour final moyen |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| ordinary / attente / disabled | 9 | 3 | 0 | 0 | 0 | 3 | 6 | — | 95.90 | 109.00 |
| ordinary / attente / observe | 9 | 3 | 0 | 0 | 0 | 3 | 6 | 9 | 95.90 | 109.00 |
| ordinary / attente / support | 9 | 3 | 0 | 0 | 0 | 3 | 6 | 9 | 96.27 | 108.44 |
| ordinary / attente / limit | 9 | 3 | 0 | 0 | 0 | 3 | 6 | 9 | 95.87 | 109.78 |
| ordinary / discretion / disabled | 9 | 9 | 9 | 9 | 0 | 0 | 0 | — | 58.07 | 91.33 |
| ordinary / discretion / observe | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 58.07 | 91.33 |
| ordinary / discretion / support | 9 | 9 | 0 | 0 | 0 | 9 | 0 | 9 | 60.77 | 94.44 |
| ordinary / discretion / limit | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 57.11 | 91.33 |
| ordinary / diffusion / disabled | 9 | 9 | 9 | 9 | 0 | 0 | 0 | — | 59.20 | 87.11 |
| ordinary / diffusion / observe | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 59.20 | 87.11 |
| ordinary / diffusion / support | 9 | 9 | 0 | 0 | 0 | 9 | 0 | 9 | 64.36 | 89.56 |
| ordinary / diffusion / limit | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 58.51 | 87.33 |
| ordinary / mobilite / disabled | 9 | 9 | 9 | 9 | 0 | 0 | 0 | — | 60.18 | 82.33 |
| ordinary / mobilite / observe | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 60.18 | 82.33 |
| ordinary / mobilite / support | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 0 | 60.18 | 82.33 |
| ordinary / mobilite / limit | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 59.70 | 82.89 |
| ordinary / polaire / disabled | 9 | 9 | 0 | 0 | 0 | 9 | 0 | — | 70.33 | 95.22 |
| ordinary / polaire / observe | 9 | 9 | 0 | 0 | 0 | 9 | 0 | 9 | 70.33 | 95.22 |
| ordinary / polaire / support | 9 | 9 | 0 | 0 | 0 | 9 | 0 | 0 | 70.33 | 95.22 |
| ordinary / polaire / limit | 9 | 9 | 0 | 0 | 0 | 9 | 0 | 9 | 69.35 | 95.44 |
| ordinary / terrestre / disabled | 9 | 9 | 9 | 9 | 0 | 0 | 0 | — | 64.68 | 78.00 |
| ordinary / terrestre / observe | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 64.68 | 78.00 |
| ordinary / terrestre / support | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 0 | 64.68 | 78.00 |
| ordinary / terrestre / limit | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 63.30 | 78.00 |
| ordinary / aerien / disabled | 9 | 9 | 9 | 9 | 0 | 0 | 0 | — | 75.05 | 82.00 |
| ordinary / aerien / observe | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 75.05 | 82.00 |
| ordinary / aerien / support | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 0 | 75.05 | 82.00 |
| ordinary / aerien / limit | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 74.23 | 82.33 |
| ordinary / maritime / disabled | 9 | 9 | 9 | 9 | 0 | 0 | 0 | — | 70.74 | 81.33 |
| ordinary / maritime / observe | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 70.74 | 81.33 |
| ordinary / maritime / support | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 0 | 70.74 | 81.33 |
| ordinary / maritime / limit | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 69.79 | 81.56 |
| ordinary / terrestre_discretion_avant / disabled | 9 | 9 | 9 | 9 | 0 | 0 | 0 | — | 60.11 | 81.00 |
| ordinary / terrestre_discretion_avant / observe | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 60.11 | 81.00 |
| ordinary / terrestre_discretion_avant / support | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 0 | 60.11 | 81.00 |
| ordinary / terrestre_discretion_avant / limit | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 58.77 | 81.00 |
| ordinary / aerien_discretion_avant / disabled | 9 | 9 | 9 | 9 | 0 | 0 | 0 | — | 64.37 | 82.33 |
| ordinary / aerien_discretion_avant / observe | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 64.37 | 82.33 |
| ordinary / aerien_discretion_avant / support | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 0 | 64.37 | 82.33 |
| ordinary / aerien_discretion_avant / limit | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 64.03 | 82.89 |
| ordinary / maritime_discretion_avant / disabled | 9 | 9 | 9 | 9 | 0 | 0 | 0 | — | 62.50 | 82.00 |
| ordinary / maritime_discretion_avant / observe | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 62.50 | 82.00 |
| ordinary / maritime_discretion_avant / support | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 0 | 62.50 | 82.00 |
| ordinary / maritime_discretion_avant / limit | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 61.57 | 82.22 |
| ordinary / saisonnier / disabled | 9 | 9 | 9 | 9 | 0 | 0 | 0 | — | 76.43 | 89.00 |
| ordinary / saisonnier / observe | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 76.43 | 89.00 |
| ordinary / saisonnier / support | 9 | 6 | 9 | 6 | 3 | 0 | 0 | 9 | 81.99 | 91.33 |
| ordinary / saisonnier / limit | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 75.08 | 89.00 |
| ordinary / polaire_diffusion / disabled | 9 | 7 | 9 | 7 | 2 | 0 | 0 | — | 76.61 | 88.44 |
| ordinary / polaire_diffusion / observe | 9 | 7 | 9 | 7 | 2 | 0 | 0 | 9 | 76.61 | 88.44 |
| ordinary / polaire_diffusion / support | 9 | 7 | 9 | 7 | 2 | 0 | 0 | 0 | 76.61 | 88.44 |
| ordinary / polaire_diffusion / limit | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 75.57 | 88.56 |
| ordinary / resilience_precoce / disabled | 9 | 6 | 9 | 6 | 3 | 0 | 0 | — | 85.17 | 95.33 |
| ordinary / resilience_precoce / observe | 9 | 6 | 9 | 6 | 3 | 0 | 0 | 9 | 85.17 | 95.33 |
| ordinary / resilience_precoce / support | 9 | 6 | 9 | 6 | 3 | 0 | 0 | 0 | 85.17 | 95.33 |
| ordinary / resilience_precoce / limit | 9 | 6 | 9 | 6 | 3 | 0 | 0 | 9 | 84.97 | 96.00 |
| ordinary / saisonnier_discret / disabled | 9 | 9 | 9 | 9 | 0 | 0 | 0 | — | 71.53 | 99.00 |
| ordinary / saisonnier_discret / observe | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 71.53 | 99.00 |
| ordinary / saisonnier_discret / support | 9 | 6 | 9 | 6 | 3 | 0 | 0 | 9 | 78.29 | 102.56 |
| ordinary / saisonnier_discret / limit | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 70.56 | 99.22 |
| reserve / attente / disabled | 9 | 3 | 0 | 0 | 0 | 3 | 6 | — | 95.90 | 109.00 |
| reserve / attente / observe | 9 | 3 | 0 | 0 | 0 | 3 | 6 | 9 | 95.90 | 109.00 |
| reserve / attente / support | 9 | 3 | 0 | 0 | 0 | 3 | 6 | 9 | 96.27 | 108.44 |
| reserve / attente / limit | 9 | 3 | 0 | 0 | 0 | 3 | 6 | 9 | 95.87 | 109.78 |
| reserve / discretion / disabled | 9 | 9 | 9 | 9 | 0 | 0 | 0 | — | 58.07 | 91.33 |
| reserve / discretion / observe | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 58.07 | 91.33 |
| reserve / discretion / support | 9 | 9 | 0 | 0 | 0 | 9 | 0 | 9 | 60.77 | 94.44 |
| reserve / discretion / limit | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 57.11 | 91.33 |
| reserve / diffusion / disabled | 9 | 9 | 9 | 9 | 0 | 0 | 0 | — | 59.20 | 87.11 |
| reserve / diffusion / observe | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 59.20 | 87.11 |
| reserve / diffusion / support | 9 | 9 | 0 | 0 | 0 | 9 | 0 | 9 | 64.36 | 89.56 |
| reserve / diffusion / limit | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 58.51 | 87.33 |
| reserve / mobilite / disabled | 9 | 9 | 9 | 9 | 0 | 0 | 0 | — | 61.41 | 83.78 |
| reserve / mobilite / observe | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 61.41 | 83.78 |
| reserve / mobilite / support | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 65.56 | 84.00 |
| reserve / mobilite / limit | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 60.24 | 84.00 |
| reserve / polaire / disabled | 9 | 9 | 0 | 0 | 0 | 9 | 0 | — | 70.47 | 95.67 |
| reserve / polaire / observe | 9 | 9 | 0 | 0 | 0 | 9 | 0 | 9 | 70.47 | 95.67 |
| reserve / polaire / support | 9 | 9 | 0 | 0 | 0 | 9 | 0 | 9 | 76.09 | 98.11 |
| reserve / polaire / limit | 9 | 9 | 0 | 0 | 0 | 9 | 0 | 9 | 69.50 | 95.89 |
| reserve / terrestre / disabled | 9 | 9 | 9 | 9 | 0 | 0 | 0 | — | 65.11 | 79.00 |
| reserve / terrestre / observe | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 65.11 | 79.00 |
| reserve / terrestre / support | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 71.80 | 80.00 |
| reserve / terrestre / limit | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 63.66 | 79.00 |
| reserve / aerien / disabled | 9 | 9 | 9 | 9 | 0 | 0 | 0 | — | 76.08 | 83.33 |
| reserve / aerien / observe | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 76.08 | 83.33 |
| reserve / aerien / support | 9 | 6 | 9 | 6 | 3 | 0 | 0 | 9 | 80.04 | 83.22 |
| reserve / aerien / limit | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 75.74 | 84.00 |
| reserve / maritime / disabled | 9 | 9 | 9 | 9 | 0 | 0 | 0 | — | 71.24 | 82.33 |
| reserve / maritime / observe | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 71.24 | 82.33 |
| reserve / maritime / support | 9 | 7 | 9 | 7 | 2 | 0 | 0 | 9 | 77.43 | 83.00 |
| reserve / maritime / limit | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 70.88 | 83.00 |
| reserve / terrestre_discretion_avant / disabled | 9 | 9 | 9 | 9 | 0 | 0 | 0 | — | 60.72 | 82.00 |
| reserve / terrestre_discretion_avant / observe | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 60.72 | 82.00 |
| reserve / terrestre_discretion_avant / support | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 65.94 | 83.56 |
| reserve / terrestre_discretion_avant / limit | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 59.83 | 82.33 |
| reserve / aerien_discretion_avant / disabled | 9 | 9 | 9 | 9 | 0 | 0 | 0 | — | 65.93 | 83.78 |
| reserve / aerien_discretion_avant / observe | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 65.93 | 83.78 |
| reserve / aerien_discretion_avant / support | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 67.83 | 84.00 |
| reserve / aerien_discretion_avant / limit | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 64.79 | 84.00 |
| reserve / maritime_discretion_avant / disabled | 9 | 9 | 9 | 9 | 0 | 0 | 0 | — | 63.69 | 83.33 |
| reserve / maritime_discretion_avant / observe | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 63.69 | 83.33 |
| reserve / maritime_discretion_avant / support | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 67.09 | 84.00 |
| reserve / maritime_discretion_avant / limit | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 63.36 | 84.00 |
| reserve / saisonnier / disabled | 9 | 9 | 9 | 9 | 0 | 0 | 0 | — | 76.73 | 90.00 |
| reserve / saisonnier / observe | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 76.73 | 90.00 |
| reserve / saisonnier / support | 9 | 6 | 9 | 6 | 3 | 0 | 0 | 9 | 82.08 | 92.33 |
| reserve / saisonnier / limit | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 75.96 | 90.44 |
| reserve / polaire_diffusion / disabled | 9 | 9 | 9 | 9 | 0 | 0 | 0 | — | 76.86 | 89.00 |
| reserve / polaire_diffusion / observe | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 76.86 | 89.00 |
| reserve / polaire_diffusion / support | 9 | 6 | 9 | 6 | 3 | 0 | 0 | 9 | 82.35 | 91.33 |
| reserve / polaire_diffusion / limit | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 75.57 | 89.00 |
| reserve / resilience_precoce / disabled | 9 | 6 | 9 | 6 | 3 | 0 | 0 | — | 85.15 | 95.33 |
| reserve / resilience_precoce / observe | 9 | 6 | 9 | 6 | 3 | 0 | 0 | 9 | 85.15 | 95.33 |
| reserve / resilience_precoce / support | 9 | 6 | 9 | 6 | 3 | 0 | 0 | 9 | 89.12 | 98.56 |
| reserve / resilience_precoce / limit | 9 | 6 | 9 | 6 | 3 | 0 | 0 | 9 | 84.94 | 96.00 |
| reserve / saisonnier_discret / disabled | 9 | 9 | 9 | 9 | 0 | 0 | 0 | — | 72.33 | 100.22 |
| reserve / saisonnier_discret / observe | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 72.33 | 100.22 |
| reserve / saisonnier_discret / support | 9 | 6 | 9 | 6 | 3 | 0 | 0 | 9 | 78.58 | 103.67 |
| reserve / saisonnier_discret / limit | 9 | 9 | 9 | 9 | 0 | 0 | 0 | 9 | 71.45 | 100.56 |

## Contrastes appariés avec désactivation

Δ jours = variante − témoin, uniquement quand les deux gagnent. Les gains et pertes comptent des changements de résultat dans les mêmes groupes. Les colonnes achats comptent des acquisitions, pas des parties : en retard / plus tôt / absentes / supplémentaires par rapport au témoin.

| Série / variante | Groupes | Victoires gagnées/perdues | Relais gagnés/perdus | Deux victoires | Δ jours moyen | Achats retard/tôt/absents/ajouts |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| ordinary / observe | 135 | 0/0 | 0/0 | 124 | 0.00 | 0/0/0/0 |
| ordinary / support | 135 | 0/6 | 0/18 | 118 | 0.82 | 87/0/3/0 |
| ordinary / limit | 135 | 2/0 | 0/0 | 124 | 0.23 | 0/0/0/0 |
| reserve / observe | 135 | 0/0 | 0/0 | 126 | 0.00 | 0/0/0/0 |
| reserve / support | 135 | 0/14 | 0/18 | 112 | 1.87 | 390/0/6/0 |
| reserve / limit | 135 | 0/0 | 0/0 | 126 | 0.33 | 0/0/0/0 |

## Date des Relais dans les paires à deux réussites

Les échecs sont exclus de ces dates, mais restent dans la table des gains/pertes ci-dessus. Une avance de relais ne signifie pas une victoire principale.

| Série / variante | Deux relais réussis | Relais plus tôt | Relais plus tard | Δ jour moyen |
| --- | ---: | ---: | ---: | ---: |
| ordinary / observe | 117 | 0 | 0 | 0.00 |
| ordinary / support | 99 | 18 | 0 | -0.44 |
| ordinary / limit | 117 | 0 | 3 | 0.03 |
| reserve / observe | 117 | 0 | 0 | 0.00 |
| reserve / support | 99 | 72 | 27 | 0.36 |
| reserve / limit | 117 | 0 | 3 | 0.03 |

## Choix réellement appliqués

| Série / choix demandé | Appliqué | Jour min–max | Points dépensés au total | Maintien automatique faute de financement |
| --- | ---: | ---: | ---: | ---: |
| ordinary / observe | 135/135 | 28–28 | 0 | 0 |
| ordinary / support | 45/135 | 28–30 | 270 | 90 |
| ordinary / limit | 135/135 | 28–28 | 0 | 0 |
| reserve / observe | 135/135 | 28–28 | 0 | 0 |
| reserve / support | 135/135 | 28–28 | 810 | 0 |
| reserve / limit | 135/135 | 28–28 | 0 | 0 |

## Progression du remède

Moyenne au même jour et nombre de parties observées. Une partie déjà terminée n'est pas prolongée artificiellement ; si les dénominateurs diffèrent, les moyennes ne sont pas des contrastes appariés. Le remède final se mesure à des jours différents, selon la fin principale.

| Série / variante | Jour | Observations | Remède moyen (%) |
| --- | ---: | ---: | ---: |
| ordinary / disabled | 0 | 135 | 0.00 |
| ordinary / disabled | 28 | 135 | 9.33 |
| ordinary / disabled | 31 | 135 | 11.18 |
| ordinary / disabled | 40 | 135 | 16.81 |
| ordinary / disabled | 43 | 135 | 18.83 |
| ordinary / disabled | 54 | 135 | 26.29 |
| ordinary / observe | 0 | 135 | 0.00 |
| ordinary / observe | 28 | 135 | 9.33 |
| ordinary / observe | 31 | 135 | 11.18 |
| ordinary / observe | 40 | 135 | 16.81 |
| ordinary / observe | 43 | 135 | 18.83 |
| ordinary / observe | 54 | 135 | 26.29 |
| ordinary / support | 0 | 135 | 0.00 |
| ordinary / support | 28 | 135 | 9.33 |
| ordinary / support | 31 | 135 | 11.26 |
| ordinary / support | 40 | 135 | 17.28 |
| ordinary / support | 43 | 135 | 19.32 |
| ordinary / support | 54 | 135 | 26.90 |
| ordinary / limit | 0 | 135 | 0.00 |
| ordinary / limit | 28 | 135 | 9.33 |
| ordinary / limit | 31 | 135 | 10.90 |
| ordinary / limit | 40 | 135 | 15.69 |
| ordinary / limit | 43 | 135 | 17.70 |
| ordinary / limit | 54 | 135 | 25.14 |
| reserve / disabled | 0 | 135 | 0.00 |
| reserve / disabled | 28 | 135 | 9.33 |
| reserve / disabled | 31 | 135 | 11.18 |
| reserve / disabled | 40 | 135 | 16.79 |
| reserve / disabled | 43 | 135 | 18.79 |
| reserve / disabled | 54 | 135 | 26.16 |
| reserve / observe | 0 | 135 | 0.00 |
| reserve / observe | 28 | 135 | 9.33 |
| reserve / observe | 31 | 135 | 11.18 |
| reserve / observe | 40 | 135 | 16.79 |
| reserve / observe | 43 | 135 | 18.79 |
| reserve / observe | 54 | 135 | 26.16 |
| reserve / support | 0 | 135 | 0.00 |
| reserve / support | 28 | 135 | 9.33 |
| reserve / support | 31 | 135 | 11.47 |
| reserve / support | 40 | 135 | 18.03 |
| reserve / support | 43 | 135 | 19.97 |
| reserve / support | 54 | 135 | 27.63 |
| reserve / limit | 0 | 135 | 0.00 |
| reserve / limit | 28 | 135 | 9.33 |
| reserve / limit | 31 | 135 | 10.90 |
| reserve / limit | 40 | 135 | 15.67 |
| reserve / limit | 43 | 135 | 17.66 |
| reserve / limit | 54 | 135 | 25.01 |

## Dates des achats

Acquis avant la fin principale ; échéance incluse J54. Dates min–max des seules acquisitions, sans inventer de date pour un achat absent.

| Série / variante / achat | Parties | Acquis | Avant J54 inclus | Jour min–max |
| --- | ---: | ---: | ---: | ---: |
| ordinary / disabled / transmission | 135 | 126 | 108 | 10–65 |
| ordinary / disabled / mobility | 135 | 126 | 81 | 25–80 |
| ordinary / disabled / discretion | 135 | 117 | 72 | 10–80 |
| ordinary / disabled / land_network | 135 | 18 | 9 | 40–65 |
| ordinary / disabled / air_bridge | 135 | 18 | 9 | 40–65 |
| ordinary / disabled / sea_logistics | 135 | 18 | 9 | 40–65 |
| ordinary / disabled / polar | 135 | 45 | 45 | 5–5 |
| ordinary / disabled / seasonal | 135 | 45 | 36 | 20–65 |
| ordinary / disabled / resilience | 135 | 9 | 9 | 25–25 |
| ordinary / observe / transmission | 135 | 126 | 108 | 10–65 |
| ordinary / observe / mobility | 135 | 126 | 81 | 25–80 |
| ordinary / observe / discretion | 135 | 117 | 72 | 10–80 |
| ordinary / observe / land_network | 135 | 18 | 9 | 40–65 |
| ordinary / observe / air_bridge | 135 | 18 | 9 | 40–65 |
| ordinary / observe / sea_logistics | 135 | 18 | 9 | 40–65 |
| ordinary / observe / polar | 135 | 45 | 45 | 5–5 |
| ordinary / observe / seasonal | 135 | 45 | 36 | 20–65 |
| ordinary / observe / resilience | 135 | 9 | 9 | 25–25 |
| ordinary / support / transmission | 135 | 126 | 108 | 10–75 |
| ordinary / support / mobility | 135 | 126 | 63 | 25–90 |
| ordinary / support / discretion | 135 | 114 | 63 | 10–90 |
| ordinary / support / land_network | 135 | 18 | 9 | 40–65 |
| ordinary / support / air_bridge | 135 | 18 | 9 | 40–65 |
| ordinary / support / sea_logistics | 135 | 18 | 9 | 40–65 |
| ordinary / support / polar | 135 | 45 | 45 | 5–5 |
| ordinary / support / seasonal | 135 | 45 | 36 | 20–65 |
| ordinary / support / resilience | 135 | 9 | 9 | 25–25 |
| ordinary / limit / transmission | 135 | 126 | 108 | 10–65 |
| ordinary / limit / mobility | 135 | 126 | 81 | 25–80 |
| ordinary / limit / discretion | 135 | 117 | 72 | 10–80 |
| ordinary / limit / land_network | 135 | 18 | 9 | 40–65 |
| ordinary / limit / air_bridge | 135 | 18 | 9 | 40–65 |
| ordinary / limit / sea_logistics | 135 | 18 | 9 | 40–65 |
| ordinary / limit / polar | 135 | 45 | 45 | 5–5 |
| ordinary / limit / seasonal | 135 | 45 | 36 | 20–65 |
| ordinary / limit / resilience | 135 | 9 | 9 | 25–25 |
| reserve / disabled / transmission | 135 | 126 | 108 | 10–65 |
| reserve / disabled / mobility | 135 | 126 | 81 | 28–80 |
| reserve / disabled / discretion | 135 | 117 | 72 | 10–80 |
| reserve / disabled / land_network | 135 | 18 | 9 | 40–65 |
| reserve / disabled / air_bridge | 135 | 18 | 9 | 40–65 |
| reserve / disabled / sea_logistics | 135 | 18 | 9 | 40–65 |
| reserve / disabled / polar | 135 | 45 | 45 | 5–5 |
| reserve / disabled / seasonal | 135 | 45 | 36 | 28–65 |
| reserve / disabled / resilience | 135 | 9 | 9 | 28–28 |
| reserve / observe / transmission | 135 | 126 | 108 | 10–65 |
| reserve / observe / mobility | 135 | 126 | 81 | 28–80 |
| reserve / observe / discretion | 135 | 117 | 72 | 10–80 |
| reserve / observe / land_network | 135 | 18 | 9 | 40–65 |
| reserve / observe / air_bridge | 135 | 18 | 9 | 40–65 |
| reserve / observe / sea_logistics | 135 | 18 | 9 | 40–65 |
| reserve / observe / polar | 135 | 45 | 45 | 5–5 |
| reserve / observe / seasonal | 135 | 45 | 36 | 28–65 |
| reserve / observe / resilience | 135 | 9 | 9 | 28–28 |
| reserve / support / transmission | 135 | 126 | 108 | 10–75 |
| reserve / support / mobility | 135 | 126 | 63 | 35–90 |
| reserve / support / discretion | 135 | 111 | 18 | 10–90 |
| reserve / support / land_network | 135 | 18 | 9 | 50–75 |
| reserve / support / air_bridge | 135 | 18 | 9 | 50–75 |
| reserve / support / sea_logistics | 135 | 18 | 9 | 50–75 |
| reserve / support / polar | 135 | 45 | 45 | 5–5 |
| reserve / support / seasonal | 135 | 45 | 36 | 30–75 |
| reserve / support / resilience | 135 | 9 | 9 | 35–35 |
| reserve / limit / transmission | 135 | 126 | 108 | 10–65 |
| reserve / limit / mobility | 135 | 126 | 81 | 28–80 |
| reserve / limit / discretion | 135 | 117 | 72 | 10–80 |
| reserve / limit / land_network | 135 | 18 | 9 | 40–65 |
| reserve / limit / air_bridge | 135 | 18 | 9 | 40–65 |
| reserve / limit / sea_logistics | 135 | 18 | 9 | 40–65 |
| reserve / limit / polar | 135 | 45 | 45 | 5–5 |
| reserve / limit / seasonal | 135 | 45 | 36 | 28–65 |
| reserve / limit / resilience | 135 | 9 | 9 | 28–28 |

## Politiques

- `attente` : aucun achat.
- `discretion` : discretion → transmission → mobility.
- `diffusion` : transmission → discretion → mobility.
- `mobilite` : transmission → mobility → discretion.
- `polaire` : polar → transmission → discretion → seasonal → mobility → resilience.
- `terrestre` : transmission → mobility → land_network → discretion.
- `aerien` : transmission → mobility → air_bridge → discretion.
- `maritime` : transmission → mobility → sea_logistics → discretion.
- `terrestre_discretion_avant` : transmission → mobility → discretion → land_network.
- `aerien_discretion_avant` : transmission → mobility → discretion → air_bridge.
- `maritime_discretion_avant` : transmission → mobility → discretion → sea_logistics.
- `saisonnier` : polar → seasonal → transmission → mobility → discretion.
- `polaire_diffusion` : polar → transmission → seasonal → mobility → discretion.
- `resilience_precoce` : polar → resilience → seasonal → transmission → mobility → discretion.
- `saisonnier_discret` : polar → seasonal → discretion → transmission → mobility.

Les quinze politiques ont le même poids ; trois graines seulement, plusieurs dates peuvent se répéter. Ces résultats décrivent des politiques automatiques complètes et les coefficients 0.11, pas des joueurs humains ni un effet causal isolé de chaque facteur. Les compteurs arctiques sont plafonnés et figés ; ils ne mesurent pas le trafic total. La décision d'ajustement et ses limites sont consignées dans le point de reprise 15.
