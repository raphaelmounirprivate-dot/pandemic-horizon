# Point 02 — J3, prototype 0.2

Date : 15 octobre 2026. Suite du [point 01](01-prototype.md).

## Livré

- `data/evolutions.json` : trois évolutions, coûts, effets et prérequis. Mobilité exige Diffusion.
- `data/events.json` : seuils de détection, réaction de huit jours, coefficients du remède et quatre événements planifiés.
- `scripts/gameplay/content.gd` : validation des schémas, coûts, coefficients, références de régions/routes, durées, doublons et cycles de prérequis. Une validation refusée conserve la partie existante.
- Détection persistante par région ; réaction locale unique et temporaire. La première détection démarre le remède ; les suivantes le renforcent.
- Fermetures indépendantes sur une même route, ralentissements locaux et bonus de recherche. Les effets sont recalculés depuis la liste active et ne modifient pas les valeurs de base.
- Carte avec marqueur de route fermée ; panneau des effets, cibles et durées ; compteur de régions détectées ; raisons d'achat visibles ; vitesse affichée pendant la pause.
- Version du projet et de l'export portée à 0.2.0. Guide joueur mis à jour depuis `docs/GUIDE-JOUEUR.md` ; sa copie dans `build/windows/` est générée par l'export.

## Vérifications exécutées

- Import Godot et tests sans interface : **265 contrôles, aucun échec**.
- 72 parties sur six départs et douze graines : 42 victoires, 30 défaites. Cette exploration ne valide pas l'équilibrage humain.
- Tests dédiés : fermeture aux jours 18/22, première expiration au 26 sans réouverture, dernière expiration et réouverture au 32 ; remplacement d'une fermeture le même jour sans annonce trompeuse.
- Cumuls de ralentissements et bonus de recherche, expiration séparée, retour exact aux facteurs de base, réaction régionale unique, absence d'importation par une route fermée et reprise après réouverture.
- Parcours d'entrée dans le viewport : clics sur menu/carte/achats, refus de prérequis sans débit, acquisition, navigation Tab/Maj+Tab dans tous les boutons, Entrée, Espace, vitesse et Échap.
- Douze captures par rendu réel OpenGL Compatibility, à 1280 × 720 et 1920 × 1080. Revue indépendante : aucun défaut visuel bloquant pour J3.
- Export release Windows : test du binaire autonome, JSON embarqués, prérequis, détection, événements superposés et expiration, bonus du remède, victoire/défaite, redémarrage et démarrage graphique. Résultat : `RUNTIME_SMOKE_OK` et sorties normales.
- SHA256 du binaire : `61976245F43A3701AECB9843B909BF14896159C806BD8A89D8E03182AD8D3359`.
- Environnement : Godot 4.7.2 standard, Windows NT 10.0.26300.0, AMD Radeon RX 6650 XT.

## Limites et essai réel à compléter

L'essai par contrôle Windows n'a pas pu démarrer : l'outil a renvoyé `Computer Use app approval timed out`, puis `computer-use request timed out: launch_app` lors d'une seconde tentative sur le binaire 0.2. Aucune ouverture par cet outil n'a été confirmée. Les événements synthétiques et captures réussis ne sont donc pas présentés comme un parcours physique clavier/souris complet.

Sur le binaire, vérifier encore : choix de départ au clavier, acquisition à la souris, Tab/Maj+Tab dans les panneaux défilants, plein écran et retour en fenêtre, défilement de l'historique du bilan et fermeture. Le défilement du journal au clavier n'a pas de configuration de focus explicite ; c'est une amélioration non bloquante relevée en revue.

Les sauvegardes et Dégel 2042 restent absents. Les événements du standard suivent des jours fixes ; leurs mécanismes sont prêts à être réutilisés pour les phases du scénario. Trois évolutions et quatre événements restent un contenu de prototype, inférieur à la cible 1.0.

## Publication et prochaine action

Les sources et documents de ce lot sont destinés à `main` après les contrôles. Le compte rendu de livraison confirme le commit, les SHA et le résultat GitHub Actions ; les binaires restent locaux.

Prochain lot : J4, données de scénarios et phases de Dégel 2042, avec annonces d'ouverture des routes arctiques et interruptions temporaires utilisant les effets indépendants déjà testés. Augmenter le contenu progressivement et reprendre l'équilibrage après introduction des nouveaux parcours.
