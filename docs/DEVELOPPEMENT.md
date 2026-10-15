# Développer et vérifier le prototype

## Environnement fixé

Godot **4.7.2 stable standard**, GDScript, rendu Compatibility, export Windows x86_64. Version observée : `4.7.2.stable.official.ed1daf0bf`. Source : [distribution officielle](https://github.com/godotengine/godot-builds/releases/tag/4.7.2-stable).

Les commandes suivantes s'exécutent depuis la racine du dépôt, sous Windows PowerShell. `-ExecutionPolicy Bypass` ne s'applique qu'au processus lancé ; aucune politique système n'est modifiée.

```powershell
# Téléchargement local de l'éditeur, sans installation globale.
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/setup-godot.ps1

# Import, puis tests sans fenêtre.
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 Import
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 Test

# Lancement du projet avec l'éditeur en mode jeu.
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 Play
```

L'outillage reste dans `.tools/`, exclu de Git et de l'import Godot. Le script de préparation vérifie les archives avec les empreintes SHA512 de la distribution officielle. Les préférences des essais sont isolées dans `.tools/user/`. Le jeu distribué utilise le répertoire utilisateur normal de Godot.

## Export Windows

```powershell
# Environ 1,2 Go de modèles officiels à télécharger ; extraction des deux modèles Windows seulement.
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/setup-godot.ps1 -WithExportTemplates
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 Import
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 Test
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 Export
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify-export.ps1
```

Résultat actuel : `build/windows-0.3.0/PandemicHorizon.exe`, ressources embarquées, accompagné du guide et des licences copiés par le script. Le dossier est calculé depuis `config/version` dans `project.godot` : `build/windows-<version>/`. Cela permet de conserver une ancienne version en cours d'exécution. Un nouvel export de la même version exige toutefois que son binaire soit fermé. L'exécutable n'est pas signé. Les exécutables, archives téléchargées et captures ne sont pas versionnés dans Git. La release GitHub 1.0 reste un jalon ultérieur.

`verify-export.ps1` copie le binaire de la version courante seul vers un chemin contenant espaces et accents, vérifie le standard (prérequis, événements, victoire/défaite), Dégel (quatre phases, routes et évolutions) et les difficultés, puis son démarrage graphique. Ce contrôle nécessite une session graphique pour sa deuxième étape ; il n'utilise ni les scènes sources ni le dossier de tests.

## Tests

- `tests/run_tests.gd` vérifie données invalides, conservation de population, bornes, replay, ordre des connexions, effets des achats, fins simultanées, redémarrage et contrôleur d'interface.
- `tests/test_gameplay.gd` couvre les schémas JSON, prérequis, détection, effets régionaux, expiration exclusive, fermetures superposées et cumuls sans effet résiduel.
- `tests/test_scenarios.gd` couvre les catalogues invalides, départ imposé, phases, climat, routes saisonnières, évolutions spécifiques, difficultés et rejeu complet. Il explore 48 parties et trois stratégies ciblées gagnantes de Dégel, une par difficulté, avec les points normalement gagnés.
- `tests/input_journey.gd` injecte des événements souris/clavier dans le viewport : clics avec test de position, refus/acceptation d'achat, Tab/Maj+Tab, Entrée, Espace, vitesses et Échap. Il teste le routage Godot ; il ne simule pas le pilote d'entrée Windows ni des gestes humains. API utilisée : [Viewport.push_input](https://docs.godotengine.org/en/stable/classes/class_viewport.html#class-viewport-method-push-input).
- 72 parties automatisées explorent six départs et douze graines, avec ou sans achats automatiques. Ce lot ne mesure pas la difficulté pour des joueurs humains.
- La commande `Capture` utilise un vrai rendu graphique et produit seize captures à 1280 × 720 et 1920 × 1080 : menus Standard/Dégel, jeu Standard, quatre phases de Dégel et bilan. Elle nécessite une session graphique.
- Le script `dev.ps1` signale un échec si le moteur renvoie une erreur ou si un test échoue. Le workflow GitHub exécute import et tests ; il ne publie aucun binaire.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 Capture
```

Les essais automatiques et les captures ne prouvent pas la facilité d'utilisation, l'équilibrage final ou le fonctionnement sur toutes les configurations Windows.

## Organisation

- `scripts/simulation/world.gd` : état du monde et règles ; aucune dépendance aux scènes.
- `data/regions.json` : six régions fictives et connexions, avec validation au lancement.
- `data/evolutions.json` : coûts, prérequis et modificateurs ; `data/events.json` : calendrier, effets temporaires, détection et recherche.
- `scripts/gameplay/content.gd` : validation des références, bornes et cycles avant de modifier le monde.
- `data/scenarios.json` et `scripts/gameplay/scenarios.gd` : catalogue et validation des phases, difficultés, routes et contenus spécifiques. Les données du standard ne sont pas modifiées lorsque Dégel démarre.
- `scripts/ui/main.gd` : menus, commandes et accumulation du temps de simulation.
- `scripts/ui/region_map.gd` : carte schématique et sélection des régions.
- `docs/REGLES.md` : paramètres effectifs du prototype.
- `docs/suivi/00-index.md` : point de reprise pour les prochaines sessions.

Avant un push : import, tests, contrôle des écrans modifiés, `git diff --check` et revue des fichiers inclus. Consigner le résultat dans le point de suivi du lot.
