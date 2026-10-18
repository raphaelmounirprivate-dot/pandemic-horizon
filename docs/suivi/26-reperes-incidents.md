# Point 26 — Repères des incidents, candidat 0.21

Date : 17 octobre 2026. Base : `f78f28a`. Suite de la lecture des aléas 0.20.

## Réalisation

Présentation en lecture seule dans `scripts/ui/incident_view.gd`. Les seuls aléas actifs fournissent les compteurs et les repères : tempête sur le milieu de sa vraie courbe maritime, séisme et reprise régionale près de leur région. Les incidents mondiaux restent nommés « Monde » dans les listes ; aucune localisation fictive pour les changements de recherche ou transports mondiaux.

F4 ou Local parcourt les incidents locaux actifs : zoom minimum ×1,8, déplacement borné, contexte régional et anneau clair autour du repère ciblé. Le repère maritime se clique et se survole ; les régions gardent leurs cibles de 44 px et leurs infobulles complétées. La portée, l'effet appliqué, les jours restants et la fin exclusive sont indiqués. Aucun nouveau contrôle d'achat ni menu déroulant.

Les aléas sont présentés en tête des effets actifs, également dans Monde/F3. Le ciblage se conserve en mémoire au retour de cet écran ; les repères se reconstruisent après chargement et disparaissent à expiration. Les anciennes parties classiques gardent leur présentation sans commande Local.

## Vérification

3 444 contrôles réussis, dont 129 ciblés : clic et F4 synthétiques, positions après zoom, infobulles, compteurs local/mondial, refus des événements futurs ou mondiaux, expiration, reprise et état du modèle/RNG strictement identique avant/après consultation. Aucun JSON de règles ni format de sauvegarde modifié. Les références historiques restent exactes.

Vingt-quatre captures natives exactes : absence, décision en attente, tempête, séisme, panne mondiale, occasion favorable, ciblage et Monde ; trois résolutions. Revue indépendante `ship`. Limite acceptée : rayon de clic maritime 16 pixels logiques, avec alternative F4/Local ; les cibles régionales restent 44 px. Le petit panneau des effets défile, Monde fournit la lecture complète. Aucune validation physique/DPI ni étude avec des joueurs déduite de ces captures.

## Livraison

Export autonome, tests de ressources et lancement graphique à consigner après vérification. Commit puis bundle/sources vérifiés et archive Windows versionnée, sans effacer les anciens exports. Essais réels à compléter dans TESTS-JOUEURS.md avant validation 1.0.

Clôture le 18 octobre 2026 : documentation mise à jour ; export depuis un commit propre, BUILD.json lié au binaire et à son SHA-256, rejet des exports périmés. Cinq contrôles de provenance passent. La CI construit, vérifie et conserve l’archive Windows. Les identifiants finaux figurent dans les manifestes de sauvegarde et de livraison.
