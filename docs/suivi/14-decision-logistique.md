# Point 14 — Décision logistique, prototype 0.11

Date : 16 octobre 2026. Base : `2505179`, branche `main`.

## Périmètre livré

Premier événement à trois choix explicites dans Dégel, facultatif et désactivé par défaut. Au J28, pause et présentation des coûts, effets, durée, irréversibilité et priorité des fermetures. Soutenir les ports : 6 points, mer ×1,50, remède ×1,15 ; limiter les échanges : gratuit, mer ×0,65, remède ×0,85 ; maintenir : gratuit et sans ajout. Les effets commencent le lendemain et durent douze journées. Choix possible J28–30, neutralisation au J31. Retour en pause, F2 pour rouvrir, F1 pour l'aide. Initialement, le focus est sur Retour pour éviter une dépense involontaire.

Catalogue JSON validé et mis en mémoire ; état distinct des événements planifiés pour représenter correctement l'effet différé. Paiement unique, refus sans mutation. Les facteurs se multiplient avec les effets existants sans rouvrir une route. Aucun changement du catalogue antérieur, des objectifs ou du score. La simulation sans activation conserve ses trajectoires.

## Persistance

Format 3, sept JSON normalisés dans l'empreinte. État vide ou quatre champs décision ; coût intégré à l'invariant des points. Format 1 reconnu pour 0.7/0.8, format 2 reconnu pour 0.9/0.10. Les anciennes parties conservent leurs objectifs, sans décision rétroactive. Lecture sans écriture ; premier enregistrement conserve le texte original en secours. Les exports anciens restent disponibles pour leurs formats.

Huit véritables références 0.10 figées avec `2505179` avant toute modification : Standard sans objectif et Dégel avec objectif en cours/réussi/échoué. Rejeu de trente jours avec la même politique et comparaison complète, en plus des références historiques 0.7–0.9. Provenance dans `tests/fixtures/README.md`.

## Fichiers principaux

- `data/decisions.json`, `scripts/gameplay/decisions.gd`, `scripts/simulation/world.gd` : catalogue, état, calendrier et facteurs.
- `scripts/persistence/save_store.gd` : format 3, coût et compatibilité.
- `scripts/ui/main.gd`, `scripts/ui/help.gd` : activation, choix, navigation et aide.
- `tests/test_decisions.gd`, `tests/capture_decisions.gd` : règles, reprise, entrées synthétiques et captures.
- Guide joueur, règles, développement et index mis à jour ; export séparé `build/windows-0.11.0/`.

## Vérifications

- Import Godot 4.7.2 et export Windows 0.11.0 réussis.
- Suite complète : **2 125 contrôles, zéro échec**, dont règles de décision, choix tardif, neutralisation, fermeture prioritaire, coût unique, sauvegardes, trente jours de reprise 0.10 et parcours synthétiques souris/clavier aux deux tailles.
- Exécutable exporté : `RUNTIME_SMOKE_OK` en mode headless puis avec rendu OpenGL sur AMD Radeon RX 6650 XT. Le contrôle inclut choix payant, reprise et expiration.
- SHA256 `build/windows-0.11.0/PandemicHorizon.exe` : `261493430E836068D97627F6FC92CD000479F1EE94B3F6AE8E4391B4157A9E82`.
- `git diff --check` réussi. Le compte rendu de livraison confirme commit, push et résultat GitHub Actions.

Revue indépendante Impeccable : disposition `ship`, 22 captures natives valides aux résolutions 1280 × 720 et 1920 × 1080. Coûts, facteurs et durée visibles avant validation, refus expliqué et focus initial sans dépense. Identité existante conservée. Aucun détecteur HTML/CSS, aucun raster livré.

Documentation indépendante achevée : PRODUCT actualisé, DESIGN et sidecar préservés (empreinte du sidecar `6256EF48491CA369B3500B4F4EB9F951D7B3D4865251F7B32D45CB1422E9B105`). Dérives documentaires antérieures signalées sans changement du système visuel.

## Limites et prochaine étape

Les entrées souris/clavier sont synthétiques, injectées dans Godot. Aucun essai physique Windows ni avec de nouveaux joueurs. Les coefficients constituent un premier contenu, pas un équilibrage humain validé. La validation des sauvegardes vérifie la cohérence structurelle et chronologique sans rejouer l'histoire complète.

Prochain lot : comparer les trois décisions avec un témoin sans événement, sur graines et difficultés identiques, en gardant coûts et tentatives d'achat observables. Séparer résultat facultatif, victoire principale, remède et dates. Conserver les références de compatibilité ; ajuster seulement après analyse.
