# CLAUDE.md — Pandemic Horizon (dépôt `pandemic-horizon`)

Contexte de travail pour Claude Code (et tout agent de code) sur ce dépôt. À lire en premier, avant toute modification.

## Le projet en une minute

- **Pandemic Horizon** : jeu de stratégie original, en français, hors ligne, pour Windows. Inspiré du genre « simulation de pandémie », sans aucune ressource ni texte de Plague Inc.
- **Moteur** : Godot **4.7.2 stable** (version exacte, vérifiée au chargement des sauvegardes), GDScript, rendu Compatibility, export Windows x86_64.
- **État** : candidat **0.23** (`project.godot` → `config/version`). Prototype candidat, **pas une 1.0**. Aucun essai avec de vrais joueurs n'a encore été réalisé.
- **Prochaine étape officielle** : trois sessions joueurs exploratoires (`docs/tests-joueurs/README.md`), puis corrections fondées sur les observations. Ne pas ajouter de contenu ou de catastrophes « parce que ce serait mieux » sans demande explicite.

## Langue et ton

- Interface, textes du jeu, documents, points de suivi : **français**. Commentaires de code : anglais court accepté (c'est l'usage actuel).
- Les documents distinguent toujours **prévu / implémenté / testé automatiquement / essayé par des humains / publié**. Ne jamais déduire un état d'un autre, ne jamais inventer un résultat humain.

## Commandes (PowerShell, depuis la racine)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/setup-godot.ps1          # une fois : Godot dans .tools/
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 Import            # après ajout/modif de ressources
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 Test              # régression complète (headless)
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 Play              # lancer le jeu
```

- `Test` doit finir par `RESULT: N checks, 0 failures`. `dev.ps1` échoue aussi si la sortie contient `SCRIPT ERROR:`, `ERROR:` ou `FAIL:` — un avertissement Godot transformé en erreur fait donc échouer la suite.
- `dev.ps1` isole `APPDATA`/`LOCALAPPDATA` dans `.tools/user/` : les tests ne touchent jamais les sauvegardes réelles du joueur. Pour lancer Godot à la main, reproduire cette isolation.
- Équilibrage : `dev.ps1 Balance | BalanceObjectives | BalanceArctic | BalanceDecisions | BalanceParameters` ; sorties dans `build/qa/` (hors Git).
- Captures (session graphique requise) : `dev.ps1 Capture*` ou `Godot --path . --script res://tests/capture_<thème>.gd -- --no-autosave`. Sorties dans `.impeccable/review/`.
- Livraison : voir la skill `livraison-windows` (Export → verify-export → package → checkpoint).

## Carte du code (détails : `docs/ARCHITECTURE.md`)

| Zone | Rôle |
| --- | --- |
| `scripts/simulation/world.gd` (`PandemicWorld`) | État et règles du monde. **Aucune dépendance aux scènes/UI.** Déterministe par graine. |
| `scripts/gameplay/*.gd` | Validation et logique des catalogues : contenu, scénarios, transports, objectifs, décisions, historique, contenu enrichi, crises, tactiques. |
| `scripts/persistence/save_store.gd` | Sauvegardes JSON (formats 1→7), empreintes de contenu, secours `.bak`. |
| `scripts/ui/main.gd` | Contrôleur d'interface (~450 lignes ; temps, raccourcis, préférences et flux Évolution dans des modules dédiés). Vues extraites dans `scripts/ui/*_view.gd`. |
| `data/*.json` | Toutes les règles chiffrées. |
| `tests/run_tests.gd` | Point d'entrée unique ; enchaîne toutes les suites `tests/test_*.gd`. |
| `scripts/analysis/` (dont les lanceurs `balance*.gd`) | Outils d'équilibrage, **exclus de l'export**. |
| `docs/` | Règles, guide joueur, suivi, roadmap, rapports d'équilibrage. |

## Invariants à ne jamais casser

1. **Déterminisme.** Tout aléa passe par `world.rng` (graine). Pas de `randf()` global, pas de dépendance à l'heure, à l'ordre d'un `Dictionary` non trié ou au rendu. L'animation et `latest_flows` sont de l'observation : ils ne modifient jamais le modèle et ne sont pas sérialisés.
2. **Empreintes de contenu = compatibilité des sauvegardes.** `save_store.gd` calcule une empreinte SHA-256 en chaîne : `content_hash()` (8 JSON : regions, evolutions, events, scenarios, transports, objectives, decisions, decisions-0.11) → `expanded_hash()` (+ expanded-content) → `crises_hash()` (+ crises) → `tactics_hash()` (+ tactics). **Modifier un seul octet utile d'un de ces fichiers invalide toutes les sauvegardes existantes des profils concernés.** Un changement de règles = nouveau fichier/profil + nouvelle empreinte + fixtures + test de reprise. Voir la skill `contenu-et-regles`.
3. **Profils historiques figés.** `decisions-0.11.json`, les empreintes `LEGACY_*` et les fixtures de `tests/fixtures/` décrivent des versions passées. **Ne jamais régénérer les fixtures avec la version courante**, ne jamais « corriger » un JSON historique.
4. **Pas de rétroactivité.** Une ancienne partie chargée ne reçoit ni nouvel objectif, ni nouvelle décision, ni crise. Lire ne réécrit pas le fichier ; une sauvegarde incompatible n'est jamais écrasée.
5. **Validation avant mutation.** Catalogues et sauvegardes sont validés entièrement avant de toucher au monde ; un échec laisse l'état intact.
6. **Version du moteur.** Changer de version de Godot est une migration à part entière (validation dédiée, anciens exports et checkpoints conservés).
7. **Interface.** Tout en français ; choix logistiques et réponses de crise intégrés à l'écran de jeu ; compétences dans l'écran Évolution dédié (E), un onglet par famille, sans défilement des nœuds ; « Nouvelle partie » en trois étapes à cartes (décisions de l'auteur du 19 octobre 2026) ; pas de menus déroulants ; cibles de 44 px ; information jamais portée par la couleur seule ; pause/vitesses/E/F1–F4/clavier fonctionnels. Vérifier aux trois résolutions 1280×720, 1920×1080, 2395×1060. Jetons visuels dans `DESIGN.md`.
8. **Provenance des binaires.** `Export` exige un dépôt propre et écrit `BUILD.json` ; `package-windows.ps1` refuse un binaire périmé ou modifié. Ne jamais retoucher `BUILD.json`/`VERSION.json`, ne jamais contourner un refus d'empreinte.
9. **Antivirus.** Ne jamais désactiver une protection ni ajouter d'exclusion (AVG a déjà mis en quarantaine l'exe et un script). Signaler et laisser l'utilisateur décider.
10. **Hors Git.** `build/`, `.tools/`, `.godot/`, `.impeccable/`, sauvegardes. Ne jamais committer d'exécutable ni d'archive.

## Façon de travailler sur un lot

1. Lire `docs/suivi/00-index.md`, puis le dernier point (`docs/suivi/34-…` actuellement) et `docs/roadmap/03-backlog.md`.
2. `git status` : vérifier qu'aucune modification locale n'est perdue.
3. Petit changement, puis `dev.ps1 Test`. Pour l'UI : captures aux trois résolutions. Pour les règles : comparaison appariée (mêmes graines/difficultés) avant d'ajuster un coefficient.
4. Ajouter les contrôles correspondants dans une suite `tests/test_*.gd` (skill `godot-tests`).
5. Clore avec la skill `point-de-suivi` : point NN, index, backlog, README, notes de version.
6. Avant un push : `git diff --check`, revue des fichiers inclus, commit explicite. Push et CI sont des statuts distincts.

## Skills du projet (`.claude/skills/`, source unique, versionnée)

Claude Code les charge directement depuis `.claude/skills/`. Modifier les skills à cet endroit uniquement ; `docs/agents/README.md` ne fait que les présenter.

- `godot-tests` — lancer, lire et étendre la suite de tests et les captures.
- `contenu-et-regles` — modifier les JSON de règles sans casser les sauvegardes.
- `equilibrage` — mesures appariées et rapports `EQUILIBRAGE-*.md`.
- `point-de-suivi` — clore un lot et tenir la documentation honnête.
- `livraison-windows` — export, vérification, archive, checkpoint, CI.

## Documents de référence

`README.md` (état) · `PRODUCT.md` (comportement attendu, détaillé) · `DESIGN.md` (système visuel) · `docs/REGLES.md` (paramètres effectifs) · `docs/DEVELOPPEMENT.md` (journal technique) · `docs/ARCHITECTURE.md` (carte du code) · `docs/COMPATIBILITE.md` (formats) · `docs/roadmap/` (backlog, audit) · `docs/suivi/` (historique des lots).
