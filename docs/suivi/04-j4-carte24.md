# Point 04 — Carte étendue, prototype 0.4

Date : 15 octobre 2026. Suite du [point 03](03-j4-degel-difficultes.md).

## Livré

- 24 régions fictives, 3 530 000 habitants, 38 connexions standards et 39 dans Dégel. Le réseau est connexe, y compris depuis l'unique sortie initiale de Boréale dans Dégel.
- Carte schématique organisée en quatre rangées de six. Boutons de 112 × 44 px, noms en 14 px, barres de couverture et compteur de détection adaptés au nombre réel de régions.
- Positions dupliquées rejetées par la validation. Test géométrique des limites et des superpositions aux tailles 1280 × 720 et 1920 × 1080 ; clic sur la dernière région et parcours Tab de toutes les régions.
- Réponse du remède ajustée aux 24 régions : `0,6 + couverture × 0,6 + détections × 0,015`, avant les modificateurs existants. Croissance, coûts, gains de points, phases et coefficients de difficulté conservés.
- Script reproductible `scripts/balance.gd`, commande `dev.ps1 Balance`, rapport CSV généré et [rapport d'équilibrage](../EQUILIBRAGE-0.4.md) versionné. Le script d'exploration est exclu de l'exécutable.
- Guide joueur et export versionnés en 0.4.0. Les anciennes versions restent disponibles dans leurs propres dossiers.

## Vérifications exécutées

- **952 contrôles automatisés, aucun échec**, incluant connexité depuis chaque région, géométrie, achats, événements, climat, reproduction de parties et navigation synthétique.
- 288 parties de régression sur 24 départs et douze graines : 156 victoires, 132 défaites. Les 48 parties du test de scénarios produisent Standard 16/8 et Dégel 12/12 ; ces chiffres ne sont pas ceux du rapport d'équilibrage distinct.
- Une stratégie d'achats légaux gagnante vérifiée depuis chacun des 24 départs standards en difficile, graine 2042. Les trois difficultés de Dégel restent gagnables dans les tests ciblés.
- Exploration séparée de **909 parties** sur les graines 7, 42 et 2042 : 739 victoires et 170 défaites ; chaque départ autorisé et chaque difficulté ont au moins une victoire observée parmi les politiques testées.
- 93 323 pas dans cette exploration ; dernier passage sans rendu : moyenne 0,346 ms, maximum observé 1,347 ms par pas sur le poste de développement. Cette mesure n'est pas une mesure de fréquence d'affichage.
- Seize captures par rendu réel à 1280 × 720 et 1920 × 1080, revue indépendante sans défaut visuel bloquant. Le grand format conserve la composition logique par mise à l'échelle.
- Export release Windows testé depuis un chemin avec espaces et accents, sans ressources sources : 24 régions et boutons chargés, achats, standard victoire/défaite, phases/routes de Dégel, évolutions climatiques, difficultés, menus et démarrage graphique. Résultat `RUNTIME_SMOKE_OK`, sorties normales.
- SHA256 du binaire : `D5D0944D748716A61A828CF898D4FBE4D7DC7DBC9E6AC43023D8397563294F93`.
- Environnement : Godot 4.7.2 standard, Windows NT 10.0.26300.0, AMD Radeon RX 6650 XT.

## Limites et suite

Le réseau reste abstrait : les connexions ne sont pas encore classées en routes terrestres, aériennes et maritimes. Le volume final d'évolutions et d'événements, le tutoriel et la durée cible de 15 à 30 minutes ne sont pas atteints. Les politiques automatisées gagnent de façon fiable avec les trois évolutions standards ; une validation humaine et davantage de variété restent nécessaires avant de déclarer l'équilibrage final.

Aucun nouvel essai physique Windows n'est revendiqué. Les essais utilisent les événements synthétiques de Godot et le rendu réel. Vérifier sur un autre PC et avec des joueurs. Suivi visuel non bloquant : mettre en évidence les connexions de la région sélectionnée pour mieux lire la longue route Boréale–Orient.

**Prochain lot : J5, sauvegarde et chargement versionnés de la partie complète**, incluant régions, choix du scénario, difficulté, phase, événements actifs/déclenchés, achats, journal et état aléatoire. Tester l'égalité de l'état restauré et des journées suivantes, le fichier corrompu et la copie de secours.

Les sources et documents sont destinés à `main` après les contrôles. Le compte rendu de livraison confirme le commit et GitHub Actions. Binaire local : `build/windows-0.4.0/PandemicHorizon.exe`.
