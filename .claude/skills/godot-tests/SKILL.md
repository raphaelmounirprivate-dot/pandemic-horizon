---
name: godot-tests
description: Lancer, lire et étendre la suite de tests Godot de Pandemic Horizon (dev.ps1 Test, suites tests/test_*.gd, captures aux trois résolutions). À utiliser après toute modification de code ou de données, ou pour ajouter des contrôles.
---

# Tests et captures — Pandemic Horizon

## Lancer

Depuis la racine (Windows ; depuis Git Bash, la même commande fonctionne) :

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 Import   # si ressources/scènes/scripts ajoutés
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 Test
```

- Si `.tools/godot/` est absent : `scripts/setup-godot.ps1` d'abord.
- Succès = dernière ligne `RESULT: N checks, 0 failures` **et** code de sortie 0.
- `dev.ps1` échoue aussi sur toute ligne contenant `SCRIPT ERROR:`, `ERROR:` ou `FAIL:` — chercher ces lignes en premier. Chaque échec affiche `FAIL: <description en français>`.
- La suite complète prend plusieurs minutes (beaucoup de parties simulées). Pour itérer vite sur une seule suite, écrire temporairement un lanceur dans `scripts/analysis/` (exclu de l'export) qui charge uniquement la suite visée, puis **toujours** finir par la suite complète.
- Les écritures sont isolées dans `.tools/user/` ; les tests passent `--no-autosave`. Ne jamais pointer un test vers `user://saves` réel.

## Ajouter des contrôles

1. Si une suite existante couvre le domaine (`test_crises.gd`, `test_tactics.gd`, `test_persistence.gd`…), y ajouter les contrôles.
2. Sinon créer `tests/test_<domaine>.gd` sur ce modèle :

```gdscript
extends RefCounted
const World = preload("res://scripts/simulation/world.gd")
const Store = preload("res://scripts/persistence/save_store.gd")

func run(tree: SceneTree, check: Callable) -> void:
	var world = World.new()
	check.call(world.start("boreale", 2042).is_empty(), "Démarrage valide")
	# … contrôles avec messages en français, précis et uniques
```

   - Synchrone : `func run(check: Callable)` ; asynchrone (UI, frames) : `run(tree, check)` avec `await`.
3. L'enregistrer à la fin de `tests/run_tests.gd`, avant la ligne `print("RESULT…")`, avec un seuil qui détecte une suite qui ne s'exécute plus :

```gdscript
	var before_domaine = checks
	await load("res://tests/test_domaine.gd").new().run(self, check)
	check(checks - before_domaine >= 30, "Suite <domaine> entièrement exécutée")
```

4. Générer le `.uid` : lancer `dev.ps1 Import` puis inclure le fichier `.gd.uid` créé dans le commit.

## Ce qu'un bon contrôle vérifie ici

- **Refus sans mutation** : après un appel refusé, comparer l'état (`Store.new().encode(world)` sans `saved_at`) avant/après.
- **Rejeu** : deux mondes avec même graine et mêmes actions → `regions`, `rng.state`, `cure`, `journal`, `active_events` identiques.
- **Sauvegarde/reprise** : encoder, recharger, avancer N jours dans les deux mondes, comparer.
- **Compatibilité** : les fixtures de `tests/fixtures/` se chargent toujours, sans réécriture et sans contenu rétroactif. **Ne jamais régénérer une fixture.**
- **Interface** : au moins 1280×720 et 1920×1080 ; focus clavier, cibles ≥ 44 px, pas de défilement des compétences.

## Captures visuelles (session graphique requise)

```powershell
.tools/godot/Godot_v4.7.2-stable_win64_console.exe --path . --script res://tests/capture_<thème>.gd -- --no-autosave
```

(ou `dev.ps1 Capture`, `CaptureObjectives`, `CaptureArctic`, `CaptureDecisions`). Les PNG vont dans `.impeccable/review/`, hors Git. Résolutions natives attendues : 1280×720, 1920×1080, 2395×1060 ; le script refuse une taille différente. Regarder réellement les images (Read) avant de déclarer un écran correct, et vérifier les états combinés (ex. 24 compétences + choix en attente) qui ont déjà débordé.

## Limites à rappeler dans les comptes rendus

Tests et captures ne prouvent ni la compréhension par des joueurs, ni le rendu aux échelles Windows 125/150 %, ni le fonctionnement sur un autre PC.
