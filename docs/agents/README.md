# Skills des agents de code

Les skills du projet sont versionnées dans **[`.claude/skills/`](../../.claude/skills/)**, source unique. Claude Code les charge directement ; les autres agents (Codex, Cline…) peuvent lire les mêmes fichiers `SKILL.md`. Il n'y a plus de copie à synchroniser : modifier une skill à cet endroit uniquement.

| Skill | Usage |
| --- | --- |
| [`godot-tests`](../../.claude/skills/godot-tests/SKILL.md) | Lancer, lire et étendre `dev.ps1 Test` et les captures. |
| [`contenu-et-regles`](../../.claude/skills/contenu-et-regles/SKILL.md) | Modifier `data/*.json` sans casser les sauvegardes. |
| [`equilibrage`](../../.claude/skills/equilibrage/SKILL.md) | Mesures appariées et rapports `EQUILIBRAGE-*.md`. |
| [`point-de-suivi`](../../.claude/skills/point-de-suivi/SKILL.md) | Clore un lot : point NN, index, backlog, README. |
| [`livraison-windows`](../../.claude/skills/livraison-windows/SKILL.md) | Export identifié, vérification, ZIP, checkpoint, CI. |
