# Pandemic Horizon

Jeu de stratégie original pour PC Windows, en français et hors ligne, inspiré du genre de la simulation de pandémie. On pilote l'évolution d'un agent fictif dans un monde stylisé de 24 régions : gérer ses points d'évolution, s'adapter aux réactions des régions, aux transports et aux aléas, et atteindre 90 % de la population avant l'achèvement du remède.

Code, interface, textes et ressources sont originaux ; le jeu est autonome et ne reprend rien de Plague Inc. Dépôt `pandemic-horizon` (ancien nom de travail `plague-inc-evolved`, renommé le 19 octobre 2026 ; l'ancienne adresse redirige).

## État

**Candidat 0.23, prototype : pas une 1.0.** Les fonctionnalités sont implémentées et vérifiées automatiquement (6 486 contrôles, zéro échec), mais **aucun essai avec de vrais joueurs n'a encore eu lieu** et aucune release binaire n'est publiée.

- Scénarios Standard, Dégel 2042 et Réseaux fragiles ; trois difficultés ; profils facultatifs enrichi, aléas et crises réactives.
- Sauvegardes locales, tutoriel, aide F1, accessibilité (clavier, mouvements réduits, lecture agrandie, sons facultatifs).

Derniers lots : [point 30](docs/suivi/30-ecrans-dedies.md), écrans dédiés (Évolution, nouvelle partie en trois étapes, bilan illustré), puis [points 31](docs/suivi/31-vue-de-jeu.md) [et 32](docs/suivi/32-tutoriel-sauvegardes.md), écran de jeu, tutoriel et sauvegardes extraits de `main.gd` ; enfin [point 34](docs/suivi/34-gameplay-type-aide.md), typage strict du gameplay et aide F1 en boutons ; aucun changement de règles.

Prochaine étape : [trois sessions exploratoires avec des joueurs](docs/tests-joueurs/README.md), puis corrections fondées sur les observations. Historique : [CHANGELOG.md](CHANGELOG.md).

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
