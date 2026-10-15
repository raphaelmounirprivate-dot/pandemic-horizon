# Point 01 — Prototype 0.1

Date : 15 octobre 2026.

## Livré dans les sources

- Projet Godot 4.7.2 standard, menu, choix du départ, paramètres de plein écran et profil d'export Windows.
- Simulation de six régions, diffusion par connexions, remède, population conservée, graine reproductible et score.
- Partie complète : pause, trois vitesses, sélection des régions, journal, bilan et redémarrage.
- Trois achats uniques avec coûts et effets affichés. Première partie de J3 ; réactions et événements pas encore implémentés.
- Scripts PowerShell de préparation et de vérification ; workflow GitHub pour l'import et les tests.

## Vérifications de développement

- Import Godot et suite automatisée : 188 contrôles, aucun échec.
- 72 parties automatisées : 50 victoires et 22 défaites. Ce résultat couvre les cas de test et ne valide pas l'équilibrage humain.
- Rendu réel OpenGL Compatibility sur AMD Radeon RX 6650 XT : menu, jeu, paramètres et bilan capturés à 1280 × 720 et 1920 × 1080.
- Un débordement des commandes de jeu à la résolution minimale a été corrigé puis les écrans recapturés.
- Export Windows release avec ressources embarquées généré ; binaire exécuté depuis `build/Essai Windows été/`, sans charger le projet source.
- Test automatisé du binaire : achats, victoire, défaite, redémarrage, paramètres et menu ; marqueur `RUNTIME_SMOKE_OK` et sortie normale. Démarrage graphique OpenGL également vérifié.
- Environnement observé : Windows NT 10.0.26300.0, Radeon RX 6650 XT. Pas encore d'essai sur un autre PC.
- Empreinte SHA256 du binaire testé : `0BEB2AAE429F63404CDD7381C4DD8D82B83F3125FDC6CBB0FCC0FAC439FDAC93`.
- Revue indépendante des huit captures et du code d'interface : aucun défaut bloquant relevé pour le prototype 0.1.
- Publication GitHub : la vérification du push et des SHA est consignée dans le compte rendu de livraison ; aucun binaire n'est inclus dans Git.

## État des jalons

J0 à J2 : fondation, simulation et boucle complète livrées, vérifiées automatiquement et sur export Windows local. Le parcours physique complet souris/clavier et le test sur un autre PC restent à faire. J3 : trois évolutions simples seulement. J4 à J7 restent à faire.

## Limites connues

- Carte schématique et paramètres provisoires ; parties courtes, sans validation auprès de joueurs.
- Une difficulté et un scénario standard ; pas encore de phases climatiques ni de fermetures de routes.
- Pas de sauvegarde de partie ; seul le réglage de plein écran est stocké.
- Les essais automatiques du contrôleur ne remplacent pas un parcours physique complet souris/clavier.
- Améliorations non bloquantes relevées en revue : indiquer la vitesse choisie pendant la pause et renforcer l'aspect des évolutions acquises. Vérifier aussi le plein écran et tout le parcours Tab/Maj + Tab en session réelle.

## Prochaine action

Commencer DEV-08/DEV-09 : prérequis, données d'évolutions et événements avec durée. Tester plusieurs effets simultanés sur une route avant d'intégrer les tempêtes de Dégel 2042.
