# Mesures du profil enrichi 0.18

240 parties : deux scénarios, trois difficultés, cinq graines (7, 42, 2042, 777, 9001), trois politiques communes aux deux profils et deux propres au profil enrichi. Départ Boréale, objectifs facultatifs actifs, décision logistique désactivée pour isoler le catalogue. Achats légaux, ordre strict, horizon 500 jours. Aucune réserve injectée.

Exploration déterministe, pas validation humaine ni preuve d'optimalité. Les essais joueurs restent à faire. Les coefficients ne sont pas ajustés automatiquement.

| Scénario | Difficulté | Profil | Politique | Victoires/5 | Objectif/5 | Remède final moyen | Jour final moyen |
| --- | --- | --- | --- | --- | --- | --- | --- |
| standard | easy | classic | discretion | 5 | 0 | 44.37 % | 105.0 |
| standard | easy | classic | mobility | 5 | 5 | 48.44 % | 98.0 |
| standard | easy | classic | maritime | 5 | 5 | 54.61 % | 96.0 |
| standard | easy | enriched | discretion | 5 | 0 | 44.52 % | 104.8 |
| standard | easy | enriched | mobility | 5 | 5 | 48.76 % | 98.0 |
| standard | easy | enriched | maritime | 5 | 5 | 54.93 % | 96.0 |
| standard | easy | enriched | network | 5 | 5 | 50.40 % | 92.0 |
| standard | easy | enriched | growth | 5 | 2 | 57.62 % | 103.6 |
| standard | normal | classic | discretion | 5 | 0 | 59.68 % | 105.0 |
| standard | normal | classic | mobility | 5 | 5 | 64.99 % | 98.0 |
| standard | normal | classic | maritime | 5 | 5 | 73.25 % | 96.0 |
| standard | normal | enriched | discretion | 5 | 0 | 59.91 % | 104.8 |
| standard | normal | enriched | mobility | 5 | 5 | 65.42 % | 98.0 |
| standard | normal | enriched | maritime | 5 | 5 | 73.64 % | 96.0 |
| standard | normal | enriched | network | 5 | 5 | 67.63 % | 92.0 |
| standard | normal | enriched | growth | 5 | 0 | 77.40 % | 103.8 |
| standard | hard | classic | discretion | 5 | 0 | 78.92 % | 105.0 |
| standard | hard | classic | mobility | 5 | 5 | 86.34 % | 98.0 |
| standard | hard | classic | maritime | 5 | 5 | 97.16 % | 96.0 |
| standard | hard | enriched | discretion | 5 | 0 | 79.49 % | 105.0 |
| standard | hard | enriched | mobility | 5 | 5 | 86.94 % | 98.0 |
| standard | hard | enriched | maritime | 5 | 5 | 97.68 % | 96.0 |
| standard | hard | enriched | network | 5 | 5 | 89.78 % | 92.0 |
| standard | hard | enriched | growth | 0 | 0 | 100.00 % | 103.0 |
| degel2042 | easy | classic | discretion | 5 | 5 | 42.15 % | 91.4 |
| degel2042 | easy | classic | mobility | 5 | 5 | 43.76 % | 82.4 |
| degel2042 | easy | classic | maritime | 5 | 5 | 51.26 % | 81.2 |
| degel2042 | easy | enriched | discretion | 5 | 5 | 42.62 % | 91.4 |
| degel2042 | easy | enriched | mobility | 5 | 5 | 44.92 % | 83.0 |
| degel2042 | easy | enriched | maritime | 5 | 5 | 51.99 % | 81.4 |
| degel2042 | easy | enriched | network | 5 | 5 | 48.62 % | 80.0 |
| degel2042 | easy | enriched | growth | 5 | 0 | 54.30 % | 87.0 |
| degel2042 | normal | classic | discretion | 5 | 5 | 57.09 % | 91.4 |
| degel2042 | normal | classic | mobility | 5 | 5 | 59.10 % | 82.4 |
| degel2042 | normal | classic | maritime | 5 | 5 | 69.14 % | 81.2 |
| degel2042 | normal | enriched | discretion | 5 | 5 | 57.69 % | 91.4 |
| degel2042 | normal | enriched | mobility | 5 | 5 | 60.69 % | 83.0 |
| degel2042 | normal | enriched | maritime | 5 | 5 | 70.79 % | 81.8 |
| degel2042 | normal | enriched | network | 5 | 5 | 65.62 % | 80.0 |
| degel2042 | normal | enriched | growth | 5 | 0 | 73.17 % | 87.0 |
| degel2042 | hard | classic | discretion | 5 | 5 | 75.10 % | 91.4 |
| degel2042 | hard | classic | mobility | 5 | 5 | 77.98 % | 82.4 |
| degel2042 | hard | classic | maritime | 5 | 5 | 91.56 % | 81.4 |
| degel2042 | hard | enriched | discretion | 5 | 5 | 75.91 % | 91.4 |
| degel2042 | hard | enriched | mobility | 5 | 5 | 79.98 % | 83.0 |
| degel2042 | hard | enriched | maritime | 5 | 5 | 93.24 % | 81.8 |
| degel2042 | hard | enriched | network | 5 | 5 | 86.49 % | 80.0 |
| degel2042 | hard | enriched | growth | 5 | 0 | 97.01 % | 87.4 |

## Achats observés, normale et graine 2042

- standard / classic / discretion : J10 discretion (14 pts), J30 transmission (12 pts), J50 mobility (10 pts).
- standard / classic / mobility : J10 transmission (12 pts), J25 mobility (10 pts), J50 discretion (14 pts).
- standard / classic / maritime : J10 transmission (12 pts), J25 mobility (10 pts), J40 sea_logistics (10 pts), J65 discretion (14 pts).
- standard / enriched / discretion : J10 discretion (14 pts), J30 transmission (12 pts), J50 mobility (10 pts).
- standard / enriched / mobility : J10 transmission (12 pts), J25 mobility (10 pts), J50 discretion (14 pts).
- standard / enriched / maritime : J10 transmission (12 pts), J25 mobility (10 pts), J40 sea_logistics (10 pts), J65 discretion (14 pts).
- standard / enriched / network : J10 transmission (12 pts), J25 mobility (10 pts), J45 network (11 pts), J65 discretion (14 pts), J80 relay (8 pts).
- standard / enriched / growth : J10 transmission (12 pts), J20 relay (8 pts), J35 focus (9 pts), J60 discretion (14 pts), J75 mobility (10 pts).
- degel2042 / classic / discretion : J10 discretion (14 pts), J30 transmission (12 pts), J50 mobility (10 pts).
- degel2042 / classic / mobility : J10 transmission (12 pts), J25 mobility (10 pts), J50 discretion (14 pts).
- degel2042 / classic / maritime : J10 transmission (12 pts), J25 mobility (10 pts), J40 sea_logistics (10 pts), J65 discretion (14 pts).
- degel2042 / enriched / discretion : J10 discretion (14 pts), J30 transmission (12 pts), J50 mobility (10 pts).
- degel2042 / enriched / mobility : J10 transmission (12 pts), J25 mobility (10 pts), J50 discretion (14 pts).
- degel2042 / enriched / maritime : J10 transmission (12 pts), J25 mobility (10 pts), J40 sea_logistics (10 pts), J65 discretion (14 pts).
- degel2042 / enriched / network : J10 transmission (12 pts), J25 mobility (10 pts), J45 network (11 pts), J65 discretion (14 pts).
- degel2042 / enriched / growth : J10 transmission (12 pts), J20 relay (8 pts), J35 focus (9 pts), J60 discretion (14 pts), J75 mobility (10 pts).

Traces complètes : `build/qa/expanded-balance.json` (hors Git), script reproductible `scripts/balance_expanded.gd`. Les défaites peuvent inclure une réussite facultative. Comparer les profils uniquement sur les mêmes scénarios, graines et politiques communes. Les politiques enrichies sont des alternatives, sans témoin classique de même liste d'achats.
