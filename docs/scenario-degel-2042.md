# Scénario proposé : Dégel 2042

**Statut : implémenté dans le prototype 0.4 sur 24 régions, à éprouver auprès de joueurs.** Voir les [règles effectives](REGLES.md), le [rapport d'équilibrage](EQUILIBRAGE-0.4.md) et le [point de contrôle 04](suivi/04-j4-carte24.md). Les sauvegardes restent absentes ; leur critère ci-dessous est réservé au jalon J5.

## Situation initiale

En 2042, un dégel exceptionnel perturbe les routes commerciales et les infrastructures de plusieurs régions. Un agent entièrement fictif apparaît dans la zone arctique. Le joueur doit adapter son évolution à un monde dont les connexions et le climat changent pendant la partie.

## Objectif

Atteindre le seuil de propagation mondiale défini par le jeu avant que la recherche du remède soit achevée. Le seuil exact, le calcul du score et le rythme de recherche seront fixés lors des tests d'équilibrage. Le joueur doit pouvoir consulter ces valeurs dès le lancement d'une partie.

## Phases

| Phase | Changement | Conséquence de jeu prévue |
| --- | --- | --- |
| Isolement | Départ dans une région arctique | Peu de connexions ; avantage à l'adaptation au froid |
| Ouverture | Apparition de routes maritimes saisonnières | Nouvelles connexions entre régions |
| Instabilité | Tempêtes et perturbations des transports | Certaines routes deviennent temporairement indisponibles |
| Mobilisation | Coordination accrue des régions | La recherche du remède s'accélère |

## Évolutions spécifiques proposées

- **Adaptation polaire** : améliore la progression dans les régions froides.
- **Mobilité saisonnière** : augmente l'utilisation des routes ouvertes pendant le dégel.
- **Résilience climatique** : réduit les pénalités liées aux changements de température.

Ces améliorations seront exprimées en coefficients abstraits de jeu, avec coût et effets affichés. Elles ne décrivent pas des mécanismes biologiques réels.

## Critères de validation

- Le scénario modifie effectivement les connexions, événements et coefficients du moteur.
- Une interruption de transport a une durée déterminée et se termine correctement.
- Le journal affiche chaque changement important et sa conséquence.
- Une sauvegarde restaure la phase climatique et les routes actives.
- La victoire et la défaite restent possibles avec les mêmes règles annoncées au joueur.
- Les niveaux de difficulté changent la réponse du monde sans masquer leurs effets.
