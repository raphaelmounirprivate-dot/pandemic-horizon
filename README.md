# Pandemic Horizon

Jeu de stratégie original pour PC Windows, en français et hors ligne, inspiré du genre de la simulation de pandémie. On pilote l'évolution d'un agent fictif dans un monde stylisé de 24 régions : gérer ses points d'évolution, s'adapter aux réactions des régions, aux transports et aux aléas, et atteindre 90 % de la population avant l'achèvement du remède.

Code, interface, textes et ressources sont originaux ; le jeu est autonome et ne reprend rien de Plague Inc. Dépôt `pandemic-horizon` (ancien nom de travail `plague-inc-evolved`, renommé le 19 octobre 2026 ; l'ancienne adresse redirige).

## État

**Candidat 0.26.0 expérimental local : pas une 1.0.** 6830 contrôles automatiques réussis, zéro échec. Archive Windows locale `PandemicHorizon-0.26.0-Windows-x64-0bae202.zip` vérifiée (non publiée). Aucun essai externe avec des joueurs documenté.

- 0.26 : les crises stratégiques dépendent de l’état du monde (liaison interrompue, pression scientifique, foyer développé, passage ouvert, coordination), ONDE se décale des décisions, Discrétion agit 30 jours et retarde la détection, une ligne « En cours » résume les effets actifs. Format 9 ; parties 0.25 conservées. Voir le [point 37](docs/suivi/37-situations-strategiques.md) et les [mesures de 2 520 parties](docs/equilibrage/EQUILIBRAGE-0.26-SITUATIONS.md) : Discrétion n’est plus dominante ; Mobilité, devenue la plus sûre, reçoit une contrepartie (remède ×1,15) qui réduit son avance ([variantes](docs/equilibrage/EQUILIBRAGE-0.26-VARIANTES.md)).

- Profils historiques conservés ; Standard, Dégel 2042 et Réseaux fragiles, trois difficultés, sauvegardes locales et tutoriel.
- Nouveau profil facultatif : choisir NACRE, ONDE ou VOILE à l’étape 2 de Nouvelle partie. Trois mécaniques d’agent, crises de coordination récurrentes, six secondes par journée à ×1 et pauses aux décisions / premiers achats.
- Bilan explicatif, effets régionaux d’agent, ambiance sonore facultative. Format 8 distinct, anciennes sauvegardes conservées.

Voir le [point 36](docs/suivi/36-profil-strategique.md) et les [mesures de 1 080 parties](docs/equilibrage/EQUILIBRAGE-0.25-STRATEGIE.md). Les trois stratégies mesurées sont viables en normale ; Discrétion reste très forte. Le profil demande encore un équilibrage humain. Lot non publié : les anciens exécutables ne sont pas mis à jour par ces modifications de sources.

Prochaine étape : [sessions joueurs](docs/tests-joueurs/README.md) sur le rythme, les situations et les choix du profil stratégique 0.26. Historique : [CHANGELOG.md](CHANGELOG.md).

## Lancer et développer

Sous Windows, depuis la racine du dépôt :

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/setup-godot.ps1   # une fois : Godot 4.7.2 vérifié par SHA-512
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 Import
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 Test
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 Play
```

Les exécutables et archives sont produits hors Git dans `build/` (voir [DEVELOPPEMENT.md](docs/DEVELOPPEMENT.md)). Les agents de code lisent d'abord [CLAUDE.md](CLAUDE.md).

## Documentation

| Document | Contenu |
| --- | --- |
| [Guide joueur](docs/GUIDE-JOUEUR.md) | Commandes, parcours et limites du prototype |
| [Règles](docs/REGLES.md) | Paramètres effectivement implémentés |
| [PRODUCT.md](PRODUCT.md) · [DESIGN.md](DESIGN.md) | Comportement attendu · système visuel |
| [Architecture](docs/ARCHITECTURE.md) | Carte du code, invariants, outils |
| [Compatibilité](docs/COMPATIBILITE.md) | Formats de sauvegarde |
| [Points de suivi](docs/suivi/00-index.md) | Ce qui a réellement été fait, testé et publié |
| [Feuille de route](docs/roadmap/README.md) | Backlog, audits, décisions ouvertes |
| [Plan de développement](docs/plan-developpement.md) | Périmètre de la 1.0 et jalons |
| [Dégel 2042](docs/scenario-degel-2042.md) | Conception du scénario arctique |
| [Antivirus](docs/ANTIVIRUS.md) | Exécutable non signé, faux positifs |
