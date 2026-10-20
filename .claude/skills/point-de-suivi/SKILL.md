---
name: point-de-suivi
description: Clore un lot de Pandemic Horizon - créer le point docs/suivi/NN-*.md, mettre à jour l'index, le backlog, le README, les notes de version et l'audit, en distinguant prévu, implémenté, testé, essayé et publié. À utiliser à la fin de chaque lot ou livraison.
---

# Point de suivi et documentation de fin de lot

## Règle d'honnêteté

Chaque affirmation porte un statut parmi : **prévu / implémenté / testé automatiquement / revu sur captures / essayé par des joueurs / publié (push, CI, archive)**. Ne jamais déduire l'un de l'autre. Ne jamais écrire qu'un essai humain, DPI, sonore ou sur un second PC a eu lieu sans fiche réellement remplie dans `docs/tests-joueurs/`. Citer les chiffres réels (contrôles, parties, commit, SHA-256) tels que produits par les commandes.

## Étapes

1. **Numéro** : prendre le plus grand `docs/suivi/NN-*.md` + 1 (actuellement 32 → prochain **33**). Nom : `NN-<thème-court-en-kebab>.md`.
2. **Créer le point** (français, concis) :

```markdown
# Point NN — <titre>

Candidat <version> : <ce qui change pour le joueur, en une phrase>.

<Périmètre : fichiers principaux, données, profils/formats touchés ou explicitement inchangés.>

<Vérifications réelles : commande, résultat exact (« N contrôles réussis, zéro échec »), captures (nombre, résolutions), mesures (rapport lié).>

<Limites et réserves : ce qui n'est pas prouvé.>

<Livraison : commit local / push / CI (lien) / archive / checkpoint — chaque statut séparément.>

Prochaine étape : <une action>.
```

3. **`docs/suivi/00-index.md`** : ajouter la ligne `- [Point NN — Titre](NN-….md) : résumé.` au même format que les points 01–25 ; actualiser la phrase « Prochaine étape » et le prochain numéro attendu.
4. **`docs/roadmap/03-backlog.md`** : changer le statut des identifiants concernés (proposé → prêt → en cours → à vérifier → terminé ; « différé »), avec preuve et lien vers le point.
5. **`README.md`** : paragraphe « État du projet » (version, résumé, nombre de contrôles, lien vers le point) et « Prochaine étape ».
6. **Notes de version** si la version change : `docs/versions/NOTES-VERSION-<majeur.mineur>.md` (le script de paquet l'embarque automatiquement d'après `config/version`).
7. **`docs/roadmap/05-audit-…md`** ou nouveau document d'audit si l'état d'une demande de l'audit change.
8. Si les règles changent : `docs/REGLES.md`, `PRODUCT.md`, `docs/GUIDE-JOUEUR.md`, `docs/COMPATIBILITE.md`, aide en jeu (`scripts/ui/help.gd`).
9. **Vérifier** les liens relatifs ajoutés (le fichier cible existe), puis `git diff --check`. Une mise à jour purement documentaire ne nécessite pas de réexporter le jeu.

## Style

Phrases courtes, chiffres exacts, pas d'adjectifs promotionnels. Conserver les archives et rapports historiques : on ajoute, on ne réécrit pas le passé (un audit obsolète part dans `docs/roadmap/archives/`).
