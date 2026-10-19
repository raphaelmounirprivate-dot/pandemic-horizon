# Développer et vérifier le prototype

## Environnement fixé

Le prototype 0.14 ajoute la caméra de carte. `tests/test_map_camera.gd` vérifie zoom, déplacement, limites, sélection, focus, centre et invariance du modèle. Pour quinze captures natives : lancer Godot avec `--path . --script res://tests/capture_camera.gd -- --no-autosave`. Le script refuse une taille PNG différente de la résolution demandée. `window/stretch/aspect="expand"` permet un véritable rendu 2395 × 1060, au lieu d'un rendu intérieur 16:9.

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

Résultat actuel : `build/windows-0.17.0/PandemicHorizon.exe`, ressources embarquées, accompagné du guide et des licences copiés par le script. Le dossier est calculé depuis `config/version` dans `project.godot` : `build/windows-<version>/`. Cela permet de conserver une ancienne version en cours d'exécution. Un nouvel export de la même version exige toutefois que son binaire soit fermé. L'exécutable n'est pas signé. Les exécutables, archives téléchargées et captures ne sont pas versionnés dans Git. La release GitHub 1.0 reste un jalon ultérieur.

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

### Analyse des objectifs

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 BalanceObjectives
```

Cette commande explore **4 320 parties Standard**, soit 2 160 paires avec/sans Premiers relais : 24 départs, trois difficultés, graines 7/42/2042 et dix ordres d'achat. Les politiques sont partagées avec `Balance` dans `scripts/analysis/strategy_comparison.gd`. Le rapport conservé du lot 11 mesure les règles 0.9.0 ; la commande utilise le contenu actuel du projet et indique son empreinte.

`build/qa/balance-objectives.csv` garde les résultats, achats réels, identifiant et état de l'objectif ainsi qu'une empreinte de l'état enregistrable. Pour chaque paire, la commande vérifie l'identité des champs de simulation (dont populations, remède exact, RNG, effets, points et achats), hors objectif, journal et date d'enregistrement. Elle compare aussi explicitement résultat, durée, couverture, score et trace d'achats ; toute dérive ou paire absente/dupliquée fait échouer la commande. Le témoin sans objectif n'est jamais compté comme un échec facultatif.

`build/qa/balance-objectives.md` présente les quatre combinaisons objectif/victoire, le taux observé, les dates des seules réussites, puis les détails par difficulté, politique et départ. Moteur et empreinte normalisée du contenu sont indiqués pour reproduire la mesure. Les fichiers générés restent hors de Git ; le [rapport conservé](EQUILIBRAGE-0.9-OBJECTIFS.md) et le [point 11](suivi/11-analyse-objectifs.md) consignent la livraison.

`tests/test_objective_comparison.gd` couvre les paires réelles, les quatre combinaisons synthétiques, les dates, les dénominateurs, les témoins sans objectif et le refus des dérives. Le script `scripts/balance_objectives.gd` et tous les modules d'analyse sont exclus de l'export Windows.

Les essais automatiques et les captures ne prouvent pas la facilité d'utilisation, l'équilibrage final ou le fonctionnement sur toutes les configurations Windows.

Le [point 12](suivi/12-relais-arctiques.md) livre Relais arctiques en 0.10. `tests/test_arctic_relays.gd` vérifie fenêtres, routes fermées, sens, quotas, reprise, références 0.9 et 99 paires Dégel avec/sans objectif, sur trois graines/difficultés et onze politiques. `dev.ps1 CaptureArctic` rend 22 vues ciblées dans `.impeccable/review/`. Le catalogue d'objectifs est lu et validé depuis une copie en mémoire ; redémarrer le processus après une modification de `data/objectives.json`.

### Stratégies climatiques précoces

`dev.ps1 BalanceArctic` génère `build/qa/balance-arctic.csv` et `.md` : 270 parties Dégel, soit 135 paires avec/sans Relais arctiques, trois difficultés, graines 7/42/2042 et quinze politiques. Les onze politiques historiques sont conservées ; quatre ordres précoces sont ajoutés dans `scripts/analysis/arctic_analysis.gd` sans modifier le catalogue historique.

Le comparateur commun prend l'identifiant d'objectif et la liste de politiques autorisées. Il vérifie les compteurs arctiques, leurs bornes/fenêtres et la cohérence de la résolution, puis les mêmes empreintes, résultats et achats entre modes. Les comportements Standard restent couverts par leurs tests existants.

Le rapport sépare les quatre résultats objectif/victoire et détaille les achats climatiques et de base : nombre acquis, nombre acquis avant la fin du jour 54 et dates min–max des seules acquisitions réelles. Les compteurs de l'objectif restent plafonnés et figés ; ils ne représentent pas le trafic total après sa résolution. Le [rapport conservé](EQUILIBRAGE-0.10-CLIMATIQUE.md) et le [point 13](suivi/13-strategies-climatiques.md) consignent les mesures. `tests/test_arctic_analysis.gd` vérifie nouveaux ordres légaux, témoins, chronologie et refus des incohérences. Ce lot ne change ni le jeu 0.10.0, ni son interface, ni ses sauvegardes ; les outils restent exclus de l'exécutable.

## Organisation

Présentation 0.13 : `scripts/ui/region_map.gd` projette `assets/maps/world-land.geojson`, géométrie Natural Earth du domaine public (provenance dans `docs/licences/Natural-Earth.txt`). Les régions utilisent des ancres visuelles distinctes des données de simulation ; une relaxation déterministe sépare leurs zones de clic de 44 px. Les points terrestres sont préparés à la construction, sans RNG de simulation. Les flèches lisent `world.latest_flows`, observation non sérialisée des échanges du dernier pas ; elles sont filtrées par date et fermeture. L'animation utilise son propre temps et s'arrête en pause. `main.gd` expose tous les achats dans une grille à trois colonnes, avec coûts, effets et raisons visibles ; les choix J28 sont intégrés sous la carte. Le contrôle de géométrie couvre 1280 × 720, 1920 × 1080 et 2395 × 1060. `CaptureDecisions` capture 34 états/taille et la vue large du joueur. `tests/test_world_presentation.gd` vérifie absence de menus/panneaux déroulants en jeu, visibilité, flux légaux, pause et absence de mutation par animation. Le format 4 et les données de simulation sont conservés.

La 0.12 applique le coût 3 aux nouvelles parties. `PandemicWorld.decision_rules` fige la définition pour la partie ; `decision_profile` identifie 0.11 ou 0.12. Format 4 et empreinte de huit JSON, dont `decisions-0.11.json` : les fichiers de format 3 avec empreinte 0.11 reconnue sont reconstruits avec le profil historique 6 points avant validation du budget. Ce profil est conservé au réenregistrement ; aucun remboursement ni changement de prix d'une décision en attente. Les hypothèses d'analyse ne sont pas des profils de sauvegarde supplémentaires. Les tests rejouent les huit références 0.11 et refusent profils absents, inconnus et budgets contradictoires.

Paramètres du soutien : `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 BalanceParameters`. La commande compare douze modèles sur 1 620 parties : témoins désactivé/maintien/limitation et neuf combinaisons coût 0/3/6 × remède 1/1,075/1,15. La réserve reste fixée à 6 dans chaque modèle, indépendamment du coût testé, pour financer tous les choix au J28. Le paramètre facultatif `reserve_floor` de l'outil de comparaison est enregistré et validé dans les traces ; les appels historiques gardent leur comportement. `scripts/analysis/logistics_parameters.gd` remplace temporairement le catalogue en mémoire pendant un appel synchrone, puis restaure sa valeur précédente, même sur erreur retournée. Aucun `await` ni retour anticipé n'est permis dans cette section. Ne jamais sauvegarder un monde hypothétique comme partie jouable. Les paramètres et leur empreinte accompagnent chaque observation. Sorties locales : `build/qa/balance-parameters.jsonl` et `.md`. Les tests couvrent restauration du catalogue, prix payé, réserve constante, budget, témoins, expériences incohérentes et références 0.11. Ce module et son lanceur sont exclus du binaire. Voir le [point 16](suivi/16-parametres-logistiques.md) et le [rapport](EQUILIBRAGE-0.12-PARAMETRES.md).

Analyse des décisions : `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 BalanceDecisions`. `scripts/analysis/decision_comparison.gd` lance les quatre variantes et reconstruit séparément le budget, les tentatives et le choix pour valider les traces. La commande exige 1 080 observations : deux séries de financement × trois difficultés × trois graines × quinze politiques × quatre variantes. Elle vérifie les groupes complets, l'égalité avant décision et le maintien sans dérive, puis écrit `build/qa/balance-decisions.csv` et `.md`. Le CSV conserve les tentatives refusées, points avant/après et relevés du remède aux J0/28/31/40/43/54. Une partie terminée n'est pas prolongée pour fabriquer un relevé. `tests/test_decision_comparison.gd` contrôle les budgets légaux, le soutien non financé, les contrastes et les cohortes incohérentes. Le rapport conservé est [EQUILIBRAGE-0.11-DECISIONS.md](EQUILIBRAGE-0.11-DECISIONS.md), la décision d'équilibrage est au [point 15](suivi/15-analyse-decisions.md). Ces outils restent exclus de l'exécutable ; ce lot conserve les règles, le format et l'interface 0.11.

Le [point 14](suivi/14-decision-logistique.md) livre la décision logistique 0.11. `data/decisions.json` définit trois options ; `scripts/gameplay/decisions.gd` gère déclenchement, choix, paiement, échéance et modificateurs. Le catalogue est validé puis conservé en mémoire : redémarrer après modification. `tests/test_decisions.gd` couvre la chronologie, les coûts, le cumul, les sauvegardes, huit références 0.10 et les entrées synthétiques aux deux résolutions. `dev.ps1 CaptureDecisions` rend 35 vues ciblées hors Git. L'événement est désactivé par défaut, réservé à Dégel et n'est jamais ajouté à une ancienne sauvegarde.

- `scripts/simulation/world.gd` : état du monde et règles ; aucune dépendance aux scènes.
- `scripts/persistence/save_store.gd` : format JSON 4, validation avant mutation, écriture temporaire vérifiée puis renommage, copie précédente et récupération. Compatibilité contrôlée par empreinte des huit fichiers de données et version exacte du moteur. La graine et l'état RNG sont des chaînes décimales ; le remède utilise huit octets IEEE-754 en hexadécimal pour éviter la dérive constatée du dernier bit lors du passage JSON. Aucun objet ou script n'est désérialisé.
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
- Le format courant est 4 ; son empreinte normalise les fins de ligne de huit JSON, dont `objectives.json` et `decisions.json`. Le format 2 reste accepté uniquement pour les empreintes 0.9 et 0.10 reconnues, sans champ décision ; les objectifs historiques sont conservés. L'empreinte connue 0.9 accepte uniquement son objectif historique Premiers relais ou un état vide. Le format 1 reste accepté pour les empreintes 0.7 connues (anciens achats uniquement) et l'empreinte normalisée 0.8, sans champ objectif ni activation rétroactive. La lecture reconstruit et valide le monde sans modifier le fichier ; la première écriture 0.12 garde l'original en secours. Les compteurs arctiques sont validés, bornés, reconstruits en entiers et cohérents avec la date et les fenêtres ; la validation ne rejoue pas toute l'histoire d'un fichier. Toute autre compatibilité doit être vérifiée avant d'étendre l'allowlist.
- `scripts/gameplay/objectives.gd` : validation du catalogue, décompte, échéance et résolution facultative, sans effet sur les paramètres de simulation. `tests/test_objectives.gd` couvre seuil exact, jour limite, fin simultanée, état figé, sauvegardes incohérentes, reprise et entrées synthétiques aux deux résolutions. Les quatre références 0.8 de `tests/fixtures/` ont été générées avant modification du code ; ne pas les régénérer avec une nouvelle version.
- `dev.ps1 CaptureObjectives` capture dix-huit vues ciblées (neuf états aux deux tailles) dans `.impeccable/review/`, hors Git. Elles couvrent choix désactivé/activé, Dégel, progression, réussite, échec, deux bilans et une ancienne partie sans objectif.
- `scripts/ui/region_map.gd` : fond géographique vectoriel, sélection des régions fictives, couverture rouge et flux orientés du jour.
- `docs/REGLES.md` : paramètres effectifs du prototype.
- `docs/suivi/00-index.md` : point de reprise pour les prochaines sessions.

Avant un push : import, tests, contrôle des écrans modifiés, `git diff --check` et revue des fichiers inclus. Consigner le résultat dans le point de suivi du lot.

## Clôture du cycle 0.19

3 141 contrôles automatiques passent. Captures de confort : tests/capture_comfort.gd ; profil enrichi : tests/capture_expanded.gd. Avant livraison : dev.ps1 Export, puis verify-export.ps1. Après commit propre : checkpoint.ps1 pour le bundle et les sources, package-windows.ps1 pour le ZIP Windows identifié par commit et SHA-256. L’archive est locale, les binaires restent hors Git ; le push main est distinct.

Le script de paquet vérifie les ressources de l’exécutable, sa copie en chemin accentué, les fichiers du ZIP et l’empreinte du binaire archivé. Les préférences de développement restent isolées. Essais humains à compléter dans TESTS-JOUEURS.md avant de déclarer le cycle validé en 1.0.

## Extension 0.20

Aléas : tests/test_crises.gd ; captures : tests/capture_crises.gd ; mesures : scripts/analysis/balance_crises.gd (anciennement scripts/balance_crises.gd) (140 parties). Aucun JSON historique modifié : crises.json séparé, format 6, profils 4/5 inchangés. Le script package-windows.ps1 choisit désormais les notes correspondant à la version du projet. Export séparé build/windows-0.20.0/ ; sauvegarde et archive identifiées par commit après vérification.

## Provenance vérifiée (0.21)

Après Import et Test, commiter les sources avant Export : celui-ci exige un dépôt propre et crée BUILD.json (commit, version, empreintes exécutable et moteur). package-windows.ps1 refuse un binaire ancien ou modifié avant d’écrire VERSION.json. Ne pas retoucher ces manifestes. test-build-identity.ps1 vérifie les refus ; la CI exporte le commit testé et conserve le ZIP avec ses empreintes.

## Vues et vérification 0.23

Le contrôleur garde les wrappers de navigation. menu_view.gd, settings_view.gd et overview_view.gd construisent leurs écrans. skill_presenter.gd lit data/skill-families.json et le modèle sans changer les règles sauvegardées ; family_symbol.gd partage les symboles entre légende et nœuds.

Captures : Godot `--path . --script res://tests/capture_skills.gd -- --no-autosave`. Les tests clavier suivent l'ordre visible des familles, avec les mêmes contrôles de focus et de limites. Les états combinant objectif, fiche complète et choix en attente doivent rester dans la matrice.

La suite réactive compare la reprise à la partie originale aux frontières du choix, au terme de ses effets et tous les dix jours sur 45 trajectoires. Cela évite de comparer deux reprises identiques entre elles ; les reprises quotidiennes ont déjà été vérifiées lors de la clôture 0.22.

Compatibilité : COMPATIBILITE.md. Sessions humaines : tests-joueurs/README.md. Les captures automatiques ne sont pas des résultats joueurs.
