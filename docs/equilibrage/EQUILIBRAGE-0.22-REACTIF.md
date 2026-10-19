# Crises réactives — mesures 0.22

Date : 18 octobre 2026. Simulation abstraite, mesures automatiques locales ; aucun joueur humain.

## Ciblage apparié

Commande : moteur Godot 4.7.2, `--headless --path . --script res://scripts/analysis/reactive_event_audit.gd`, puis la même commande avec `-- --reactive`.

Trois scénarios × deux difficultés (normale/difficile) × cinq graines (7, 42, 2042, 777, 9001). Départ Boréale, ou Centrale dans Réseaux fragiles. Achats légaux Diffusion → Mobilité → Discrétion, premier achat possible, sans fonds ajoutés. Réponse gratuite subir. Ni objectif facultatif ni décision logistique. Le Double relais reste obligatoire dans le nouveau profil fragile. Le script lit l'instantané avant croissance et la cible effectivement résolue après activation. Un incident complet a été observé pendant toute sa durée.

| Scénario | Incidents complets historiques / réactifs | Sans occasion historique | Sans occasion réactif |
| --- | --- | --- | --- |
| Standard | 26 / 26 | 16 | 0 |
| Dégel 2042 | 20 / 20 | 10 | 0 |
| Réseaux fragiles | 30 / 30 | 22 | 0 |
| Total | 76 / 76 | 48 (63,2 %) | 0 |

Une occasion signifie uniquement actifs > 0 ET sains > 0 au moins un jour. Ce n'est ni un nombre d'infections supplémentaires attribuables à l'incident ni une mesure de satisfaction. Les cibles ne sont pas déplacées rétroactivement. Les fichiers bruts sont générés dans build/qa/regional-historical.json et regional-reactive.json.

## Réponses et contraintes : 270 parties

Commande : `--headless --path . --script res://scripts/analysis/reactive_balance.gd`. Même grille de 30 configurations × trois politiques × trois réponses demandées. Une réponse indisponible faute de points est retentée pendant la fenêtre, sinon le défaut gratuit s'applique. Dates et choix réels, coûts, achats datés, remède, couverture, objectif et issue figurent dans build/qa/reactive-balance.json.

- Mobilité : Diffusion → Mobilité → Discrétion.
- Croissance : Diffusion → Relais locaux → Foyers persistants → Cohésion → Discrétion.
- Attente : aucun achat ; les réponses aux crises restent autorisées.

Chaque cellule ci-dessous contient dix configurations (deux difficultés, cinq graines) par réponse.

| Scénario / politique | Subir : victoires | Détour : victoires | Occasion : victoires |
| --- | --- | --- | --- |
| Standard / mobilité | 10/10 | 10/10 | 10/10 |
| Standard / croissance | 5/10 | 5/10 | 5/10 |
| Standard / attente | 0/10 | 0/10 | 0/10 |
| Dégel / mobilité | 10/10 | 10/10 | 10/10 |
| Dégel / croissance | 5/10 | 5/10 | 5/10 |
| Dégel / attente | 0/10 | 0/10 | 0/10 |
| Fragile / mobilité | 10/10 | 10/10 | 10/10 |
| Fragile / croissance | 0/10 | 0/10 | 0/10 |
| Fragile / attente | 0/10 | 0/10 | 0/10 |

Double relais : 30/30 réussites pour mobilité, 0/30 pour croissance et 0/30 pour attente. Dans les deux derniers groupes la défaite survient au J60 : la contrainte distingue réellement ce scénario. Les victoires mobilité vont de J98–99 dans Standard, J82–85 dans Dégel et J78–81 dans Fragile, selon la réponse et la graine.

Les trois réponses ne changent aucun taux de victoire dans cette grille. Elles modifient flux, remède et parfois la date finale : cela justifie leur contrôle technique, pas une affirmation de compromis ludique validé. Le détour à 3 points et l'occasion à 1 point sont des valeurs candidates. Aucun ajustement supplémentaire n'est justifié par ces seuls taux ; tester les décisions avec des joueurs avant de les figer. La forte supériorité de mobilité dans ces politiques reste une piste d'équilibrage, sans preuve que toutes les stratégies alternatives échouent.
