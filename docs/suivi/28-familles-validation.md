# Point 28 — familles et validation après l'audit

Candidat 0.23 : Diffusion/Discrétion/Résilience, légende, ascendance transitive et fiche complète comparant les coefficients. Métadonnées de présentation séparées des règles : coûts, prérequis, exclusions, simulation et formats de sauvegarde inchangés.

Menu, paramètres et bilan extraits de main.gd : 1 089 lignes contre 1 317 dans le constat initial. Les vues accèdent encore au contrôleur : première étape de découpage, pas refonte globale achevée.

Revue indépendante : deux corrections demandées (fiche complète et qualification des coefficients), appliquées et jugées résolues. La régression a ensuite révélé un dépassement dans deux états combinés : suivi arctique classique, et 24 compétences avec choix logistique. Espacements structurels corrigés, cibles de 44 px conservées ; captures et vérification supplémentaires demandées.

Les nouveaux contrôles vérifient familles sans doublon, ascendance, coefficients, non-mutation, qualification des états et callbacks. Les sauvegardes réactives sont comparées à la partie originale aux frontières du choix et de ses effets, ainsi que tous les dix jours sur 45 trajectoires. La 0.22 avait en plus vérifié les reprises quotidiennes : 19 422 contrôles réussis au total. Résultat complet final 0.23 : 6 061 contrôles réussis, zéro échec, plus cinq contrôles de provenance.

La 0.22 publiée au 2b65f07 possède checkpoint, archive Windows et CI réussie 39148411239. La 0.23 suit la même clôture par commit propre, export identifié, vérification, archive et checkpoint.

L'audit 05-audit-2026-10-18.md a été réécrit ; son état initial est conservé en archive. Prochaine étape : trois sessions exploratoires selon docs/tests-joueurs/README.md, puis corrections fondées sur les observations. Aucun essai réel, DPI ou second PC déclaré terminé.

Recontrôle des débordements : 2 972 contrôles ciblés réussis ; vingt-sept captures finales incluant suivi arctique classique et choix en attente avec 24 compétences. Verdict de la revue sur les corrections et ces états : résolus, disposition ship. Le kit joueurs et la matrice de compatibilité sont inclus dans le ZIP Windows.

Réserve constatée le 18 octobre : binaire original cf733b3 testé (smoke/graphique), ZIP et bundle vérifiés, mais copie accentuée et restauration du script bloquées. Les anciens manifestes signalent cette limite.

Recontrôle du 19 octobre : AVG avait mis le binaire de contrôle et le script en quarantaine (`IDP.HELU.PSD11`, `IDP.Generic`). Le script a pu être restauré depuis Git ; son blob est identique à HEAD, sa syntaxe est valide et les cinq contrôles de provenance passent. Le dépôt est redevenu propre et les contrôles smoke/graphique du chemin accentué réussissent. Les deux CI du commit e995e9f sont réussies ; archives historiques conservées.

L'utilisateur a précisé qu'AVG est désactivé. Les services en cours d'exécution ne prouvent pas une protection active : les tests ne valident pas l'absence de quarantaine après réactivation. L'agent n'a pas désactivé de protection ni ajouté d'exclusion. Fichiers rétablis et livraison fonctionnelle dans les conditions actuelles ; recontrôle AVG actif à réaliser avant de déclarer le blocage durablement résolu, puis sessions joueurs. Aucun essai humain ou second PC n'est déduit de ces contrôles.

Correctif d'empaquetage du même jour : les fichiers du kit joueurs déjà identiques sont conservés, et les copies nécessaires sont vérifiées par SHA-256. Le contrôle complet avait échoué sur la réécriture de resultats.csv malgré des empreintes identiques. Aucun coefficient, interface ou format de sauvegarde n'est modifié.
