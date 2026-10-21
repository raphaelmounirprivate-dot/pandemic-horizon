# Point 34 — typage du gameplay, aide en boutons, contrôleur allégé

Candidat 0.23 : pour le joueur, seule l'aide F1 change ; ses sujets sont des boutons au lieu d'une liste déroulante. Aucune règle, aucun coefficient, aucun format ni aucune empreinte de contenu modifiés.

## Périmètre

- `8f80ea5` — **typage strict de `scripts/gameplay/`** (ANA-09, étape 2 terminée). `res://scripts/gameplay` retiré de `directory_rules` ; 9 fichiers typés. Même règle qu'au point 33 : `Variant` pour tout élément lu avant validation (catalogues JSON, états de sauvegarde), types exacts pour les valeurs validées ou produites par le jeu, paramètres `world: RefCounted` et lambdas typées dans `tactics.gd` et `transports.gd`. Aucun changement de logique.
- `784c61a` — **aide F1 sans liste déroulante** (invariant 7 : « pas de menus déroulants »). L'aide utilisait encore un `OptionButton` depuis la 0.6. Nouveau `scripts/ui/help_view.gd` : grille de 10 boutons (5 colonnes, 44 px), sujet affiché marqué « ● » dans le texte, encadré et nommé dans l'infobulle (pas par la couleur seule) ; le premier sujet reçoit le focus. Textes d'aide inchangés (`help.gd`).
- `784c61a` — **découpage de `main.gd`** (ANA-06) : 597 → 446 lignes. Extraits : `game_clock.gd` (pause, vitesse, journées d'une demi-seconde), `shortcuts.gd` (Échap, E, F1–F4, Espace, 1/2/4), `preferences.gd` (settings.cfg et thème), `evolution_flow.gd` (ouverture, sélection, achat, fermeture de l'écran Évolution). `main.gd` garde les points d'entrée publics, qui délèguent.
- Nouvelle suite `tests/test_help_view.gd` (31 contrôles) : pas de liste déroulante, un bouton par sujet, cibles ≥ 44 px dans la fenêtre aux trois résolutions depuis le menu et la partie, marque écrite unique, clic, borne, pause conservée, F1.

## Vérifications réelles

- `--check-only` sur les 9 fichiers de `scripts/gameplay/` : code 0.
- `dev.ps1 Test` après le typage : **6 455 contrôles réussis, zéro échec**. Après le découpage et l'aide : **6 486 contrôles réussis, zéro échec**.
- Smoke test depuis les sources (`-- --smoke-test`) : `RUNTIME_SMOKE_OK`, code 0.
- Captures de l'aide revues : 9 images (menu, partie sur Transports, lecture agrandie) à 1280×720, 1920×1080 et 2395×1060, dans `.impeccable/review/help-34/` (hors Git). Deux rangées de cinq sujets, aucun débordement.

## Limites

- `scripts/ui/`, `tests/` et `scripts/analysis/` restent non typés. Les vues reçoivent le contrôleur en paramètre non typé (`ui`) ; le typer exige une classe nommée pour `main.gd` et un traitement des dépendances circulaires entre vues : chantier séparé.
- Règles `unsafe_*` toujours désactivées.
- `gdlint` non exécuté localement : contrôlé par la CI.
- Lecture de l'aide par des joueurs : non essayée.

## Livraison

Commits locaux `8f80ea5` et `784c61a`. Push, CI et archive : voir le point suivant ou la section Livraison du CHANGELOG.

Prochaine étape : trois sessions joueurs exploratoires ([protocole](../tests-joueurs/README.md)).
