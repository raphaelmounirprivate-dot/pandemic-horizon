---
name: livraison-windows
description: Produire une livraison Windows vérifiée de Pandemic Horizon - montée de version, commit propre, export Godot identifié (BUILD.json), verify-export, ZIP par package-windows, checkpoint, push et CI. À utiliser pour tout nouvel exécutable ou archive.
---

# Livraison Windows identifiée

Chaque binaire doit pouvoir être relié à un commit exact. Les scripts refusent un dépôt sale, un binaire périmé ou modifié : **ne jamais contourner ces refus**, ne jamais éditer `BUILD.json` / `VERSION.json` à la main.

## Pré-requis

- `.tools/godot/` avec modèles d'export : `scripts/setup-godot.ps1 -WithExportTemplates` (~1,2 Go).
- Session graphique Windows (la seconde étape de `verify-export.ps1` lance le jeu).

## 1. Montée de version (si nouvelle version)

Mettre la même version partout :

- `project.godot` → `config/version="X.Y.Z"` (source de vérité des scripts) ;
- `export_presets.cfg` → `export_path="build/windows-X.Y.Z/PandemicHorizon.exe"`, `application/file_version` et `application/product_version` = `"X.Y.Z.0"` ;
- `docs/versions/NOTES-VERSION-X.Y.md` présent (requis par `package-windows.ps1`) ;
- README / point de suivi (skill `point-de-suivi`).

## 2. Valider puis committer

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 Import
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 Test
git diff --check
git status            # revoir la liste des fichiers ; aucun binaire, rien de build/ ni .tools/
git commit -m "…"     # message explicite ; demander à l'utilisateur avant de committer
```

## 3. Exporter, vérifier, empaqueter, sauvegarder

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 Export          # exige un dépôt propre → build/windows-X.Y.Z/ + BUILD.json
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify-export.ps1       # chemin accentué, smoke test, démarrage graphique
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/test-build-identity.ps1 # refus des identités altérées
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/package-windows.ps1     # build/releases/PandemicHorizon-X.Y.Z-Windows-x64-<sha7>.zip
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/checkpoint.ps1          # build/checkpoints/X.Y.Z-<sha7>/ (bundle + sources)
```

- Réexporter la même version exige de **fermer** le jeu en cours d'exécution.
- Relever et consigner : commit complet, nombre de contrôles, SHA-256 du ZIP (`Get-FileHash`), chemin du checkpoint.

## 4. Publier (uniquement sur demande de l'utilisateur)

`git push` puis suivre la CI `.github/workflows/test.yml` (Windows : setup, import, tests, provenance, export, paquet, artefact `windows-<sha>`). Distinguer dans le compte rendu : commit local, push, CI réussie (lien), archive locale, tag (`vX.Y.Z-rc.N` si demandé). Aucune release GitHub binaire n'est publiée à ce stade sans décision explicite.

## Antivirus (AVG)

AVG a déjà mis en quarantaine l'exécutable (`IDP.HELU.PSD11`) et `package-windows.ps1` (`IDP.Generic`). En cas de blocage : le constater (index de quarantaine), restaurer un script depuis Git (`git checkout -- <fichier>` puis comparer le blob avec `HEAD`), et **laisser l'utilisateur** décider de toute action sur l'antivirus. Ne jamais désactiver une protection ni ajouter d'exclusion. Un test réussi avec la protection désactivée ne prouve pas le fonctionnement avec la protection active : le noter.

## Ce que la livraison ne prouve pas

Exécution sur un autre PC sans Godot, échelles 125/150 %, son réel, compréhension par des joueurs. Ces points restent « à réaliser » tant qu'aucune fiche de session n'est remplie.
