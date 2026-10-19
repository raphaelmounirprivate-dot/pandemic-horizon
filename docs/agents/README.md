# Skills Claude Code du projet

Copie de travail des skills du projet. Claude Code les charge depuis `.claude/skills/` ; les installer une fois depuis la racine du dépôt :

```powershell
New-Item -ItemType Directory -Force .claude/skills | Out-Null
Copy-Item -Recurse -Force docs/agents/skills/* .claude/skills/
```

| Skill | Usage |
| --- | --- |
| `godot-tests` | Lancer, lire et étendre `dev.ps1 Test` et les captures. |
| `contenu-et-regles` | Modifier `data/*.json` sans casser les sauvegardes. |
| `equilibrage` | Mesures appariées et rapports `EQUILIBRAGE-*.md`. |
| `point-de-suivi` | Clore un lot : point NN, index, backlog, README. |
| `livraison-windows` | Export identifié, vérification, ZIP, checkpoint, CI. |

Après une modification d'une skill ici, relancer la commande de copie. Les autres agents (Codex, Cline…) peuvent lire ces fichiers directement.
