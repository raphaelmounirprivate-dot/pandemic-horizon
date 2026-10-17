# Point 22 — Actualités, historique et bilan, prototype 0.17

Date : 17 octobre 2026. Base : `3c6b2fa`. Lot D : EVT-01, EVT-02, STA-01 et STA-02.

## Réalisation

« Monde [F3] » ouvre en pause un écran de consultation depuis la partie ou le bilan : situation actuelle, courbes de population cumulée touchée et de remède, achats datés, effets courants avec leur durée et actualités réelles en ordre récent. F3 ou Échap revient à l'écran précédent ; l'aide F1 revient aussi correctement. Le journal compact en jeu est cliquable et son infobulle reprend les dernières annonces.

Le modèle observe une mesure entière par journée (population, cure au centième de pourcentage, points et détection), limitée aux 2 048 dernières journées, et les dates des achats réussis. Ces observations ne sont jamais utilisées pour calculer la simulation ou tirer du hasard.

## Sauvegardes et références

Format 4 conservé, avec champs optionnels `history` et `purchase_history`. Validation des bornes, conservation de population, ordre des journées, progression monotone des cumulés et cohérence des achats. Les valeurs JSON sont normalisées en entiers à la lecture. Sans ces champs, aucun passé n'est inventé : l'observation reprend au prochain jour ou achat réel. Un exécutant ancien ne garantit pas la conservation de ces nouveaux champs.

Les comparaisons avec les snapshots historiques restent exactes sur tout l'état du modèle. Elles excluent uniquement les deux nouveaux champs d'observation, absents des vrais exécutables anciens ; aucun snapshot n'a été régénéré. Les nouvelles reprises sont testées avec leur historique complet, et les fichiers historiques restent lus sans réécriture.

## Vérifications

2 692 contrôles passants après intégration, dont trente contrôles ciblés de l'historique et de la navigation. Dix-huit captures natives couvrent départ, partie en cours, décision en attente, victoire, défaite et ancien fichier sans historique, aux trois dimensions exactes.

Revue : seul doublon du résumé logistique dans les effets à corriger ; suppression de cet ajout lorsqu'il est déjà présent. Verdict `ship` limité à cette correction, confirmée aux trois tailles. Export autonome, smoke test et démarrage graphique sans erreur. SHA-256 : `43408BE6F98BA1FFC3D58A4BF0DA53940C5A707545E49B55C2DE08CD24C8BE48`.

## Sauvegarde et suite

Commit, bundle Git vérifié et archive des sources à créer avant le lot E. Essais physiques et joueurs non réalisés. Suite : identité d'agent, fiches de scénarios, catalogue enrichi optionnel et comparaison des stratégies.
