# AGENTS.md

Instructions pour les agents de code (Codex, Cline, Junie, Gemini, Copilot…). Le contexte complet est dans **[CLAUDE.md](CLAUDE.md)** : le lire avant toute modification. Les procédures détaillées sont dans `.claude/skills/*/SKILL.md` (Markdown lisible par tout agent).

Rappel des règles non négociables :

- Godot 4.7.2 exact, GDScript, interface et documents en français.
- Tests : `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 Test` → `RESULT: N checks, 0 failures`.
- Ne jamais modifier un JSON de règles de la chaîne d'empreintes sans nouveau profil (casse les sauvegardes), ne jamais régénérer `tests/fixtures/`.
- Tout aléa via `world.rng` ; le modèle ne dépend jamais de l'interface.
- Ne jamais retoucher `BUILD.json`/`VERSION.json`, ne jamais désactiver un antivirus ni ajouter d'exclusion.
- Ne jamais déclarer un essai humain, DPI ou second PC qui n'a pas eu lieu.
