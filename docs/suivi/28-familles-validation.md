# Point 28 — familles et validation après l'audit

Candidat 0.23 : Diffusion/Discrétion/Résilience, légende, ascendance transitive et fiche complète comparant les coefficients. Métadonnées de présentation séparées des règles : coûts, prérequis, exclusions, simulation et formats de sauvegarde inchangés.

Menu, paramètres et bilan extraits de main.gd : 1 089 lignes contre 1 317 dans le constat initial. Les vues accèdent encore au contrôleur : première étape de découpage, pas refonte globale achevée.

Revue indépendante : deux corrections demandées (fiche complète et qualification des coefficients), appliquées et jugées résolues. La régression a ensuite révélé un dépassement dans deux états combinés : suivi arctique classique, et 24 compétences avec choix logistique. Espacements structurels corrigés, cibles de 44 px conservées ; captures et vérification supplémentaires demandées.

Les nouveaux contrôles vérifient familles sans doublon, ascendance, coefficients, non-mutation, qualification des états et callbacks. Les sauvegardes réactives sont comparées à la partie originale aux frontières du choix et de ses effets, ainsi que tous les dix jours sur 45 trajectoires. La 0.22 avait en plus vérifié les reprises quotidiennes : 19 422 contrôles réussis au total. Résultat complet final 0.23 : 6 061 contrôles réussis, zéro échec, plus cinq contrôles de provenance.

La 0.22 publiée au 2b65f07 possède checkpoint, archive Windows et CI réussie 39148411239. La 0.23 suit la même clôture par commit propre, export identifié, vérification, archive et checkpoint.

L'audit 05-audit-2026-10-18.md a été réécrit ; son état initial est conservé en archive. Prochaine étape : trois sessions exploratoires selon docs/tests-joueurs/README.md, puis corrections fondées sur les observations. Aucun essai réel, DPI ou second PC déclaré terminé.

Recontrôle des débordements : 2 972 contrôles ciblés réussis ; vingt-sept captures finales incluant suivi arctique classique et choix en attente avec 24 compétences. Verdict de la revue sur les corrections et ces états : résolus, disposition ship. Le kit joueurs et la matrice de compatibilité sont inclus dans le ZIP Windows.

Réserve finale de livraison : binaire original cf733b3 testé (smoke/graphique), ZIP et bundle vérifiés. Contrôle du chemin accentué bloqué localement ; restauration de scripts/package-windows.ps1 refusée par Windows. Le script intact reste commité, la suppression locale ne doit pas être commitée. Voir la réserve détaillée dans l'audit. Les manifestes locaux signalent la limite ; aucun essai physique de compatibilité n'est déduit des contrôles passés.
