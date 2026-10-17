# Règles du prototype 0.17

## Présentation du monde et des flux

Les positions géographiques de l'interface sont distinctes des coordonnées historiques des données. Les 24 régions, 38/39 connexions, populations et règles restent identiques. Le fond terrestre Natural Earth est purement visuel. Les points et halos rouges utilisent la proportion `actifs + retirés` par région ; leur nombre et leur taille sont des illustrations, pas une localisation de personnes. Les marqueurs numérotés et leurs infobulles permettent la sélection des régions fictives.

À chaque pas, `latest_flows` observe les échanges effectivement ajoutés au modèle : source, destination, unités, mode et jour. Cette observation ne participe à aucun calcul et n'est pas sauvegardée. Une flèche exige le même jour et une route ouverte. L'horloge visuelle est indépendante du RNG et ne progresse qu'en lecture ; la pause la fige. Une partie chargée réaffiche les foyers immédiatement, puis les flux au prochain pas. Les évolutions sont toutes visibles en grille et la décision logistique apparaît sous la carte, en pause au J28.

## Décision Logistique sous tension

Profil 0.12 : soutien à 3 points ; profil historique 0.11 : 6 points, autres effets identiques. Le monde conserve sa définition de décision depuis le démarrage ou le chargement. Format 4 : champ `decision_profile` vide sans événement, sinon `0.11` ou `0.12`. Les sauvegardes de format 3 reconnues reçoivent le profil 0.11 sans changer le budget, le choix ou son futur ; les formats 1/2 gardent l'absence de décision. Le profil, l'état et les points doivent être cohérents. Les anciennes règles sont figées dans `data/decisions-0.11.json`, inclus dans l'empreinte de contenu courante.

Activation facultative avant une nouvelle partie Dégel, désactivée par défaut. Catalogue `data/decisions.json`. Déclenchement au J28, choix manuel possible J28–30 inclus ; J31 applique automatiquement le maintien neutre. L'interface interrompt la simulation au déclenchement et revient toujours en pause.

Soutenir les ports coûte 3 points, multiplie les échanges maritimes par 1,50 et la vitesse du remède par 1,15. Limiter les échanges est gratuit, mer ×0,65 et remède ×0,85. Maintenir la situation est gratuit et sans effet supplémentaire. Un choix unique, irréversible ; refus sans mutation si les points manquent. Les deux options actives durent douze pas journaliers à compter du lendemain : sélection J28 → J29–40, expiration J41. Les facteurs se multiplient avec les événements et spécialisations ; les fermetures restent prioritaires. Aucun effet sur la terre ou l'air, aucun bonus direct de score ou de points.

État sauvegardé en format 4 : dictionnaire vide si désactivé, sinon `status`, `choice`, `day`, `reason`. États : `scheduled`, `pending`, `active`, `expired`, `resolved`, `cancelled`. Le coût entre dans l'invariant des points acquis moins achats et choix. Si la partie finit avant le déclenchement, annulation ; pendant l'attente, maintien gratuit. Les sauvegardes 0.7–0.10 reconnues restent sans décision rétroactive ; leurs objectifs existants sont conservés. La validation contrôle l'état et la chronologie, sans rejouer toute l'histoire du fichier.

Ces règles sont provisoires et abstraites. Elles ne représentent aucun modèle biologique réel.

- 24 régions fictives, population constante de 3 530 000 personnes, 38 connexions bidirectionnelles dans le standard, pouvant être fermées temporairement. Dégel ajoute une 39e connexion.
- 200 cas actifs au départ ; chaque personne passe de saine à active puis retirée, sans réinfection. Le cumul touché est actif + retiré.
- Une journée expire les effets terminés, active les événements planifiés et vérifie les seuils de détection. Ensuite elle lit un instantané commun des 24 régions : échanges par routes ouvertes, progression locale, retrait, puis remède, points et fin de partie. Aucun transfert de population lors des échanges : les connexions produisent des cas locaux. La détection utilise les actifs de la veille, avant la progression du jour.
- Progression locale de base : 22 % des actifs, modulée par un tirage entre 0,92 et 1,08. Retrait : 2,5 % des actifs, au moins un lorsque des cas existent. Les entiers sont tronqués et les nouveaux cas bornés par la population saine.
- Sur une connexion ouverte, si la source compte au moins 1 000 actifs, les imports valent `max(1, entier(actifs × 0,001 × Mobilité × bonus saisonnier × profil transport × effets du type × spécialisation du type))`. Le minimum d'un s'applique après multiplication et troncature. L'ordre des opérations 0.7 est conservé, puis la spécialisation s'applique en dernier. Les sains disponibles bornent ensuite les nouveaux cas.
- `data/transports.json` classe les 38 liaisons standards : 22 terrestres (×1), 8 aériennes (×1,2), 8 maritimes (×0,8). Dégel ajoute une neuvième maritime. Les deux routes saisonnières sont maritimes. Chaque arête a un type unique et symétrique ; références, doublons, couverture du réseau et bornes des coefficients sont validés avant mutation du monde.
- Graine par défaut : 2042. Les sauvegardes conservent la graine et l'état aléatoire sur 64 bits, ainsi que la valeur exacte du remède. Le chargement reprend en pause avec les mêmes journées suivantes. Voir le [guide](GUIDE-JOUEUR.md#sauvegarder-et-reprendre).
- 8 points au départ, puis 3 tous les cinq jours. Trois achats de base définis dans `data/evolutions.json` : Diffusion (12 points, +8 points de croissance), Mobilité (10 points, échanges ×3, exige Diffusion), Discrétion (14 points, remède ×0,7). Coûts, effets et prérequis sont validés avant le lancement ; les cycles de prérequis sont refusés.
- Trois spécialisations communes s'ajoutent, exigeant Mobilité et s'excluant deux à deux : Réseau terrestre (9 points, terre ×1,8, vitesse du remède ×1,08), Pont aérien (10 points, air ×3, remède ×1,18), Logistique maritime (10 points, mer ×2,5, remède ×1,12). Elles sont facultatives et irréversibles. Les exclusions doivent être réciproques, connues, uniques et ne peuvent viser un prérequis. Leur état est dérivé des achats et vérifié au chargement.
- Détection régionale lorsque les actifs atteignent au moins 500 personnes ET 1,5 % de la population régionale. Une détection reste acquise jusqu'à la fin de la partie ; elle provoque une seule réaction locale de huit jours, multipliant la croissance locale par 0,8.
- Le remède commence dès la première détection. Gain quotidien en points de pourcentage : `0,6 + couverture × 0,6 + nombre de régions détectées × 0,015`, multiplié par les modificateurs de Discrétion et des événements. La couverture est comprise entre 0 et 1. Les règles de détection et de recherche sont dans `data/events.json`. Ces trois coefficients ont été ajustés après des simulations sur la carte étendue ; voir le [rapport](EQUILIBRAGE-0.4.md).
- Victoire lorsque le cumul touché atteint 90 %. Défaite si remède à 100 % ou disparition des actifs. Priorité le même jour : remède, victoire, extinction.
- Score : `arrondi(max(0, arrondi(couverture × 10 000) − jours × 10) × coefficient de difficulté)`.
- Une journée dure 0,5 seconde à vitesse ×1 ; ×2 et ×4 exécutent les mêmes pas. Pause sans progression. La durée des parties n'est pas encore équilibrée pour la cible finale de 15 à 30 minutes.

Le prototype démarre en pause pour laisser le temps de lire et de choisir. Changer le départ ou recommencer réinitialise entièrement le monde. Le menu pendant une partie conserve le monde en mémoire ; quitter l'application le perd.

## Objectif facultatif Standard

`data/objectives.json` définit Premiers relais : trois régions ayant chacune au moins 10 % de population touchée à la fin du jour 50 au plus tard. Le décompte utilise actifs + retirés et compare les entiers `(actifs + retirés) × 100 >= population × 10`. L'objectif est désactivé par défaut, activable seulement avant une nouvelle partie Standard. Dégel et le tutoriel n'en ajoutent pas.

Après les pas régionaux, le remède, les points et la résolution de la fin principale, le suivi compte les régions qualifiées. Atteindre le seuil au jour 50 réussit ; sinon le jour 50 clôt en échec. Une fin principale anticipée clôt aussi le suivi, après avoir vérifié une éventuelle réussite ce jour-là. La réussite facultative reste indépendante de la victoire principale : le remède garde sa priorité pour celle-ci.

L'état `pending`, `completed` ou `failed`, le progrès borné à trois, la date et le motif de résolution sont conservés dans le format de sauvegarde 2. Une résolution fige le compteur et ajoute une annonce unique au journal. Aucun changement de population, d'échanges, de recherche, de points, de score ou d'état aléatoire. Rejouer conserve le choix et réinitialise le suivi. Les anciennes parties de format 1 reconnues sont reprises sans objectif rétroactif.

## Objectif facultatif Dégel : flux saisonniers

Relais arctiques compte les unités d'échange ajoutées à l'entrée régionale par Boréale → Orient de J36 à J54, et Boréale → Centrale de J39 à J54. Les dates suivent la fin des fermetures cumulées dans la phase Instabilité. Chaque compteur est plafonné à 1 000 ; les deux quotas sont nécessaires. La route doit être ouverte et le sens correct. Aucune unité avant sa fenêtre, après résolution ou après J54 ; les autres routes et le sens inverse sont exclus.

Il s'agit du flux calculé avant la progression locale et sa borne par les habitants sains : pas d'un transfert de population ni d'une mesure de nouveaux touchés. Le calcul des imports reste exactement celui de 0.9 ; seule l'observation de sa valeur est ajoutée. L'objectif ne consomme aucune unité et ne modifie aucun résultat de simulation.

Le format 2 conserve les deux compteurs et le nombre de quotas atteints, en plus de l'état, de la date et du motif de résolution. Les fenêtres sont validées contre les routes saisonnières, la phase et les fermetures planifiées. Les anciennes parties 0.9 gardent Premiers relais s'il était activé ; aucune ne reçoit Relais arctiques rétroactivement.

## Événements temporaires

Les événements du standard sont déterministes, à des jours fixes, et définis dans `data/events.json`. Dégel 2042 possède son propre calendrier dans `data/scenarios.json` et remplace les événements standards.

| Événement | Jours d'application inclus | Effet |
| --- | --- | --- |
| Tempête boréale | 18 à 25 | Ferme Boréale ↔ Centrale |
| Contrôle des transports | 22 à 31 | Ferme la même route indépendamment de la tempête |
| Mesures de prudence | 35 à 41 | Croissance de Centrale ×0,65 |
| Mobilisation scientifique | 44 à 51 | Gain de remède ×1,35 |
| Contrôles aériens | 40 à 47 | Échanges du type aérien ×0,6 |
| Retards portuaires | 45 à 51 | Échanges du type maritime ×0,7 |

Un effet de durée huit jours activé au jour 18 possède une borne de fin exclusive au jour 26. Le panneau indique le nombre de pas quotidiens restant avant cette expiration. La pause suspend ce compte à rebours.

Chaque cause de fermeture conserve son propre délai. La route est fermée dès qu'au moins une cause est active : elle ne se rouvre ici qu'au jour 32. Les multiplicateurs ayant la même cible se multiplient ; par exemple une réaction ×0,8 et des mesures ×0,65 donnent ×0,52. Ils sont recalculés depuis les effets actifs, sans altérer les coefficients de base. Leur expiration ne retire donc pas un autre effet encore actif.

Le journal annonce activation, conséquence, fin et rétablissement réel des routes. Les événements et réactions se déclenchent une seule fois chacun. Les sauvegardes conservent les effets actifs et déjà déclenchés, leurs bornes et la suite aléatoire. La congestion des ports arctiques de Dégel s'applique du jour 34 au 39 inclus, avec un facteur maritime ×0,5 ; les fermetures restent prioritaires.

## Scénarios, climat et difficultés

Le catalogue `data/scenarios.json` décrit les scénarios, leurs phases, leurs routes et leurs évolutions additionnelles, ainsi que les trois difficultés. Il est validé intégralement avant de modifier une partie : identifiants, références, dates, coefficients et ordre des phases.

Dégel impose Boréale, seule région froide. Boréale ↔ Occident reste ouverte initialement. Boréale ↔ Centrale devient saisonnière et une 39e connexion, Boréale ↔ Orient, est ajoutée. Ces deux routes s'ouvrent au jour 12, sous réserve de toute fermeture temporaire active. Le reste de la carte demeure joignable par l'unique sortie initiale de Boréale.

| Phase | Jour initial | Température fictive | Croissance froide | Autres régions | Remède de phase |
| --- | --- | --- | --- | --- | --- |
| Isolement | 0 | −18 °C | ×0,8 | ×1 | ×1 |
| Ouverture | 12 | −5 °C | ×0,95 | ×1 | ×1 |
| Instabilité | 28 | 5 °C | ×0,75 | ×0,9 | ×1 |
| Mobilisation | 55 | 9 °C | ×0,9 | ×0,95 | ×1,35 |

Les transitions précèdent l'expiration et l'activation des événements quotidiens, puis la détection et la simulation. Les phases sont des paliers, sans interpolation. Une transition saisonnière ne supprime jamais les autres causes de fermeture.

Les tempêtes ferment Boréale ↔ Centrale aux jours 28–35 et une inspection la maintient fermée aux jours 31–38 ; réouverture au jour 39. Boréale ↔ Orient est fermée aux jours 30–35 et rouvre au jour 36. Les réactions régionales restent identiques au standard.

Les trois évolutions spécifiques sont : Adaptation polaire (9 points, facteur froid ×1,25), Mobilité saisonnière (10 points, échanges saisonniers ×2, exige Adaptation polaire) et Résilience climatique (12 points, exige Adaptation polaire). Résilience remplace une pénalité climatique `f < 1` par `1 − (1 − f) × 0,5` avant l'adaptation au froid. Elle n'atténue ni les réactions régionales ni les fermetures de route. Les six évolutions communes restent disponibles, soit neuf options dans Dégel. Les trois spécialisations s'excluent : au plus quatre achats en Standard et sept dans Dégel.

Les difficultés appliquent les facteurs recherche/détection/score suivants : Facile `0,75 / 1,25 / 0,8`, Normale `1 / 1 / 1`, Difficile `1,3 / 0,75 / 1,25`. Le multiplicateur de détection porte sur le seuil de 1,5 %, pas sur les 500 actifs minimum. Le gain du remède multiplie les effets des évolutions, des événements, de la phase et de la difficulté. Ces règles sont explicites dans le menu et le bilan.

## Profil enrichi 0.18

Facultatif au lancement ; douze évolutions et huit événements supplémentaires définis dans data/expanded-content.json. Coûts, prérequis, effets et dates sont validés avant de modifier la partie. Le format 5 fixe le profil enriched-0.18 et une empreinte complète. Le format 4 classique reste inchangé ; anciens achats, références et tutoriel sont conservés. Les effets se multiplient et expirent selon les règles existantes, les fermetures restent prioritaires. Mesures : EQUILIBRAGE-0.18-ENRICHI.md ; essais joueurs à réaliser.

## Aléas et résilience 0.20

Le catalogue crises.json ajoute trois compétences au profil enrichi et douze incidents tirés au lancement par un flux aléatoire indépendant de la propagation (graine xor 0x20422020). Un sac de huit types est mélangé sans répétition puis renouvelé. Dates : 18 + 8×index ±2 jours, ou 12 + 6×index ±2 dans Réseaux fragiles ; durées et cibles sont tirées selon le catalogue. Les tirages sont reconstruits à l’identique au chargement, pas recalculés à chaque journée.

Les pénalités des seuls aléas sont atténuées par les trois compétences : facteur f inférieur à 1 devient 1−(1−f)×0,5 pour transports/croissance, facteur f supérieur à 1 devient 1+(f−1)×0,5 pour remède. Favorables et événements classiques restent inchangés ; fermetures prioritaires, cumul multiplicatif et fin exclusive existants. Les profils 4/5 sont conservés ; le format 6 fixe crises-0.20 et son empreinte propre. Détails et mesures : point 25 et EQUILIBRAGE-0.20-ALEAS.md.
