# Point 27 — crises réactives et Double relais

Le profil facultatif tactics-0.22 complète crises-0.20 sans changer les anciennes parties. Ciblage régional au déclenchement, trois réponses à la première panne, sauvegarde 7 et contrainte Double relais dans Réseaux fragiles. Voir les notes 0.22 et le rapport EQUILIBRAGE-0.22-REACTIF.md.

Vérification initiale : 3 444 contrôles historiques, 15 978 nouveaux contrôles réussis. Reprise JSON quotidienne sur 45 parcours, coût exact, refus sans débit, expiration/cumul, échéance incluse, panne conservée et interface intégrée. Douze captures natives dans trois tailles ; revue indépendante : disposition ship sur cette extension. Aucun essai joueur réalisé.

La 0.21 est clôturée au commit 9018202 : checkpoint 0.21.0-9018202 et archive Windows vérifiés localement. Sa première CI a échoué sur le périphérique audio absent du runner après réussite des tests/export ; correction explicite Dummy en CI dans cette étape.

La sauvegarde de ce lot est créée à son commit propre avec scripts/checkpoint.ps1 ; l'export et l'archive portent ce même commit dans BUILD.json et VERSION.json.

Régression complète finale du lot : 19 422 contrôles, zéro échec. Les cinq contrôles de provenance PowerShell passent également.
