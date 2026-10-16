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

Résultat actuel : `build/windows-0.8.0/PandemicHorizon.exe`, ressources embarquées, accompagné du guide et des licences copiés par le script. Le dossier est calculé depuis `config/version` dans `project.godot` : `build/windows-<version>/`. Cela permet de conserver une ancienne version en cours d'exécution. Un nouvel export de la même version exige toutefois que son binaire soit fermé. L'exécutable n'est pas signé. Les exécutables, archives téléchargées et captures ne sont pas versionnés dans Git. La release GitHub 1.0 reste un jalon ultérieur.

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
- La commande `Capture` utilise un vrai rendu graphique et produit cinquante-deux captures à 1280 × 720 et 1920 × 1080 : menus Standard/Dégel et reprise, jeu Standard, quatre phases de Dégel, sauvegardes vides/remplies, confirmation, bilan, aide contextuelle, six étapes et sauvegardes du tutoriel, choix des spécialisations et partie 0.7 compatible. Elle nécessite une session graphique.
- Le script `dev.ps1` signale un échec si le moteur renvoie une erreur ou si un test échoue. Le workflow GitHub exécute import et tests ; il ne publie aucun binaire.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 Capture
```

La commande `Balance` explore séparément 2 259 parties, puis écrit `build/qa/balance.csv` et `build/qa/balance-comparison.md`. Ces fichiers générés restent hors de Git. Le script d'exploration et son module `scripts/analysis/` sont exclus du jeu exporté.

Le CSV conserve les neuf colonnes historiques et ajoute `purchases_json` : identifiant, jour, points avant/après de chaque achat réel. Une seule tentative du premier achat manquant est faite avant chaque journée ; aucun point n'est ajouté artificiellement. Une politique inconnue, répétée, incompatible ou sans ses prérequis est refusée ; une partie sans résultat à la limite est une erreur, pas une défaite.

Le rapport compare 675 paires à scénario, difficulté, départ et graine identiques : spécialisation avant Discrétion, ou Discrétion avant spécialisation, toujours après Diffusion puis Mobilité. Il distingue les victoires propres à chaque ordre, les deux victoires, les deux défaites et les spécialisations effectivement acquises. La durée moyenne comparée porte uniquement sur les doubles victoires. Une paire incomplète ou dupliquée est refusée. La synthèse et le détail par départ utilisent les mêmes observations.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 Balance
```

Voir [EQUILIBRAGE-0.4.md](EQUILIBRAGE-0.4.md) pour la méthode et les limites des résultats mesurés.

Le [point 07](suivi/07-transports.md) contient les nouveaux résultats 0.7 avec les transports différenciés. Le rapport 0.4 reste un historique ; les chiffres ne sont pas interchangeables.

Le [point 08](suivi/08-specialisations.md) mesure les spécialisations 0.8 sur 1 584 parties. Les trois politiques supplémentaires achètent la spécialisation avant Discrétion, ce qui modifie aussi le budget et l'ordre des achats.

Le [point 09](suivi/09-ordres-achats.md) et le [rapport apparié](EQUILIBRAGE-0.8-ORDRES.md) comparent les deux ordres sans modifier les règles 0.8. `tests/test_strategy_comparison.gd` vérifie la conservation des résultats de l'ancienne boucle, la trace des achats, le rejeu, les appariements et les calculs du rapport.

Les essais automatiques et les captures ne prouvent pas la facilité d'utilisation, l'équilibrage final ou le fonctionnement sur toutes les configurations Windows.

## Organisation

- `scripts/simulation/world.gd` : état du monde et règles ; aucune dépendance aux scènes.
- `scripts/persistence/save_store.gd` : format JSON 1, validation avant mutation, écriture temporaire vérifiée puis renommage, copie précédente et récupération. Compatibilité contrôlée par empreinte des cinq fichiers de données et version exacte du moteur. La graine et l'état RNG sont des chaînes décimales ; le remède utilise huit octets IEEE-754 en hexadécimal pour éviter la dérive constatée du dernier bit lors du passage JSON. Aucun objet ou script n'est désérialisé.
- `data/regions.json` : 24 régions fictives et connexions, avec validation au lancement.
- `data/evolutions.json` : coûts, prérequis et modificateurs ; `data/events.json` : calendrier, effets temporaires, détection et recherche.
- `scripts/gameplay/content.gd` : validation des références, bornes et cycles avant de modifier le monde.
- `data/scenarios.json` et `scripts/gameplay/scenarios.gd` : catalogue et validation des phases, difficultés, routes et contenus spécifiques. Les données du standard ne sont pas modifiées lorsque Dégel démarre.
- `scripts/ui/main.gd` : menus, commandes et accumulation du temps de simulation.
- `scripts/ui/tutorial.gd` : progression des six exercices, conditions de réussite et arrêts pédagogiques ; les règles de `PandemicWorld` restent utilisées sans modifier artificiellement points ou populations.
- `scripts/ui/help.gd` : neuf sujets en français, dont un résumé calculé à partir du monde courant ; aucun appel réseau.
- `data/transports.json` et `scripts/gameplay/transports.gd` : profils, attribution unique de chaque liaison standard ou saisonnière, validation des références et coefficients. Les appels programmatiques avec un monde personnalisé utilisent des profils neutres, sauf si `transport_source` est fourni explicitement à `World.start` ; le jeu distribué charge toujours le fichier de transports.
- `tests/test_transports.gd` : schémas invalides, symétrie, imports mesurés par type, fermeture prioritaire, effets cumulés et expiration, saison/Mobilité/transport combinés, reprise exacte après sauvegarde et détails d'interface. Les sauvegardes 0.7 utilisent `user://saves/transports-1`, distinct des parties 0.6.
- `tests/test_specializations.gd` : exclusions symétriques et sans contradiction, coûts, imports, contreparties réelles de recherche, rejeu après achat, contrôle des sauvegardes et parcours Tab/Maj+Tab des neuf groupes de Dégel aux deux tailles. `tests/fixtures/` conserve quatre états générés avec le commit 0.7 pour vérifier vingt journées de reprise identique et l'absence de réécriture à la lecture. Ne pas régénérer ces références avec la version courante.
- Le format reste 1 ; les empreintes 0.7 connues sont acceptées uniquement avec les anciens achats. La lecture reconstruit et valide le monde sans modifier le fichier ; la première écriture 0.8 garde l'original en secours. L'empreinte 0.8 normalise les fins de ligne des cinq fichiers JSON. Toute autre compatibilité doit être vérifiée avant d'étendre l'allowlist.
- `scripts/ui/region_map.gd` : carte schématique et sélection des régions.
- `docs/REGLES.md` : paramètres effectifs du prototype.
- `docs/suivi/00-index.md` : point de reprise pour les prochaines sessions.

Avant un push : import, tests, contrôle des écrans modifiés, `git diff --check` et revue des fichiers inclus. Consigner le résultat dans le point de suivi du lot.
