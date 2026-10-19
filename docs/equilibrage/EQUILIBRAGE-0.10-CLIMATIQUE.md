# Stratégies climatiques — prototype 0.10.0

Moteur : `4.7.2-stable (official)`. Empreinte du contenu : `f62d5506dcce2d68eec5c590a3efaf3e7b0bf8ef4f406486451afcfd317d19db`.

Commande : `dev.ps1 BalanceArctic`. Dégel, départ Boréale, difficultés facile/normale/difficile, graines 7/42/2042 et quinze politiques (onze historiques, quatre climatiques précoces). Une tentative du premier achat manquant avant chaque journée ; points légaux ; arrêt au résultat principal, limite de 500 jours.

Chaque paire active/désactive Relais arctiques, à graine, difficulté et décisions identiques. Appariement et empreintes suivent les mêmes contrôles que BalanceObjectives : seul le suivi, ses annonces et la date d'enregistrement sont exclus. Toute dérive, paire manquante ou dupliquée est une erreur. Les témoins ne sont pas des échecs facultatifs.

Quotas : 1 000 unités sortantes par route, Orient J36–54 et Centrale J39–54. Les compteurs sont plafonnés et figés à la résolution : ils ne mesurent pas les flux totaux ultérieurs. Deux succès = objectif et victoire principale ; objectif seul ou victoire seule séparent les deux résultats. Les dates moyennes concernent uniquement les réussites. Les taux décrivent cet échantillon, pas des joueurs humains ; aucun coefficient n'est modifié.

## Ensemble

| Échantillon | Paires | Objectif réussi | Taux observé | Deux succès | Objectif seul | Victoire seule | Deux échecs | Jour moyen réussi | Jours réussis min–max |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Dégel | 135 | 117 | 86.7 % | 112 | 5 | 12 | 6 | 47.00 | 42–53 |

## Résultats par difficulté et politique

| Difficulté / politique | Paires | Objectif réussi | Taux observé | Deux succès | Objectif seul | Victoire seule | Deux échecs | Jour moyen réussi | Jours réussis min–max |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| easy / aerien | 3 | 3 | 100.0 % | 3 | 0 | 0 | 0 | 45.00 | 45–45 |
| easy / aerien_discretion_avant | 3 | 3 | 100.0 % | 3 | 0 | 0 | 0 | 45.00 | 45–45 |
| easy / attente | 3 | 0 | 0.0 % | 0 | 0 | 3 | 0 | — | — |
| easy / diffusion | 3 | 3 | 100.0 % | 3 | 0 | 0 | 0 | 53.00 | 53–53 |
| easy / discretion | 3 | 3 | 100.0 % | 3 | 0 | 0 | 0 | 52.00 | 52–52 |
| easy / maritime | 3 | 3 | 100.0 % | 3 | 0 | 0 | 0 | 42.00 | 42–42 |
| easy / maritime_discretion_avant | 3 | 3 | 100.0 % | 3 | 0 | 0 | 0 | 45.00 | 45–45 |
| easy / mobilite | 3 | 3 | 100.0 % | 3 | 0 | 0 | 0 | 45.00 | 45–45 |
| easy / polaire | 3 | 0 | 0.0 % | 0 | 0 | 3 | 0 | — | — |
| easy / polaire_diffusion | 3 | 3 | 100.0 % | 3 | 0 | 0 | 0 | 49.00 | 49–49 |
| easy / resilience_precoce | 3 | 3 | 100.0 % | 3 | 0 | 0 | 0 | 49.00 | 49–49 |
| easy / saisonnier | 3 | 3 | 100.0 % | 3 | 0 | 0 | 0 | 48.00 | 48–48 |
| easy / saisonnier_discret | 3 | 3 | 100.0 % | 3 | 0 | 0 | 0 | 48.00 | 48–48 |
| easy / terrestre | 3 | 3 | 100.0 % | 3 | 0 | 0 | 0 | 45.00 | 45–45 |
| easy / terrestre_discretion_avant | 3 | 3 | 100.0 % | 3 | 0 | 0 | 0 | 45.00 | 45–45 |
| hard / aerien | 3 | 3 | 100.0 % | 3 | 0 | 0 | 0 | 45.00 | 45–45 |
| hard / aerien_discretion_avant | 3 | 3 | 100.0 % | 3 | 0 | 0 | 0 | 45.00 | 45–45 |
| hard / attente | 3 | 0 | 0.0 % | 0 | 0 | 0 | 3 | — | — |
| hard / diffusion | 3 | 3 | 100.0 % | 3 | 0 | 0 | 0 | 53.00 | 53–53 |
| hard / discretion | 3 | 3 | 100.0 % | 3 | 0 | 0 | 0 | 52.00 | 52–52 |
| hard / maritime | 3 | 3 | 100.0 % | 3 | 0 | 0 | 0 | 42.00 | 42–42 |
| hard / maritime_discretion_avant | 3 | 3 | 100.0 % | 3 | 0 | 0 | 0 | 45.00 | 45–45 |
| hard / mobilite | 3 | 3 | 100.0 % | 3 | 0 | 0 | 0 | 45.00 | 45–45 |
| hard / polaire | 3 | 0 | 0.0 % | 0 | 0 | 3 | 0 | — | — |
| hard / polaire_diffusion | 3 | 3 | 100.0 % | 1 | 2 | 0 | 0 | 49.00 | 49–49 |
| hard / resilience_precoce | 3 | 3 | 100.0 % | 0 | 3 | 0 | 0 | 49.00 | 49–49 |
| hard / saisonnier | 3 | 3 | 100.0 % | 3 | 0 | 0 | 0 | 48.00 | 48–48 |
| hard / saisonnier_discret | 3 | 3 | 100.0 % | 3 | 0 | 0 | 0 | 48.00 | 48–48 |
| hard / terrestre | 3 | 3 | 100.0 % | 3 | 0 | 0 | 0 | 45.00 | 45–45 |
| hard / terrestre_discretion_avant | 3 | 3 | 100.0 % | 3 | 0 | 0 | 0 | 45.00 | 45–45 |
| normal / aerien | 3 | 3 | 100.0 % | 3 | 0 | 0 | 0 | 45.00 | 45–45 |
| normal / aerien_discretion_avant | 3 | 3 | 100.0 % | 3 | 0 | 0 | 0 | 45.00 | 45–45 |
| normal / attente | 3 | 0 | 0.0 % | 0 | 0 | 0 | 3 | — | — |
| normal / diffusion | 3 | 3 | 100.0 % | 3 | 0 | 0 | 0 | 53.00 | 53–53 |
| normal / discretion | 3 | 3 | 100.0 % | 3 | 0 | 0 | 0 | 52.00 | 52–52 |
| normal / maritime | 3 | 3 | 100.0 % | 3 | 0 | 0 | 0 | 42.00 | 42–42 |
| normal / maritime_discretion_avant | 3 | 3 | 100.0 % | 3 | 0 | 0 | 0 | 45.00 | 45–45 |
| normal / mobilite | 3 | 3 | 100.0 % | 3 | 0 | 0 | 0 | 45.00 | 45–45 |
| normal / polaire | 3 | 0 | 0.0 % | 0 | 0 | 3 | 0 | — | — |
| normal / polaire_diffusion | 3 | 3 | 100.0 % | 3 | 0 | 0 | 0 | 49.00 | 49–49 |
| normal / resilience_precoce | 3 | 3 | 100.0 % | 3 | 0 | 0 | 0 | 49.00 | 49–49 |
| normal / saisonnier | 3 | 3 | 100.0 % | 3 | 0 | 0 | 0 | 48.00 | 48–48 |
| normal / saisonnier_discret | 3 | 3 | 100.0 % | 3 | 0 | 0 | 0 | 48.00 | 48–48 |
| normal / terrestre | 3 | 3 | 100.0 % | 3 | 0 | 0 | 0 | 45.00 | 45–45 |
| normal / terrestre_discretion_avant | 3 | 3 | 100.0 % | 3 | 0 | 0 | 0 | 45.00 | 45–45 |

## Achats réellement effectués

Tous les achats jusqu'à la fin principale sont comptés. La colonne avant échéance compte ceux effectués au plus tard au jour 54 ; un achat plus tardif peut aider la victoire principale mais arrive après la fenêtre de l'objectif. Aucun achat absent n'entre dans les dates min–max.

| Difficulté / politique / achat | Parties | Acquis | Avant échéance inclus | Jours acquis min–max |
| --- | ---: | ---: | ---: | ---: |
| easy / aerien / polar | 3 | 0 | 0 | — |
| easy / aerien / seasonal | 3 | 0 | 0 | — |
| easy / aerien / resilience | 3 | 0 | 0 | — |
| easy / aerien / transmission | 3 | 3 | 3 | 10–10 |
| easy / aerien / mobility | 3 | 3 | 3 | 25–25 |
| easy / aerien / discretion | 3 | 3 | 0 | 65–65 |
| easy / aerien_discretion_avant / polar | 3 | 0 | 0 | — |
| easy / aerien_discretion_avant / seasonal | 3 | 0 | 0 | — |
| easy / aerien_discretion_avant / resilience | 3 | 0 | 0 | — |
| easy / aerien_discretion_avant / transmission | 3 | 3 | 3 | 10–10 |
| easy / aerien_discretion_avant / mobility | 3 | 3 | 3 | 25–25 |
| easy / aerien_discretion_avant / discretion | 3 | 3 | 3 | 50–50 |
| easy / attente / polar | 3 | 0 | 0 | — |
| easy / attente / seasonal | 3 | 0 | 0 | — |
| easy / attente / resilience | 3 | 0 | 0 | — |
| easy / attente / transmission | 3 | 0 | 0 | — |
| easy / attente / mobility | 3 | 0 | 0 | — |
| easy / attente / discretion | 3 | 0 | 0 | — |
| easy / diffusion / polar | 3 | 0 | 0 | — |
| easy / diffusion / seasonal | 3 | 0 | 0 | — |
| easy / diffusion / resilience | 3 | 0 | 0 | — |
| easy / diffusion / transmission | 3 | 3 | 3 | 10–10 |
| easy / diffusion / mobility | 3 | 3 | 3 | 50–50 |
| easy / diffusion / discretion | 3 | 3 | 3 | 30–30 |
| easy / discretion / polar | 3 | 0 | 0 | — |
| easy / discretion / seasonal | 3 | 0 | 0 | — |
| easy / discretion / resilience | 3 | 0 | 0 | — |
| easy / discretion / transmission | 3 | 3 | 3 | 30–30 |
| easy / discretion / mobility | 3 | 3 | 3 | 50–50 |
| easy / discretion / discretion | 3 | 3 | 3 | 10–10 |
| easy / maritime / polar | 3 | 0 | 0 | — |
| easy / maritime / seasonal | 3 | 0 | 0 | — |
| easy / maritime / resilience | 3 | 0 | 0 | — |
| easy / maritime / transmission | 3 | 3 | 3 | 10–10 |
| easy / maritime / mobility | 3 | 3 | 3 | 25–25 |
| easy / maritime / discretion | 3 | 3 | 0 | 65–65 |
| easy / maritime_discretion_avant / polar | 3 | 0 | 0 | — |
| easy / maritime_discretion_avant / seasonal | 3 | 0 | 0 | — |
| easy / maritime_discretion_avant / resilience | 3 | 0 | 0 | — |
| easy / maritime_discretion_avant / transmission | 3 | 3 | 3 | 10–10 |
| easy / maritime_discretion_avant / mobility | 3 | 3 | 3 | 25–25 |
| easy / maritime_discretion_avant / discretion | 3 | 3 | 3 | 50–50 |
| easy / mobilite / polar | 3 | 0 | 0 | — |
| easy / mobilite / seasonal | 3 | 0 | 0 | — |
| easy / mobilite / resilience | 3 | 0 | 0 | — |
| easy / mobilite / transmission | 3 | 3 | 3 | 10–10 |
| easy / mobilite / mobility | 3 | 3 | 3 | 25–25 |
| easy / mobilite / discretion | 3 | 3 | 3 | 50–50 |
| easy / polaire / polar | 3 | 3 | 3 | 5–5 |
| easy / polaire / seasonal | 3 | 3 | 0 | 65–65 |
| easy / polaire / resilience | 3 | 0 | 0 | — |
| easy / polaire / transmission | 3 | 3 | 3 | 25–25 |
| easy / polaire / mobility | 3 | 3 | 0 | 80–80 |
| easy / polaire / discretion | 3 | 3 | 3 | 45–45 |
| easy / polaire_diffusion / polar | 3 | 3 | 3 | 5–5 |
| easy / polaire_diffusion / seasonal | 3 | 3 | 3 | 40–40 |
| easy / polaire_diffusion / resilience | 3 | 0 | 0 | — |
| easy / polaire_diffusion / transmission | 3 | 3 | 3 | 25–25 |
| easy / polaire_diffusion / mobility | 3 | 3 | 0 | 55–55 |
| easy / polaire_diffusion / discretion | 3 | 3 | 0 | 80–80 |
| easy / resilience_precoce / polar | 3 | 3 | 3 | 5–5 |
| easy / resilience_precoce / seasonal | 3 | 3 | 3 | 40–40 |
| easy / resilience_precoce / resilience | 3 | 3 | 3 | 25–25 |
| easy / resilience_precoce / transmission | 3 | 3 | 0 | 60–60 |
| easy / resilience_precoce / mobility | 3 | 3 | 0 | 75–75 |
| easy / resilience_precoce / discretion | 3 | 0 | 0 | — |
| easy / saisonnier / polar | 3 | 3 | 3 | 5–5 |
| easy / saisonnier / seasonal | 3 | 3 | 3 | 20–20 |
| easy / saisonnier / resilience | 3 | 0 | 0 | — |
| easy / saisonnier / transmission | 3 | 3 | 3 | 40–40 |
| easy / saisonnier / mobility | 3 | 3 | 0 | 55–55 |
| easy / saisonnier / discretion | 3 | 3 | 0 | 80–80 |
| easy / saisonnier_discret / polar | 3 | 3 | 3 | 5–5 |
| easy / saisonnier_discret / seasonal | 3 | 3 | 3 | 20–20 |
| easy / saisonnier_discret / resilience | 3 | 0 | 0 | — |
| easy / saisonnier_discret / transmission | 3 | 3 | 0 | 65–65 |
| easy / saisonnier_discret / mobility | 3 | 3 | 0 | 80–80 |
| easy / saisonnier_discret / discretion | 3 | 3 | 3 | 45–45 |
| easy / terrestre / polar | 3 | 0 | 0 | — |
| easy / terrestre / seasonal | 3 | 0 | 0 | — |
| easy / terrestre / resilience | 3 | 0 | 0 | — |
| easy / terrestre / transmission | 3 | 3 | 3 | 10–10 |
| easy / terrestre / mobility | 3 | 3 | 3 | 25–25 |
| easy / terrestre / discretion | 3 | 3 | 0 | 65–65 |
| easy / terrestre_discretion_avant / polar | 3 | 0 | 0 | — |
| easy / terrestre_discretion_avant / seasonal | 3 | 0 | 0 | — |
| easy / terrestre_discretion_avant / resilience | 3 | 0 | 0 | — |
| easy / terrestre_discretion_avant / transmission | 3 | 3 | 3 | 10–10 |
| easy / terrestre_discretion_avant / mobility | 3 | 3 | 3 | 25–25 |
| easy / terrestre_discretion_avant / discretion | 3 | 3 | 3 | 50–50 |
| hard / aerien / polar | 3 | 0 | 0 | — |
| hard / aerien / seasonal | 3 | 0 | 0 | — |
| hard / aerien / resilience | 3 | 0 | 0 | — |
| hard / aerien / transmission | 3 | 3 | 3 | 10–10 |
| hard / aerien / mobility | 3 | 3 | 3 | 25–25 |
| hard / aerien / discretion | 3 | 3 | 0 | 65–65 |
| hard / aerien_discretion_avant / polar | 3 | 0 | 0 | — |
| hard / aerien_discretion_avant / seasonal | 3 | 0 | 0 | — |
| hard / aerien_discretion_avant / resilience | 3 | 0 | 0 | — |
| hard / aerien_discretion_avant / transmission | 3 | 3 | 3 | 10–10 |
| hard / aerien_discretion_avant / mobility | 3 | 3 | 3 | 25–25 |
| hard / aerien_discretion_avant / discretion | 3 | 3 | 3 | 50–50 |
| hard / attente / polar | 3 | 0 | 0 | — |
| hard / attente / seasonal | 3 | 0 | 0 | — |
| hard / attente / resilience | 3 | 0 | 0 | — |
| hard / attente / transmission | 3 | 0 | 0 | — |
| hard / attente / mobility | 3 | 0 | 0 | — |
| hard / attente / discretion | 3 | 0 | 0 | — |
| hard / diffusion / polar | 3 | 0 | 0 | — |
| hard / diffusion / seasonal | 3 | 0 | 0 | — |
| hard / diffusion / resilience | 3 | 0 | 0 | — |
| hard / diffusion / transmission | 3 | 3 | 3 | 10–10 |
| hard / diffusion / mobility | 3 | 3 | 3 | 50–50 |
| hard / diffusion / discretion | 3 | 3 | 3 | 30–30 |
| hard / discretion / polar | 3 | 0 | 0 | — |
| hard / discretion / seasonal | 3 | 0 | 0 | — |
| hard / discretion / resilience | 3 | 0 | 0 | — |
| hard / discretion / transmission | 3 | 3 | 3 | 30–30 |
| hard / discretion / mobility | 3 | 3 | 3 | 50–50 |
| hard / discretion / discretion | 3 | 3 | 3 | 10–10 |
| hard / maritime / polar | 3 | 0 | 0 | — |
| hard / maritime / seasonal | 3 | 0 | 0 | — |
| hard / maritime / resilience | 3 | 0 | 0 | — |
| hard / maritime / transmission | 3 | 3 | 3 | 10–10 |
| hard / maritime / mobility | 3 | 3 | 3 | 25–25 |
| hard / maritime / discretion | 3 | 3 | 0 | 65–65 |
| hard / maritime_discretion_avant / polar | 3 | 0 | 0 | — |
| hard / maritime_discretion_avant / seasonal | 3 | 0 | 0 | — |
| hard / maritime_discretion_avant / resilience | 3 | 0 | 0 | — |
| hard / maritime_discretion_avant / transmission | 3 | 3 | 3 | 10–10 |
| hard / maritime_discretion_avant / mobility | 3 | 3 | 3 | 25–25 |
| hard / maritime_discretion_avant / discretion | 3 | 3 | 3 | 50–50 |
| hard / mobilite / polar | 3 | 0 | 0 | — |
| hard / mobilite / seasonal | 3 | 0 | 0 | — |
| hard / mobilite / resilience | 3 | 0 | 0 | — |
| hard / mobilite / transmission | 3 | 3 | 3 | 10–10 |
| hard / mobilite / mobility | 3 | 3 | 3 | 25–25 |
| hard / mobilite / discretion | 3 | 3 | 3 | 50–50 |
| hard / polaire / polar | 3 | 3 | 3 | 5–5 |
| hard / polaire / seasonal | 3 | 3 | 0 | 65–65 |
| hard / polaire / resilience | 3 | 0 | 0 | — |
| hard / polaire / transmission | 3 | 3 | 3 | 25–25 |
| hard / polaire / mobility | 3 | 3 | 0 | 80–80 |
| hard / polaire / discretion | 3 | 3 | 3 | 45–45 |
| hard / polaire_diffusion / polar | 3 | 3 | 3 | 5–5 |
| hard / polaire_diffusion / seasonal | 3 | 3 | 3 | 40–40 |
| hard / polaire_diffusion / resilience | 3 | 0 | 0 | — |
| hard / polaire_diffusion / transmission | 3 | 3 | 3 | 25–25 |
| hard / polaire_diffusion / mobility | 3 | 3 | 0 | 55–55 |
| hard / polaire_diffusion / discretion | 3 | 3 | 0 | 80–80 |
| hard / resilience_precoce / polar | 3 | 3 | 3 | 5–5 |
| hard / resilience_precoce / seasonal | 3 | 3 | 3 | 40–40 |
| hard / resilience_precoce / resilience | 3 | 3 | 3 | 25–25 |
| hard / resilience_precoce / transmission | 3 | 3 | 0 | 60–60 |
| hard / resilience_precoce / mobility | 3 | 3 | 0 | 75–75 |
| hard / resilience_precoce / discretion | 3 | 0 | 0 | — |
| hard / saisonnier / polar | 3 | 3 | 3 | 5–5 |
| hard / saisonnier / seasonal | 3 | 3 | 3 | 20–20 |
| hard / saisonnier / resilience | 3 | 0 | 0 | — |
| hard / saisonnier / transmission | 3 | 3 | 3 | 40–40 |
| hard / saisonnier / mobility | 3 | 3 | 0 | 55–55 |
| hard / saisonnier / discretion | 3 | 3 | 0 | 80–80 |
| hard / saisonnier_discret / polar | 3 | 3 | 3 | 5–5 |
| hard / saisonnier_discret / seasonal | 3 | 3 | 3 | 20–20 |
| hard / saisonnier_discret / resilience | 3 | 0 | 0 | — |
| hard / saisonnier_discret / transmission | 3 | 3 | 0 | 65–65 |
| hard / saisonnier_discret / mobility | 3 | 3 | 0 | 80–80 |
| hard / saisonnier_discret / discretion | 3 | 3 | 3 | 45–45 |
| hard / terrestre / polar | 3 | 0 | 0 | — |
| hard / terrestre / seasonal | 3 | 0 | 0 | — |
| hard / terrestre / resilience | 3 | 0 | 0 | — |
| hard / terrestre / transmission | 3 | 3 | 3 | 10–10 |
| hard / terrestre / mobility | 3 | 3 | 3 | 25–25 |
| hard / terrestre / discretion | 3 | 3 | 0 | 65–65 |
| hard / terrestre_discretion_avant / polar | 3 | 0 | 0 | — |
| hard / terrestre_discretion_avant / seasonal | 3 | 0 | 0 | — |
| hard / terrestre_discretion_avant / resilience | 3 | 0 | 0 | — |
| hard / terrestre_discretion_avant / transmission | 3 | 3 | 3 | 10–10 |
| hard / terrestre_discretion_avant / mobility | 3 | 3 | 3 | 25–25 |
| hard / terrestre_discretion_avant / discretion | 3 | 3 | 3 | 50–50 |
| normal / aerien / polar | 3 | 0 | 0 | — |
| normal / aerien / seasonal | 3 | 0 | 0 | — |
| normal / aerien / resilience | 3 | 0 | 0 | — |
| normal / aerien / transmission | 3 | 3 | 3 | 10–10 |
| normal / aerien / mobility | 3 | 3 | 3 | 25–25 |
| normal / aerien / discretion | 3 | 3 | 0 | 65–65 |
| normal / aerien_discretion_avant / polar | 3 | 0 | 0 | — |
| normal / aerien_discretion_avant / seasonal | 3 | 0 | 0 | — |
| normal / aerien_discretion_avant / resilience | 3 | 0 | 0 | — |
| normal / aerien_discretion_avant / transmission | 3 | 3 | 3 | 10–10 |
| normal / aerien_discretion_avant / mobility | 3 | 3 | 3 | 25–25 |
| normal / aerien_discretion_avant / discretion | 3 | 3 | 3 | 50–50 |
| normal / attente / polar | 3 | 0 | 0 | — |
| normal / attente / seasonal | 3 | 0 | 0 | — |
| normal / attente / resilience | 3 | 0 | 0 | — |
| normal / attente / transmission | 3 | 0 | 0 | — |
| normal / attente / mobility | 3 | 0 | 0 | — |
| normal / attente / discretion | 3 | 0 | 0 | — |
| normal / diffusion / polar | 3 | 0 | 0 | — |
| normal / diffusion / seasonal | 3 | 0 | 0 | — |
| normal / diffusion / resilience | 3 | 0 | 0 | — |
| normal / diffusion / transmission | 3 | 3 | 3 | 10–10 |
| normal / diffusion / mobility | 3 | 3 | 3 | 50–50 |
| normal / diffusion / discretion | 3 | 3 | 3 | 30–30 |
| normal / discretion / polar | 3 | 0 | 0 | — |
| normal / discretion / seasonal | 3 | 0 | 0 | — |
| normal / discretion / resilience | 3 | 0 | 0 | — |
| normal / discretion / transmission | 3 | 3 | 3 | 30–30 |
| normal / discretion / mobility | 3 | 3 | 3 | 50–50 |
| normal / discretion / discretion | 3 | 3 | 3 | 10–10 |
| normal / maritime / polar | 3 | 0 | 0 | — |
| normal / maritime / seasonal | 3 | 0 | 0 | — |
| normal / maritime / resilience | 3 | 0 | 0 | — |
| normal / maritime / transmission | 3 | 3 | 3 | 10–10 |
| normal / maritime / mobility | 3 | 3 | 3 | 25–25 |
| normal / maritime / discretion | 3 | 3 | 0 | 65–65 |
| normal / maritime_discretion_avant / polar | 3 | 0 | 0 | — |
| normal / maritime_discretion_avant / seasonal | 3 | 0 | 0 | — |
| normal / maritime_discretion_avant / resilience | 3 | 0 | 0 | — |
| normal / maritime_discretion_avant / transmission | 3 | 3 | 3 | 10–10 |
| normal / maritime_discretion_avant / mobility | 3 | 3 | 3 | 25–25 |
| normal / maritime_discretion_avant / discretion | 3 | 3 | 3 | 50–50 |
| normal / mobilite / polar | 3 | 0 | 0 | — |
| normal / mobilite / seasonal | 3 | 0 | 0 | — |
| normal / mobilite / resilience | 3 | 0 | 0 | — |
| normal / mobilite / transmission | 3 | 3 | 3 | 10–10 |
| normal / mobilite / mobility | 3 | 3 | 3 | 25–25 |
| normal / mobilite / discretion | 3 | 3 | 3 | 50–50 |
| normal / polaire / polar | 3 | 3 | 3 | 5–5 |
| normal / polaire / seasonal | 3 | 3 | 0 | 65–65 |
| normal / polaire / resilience | 3 | 0 | 0 | — |
| normal / polaire / transmission | 3 | 3 | 3 | 25–25 |
| normal / polaire / mobility | 3 | 3 | 0 | 80–80 |
| normal / polaire / discretion | 3 | 3 | 3 | 45–45 |
| normal / polaire_diffusion / polar | 3 | 3 | 3 | 5–5 |
| normal / polaire_diffusion / seasonal | 3 | 3 | 3 | 40–40 |
| normal / polaire_diffusion / resilience | 3 | 0 | 0 | — |
| normal / polaire_diffusion / transmission | 3 | 3 | 3 | 25–25 |
| normal / polaire_diffusion / mobility | 3 | 3 | 0 | 55–55 |
| normal / polaire_diffusion / discretion | 3 | 3 | 0 | 80–80 |
| normal / resilience_precoce / polar | 3 | 3 | 3 | 5–5 |
| normal / resilience_precoce / seasonal | 3 | 3 | 3 | 40–40 |
| normal / resilience_precoce / resilience | 3 | 3 | 3 | 25–25 |
| normal / resilience_precoce / transmission | 3 | 3 | 0 | 60–60 |
| normal / resilience_precoce / mobility | 3 | 3 | 0 | 75–75 |
| normal / resilience_precoce / discretion | 3 | 0 | 0 | — |
| normal / saisonnier / polar | 3 | 3 | 3 | 5–5 |
| normal / saisonnier / seasonal | 3 | 3 | 3 | 20–20 |
| normal / saisonnier / resilience | 3 | 0 | 0 | — |
| normal / saisonnier / transmission | 3 | 3 | 3 | 40–40 |
| normal / saisonnier / mobility | 3 | 3 | 0 | 55–55 |
| normal / saisonnier / discretion | 3 | 3 | 0 | 80–80 |
| normal / saisonnier_discret / polar | 3 | 3 | 3 | 5–5 |
| normal / saisonnier_discret / seasonal | 3 | 3 | 3 | 20–20 |
| normal / saisonnier_discret / resilience | 3 | 0 | 0 | — |
| normal / saisonnier_discret / transmission | 3 | 3 | 0 | 65–65 |
| normal / saisonnier_discret / mobility | 3 | 3 | 0 | 80–80 |
| normal / saisonnier_discret / discretion | 3 | 3 | 3 | 45–45 |
| normal / terrestre / polar | 3 | 0 | 0 | — |
| normal / terrestre / seasonal | 3 | 0 | 0 | — |
| normal / terrestre / resilience | 3 | 0 | 0 | — |
| normal / terrestre / transmission | 3 | 3 | 3 | 10–10 |
| normal / terrestre / mobility | 3 | 3 | 3 | 25–25 |
| normal / terrestre / discretion | 3 | 3 | 0 | 65–65 |
| normal / terrestre_discretion_avant / polar | 3 | 0 | 0 | — |
| normal / terrestre_discretion_avant / seasonal | 3 | 0 | 0 | — |
| normal / terrestre_discretion_avant / resilience | 3 | 0 | 0 | — |
| normal / terrestre_discretion_avant / transmission | 3 | 3 | 3 | 10–10 |
| normal / terrestre_discretion_avant / mobility | 3 | 3 | 3 | 25–25 |
| normal / terrestre_discretion_avant / discretion | 3 | 3 | 3 | 50–50 |

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
