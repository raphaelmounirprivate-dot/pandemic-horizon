# Point 03 — Premier lot J4, prototype 0.3

Date : 15 octobre 2026. Suite du [point 02](02-j3-reactions-evenements.md).

## Livré

- Catalogue JSON de scénarios et difficultés, validation avant toute modification du monde. Le standard normal conserve ses résultats antérieurs.
- Menu Standard/Dégel et Facile/Normale/Difficile ; effets recherche, détection et score visibles avant de démarrer. Dégel impose Boréale.
- Quatre phases au jour 0, 12, 28 et 55, avec températures fictives par paliers et effets mesurables sur la croissance et la recherche.
- Deux routes saisonnières, dont une connexion supplémentaire vers Orient ; ouverture au jour 12, tempêtes superposées et rétablissement après la dernière fermeture.
- Trois évolutions spécifiques avec coûts, effets et prérequis : Adaptation polaire, Mobilité saisonnière et Résilience climatique.
- Phase et effet climatique local affichés. Recommencer conserve les paramètres de la partie courante, même si les menus ont changé entre-temps.
- Exports versionnés dans `build/windows-<version>/`. L'ancien binaire était verrouillé par un processus ouvert : aucune fermeture forcée ni perte de partie n'a été imposée.

## Vérifications

- Suite automatisée : **461 contrôles, aucun échec**.
- Régression conservée des 72 parties de J3 : 42 victoires, 30 défaites.
- 48 parties supplémentaires couvrent les deux scénarios, trois difficultés et huit graines : Standard 8 victoires/16 défaites ; Dégel 4/20 avec la politique d'achats automatique de ce lot.
- Trois parcours ciblés de Dégel avec des achats légaux, graine 2042, gagnent respectivement en Facile, Normale et Difficile. Ces cas prouvent la possibilité observée, pas l'équilibrage humain.
- Vérification de l'ordre des phases, ouverture au jour 12, tempêtes aux jours 28/31, absence de réouverture prématurée, rétablissement au jour 39, mobilisation au jour 55, effets réels des évolutions et difficultés, isolation entre parties et rejeu déterministe.
- Parcours synthétique du menu : sélection des scénarios/difficultés, départ imposé, lancement, retour au départ libre et redémarrage avec les paramètres de la partie.
- Seize captures OpenGL Compatibility à 1280 × 720 et 1920 × 1080. Revue indépendante : aucun défaut visuel bloquant. Le panneau des six évolutions est défilant et suit le focus.
- Export release autonome testé depuis un chemin avec espaces et accents : standard victoire/défaite, phases et routes de Dégel, achats climatiques, difficulté, redémarrage et démarrage graphique. Marqueur `RUNTIME_SMOKE_OK`, sorties normales.
- SHA256 du binaire 0.3.0 : `89FD768F41EA05746806816EE7A27F7033607F543D81ADE27BBE57BE6F334D3C`.
- Environnement : Godot 4.7.2 standard, Windows NT 10.0.26300.0, AMD Radeon RX 6650 XT.

## Limites et reprise

J4 est partiel : la carte reste volontairement sur six régions pour valider les règles ; la cible de 24 régions et le volume final d'évolutions/événements ne sont pas livrés. Les sauvegardes et le tutoriel restent au jalon J5. Aucun essai physique Windows supplémentaire ni test auprès de joueurs n'est revendiqué ; la limite d'outil du point 02 reste applicable. Vérifier notamment le parcours réel vers les évolutions climatiques dans le panneau défilant.

Prochain développement : étendre et valider les données de la carte vers 24 régions, puis rééquilibrer les deux scénarios sur cette carte avant la persistance complète. Conserver les tests des fermetures indépendantes et ajouter des tests de lisibilité de la carte étendue.

Les sources et documents sont destinés à `main` après les vérifications. Le compte rendu de livraison confirme le commit et GitHub Actions. Le binaire demeure local, dans `build/windows-0.3.0/`.
