# Point 20 — Transports visibles, prototype 0.15

Date : 17 octobre 2026. Base : `f5791b7`. Lot B, MON-04 à MON-06.

## Réalisation

Avions, bateaux et véhicules terrestres vectoriels suivent les échanges réels du jour. Leurs silhouettes sont orientées dans le sens du flux ; les fermetures restent prioritaires et la pause fige les mouvements. Les petits symboles près des hubs signalent la présence de liaisons aériennes ou maritimes, même temporairement fermées ; les nombres ouverts/total restent dans le panneau régional.

Le bouton « Flux : tous » parcourt tous, terre, air et mer, sans menu déroulant. Le filtre suit la caméra en mémoire entre écrans et n'affecte pas le modèle. Nouvelle partie et chargement repartent sur tous. Les croix et routes fermées restent visibles quel que soit le filtre.

Le fond Natural Earth reçoit des teintes terrestres et polaires illustratives. Elles ne sont ni une mesure de relief, ni une carte climatique réelle. Aucun raster supplémentaire n'est utilisé. Les continents sont triangulés une fois et les contours projetés sont mis en cache pour éviter leur recalcul à chaque image.

## Mesure avant/après

`tests/benchmark_map.gd`, Dégel, graine 2042, J70, achats légaux, 1280 × 720, AMD Radeon RX 6650 XT, VSync désactivée, 45 images de chauffe puis 120 mesures :

| Mesure de rendu | 0.14 avant | Après maillage et véhicules |
| --- | --- | --- |
| Médiane | 29,503 ms | 18,584 ms |
| 95e percentile | 35,151 ms | 22,181 ms |

Une mesure locale, pas une garantie sur d'autres machines. Le script mesure l'attente jusqu'au rendu d'une image, pas la seule durée GPU. Les rapports bruts sont dans `build/qa/map-benchmark-before.json` et `map-benchmark-after.json`, hors Git. Le gain observé laisse un objectif de 30 images/s sur cette scène et ce PC ; vérifier ailleurs avant de généraliser.

## Vérifications et sauvegarde de l'étape

2 543 contrôles passants, revue complète `ship`, 21 captures aux dimensions exactes, export autonome et démarrage graphique sans erreur. SHA-256 de l'exécutable : `9CB2893A390F918F3ED0617DD962563B6536600DD16E03041DE84D8AA99A29BA`.

L'étape est enregistrée dans un commit distinct avant le lot C. `scripts/checkpoint.ps1` crée après commit une sauvegarde locale vérifiée : bundle Git, archive des sources et manifeste des empreintes, sous `build/checkpoints/`. L'exécutable reste conservé dans son dossier versionné. Les sauvegardes de parties du joueur ne sont pas utilisées pour les tests.

## Suite

Lot C : relations d'évolutions, fiche et achat explicite. Les effets et tarifs existants restent inchangés pour ce lot visuel.
