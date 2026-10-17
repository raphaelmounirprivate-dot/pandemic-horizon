# Exploration des aléas 0.20

140 parties, graines 7/42/2042/777/9001, difficultés normale/difficile. Catalogue enrichi dans tous les cas. Départ Boréale pour Standard/Dégel, Centrale pour Réseaux fragiles. Achats légaux dans un ordre strict, sans réserve injectée, horizon 500 jours ; objectifs et décision logistique désactivés. Comparaison aléas activés/désactivés uniquement à politique mobilite identique sur Standard/Dégel. Les trois autres politiques ne sont pas des comparaisons isolant un seul coefficient.

Les effets favorable/défavorable sont qualifiés du point de vue de la diffusion. Douze incidents tirés par graine au lancement ; le premier sac contient chacun des huit types une fois. Deux incidents peuvent se chevaucher. Aucun essai humain ni preuve de stratégie optimale.

| Scénario | Difficulté | Aléas | Politique | Victoires/5 | Jour final moyen | Remède final moyen |
| --- | --- | --- | --- | --- | --- | --- |
| standard | normal | non | mobilite | 5 | 98.0 | 65.42 % |
| standard | normal | oui | mobilite | 5 | 98.6 | 65.85 % |
| standard | normal | oui | secours | 5 | 98.0 | 69.12 % |
| standard | normal | oui | veille | 5 | 108.2 | 65.26 % |
| standard | normal | oui | reserves | 5 | 102.2 | 75.93 % |
| standard | hard | non | mobilite | 5 | 98.0 | 86.94 % |
| standard | hard | oui | mobilite | 5 | 98.6 | 87.48 % |
| standard | hard | oui | secours | 5 | 98.0 | 91.76 % |
| standard | hard | oui | veille | 5 | 108.2 | 86.61 % |
| standard | hard | oui | reserves | 1 | 102.2 | 99.88 % |
| degel2042 | normal | non | mobilite | 5 | 83.0 | 60.69 % |
| degel2042 | normal | oui | mobilite | 5 | 82.4 | 60.55 % |
| degel2042 | normal | oui | secours | 5 | 82.4 | 65.86 % |
| degel2042 | normal | oui | veille | 5 | 91.0 | 61.29 % |
| degel2042 | normal | oui | reserves | 5 | 85.0 | 73.61 % |
| degel2042 | hard | non | mobilite | 5 | 83.0 | 79.98 % |
| degel2042 | hard | oui | mobilite | 5 | 82.6 | 80.09 % |
| degel2042 | hard | oui | secours | 5 | 82.6 | 87.05 % |
| degel2042 | hard | oui | veille | 5 | 91.2 | 81.06 % |
| degel2042 | hard | oui | reserves | 5 | 85.2 | 97.24 % |
| fragile2042 | normal | oui | mobilite | 5 | 79.0 | 58.13 % |
| fragile2042 | normal | oui | secours | 5 | 78.8 | 63.60 % |
| fragile2042 | normal | oui | veille | 5 | 89.4 | 59.34 % |
| fragile2042 | normal | oui | reserves | 5 | 83.8 | 72.85 % |
| fragile2042 | hard | oui | mobilite | 5 | 78.8 | 76.29 % |
| fragile2042 | hard | oui | secours | 5 | 78.8 | 83.75 % |
| fragile2042 | hard | oui | veille | 5 | 89.6 | 78.40 % |
| fragile2042 | hard | oui | reserves | 5 | 83.8 | 95.74 % |

## Chronologies normales, graine 2042

- standard / aléas false / mobilite : J10 transmission (12 pts), J25 mobility (10 pts), J50 discretion (14 pts).
- standard / aléas true / mobilite : J10 transmission (12 pts), J25 mobility (10 pts), J50 discretion (14 pts).
- standard / aléas true / secours : J10 transmission (12 pts), J25 mobility (10 pts), J40 backup_links (10 pts), J65 discretion (14 pts).
- standard / aléas true / veille : J10 transmission (12 pts), J30 discretion (14 pts), J50 research_watch (11 pts), J65 mobility (10 pts).
- standard / aléas true / reserves : J10 transmission (12 pts), J20 relay (8 pts), J35 regional_reserves (9 pts), J55 mobility (10 pts), J75 discretion (14 pts).
- degel2042 / aléas false / mobilite : J10 transmission (12 pts), J25 mobility (10 pts), J50 discretion (14 pts).
- degel2042 / aléas true / mobilite : J10 transmission (12 pts), J25 mobility (10 pts), J50 discretion (14 pts).
- degel2042 / aléas true / secours : J10 transmission (12 pts), J25 mobility (10 pts), J40 backup_links (10 pts), J65 discretion (14 pts).
- degel2042 / aléas true / veille : J10 transmission (12 pts), J30 discretion (14 pts), J50 research_watch (11 pts), J65 mobility (10 pts).
- degel2042 / aléas true / reserves : J10 transmission (12 pts), J20 relay (8 pts), J35 regional_reserves (9 pts), J55 mobility (10 pts), J75 discretion (14 pts).
- fragile2042 / aléas true / mobilite : J10 transmission (12 pts), J25 mobility (10 pts), J50 discretion (14 pts).
- fragile2042 / aléas true / secours : J10 transmission (12 pts), J25 mobility (10 pts), J40 backup_links (10 pts), J65 discretion (14 pts).
- fragile2042 / aléas true / veille : J10 transmission (12 pts), J30 discretion (14 pts), J50 research_watch (11 pts), J65 mobility (10 pts).
- fragile2042 / aléas true / reserves : J10 transmission (12 pts), J20 relay (8 pts), J35 regional_reserves (9 pts), J55 mobility (10 pts), J75 discretion (14 pts).
