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

Résultat actuel : `build/windows-0.6.0/PandemicHorizon.exe`, ressources embarquées, accompagné du guide et des licences copiés par le script. Le dossier est calculé depuis `config/version` dans `project.godot` : `build/windows-<version>/`. Cela permet de conserver une ancienne version en cours d'exécution. Un nouvel export de la même version exige toutefois que son binaire soit fermé. L'exécutable n'est pas signé. Les exécutables, archives téléchargées et captures ne sont pas versionnés dans Git. La release GitHub 1.0 reste un jalon ultérieur.

`verify-export.ps1` copie le binaire de la version courante seul vers un chemin contenant espaces et accents, vérifie le standard (prérequis, événements, victoire/défaite), Dégel (quatre phases, routes et évolutions) et les difficultés, puis son démarrage graphique. Ce contrôle nécessite une session graphique pour sa deuxième étape ; il n'utilise ni les scènes sources ni le dossier de tests.

Le smoke test vérifie aussi une écriture/lecture et vingt journées de reprise identique dans le binaire. Il utilise `user://smoke-persistence`, distinct des sauvegardes du joueur. Les tests et captures désactivent l'automatique par `--no-autosave` et isolent leurs écritures dans leurs propres dossiers.

En 0.6, il exécute également les six exercices, une sauvegarde/lecture d'entraînement et l'aide, puis vérifie la restitution de la partie initiale. Les fichiers du tutoriel de cet essai utilisent `user://smoke-training`, ceux des tests `user://tests-training` et ceux des captures `user://capture-training`.

## Tests

- `tests/run_tests.gd` vérifie données invalides, conservation de population, bornes, replay, ordre des connexions, effets des achats, fins simultanées, redémarrage et contrôleur d'interface.
- `tests/test_gameplay.gd` couvre les schémas JSON, prérequis, détection, effets régionaux, expiration exclusive, fermetures superposées et cumuls sans effet résiduel.
- `tests/test_scenarios.gd` couvre les catalogues invalides, départ imposé, phases, climat, routes saisonnières, évolutions spécifiques, difficultés et rejeu complet. Il explore 48 parties et trois stratégies ciblées gagnantes de Dégel, une par difficulté, avec les points normalement gagnés.
- `tests/test_map.gd` vérifie les 24 régions, les 38/39 routes, la connexité, les positions uniques, des victoires légales depuis chaque départ standard en difficile et l'absence de superposition des cibles aux deux tailles testées.
- `tests/test_persistence.gd` vérifie trente états de Standard/Dégel dans trois difficultés, la reprise de cinquante journées, l'état aléatoire 64 bits, la valeur exacte du remède, les fichiers altérés/incompatibles, le secours, les erreurs d'écriture, les emplacements et le contrôleur. Les clics dans le viewport ouvrent les sauvegardes et la confirmation d'écrasement ; Annuler reçoit le focus initial.
- `tests/test_onboarding.gd` vérifie l'aide depuis plusieurs écrans, sa pause, le contexte de région/scénario, les six actions du tutoriel, les points normalement gagnés, les arrêts exacts aux jours 1/26/32, l'isolation du monde et du fichier d'origine, la sortie anticipée et le retour aux choix précédents. Un parcours entièrement au clavier injecte les événements Entrée/Tab, y compris dans la confirmation de chargement ; les états pédagogiques et le focus après chaque réussite sont contrôlés.
- `tests/input_journey.gd` injecte des événements souris/clavier dans le viewport : clics avec test de position, refus/acceptation d'achat, Tab/Maj+Tab, Entrée, Espace, vitesses et Échap. Il teste le routage Godot ; il ne simule pas le pilote d'entrée Windows ni des gestes humains. API utilisée : [Viewport.push_input](https://docs.godotengine.org/en/stable/classes/class_viewport.html#class-viewport-method-push-input).
- 288 parties automatisées explorent les 24 départs standards et douze graines, avec ou sans achats automatiques. Ce lot ne mesure pas la difficulté pour des joueurs humains.
- La commande `Capture` utilise un vrai rendu graphique et produit quarante captures à 1280 × 720 et 1920 × 1080 : menus Standard/Dégel et reprise, jeu Standard, quatre phases de Dégel, sauvegardes vides/remplies, confirmation, bilan, aide contextuelle, six étapes et sauvegardes du tutoriel. Elle nécessite une session graphique.
- Le script `dev.ps1` signale un échec si le moteur renvoie une erreur ou si un test échoue. Le workflow GitHub exécute import et tests ; il ne publie aucun binaire.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 Capture
```

La commande `Balance` explore séparément 909 parties, puis écrit `build/qa/balance.csv` et affiche les résultats par scénario, difficulté et politique d'achats. Ce fichier généré reste hors de Git. Le script d'exploration est exclu du jeu exporté.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 Balance
```

Voir [EQUILIBRAGE-0.4.md](EQUILIBRAGE-0.4.md) pour la méthode et les limites des résultats mesurés.

Les essais automatiques et les captures ne prouvent pas la facilité d'utilisation, l'équilibrage final ou le fonctionnement sur toutes les configurations Windows.

## Organisation

- `scripts/simulation/world.gd` : état du monde et règles ; aucune dépendance aux scènes.
- `scripts/persistence/save_store.gd` : format JSON 1, validation avant mutation, écriture temporaire vérifiée puis renommage, copie précédente et récupération. Compatibilité contrôlée par empreinte des quatre fichiers de données et version exacte du moteur. La graine et l'état RNG sont des chaînes décimales ; le remède utilise huit octets IEEE-754 en hexadécimal pour éviter la dérive constatée du dernier bit lors du passage JSON. Aucun objet ou script n'est désérialisé.
- `data/regions.json` : 24 régions fictives et connexions, avec validation au lancement.
- `data/evolutions.json` : coûts, prérequis et modificateurs ; `data/events.json` : calendrier, effets temporaires, détection et recherche.
- `scripts/gameplay/content.gd` : validation des références, bornes et cycles avant de modifier le monde.
- `data/scenarios.json` et `scripts/gameplay/scenarios.gd` : catalogue et validation des phases, difficultés, routes et contenus spécifiques. Les données du standard ne sont pas modifiées lorsque Dégel démarre.
- `scripts/ui/main.gd` : menus, commandes et accumulation du temps de simulation.
- `scripts/ui/tutorial.gd` : progression des six exercices, conditions de réussite et arrêts pédagogiques ; les règles de `PandemicWorld` restent utilisées sans modifier artificiellement points ou populations.
- `scripts/ui/help.gd` : huit sujets en français, dont un résumé calculé à partir du monde courant ; aucun appel réseau.
- `scripts/ui/region_map.gd` : carte schématique et sélection des régions.
- `docs/REGLES.md` : paramètres effectifs du prototype.
- `docs/suivi/00-index.md` : point de reprise pour les prochaines sessions.

Avant un push : import, tests, contrôle des écrans modifiés, `git diff --check` et revue des fichiers inclus. Consigner le résultat dans le point de suivi du lot.
