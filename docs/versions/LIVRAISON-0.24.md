# Livraison 0.24.0 — candidat pour les sessions joueurs

Réalisée le 21 octobre 2026 sur le PC de développement (Windows 11 Pro, NVIDIA Quadro P2000, rendu Compatibility).

| Élément | Valeur |
| --- | --- |
| Commit source | `e36566d950a70cefe3fb684342eb4bcb02e7a9d5` |
| Moteur | Godot 4.7.2 stable, modèles d'export vérifiés par empreintes officielles |
| Régression | `dev.ps1 Test` : 6 486 contrôles réussis, zéro échec |
| Exécutable | `build/windows-0.24.0/PandemicHorizon.exe`, SHA-256 `29BAB4EDCD087F5F39111D71529F1D494AA3E3A62647777984FCC414BF84CA18` |
| `verify-export.ps1` | Code 0 : `RUNTIME_SMOKE_OK` depuis un chemin accentué, démarrage graphique |
| `test-build-identity.ps1` | 5 contrôles : commit/version périmés, binaire modifié et identité absente refusés |
| Archive | `build/releases/PandemicHorizon-0.24.0-Windows-x64-e36566d.zip` (38 378 271 octets), SHA-256 `FC46BCA252F4755B535AC80D3CDA067308A601D930AE0C2D73C4DAF24FB304F9` |
| Checkpoint | `build/checkpoints/0.24.0-e36566d/` (bundle Git vérifié + sources) |

Push : `682fbd4..0c3be3f` sur `main`. CI `39563200575` réussie (jobs simulation et lint/gdlint) : https://github.com/raphaelmounirprivate-dot/pandemic-horizon/actions/runs/39563200575

Archive, exécutable et checkpoint restent locaux (hors Git). Aucune release GitHub binaire.

## Non prouvé par cette livraison

- Fonctionnement sur un autre PC sans Godot, échelles 125/150 %, son réel.
- Comportement avec AVG actif : l'antivirus a déjà mis en quarantaine des versions précédentes ; pas de recontrôle consigné ici.
- Compréhension par des joueurs : aucune session réalisée.

## 0.24.1 — 21 octobre 2026

| Élément | Valeur |
| --- | --- |
| Commit source | `66df89533a15390dcf73a7d8be0b6c3a83d6afa4` |
| Régression | 6 491 contrôles réussis, zéro échec |
| Exécutable | `build/windows-0.24.1/PandemicHorizon.exe`, SHA-256 `2E7DA19774FEB137A03BB292E26E522E03DB4DDB486B781022B0A1AF5C8DB8C3` |
| `verify-export.ps1` / `test-build-identity.ps1` | Code 0 ; `RUNTIME_SMOKE_OK` ; 5 contrôles de provenance |
| Archive | `build/releases/PandemicHorizon-0.24.1-Windows-x64-66df895.zip` (38 380 367 octets), SHA-256 `50EE8AA3DE37FA17EFAC1F4F2B4233E5CA2F8EC269D9940F1010A683743D46AC` |
| Checkpoint | `build/checkpoints/0.24.1-66df895/` |

L'archive 0.24.0 est conservée. Mêmes réserves que ci-dessus (autre PC, AVG actif, joueurs).
