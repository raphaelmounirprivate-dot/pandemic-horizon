# Point 15 — Analyse des décisions logistiques

Date : 16 octobre 2026. Base : `21723e4`, branche `main`. Jeu conservé en 0.11.0.

## Périmètre

Comparer désactivation, maintien neutre, soutien et limitation à difficulté, graine, ordre d'achat et financement identiques. Mesurer séparément victoire, Relais arctiques, progression du remède, choix réellement appliqué, budget et dates d'achat. Aucun point offert, aucune fin retardée artificiellement.

Deux séries : achats habituels (`ordinary`) et réserve commune (`reserve`). Dans la seconde, les quatre variantes refusent du J20 au J27 un achat qui ferait passer le solde sous 6 points. Cette restriction finance réellement le soutien au J28, mais peut aussi retarder les achats des témoins : les contrastes se lisent au sein de chaque série. Au début de chaque journée, tenter d'abord le choix en attente, puis le premier achat manquant, puis avancer. Un soutien sans fonds peut être retenté J29/J30 ; au J31, maintien automatique. La commande distingue intention et application.

Échantillon : 1 080 parties, 270 groupes de quatre ; Boréale, Dégel, trois difficultés, graines 7/42/2042 et quinze politiques. Les quatre états avant choix sont identiques dans chaque groupe. Maintien et désactivation ont la même simulation complète, les mêmes achats et relevés ; seules décision et annonces sont exclues de l'empreinte. Les événements, populations, points, remède, objectifs et RNG restent comparés. Les budgets et tentatives sont reconstruits séparément contre les règles du monde.

## Résultats et coût des 6 points

Chaque ligne porte sur 135 parties, mêmes politiques/graines/difficultés dans sa série.

| Financement / variante | Victoires | Relais réussis | Soutien appliqué |
| --- | ---: | ---: | ---: |
| Habituel / désactivée ou maintien | 124 | 117 | — |
| Habituel / soutien | 118 | 99 | 45 |
| Habituel / limitation | 126 | 117 | — |
| Réserve / désactivée ou maintien | 126 | 117 | — |
| Réserve / soutien | 112 | 99 | 135 |
| Réserve / limitation | 126 | 117 | — |

Sans réserve, soutien appliqué au J28 dans 27 cas et au J30 dans 18 ; les 90 autres intentions finissent en maintien gratuit. Avec réserve, 135 soutiens au J28, soit 810 points réellement dépensés. Les 6 points correspondent à deux gains périodiques de 3 points ; dans ces politiques, ils décalent souvent un achat de dix jours. Par rapport au témoin de la même série, les soutiens financés retardent 390 acquisitions et en suppriment six avant la fin principale ; aucune acquisition n'est anticipée. Ces nombres comptent des acquisitions, pas des parties.

La contrepartie est observable : dans la série avec réserve, 72 paires à deux réussites atteignent les Relais plus tôt avec soutien, 27 plus tard. Parmi les 99 paires à deux réussites, le décalage moyen est +0,36 jour ; les 18 Relais perdus restent exclus de cette moyenne, et sont affichés séparément. Le soutien fait perdre 14 victoires et 18 Relais, sans nouveau succès de résultat dans cette cohorte. En achats habituels, 18 des 99 paires à deux réussites accélèrent les Relais, 81 restent identiques ; six victoires et 18 Relais sont perdus.

La limitation gratuite apporte deux victoires supplémentaires en achats habituels, aucune perte et aucune variation du nombre de Relais. Elle retarde les Relais d'un jour dans trois paires et ralentit légèrement la victoire dans les paires à deux victoires. Le [rapport généré](../EQUILIBRAGE-0.11-DECISIONS.md) donne tous les contrastes, le remède aux mêmes dates, les résultats par politique/difficulté et les dates d'achats. Le remède final moyen ne compare pas une durée identique : les parties se terminent à des jours différents.

## Décision d'équilibrage

Conserver pour ce lot coût 6, mer ×1,50, remède ×1,15 et douze journées ; conserver aussi limitation et maintien. Le soutien apparaît défavorable si l'objectif est uniquement de maximiser les victoires ou le nombre de Relais réussis dans cet échantillon. Il permet toutefois d'atteindre certains Relais plus tôt : les résultats ne démontrent donc pas une domination sur toutes les mesures. Ce lot établit ce compromis et ses coûts, sans présenter 6 points comme un prix optimal.

Aucun nouveau coefficient n'a été testé ici : réduire le coût, déplacer la fenêtre ou amplifier la mer auraient des effets différents, notamment sur les dates d'achats et la compatibilité. Les mesures de politiques complètes ne permettent pas de sélectionner l'un de ces changements avec fiabilité. Un ajustement exige une comparaison contrôlée des candidats et des références 0.11 figées avant changement ; ne pas annoncer un équilibrage validé auprès de joueurs. Le prochain lot pourra isoler coût et contrepartie à partir de cette base reproductible.

## Fichiers et reproduction

- `scripts/analysis/decision_comparison.gd` : simulations, contrôles, statistiques et rapport.
- `scripts/balance_decisions.gd`, `dev.ps1 BalanceDecisions` : cohorte complète, CSV et Markdown sous `build/qa/`.
- `tests/test_decision_comparison.gd` : budget, financement, neutralité et refus des incohérences.
- `docs/EQUILIBRAGE-0.11-DECISIONS.md` : rapport conservé ; CSV brut local `build/qa/balance-decisions.csv`.
- `export_presets.cfg` : exclusion du nouvel outil de l'exécutable. Données, simulation distribuée, interface et format de sauvegarde inchangés.

## Vérifications

- Import Godot 4.7.2 réussi.
- `BalanceDecisions` : **1 080 parties, 270 groupes complets, aucun écart du maintien**. Reconstitution du budget et des tentatives réussie pour toute la cohorte.
- Suite complète : **2 183 contrôles, zéro échec**. La nouvelle suite compte 57 contrôles ciblés ; les références 0.7–0.10 et parcours synthétiques existants continuent de passer.
- Export 0.11.0 réussi, outil de mesure exclu du paquet. `verify-export.ps1` : exécutable copié seul dans un chemin avec espaces et accents, `RUNTIME_SMOKE_OK`, puis démarrage graphique OpenGL sur AMD Radeon RX 6650 XT.
- SHA256 de l'exécutable réexporté : `9CFFBFAE8EFECBA3A7D1C4A36C222962F63BEEFB5C91DF308EB9E32DE6BB1C7F`.
- Rapport conservé identique au généré : SHA256 `7E8590BF9C045F487A2A9F1E67975C1DD4B7F11DBEECB649E2A147A36EF62774`. CSV brut local : `A57745461178FA7A007C47E8174D4842FE4C7A6AD27212EE7204241B4DCFF2B4`.
- `git diff --check` réussi. Le compte rendu de livraison confirme le commit, le push et GitHub Actions.

## Limites et suite

Quinze politiques de même poids et trois graines ; ce ne sont pas des taux de réussite humains. Plusieurs dates se répètent. Les compteurs des Relais sont plafonnés et figés ; ils ne mesurent pas le trafic total. Les effets du coût, de la mer, du remède et des dates sont combinés dans ces contrastes de politiques. Aucun essai physique ou nouveau joueur dans ce lot.

Prochaine étape : comparer séparément des coûts candidats avec le même calendrier de décision, puis la contrepartie du remède, en figeant d'abord les sauvegardes 0.11 ; retenir un changement seulement s'il améliore le compromis recherché. Organiser un essai humain sur la compréhension des choix.
