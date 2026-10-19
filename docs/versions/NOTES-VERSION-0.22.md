# Notes de version 0.22 — crises réactives

Profil facultatif distinct `tactics-0.22`, sauvegarde 7. Les profils 4, 5 et 6 gardent leurs règles.

- Les aléas régionaux de croissance choisissent au déclenchement un foyer actif possédant encore des sains, avec un hasard indépendant. La cible résolue est sauvegardée. Les catastrophes de route et les effets mondiaux gardent leur portée.
- La première panne aérienne propose trois réponses intégrées : détour (3 points, air ×1,35), subir (gratuit, aucun ajout), occasion (1 point, air ×1,70 et remède ×1,18). Choix pendant trois journées ; sans réponse, subir. Les effets payants durent six jours dès le lendemain, se multiplient avec les autres effets et ne rouvrent aucune route.
- Réseaux fragiles ajoute Double relais obligatoire : depuis Centrale, 6 000 unités vers Méridien ET Savane avant J60 inclus. Une échéance manquée provoque la défaite ; réussir les relais ne dispense pas des 90 % avant le remède.
- Format 7 : cibles, réponse, coûts et objectif conservés, rejets des données incohérentes. F2 et pause à l'ouverture de la réponse.
- La vérification graphique en CI sélectionne explicitement Dummy pour l'audio : le runner hébergé n'a pas de périphérique WASAPI. La vérification locale conserve son périphérique réel ; aucune erreur de moteur n'est ignorée.

Mesures : protocole apparié de 30 parties, 48/76 incidents régionaux complets sans occasion de croissance dans le profil historique, 0/76 en réactif. Voir EQUILIBRAGE-0.22-REACTIF.md. Ce résultat décrit une possibilité d'effet, pas l'intérêt ressenti ni un équilibre universel. Essais humains toujours à réaliser.
