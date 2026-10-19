# Ordre d'achat des spécialisations — règles 0.8

Généré par `dev.ps1 Balance`. A = spécialisation avant Discrétion ; B = Discrétion avant spécialisation. Diffusion puis Mobilité précèdent les deux achats. Une tentative du premier achat manquant par jour, avant le pas ; aucun point offert.

Chaque paire conserve scénario, difficulté, départ et graine (7, 42, 2042). Les parties s'arrêtent au résultat, au plus à 500 jours. Une spécialisation prévue peut ne jamais être achetée : les colonnes acquis comptent les achats réels. Le CSV conserve leurs jours et points avant/après.

Les résultats comparent des politiques complètes : budget, dates et effets changent ensemble. Ils ne mesurent pas un effet causal isolé et ne représentent pas des joueurs humains. Δ jours = B − A, uniquement lorsque les deux gagnent ; une valeur négative signifie une victoire plus tôt avec B. Aucun ajustement des règles n'est appliqué.

## Synthèse

| Scénario / difficulté / choix | Paires | A seul gagne | B seul gagne | Deux victoires | Deux défaites | Acquis A/B | Δ jours moyen |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| degel2042 / easy / aerien | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.33 |
| degel2042 / easy / maritime | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.67 |
| degel2042 / easy / terrestre | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.00 |
| degel2042 / hard / aerien | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.33 |
| degel2042 / hard / maritime | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.67 |
| degel2042 / hard / terrestre | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.00 |
| degel2042 / normal / aerien | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.33 |
| degel2042 / normal / maritime | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.67 |
| degel2042 / normal / terrestre | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.00 |
| standard / easy / aerien | 72 | 0 | 0 | 72 | 0 | 72/72 | 2.19 |
| standard / easy / maritime | 72 | 0 | 0 | 72 | 0 | 72/72 | 0.40 |
| standard / easy / terrestre | 72 | 0 | 0 | 72 | 0 | 72/72 | 2.60 |
| standard / hard / aerien | 72 | 0 | 17 | 49 | 6 | 72/72 | 2.20 |
| standard / hard / maritime | 72 | 0 | 19 | 47 | 6 | 72/72 | 0.38 |
| standard / hard / terrestre | 72 | 0 | 3 | 69 | 0 | 72/72 | 2.65 |
| standard / normal / aerien | 72 | 0 | 0 | 72 | 0 | 72/72 | 2.25 |
| standard / normal / maritime | 72 | 0 | 0 | 72 | 0 | 72/72 | 0.39 |
| standard / normal / terrestre | 72 | 0 | 0 | 72 | 0 | 72/72 | 2.67 |

## Par départ

| Scénario / difficulté / choix / départ | Paires | A seul gagne | B seul gagne | Deux victoires | Deux défaites | Acquis A/B | Δ jours moyen |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| degel2042 / easy / aerien / boreale | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.33 |
| degel2042 / easy / maritime / boreale | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.67 |
| degel2042 / easy / terrestre / boreale | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.00 |
| degel2042 / hard / aerien / boreale | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.33 |
| degel2042 / hard / maritime / boreale | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.67 |
| degel2042 / hard / terrestre / boreale | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.00 |
| degel2042 / normal / aerien / boreale | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.33 |
| degel2042 / normal / maritime / boreale | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.67 |
| degel2042 / normal / terrestre / boreale | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.00 |
| standard / easy / aerien / archipel | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.00 |
| standard / easy / aerien / atlantide | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.00 |
| standard / easy / aerien / australe | 3 | 0 | 0 | 3 | 0 | 3/3 | 2.67 |
| standard / easy / aerien / boreale | 3 | 0 | 0 | 3 | 0 | 3/3 | 4.00 |
| standard / easy / aerien / cap_sud | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.00 |
| standard / easy / aerien / centrale | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.00 |
| standard / easy / aerien / corail | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.00 |
| standard / easy / aerien / delta | 3 | 0 | 0 | 3 | 0 | 3/3 | 2.00 |
| standard / easy / aerien / equateur | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.33 |
| standard / easy / aerien / hauts_pays | 3 | 0 | 0 | 3 | 0 | 3/3 | 4.00 |
| standard / easy / aerien / jade | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.00 |
| standard / easy / aerien / levant | 3 | 0 | 0 | 3 | 0 | 3/3 | 2.00 |
| standard / easy / aerien / littoral | 3 | 0 | 0 | 3 | 0 | 3/3 | 4.33 |
| standard / easy / aerien / meridien | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.67 |
| standard / easy / aerien / mousson | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.00 |
| standard / easy / aerien / occident | 3 | 0 | 0 | 3 | 0 | 3/3 | 2.33 |
| standard / easy / aerien / orient | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.33 |
| standard / easy / aerien / pacifique | 3 | 0 | 0 | 3 | 0 | 3/3 | 5.00 |
| standard / easy / aerien / peninsule | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.00 |
| standard / easy / aerien / plateaux | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.67 |
| standard / easy / aerien / savane | 3 | 0 | 0 | 3 | 0 | 3/3 | 4.33 |
| standard / easy / aerien / steppes | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.33 |
| standard / easy / aerien / taiga | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.67 |
| standard / easy / aerien / toundra | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.00 |
| standard / easy / maritime / archipel | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.67 |
| standard / easy / maritime / atlantide | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.00 |
| standard / easy / maritime / australe | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.00 |
| standard / easy / maritime / boreale | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.00 |
| standard / easy / maritime / cap_sud | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.00 |
| standard / easy / maritime / centrale | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.00 |
| standard / easy / maritime / corail | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.00 |
| standard / easy / maritime / delta | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.00 |
| standard / easy / maritime / equateur | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.33 |
| standard / easy / maritime / hauts_pays | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.00 |
| standard / easy / maritime / jade | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.00 |
| standard / easy / maritime / levant | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.00 |
| standard / easy / maritime / littoral | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.67 |
| standard / easy / maritime / meridien | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.67 |
| standard / easy / maritime / mousson | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.33 |
| standard / easy / maritime / occident | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.67 |
| standard / easy / maritime / orient | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.33 |
| standard / easy / maritime / pacifique | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.00 |
| standard / easy / maritime / peninsule | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.00 |
| standard / easy / maritime / plateaux | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.00 |
| standard / easy / maritime / savane | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.00 |
| standard / easy / maritime / steppes | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.00 |
| standard / easy / maritime / taiga | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.00 |
| standard / easy / maritime / toundra | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.00 |
| standard / easy / terrestre / archipel | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.33 |
| standard / easy / terrestre / atlantide | 3 | 0 | 0 | 3 | 0 | 3/3 | 4.00 |
| standard / easy / terrestre / australe | 3 | 0 | 0 | 3 | 0 | 3/3 | 2.67 |
| standard / easy / terrestre / boreale | 3 | 0 | 0 | 3 | 0 | 3/3 | 2.00 |
| standard / easy / terrestre / cap_sud | 3 | 0 | 0 | 3 | 0 | 3/3 | 2.67 |
| standard / easy / terrestre / centrale | 3 | 0 | 0 | 3 | 0 | 3/3 | 2.00 |
| standard / easy / terrestre / corail | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.00 |
| standard / easy / terrestre / delta | 3 | 0 | 0 | 3 | 0 | 3/3 | 2.33 |
| standard / easy / terrestre / equateur | 3 | 0 | 0 | 3 | 0 | 3/3 | 4.00 |
| standard / easy / terrestre / hauts_pays | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.00 |
| standard / easy / terrestre / jade | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.00 |
| standard / easy / terrestre / levant | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.00 |
| standard / easy / terrestre / littoral | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.67 |
| standard / easy / terrestre / meridien | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.67 |
| standard / easy / terrestre / mousson | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.00 |
| standard / easy / terrestre / occident | 3 | 0 | 0 | 3 | 0 | 3/3 | 2.00 |
| standard / easy / terrestre / orient | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.33 |
| standard / easy / terrestre / pacifique | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.00 |
| standard / easy / terrestre / peninsule | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.33 |
| standard / easy / terrestre / plateaux | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.00 |
| standard / easy / terrestre / savane | 3 | 0 | 0 | 3 | 0 | 3/3 | 2.00 |
| standard / easy / terrestre / steppes | 3 | 0 | 0 | 3 | 0 | 3/3 | 4.00 |
| standard / easy / terrestre / taiga | 3 | 0 | 0 | 3 | 0 | 3/3 | 2.33 |
| standard / easy / terrestre / toundra | 3 | 0 | 0 | 3 | 0 | 3/3 | 2.00 |
| standard / hard / aerien / archipel | 3 | 0 | 3 | 0 | 0 | 3/3 | — |
| standard / hard / aerien / atlantide | 3 | 0 | 3 | 0 | 0 | 3/3 | — |
| standard / hard / aerien / australe | 3 | 0 | 0 | 3 | 0 | 3/3 | 2.33 |
| standard / hard / aerien / boreale | 3 | 0 | 0 | 3 | 0 | 3/3 | 4.33 |
| standard / hard / aerien / cap_sud | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.67 |
| standard / hard / aerien / centrale | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.00 |
| standard / hard / aerien / corail | 3 | 0 | 3 | 0 | 0 | 3/3 | — |
| standard / hard / aerien / delta | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.67 |
| standard / hard / aerien / equateur | 3 | 0 | 0 | 3 | 0 | 3/3 | 2.00 |
| standard / hard / aerien / hauts_pays | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.33 |
| standard / hard / aerien / jade | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.33 |
| standard / hard / aerien / levant | 3 | 0 | 3 | 0 | 0 | 3/3 | — |
| standard / hard / aerien / littoral | 3 | 0 | 0 | 0 | 3 | 3/3 | — |
| standard / hard / aerien / meridien | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.67 |
| standard / hard / aerien / mousson | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.00 |
| standard / hard / aerien / occident | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.67 |
| standard / hard / aerien / orient | 3 | 0 | 2 | 1 | 0 | 3/3 | 2.00 |
| standard / hard / aerien / pacifique | 3 | 0 | 0 | 0 | 3 | 3/3 | — |
| standard / hard / aerien / peninsule | 3 | 0 | 3 | 0 | 0 | 3/3 | — |
| standard / hard / aerien / plateaux | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.00 |
| standard / hard / aerien / savane | 3 | 0 | 0 | 3 | 0 | 3/3 | 4.00 |
| standard / hard / aerien / steppes | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.67 |
| standard / hard / aerien / taiga | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.00 |
| standard / hard / aerien / toundra | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.67 |
| standard / hard / maritime / archipel | 3 | 0 | 3 | 0 | 0 | 3/3 | — |
| standard / hard / maritime / atlantide | 3 | 0 | 0 | 0 | 3 | 3/3 | — |
| standard / hard / maritime / australe | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.00 |
| standard / hard / maritime / boreale | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.00 |
| standard / hard / maritime / cap_sud | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.00 |
| standard / hard / maritime / centrale | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.00 |
| standard / hard / maritime / corail | 3 | 0 | 3 | 0 | 0 | 3/3 | — |
| standard / hard / maritime / delta | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.67 |
| standard / hard / maritime / equateur | 3 | 0 | 1 | 2 | 0 | 3/3 | 0.50 |
| standard / hard / maritime / hauts_pays | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.00 |
| standard / hard / maritime / jade | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.33 |
| standard / hard / maritime / levant | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.00 |
| standard / hard / maritime / littoral | 3 | 0 | 3 | 0 | 0 | 3/3 | — |
| standard / hard / maritime / meridien | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.00 |
| standard / hard / maritime / mousson | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.33 |
| standard / hard / maritime / occident | 3 | 0 | 3 | 0 | 0 | 3/3 | — |
| standard / hard / maritime / orient | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.00 |
| standard / hard / maritime / pacifique | 3 | 0 | 0 | 0 | 3 | 3/3 | — |
| standard / hard / maritime / peninsule | 3 | 0 | 3 | 0 | 0 | 3/3 | — |
| standard / hard / maritime / plateaux | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.00 |
| standard / hard / maritime / savane | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.33 |
| standard / hard / maritime / steppes | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.00 |
| standard / hard / maritime / taiga | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.00 |
| standard / hard / maritime / toundra | 3 | 0 | 3 | 0 | 0 | 3/3 | — |
| standard / hard / terrestre / archipel | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.33 |
| standard / hard / terrestre / atlantide | 3 | 0 | 3 | 0 | 0 | 3/3 | — |
| standard / hard / terrestre / australe | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.00 |
| standard / hard / terrestre / boreale | 3 | 0 | 0 | 3 | 0 | 3/3 | 2.00 |
| standard / hard / terrestre / cap_sud | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.00 |
| standard / hard / terrestre / centrale | 3 | 0 | 0 | 3 | 0 | 3/3 | 2.00 |
| standard / hard / terrestre / corail | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.00 |
| standard / hard / terrestre / delta | 3 | 0 | 0 | 3 | 0 | 3/3 | 2.67 |
| standard / hard / terrestre / equateur | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.67 |
| standard / hard / terrestre / hauts_pays | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.00 |
| standard / hard / terrestre / jade | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.33 |
| standard / hard / terrestre / levant | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.00 |
| standard / hard / terrestre / littoral | 3 | 0 | 0 | 3 | 0 | 3/3 | 2.00 |
| standard / hard / terrestre / meridien | 3 | 0 | 0 | 3 | 0 | 3/3 | 4.00 |
| standard / hard / terrestre / mousson | 3 | 0 | 0 | 3 | 0 | 3/3 | 4.00 |
| standard / hard / terrestre / occident | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.67 |
| standard / hard / terrestre / orient | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.33 |
| standard / hard / terrestre / pacifique | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.00 |
| standard / hard / terrestre / peninsule | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.33 |
| standard / hard / terrestre / plateaux | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.00 |
| standard / hard / terrestre / savane | 3 | 0 | 0 | 3 | 0 | 3/3 | 2.00 |
| standard / hard / terrestre / steppes | 3 | 0 | 0 | 3 | 0 | 3/3 | 4.00 |
| standard / hard / terrestre / taiga | 3 | 0 | 0 | 3 | 0 | 3/3 | 2.67 |
| standard / hard / terrestre / toundra | 3 | 0 | 0 | 3 | 0 | 3/3 | 2.00 |
| standard / normal / aerien / archipel | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.00 |
| standard / normal / aerien / atlantide | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.33 |
| standard / normal / aerien / australe | 3 | 0 | 0 | 3 | 0 | 3/3 | 2.67 |
| standard / normal / aerien / boreale | 3 | 0 | 0 | 3 | 0 | 3/3 | 4.33 |
| standard / normal / aerien / cap_sud | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.33 |
| standard / normal / aerien / centrale | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.00 |
| standard / normal / aerien / corail | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.00 |
| standard / normal / aerien / delta | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.67 |
| standard / normal / aerien / equateur | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.67 |
| standard / normal / aerien / hauts_pays | 3 | 0 | 0 | 3 | 0 | 3/3 | 4.00 |
| standard / normal / aerien / jade | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.00 |
| standard / normal / aerien / levant | 3 | 0 | 0 | 3 | 0 | 3/3 | 2.33 |
| standard / normal / aerien / littoral | 3 | 0 | 0 | 3 | 0 | 3/3 | 4.00 |
| standard / normal / aerien / meridien | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.67 |
| standard / normal / aerien / mousson | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.00 |
| standard / normal / aerien / occident | 3 | 0 | 0 | 3 | 0 | 3/3 | 2.00 |
| standard / normal / aerien / orient | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.33 |
| standard / normal / aerien / pacifique | 3 | 0 | 0 | 3 | 0 | 3/3 | 5.00 |
| standard / normal / aerien / peninsule | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.00 |
| standard / normal / aerien / plateaux | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.67 |
| standard / normal / aerien / savane | 3 | 0 | 0 | 3 | 0 | 3/3 | 4.33 |
| standard / normal / aerien / steppes | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.67 |
| standard / normal / aerien / taiga | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.00 |
| standard / normal / aerien / toundra | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.00 |
| standard / normal / maritime / archipel | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.33 |
| standard / normal / maritime / atlantide | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.00 |
| standard / normal / maritime / australe | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.00 |
| standard / normal / maritime / boreale | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.00 |
| standard / normal / maritime / cap_sud | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.67 |
| standard / normal / maritime / centrale | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.00 |
| standard / normal / maritime / corail | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.00 |
| standard / normal / maritime / delta | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.67 |
| standard / normal / maritime / equateur | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.00 |
| standard / normal / maritime / hauts_pays | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.00 |
| standard / normal / maritime / jade | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.67 |
| standard / normal / maritime / levant | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.00 |
| standard / normal / maritime / littoral | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.00 |
| standard / normal / maritime / meridien | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.00 |
| standard / normal / maritime / mousson | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.67 |
| standard / normal / maritime / occident | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.00 |
| standard / normal / maritime / orient | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.33 |
| standard / normal / maritime / pacifique | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.00 |
| standard / normal / maritime / peninsule | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.00 |
| standard / normal / maritime / plateaux | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.00 |
| standard / normal / maritime / savane | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.00 |
| standard / normal / maritime / steppes | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.00 |
| standard / normal / maritime / taiga | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.00 |
| standard / normal / maritime / toundra | 3 | 0 | 0 | 3 | 0 | 3/3 | 0.00 |
| standard / normal / terrestre / archipel | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.33 |
| standard / normal / terrestre / atlantide | 3 | 0 | 0 | 3 | 0 | 3/3 | 4.67 |
| standard / normal / terrestre / australe | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.00 |
| standard / normal / terrestre / boreale | 3 | 0 | 0 | 3 | 0 | 3/3 | 2.00 |
| standard / normal / terrestre / cap_sud | 3 | 0 | 0 | 3 | 0 | 3/3 | 2.67 |
| standard / normal / terrestre / centrale | 3 | 0 | 0 | 3 | 0 | 3/3 | 2.00 |
| standard / normal / terrestre / corail | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.00 |
| standard / normal / terrestre / delta | 3 | 0 | 0 | 3 | 0 | 3/3 | 2.67 |
| standard / normal / terrestre / equateur | 3 | 0 | 0 | 3 | 0 | 3/3 | 4.00 |
| standard / normal / terrestre / hauts_pays | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.00 |
| standard / normal / terrestre / jade | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.00 |
| standard / normal / terrestre / levant | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.00 |
| standard / normal / terrestre / littoral | 3 | 0 | 0 | 3 | 0 | 3/3 | 2.00 |
| standard / normal / terrestre / meridien | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.67 |
| standard / normal / terrestre / mousson | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.00 |
| standard / normal / terrestre / occident | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.67 |
| standard / normal / terrestre / orient | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.33 |
| standard / normal / terrestre / pacifique | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.00 |
| standard / normal / terrestre / peninsule | 3 | 0 | 0 | 3 | 0 | 3/3 | 3.67 |
| standard / normal / terrestre / plateaux | 3 | 0 | 0 | 3 | 0 | 3/3 | 1.00 |
| standard / normal / terrestre / savane | 3 | 0 | 0 | 3 | 0 | 3/3 | 2.00 |
| standard / normal / terrestre / steppes | 3 | 0 | 0 | 3 | 0 | 3/3 | 4.00 |
| standard / normal / terrestre / taiga | 3 | 0 | 0 | 3 | 0 | 3/3 | 2.33 |
| standard / normal / terrestre / toundra | 3 | 0 | 0 | 3 | 0 | 3/3 | 2.00 |
