---
name: contenu-et-regles
description: Modifier ou ajouter du contenu de jeu (évolutions, événements, scénarios, transports, objectifs, crises, coefficients) dans data/*.json sans casser les sauvegardes existantes ni les profils historiques de Pandemic Horizon.
---

# Contenu et règles — sans casser les sauvegardes

## D'abord : quel fichier, quelle conséquence ?

| Fichier | Dans l'empreinte ? | Effet d'une modification |
| --- | --- | --- |
| `regions`, `evolutions`, `events`, `scenarios`, `transports`, `objectives`, `decisions` `.json` | `content_hash` (base de toute la chaîne) | **Toutes** les sauvegardes formats 4 à 7 deviennent incompatibles. |
| `decisions-0.11.json` | `content_hash` | Profil historique figé. **Ne jamais modifier.** |
| `expanded-content.json` | `expanded_hash` | Formats 5, 6, 7 cassés. |
| `crises.json` | `crises_hash` | Formats 6, 7 cassés. |
| `tactics.json` | `tactics_hash` | Format 7 cassé. |
| `skill-families.json` | Non (présentation) | Libre, mais `test_skill_families.gd` exige 24 compétences réparties sans doublon. |
| `assets/maps/*.geojson` | Non | Rendu uniquement ; refaire captures et `test_map*.gd`. |

Une simple reformulation de texte (`name`, `effect`) dans un fichier hashé casse aussi les sauvegardes : l'empreinte porte sur le texte brut normalisé LF.

## Choisir la bonne approche

1. **Correction d'un texte affiché seulement** → préférer une table de présentation hors empreinte (comme `skill-families.json`) ou un libellé côté UI ; sinon traiter comme un changement de règles.
2. **Changement de règles ou de coefficient** → nouveau profil :
   - nouveau fichier de données (ex. `data/<thème>.json` avec `"schema_version": 1` et `"profile": "<thème>-0.24"`) et module `scripts/gameplay/<thème>.gd` avec `PATH`, `PROFILE` et `validate()` ;
   - nouveau format dans `save_store.gd` (`encode`/validation) et nouvelle empreinte chaînée sur la précédente ;
   - option de partie désactivée par défaut, les anciens profils restent jouables à l'identique ;
   - ligne ajoutée à `docs/COMPATIBILITE.md`.
3. **Ajout rétrocompatible dans un profil existant** : n'existe pas. Même un ajout de clé change l'empreinte.

Avant de toucher au modèle, faire valider l'idée par l'utilisateur si elle relève de la conception (létalité, nouveaux types d'agents, nombre de régions : décisions ouvertes du backlog).

## Étapes

1. Lire le module de validation concerné (`scripts/gameplay/*.gd`) : il définit les clés obligatoires, bornes et références.
2. Mesurer le comportement de référence (skill `equilibrage`) si des coefficients bougent.
3. Modifier données + validation + `world.gd` si nécessaire. Tout aléa via `world.rng`. Effets multiplicatifs composés ; une fermeture de route reste prioritaire.
4. Tests (skill `godot-tests`) :
   - catalogue invalide refusé (clé manquante, référence inconnue, cycle de prérequis, borne) ;
   - nouvelle partie dans le nouveau profil, rejeu déterministe, sauvegarde/reprise ;
   - **anciennes fixtures toujours chargées** et sans ajout rétroactif ;
   - aide F1, tutoriel et fiches à jour si le contenu est visible.
5. Si le fichier est un catalogue validé une fois en mémoire : redémarrer le processus Godot après modification.
6. Mettre à jour `docs/REGLES.md`, `PRODUCT.md`, `docs/GUIDE-JOUEUR.md`, aide en jeu, puis skill `point-de-suivi`.

## Interdits

- Régénérer `tests/fixtures/` ou modifier les constantes `LEGACY_*_HASH` pour « faire passer » un test.
- Supprimer une vérification d'empreinte ou de version moteur.
- Ajouter un contenu à une ancienne sauvegarde au chargement.
- Introduire noms, textes ou visuels issus de Plague Inc. : tout doit être original.
