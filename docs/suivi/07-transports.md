# Point 07 — Transports, prototype 0.7

Date : 16 octobre 2026. Suite du [point 06](06-j5-tutoriel-aide.md).

## Livré

- `data/transports.json` attribue un type unique et bidirectionnel aux 38 liaisons standards : 22 terrestres, 8 aériennes et 8 maritimes. Dégel ajoute une neuvième maritime ; ses deux routes saisonnières sont maritimes.
- Profils d'échange fictifs : terrestre ×1, aérien ×1,2, maritime ×0,8. Ils se multiplient avec Mobilité, le bonus saisonnier et les événements du type concerné. Les fermetures conservent la priorité ; les imports ont toujours un minimum d'un après troncature sur une route ouverte éligible.
- Standard : contrôles aériens aux jours 40–47, échanges aériens ×0,6 ; retards portuaires aux jours 45–51, maritimes ×0,7. Dégel : congestion maritime aux jours 34–39, ×0,5. Ces effets n'affectent pas les autres types et expirent sans modifier les profils de base.
- Validation avant démarrage : profil absent/invalide, coefficient non fini, liaison inconnue, doublon inversé, couverture incomplète ou route arctique non maritime rejetés sans mutation du monde.
- Carte : trait plein terrestre, tirets aériens, points maritimes ; croix ambre pour les fermetures. Résumé régional des liaisons ouvertes sur leur total. F1 → Transports détaille destinations, type, état et coefficient de transport, distinct de Mobilité et du bonus saisonnier.
- Sauvegardes 0.7 dans `user://saves/transports-1`, avec empreinte des cinq fichiers de données. Les parties 0.6 restent dans l'ancien dossier et se jouent avec l'exécutable 0.6 ; aucune migration ni écrasement automatique. Le tutoriel conserve ses fichiers d'essai séparés.
- Export `build/windows-0.7.0/PandemicHorizon.exe`, guide et licences. Les anciennes versions restent dans leurs dossiers.

## Vérifications

- **1 287 contrôles automatisés, zéro échec**, dont 83 contrôles de transports et la régression du tutoriel et des sauvegardes.
- Imports mesurés sur une seule journée depuis 10 000 actifs : 10 terrestres, 12 aériens, 8 maritimes. Combinaison maritime ×0,8, Mobilité ×3 et saison ×2 : 48 imports. Fermeture prioritaire, deux ralentissements cumulés, expiration de chaque cause et restauration du coefficient de base vérifiés.
- Reprise exacte de quarante journées après sauvegarde pendant les effets de transport de Standard et Dégel, comparant régions, remède, RNG et effets actifs.
- Régression exploratoire : 288 parties, 157 victoires et 131 défaites. Le test de scénarios conserve Standard 16/8 et Dégel 12/12 ; ces parcours sont distincts du rapport ci-dessous.
- Quarante-deux captures réelles à 1280 × 720 et 1920 × 1080. Revue indépendante : **ship**, aucun correctif matériel demandé. Le panneau des évolutions peut défiler, avec suivi du focus. PRODUCT.md actualisé ; DESIGN.md et son sidecar conservés. Le grand format est une mise à l'échelle de la composition logique.
- Export autonome : ressources de transport chargées, profil maritime/aérien et ralentissement aérien vérifiés, standard victoire/défaite, phases de Dégel, persistance, six exercices, aide et démarrage graphique. `RUNTIME_SMOKE_OK`, depuis un chemin contenant espaces et accents.
- SHA256 : `226F486139BA636CFDAFF7D711B8F5EF055596941730D9A7AE37AD47C2822627`.
- `git diff --check` réussi. Le compte rendu confirme le commit poussé et GitHub Actions ; aucun binaire n'est publié par ce workflow.

## Exploration d'équilibrage 0.7

Commande : `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 Balance`. Même méthode que le [rapport 0.4](../EQUILIBRAGE-0.4.md) : graines 7, 42 et 2042 ; 24 départs standards, Boréale imposée pour Dégel ; quatre politiques standards et cinq pour Dégel, achats avec points normalement gagnés. CSV généré dans `build/qa/balance.csv`.

| Scénario | Difficulté | Parties | Victoires | Défaites | Jours |
| --- | --- | --- | --- | --- | --- |
| Standard | Facile | 288 | 273 | 15 | 74–158 |
| Standard | Normale | 288 | 222 | 66 | 75–132 |
| Standard | Difficile | 288 | 216 | 72 | 75–119 |
| Dégel | Facile | 15 | 15 | 0 | 82–120 |
| Dégel | Normale | 15 | 12 | 3 | 82–111 |
| Dégel | Difficile | 15 | 12 | 3 | 82–97 |

Total : 909 parties, 750 victoires, 159 défaites, 92 999 pas. Chaque départ autorisé et difficulté possède une victoire observée parmi les politiques testées. Les transports modifient les trajectoires mais les politiques d'achats testées restent très efficaces ; ce résultat ne prouve pas un équilibre final. Le passage a été exécuté en parallèle de tests, donc ses temps par pas ne servent pas de comparaison de performance isolée.

## Suite

Enrichir les évolutions par type de transport avec des choix et des compromis mesurables. Définir la compatibilité des sauvegardes avant toute nouvelle modification des données. Les transports restent des liaisons abstraites sans simulation individuelle des véhicules ; durée cible, validation humaine, ressources finales et release 1.0 restent à réaliser. Essai physique souris/clavier et autre PC Windows toujours à organiser : les parcours automatiques injectent des événements Godot.
