# Point 21 — Évolutions et achat explicite, prototype 0.16

Date : 17 octobre 2026. Base : `8ae3e88`. Lot C, EVO-01 à EVO-03.

## Réalisation

La grille complète reste intégrée. Les nœuds ont des symboles vectoriels et leurs relations de prérequis sont dessinées. Sélectionner un nœud ou le focaliser consulte sa fiche sans dépense. Le bouton séparé « Évoluer : nom · coût » est l'unique commande d'achat dans l'interface. Il devient indisponible si le budget, les prérequis, l'exclusion, le tutoriel ou l'état acquis interdisent l'achat.

Les acquisitions restent consultables. Le texte d'effet complet et le motif sont visibles dans la fiche avant l'action, et les libellés sous les nœuds conservent les états. Les coûts et règles restent inchangés. Au clavier, sélectionner avec Entrée focalise l'achat s'il est disponible ; une nouvelle activation distincte confirme. Le tutoriel explique cette séquence.

## Vérifications et sauvegarde

**2 662 contrôles, zéro échec.** 24 captures natives aux trois tailles exactes, dont objectif arctique et tutoriel. La première suite avait repéré un débordement avec l'objectif arctique : suppression du nom et du coût redondants de la fiche, conservés sur le bouton d'achat. Revue initiale `fix` : liens invisibles avant disposition, ambiguïté de sélection et motifs coupés. Ces corrections ont été vérifiées, puis le routage polaire a été rectifié pour montrer deux enfants du même parent. Verdict final `ship` au périmètre de ces corrections ; aucun essai physique ou joueur revendiqué.

Export 0.16 autonome, smoke test et démarrage graphique sans erreur. SHA-256 : `3B67366E281DC8EF3CD4826DD369B68504A711F6615D071172096B82372FC199`. Documentation et `git diff --check` vérifiés. Commit distinct et sauvegarde locale par `scripts/checkpoint.ps1` avant le lot D.

## Suite

Lot D : fil d'actualités, historique quotidien et courbes de bilan. Conserver les règles de simulation et ne pas inventer les dates manquantes des anciennes sauvegardes.
