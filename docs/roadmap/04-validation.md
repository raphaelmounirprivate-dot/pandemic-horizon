# Validation des lots et fiche de travail

## Avant de développer

1. Lire le dernier [point de suivi](../suivi/00-index.md), contrôler la branche et les modifications locales.
2. Choisir le lot et ses identifiants ; préciser ce qui sera livré et les choix encore ouverts.
3. Relever les états de référence nécessaires : début, partie avancée, choix en attente, route fermée et sauvegarde historique selon le périmètre.
4. Marquer les tâches en cours et consigner les décisions dans la fiche du lot.

## Pour considérer un lot terminé

- Critères du backlog vérifiés, avec preuves correspondant au résultat annoncé.
- Tests pertinents et régressions passants. Pour le jeu : `scripts/dev.ps1 Test` après préparation de Godot.
- Pour une modification visuelle : captures natives groupées à 1280 × 720, 1920 × 1080 et 2395 × 1060 ; vérifier aussi les états ajoutés par le lot.
- Vérifier pause, vitesses, aide, navigation clavier et sauvegardes quand le lot les touche.
- Pour un changement de règles : comparer mêmes graines/difficultés et consigner les contreparties avant d'ajuster des coefficients.
- Pour une livraison exécutable : export versionné, `scripts/verify-export.ps1`, contrôle du guide et des licences.
- Avant push : `git diff --check`, liste des fichiers incluse revue et commit explicite. Après push, distinguer synchronisation Git et résultat des tests GitHub.
- Mettre à jour backlog et point de suivi avec limites restantes. Un essai synthétique n'est pas un essai physique avec un joueur.

Une mise à jour limitée aux documents se vérifie par leurs liens, leur cohérence, leur diff et leurs statuts ; elle ne nécessite pas de réexporter le jeu.

## Modèle de fiche à copier

```markdown
# Lot <lettre> — <titre>

Statut : proposé / prêt / en cours / à vérifier / terminé / différé
Base : <version, branche, commit>
Tâches : <identifiants du backlog>

## Résultat attendu
<Action du joueur rendue possible ou plus compréhensible.>

## Périmètre et dépendances
<Livrable, données nécessaires, limites du lot.>

## Étapes
- [ ] Relever le comportement de référence.
- [ ] Réaliser les tâches retenues.
- [ ] Vérifier les critères de fin et les régressions pertinentes.
- [ ] Mettre à jour aide, documents et suivi concernés.
- [ ] Si livraison : vérifier export, commit, push et CI.

## Décisions
<Choix retenu, raison et effet sur les lots suivants.>

## Vérifications réelles
<Commandes, résultats, captures, essais et limites ; ne pas précocher.>

## Livraison et prochaine action
<Commit local, push, CI, exécutable : préciser chaque statut.>
```
