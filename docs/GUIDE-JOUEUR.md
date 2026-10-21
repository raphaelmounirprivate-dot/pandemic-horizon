# Jouer à Pandemic Horizon 0.24

Prototype Windows hors ligne. Lancer `PandemicHorizon.exe` dans `build/windows-0.24.1/`. Les anciens dossiers conservent leurs versions précédentes. Pour lancer depuis les sources, consulter le README du dépôt et `docs/DEVELOPPEMENT.md`.

1. À l'écran titre, choisir « Nouvelle partie », puis suivre les trois étapes : scénario (cartes Standard, Dégel 2042, Réseaux fragiles), difficulté et options, région de départ cliquée sur la carte du monde. Dégel impose Boréale, Réseaux fragiles impose Centrale. « Lancer la partie » démarre ; Retour ou Échap reviennent d'une étape.
2. Lire les objectifs. La partie commence en pause.
3. Cliquer sur une région pour consulter sa population et ses cas actifs.
4. Reprendre avec Espace. Ouvrir l'écran Évolution (touche E ou bouton « Évolution » à droite de la carte), choisir une famille, sélectionner une compétence pour lire sa fiche, puis activer Évoluer lorsque les points et prérequis le permettent. Mobilité exige d'abord Diffusion. Les effets et raisons d'indisponibilité sont affichés avant achat.
5. Atteindre 90 % de population touchée avant la fin du remède. Le bilan explique le résultat et présente le journal complet.

La carte du monde utilise les contours terrestres Natural Earth. Les 24 régions du jeu restent fictives : sélectionner un marqueur numéroté au clic ou avec Tab puis Entrée pour lire son nom et ses statistiques à droite. Les halos et points rouges illustrent le cumul touché ; ce ne sont ni des personnes localisées ni des frontières de simulation réelles. Les noms complets sont aussi disponibles au survol.

| Commande | Effet |
| --- | --- |
| Espace | Pause / reprise pendant la partie |
| 1, 2, 4 | Choisir la vitesse |
| E / Évolution | Ouvrir ou fermer l'écran des compétences ; la partie est en pause pendant le choix et reprend ensuite comme avant |
| F1 | Ouvrir ou fermer l'aide, en pause |
| F2 | En partie, mettre en pause et retrouver les choix logistiques intégrés |
| F3 / Monde | Consulter courbes, achats datés, effets et actualités en pause ; F3 ou Échap revient |
| Échap | Depuis Évolution : retour à la carte. Depuis la carte : menu et pause de la partie |
| Tab / Maj + Tab | Parcourir les contrôles |
| Entrée | Activer le contrôle sélectionné |
| Molette sur la carte | Zoomer autour du pointeur entre ×1 et ×4 |
| Glisser au bouton droit ou central | Déplacer la carte agrandie |
| Boutons − / + / Vue mondiale | Dézoomer, zoomer ou retrouver le monde entier |
| Flux : tous / terre / air / mer | Parcourir les filtres de véhicules ; les fermetures restent visibles |
| + / −, flèches, Origine sur la carte focalisée | Zoom, déplacement, retour au monde |
| Menu → Reprendre la partie | Retrouver la partie en mémoire, en pause |
| Sauvegardes | Enregistrer ou charger une partie sur ce PC |
| Recommencer / Nouvelle partie | Abandonner la partie courante et repartir du jour zéro |

« Retirés » signifie sortis de l'état actif. Le cumul touché additionne actifs et retirés, sans compter deux fois une personne. Les courbes discrètes montrent le réseau fictif ; les pointillés et croix ambre signalent une route fermée. Les flèches rouges suivent les échanges orientés calculés pour le jour courant, uniquement sur les routes ouvertes. Elles se figent en pause et reprennent après chargement au prochain jour simulé. Le dessin des trajectoires est illustratif.

La carte se focalise avec Tab. Quand Tab atteint une région hors champ, la vue se déplace pour la montrer ; Entrée la sélectionne. Les cibles restent de taille constante pendant le zoom. Les commandes de jeu, évolutions et choix logistiques ne se déplacent pas avec la carte. Le centre est conservé au redimensionnement et lors du retour depuis l'aide, le menu ou les sauvegardes. Nouvelle partie et chargement repartent en vue mondiale ; cette caméra temporaire n'est pas enregistrée dans les sauvegardes.

« Monde [F3] » présente les courbes de touchés et de remède, les dates d'achats observées, les effets courants et le journal récent. Une ancienne sauvegarde sans historique est signalée ; ses journées ou dates d'achat ne sont pas reconstituées. L'historique reprend ensuite à partir des nouvelles observations. La partie reste en pause pendant cette consultation.

## Objectif facultatif : Premiers relais

Avant une nouvelle partie Standard, activer « Objectif facultatif : Premiers relais » au menu. Ce choix est désactivé par défaut ; Dégel propose son propre objectif décrit ci-dessous. Premiers relais demande **trois régions ayant chacune au moins 10 % de population touchée, au plus tard à la fin du jour 50**. « Touchée » compte actifs et retirés ; les mêmes trois régions ne sont pas imposées.

Le suivi sous les compteurs mondiaux indique la progression et l'échéance. Il se fige à la réussite, au jour limite ou à la fin de partie. Atteindre le seuil exactement au jour 50 réussit ; l'atteindre plus tard ne transforme pas un objectif manqué. Une fin de partie anticipée clôt le suivi. Le journal et le bilan gardent le résultat et sa date.

Cet objectif ne rapporte aucun point ni bonus de score et ne remplace pas la victoire principale à 90 %. Une réussite facultative peut accompagner une défaite principale. « Rejouer avec les mêmes choix » conserve son activation et remet son suivi à zéro. Les anciennes parties sont chargées sans objectif facultatif ; le tutoriel conserve une session distincte.

## Objectif facultatif Dégel : Relais arctiques

Avant une nouvelle partie Dégel 2042, activer « Objectif facultatif : Relais arctiques ». Après les tempêtes, atteindre **1 000 unités d'échange sur chacune des deux routes**, dans le sens sortant de Boréale : vers Orient du jour **36 au 54 inclus**, vers Centrale du jour **39 au 54 inclus**. L'inspection maintient Centrale fermée après la fin de la tempête ; seule sa dernière réouverture permet de compter.

Les unités sont les échanges abstraits calculés par les routes ouvertes, même vers une région déjà touchée. Elles ne représentent pas des personnes transportées ou le nombre de nouveaux touchés. Mobilité, les effets saisonniers et la spécialisation maritime peuvent modifier ces flux. Une autre route, le sens inverse ou un échange hors fenêtre ne compte pas.

Le suivi affiche un compteur par destination, plafonné à 1 000. Les deux doivent atteindre leur quota avant la mobilisation du jour 55 ; une réussite au jour 54 est valide. Le résultat se fige ensuite, même si les routes continuent à fonctionner. Aucun bonus de points ou de score ; l'objectif principal reste inchangé. Changer de scénario décoche le choix et demande une nouvelle activation. Rejouer conserve le choix et réinitialise les compteurs.

## Tutoriel et aide

« Tutoriel guidé », au menu, propose six exercices facultatifs avec les vrais contrôles et les vraies règles :

1. Reprendre le temps avec Espace ; une journée passe, puis le jeu se remet en pause.
2. Sélectionner Centrale pour lire ses statistiques.
3. Au jour 10, acheter Diffusion avec les points normalement gagnés et observer le prérequis de Mobilité.
4. Au jour 23, sélectionner Boréale et lire son état détecté.
5. Reprendre jusqu'au jour 26, puis jusqu'au 32 : la fin de la tempête ne suffit pas à rouvrir une route encore fermée par une inspection.
6. Ouvrir les sauvegardes d'essai, enregistrer dans un emplacement manuel puis le charger. Confirmer le chargement, puis choisir « Terminer ».

Le focus clavier suit l'action demandée ; Entrée active le contrôle et Tab permet d'explorer les autres commandes. « Continuer » se débloque après l'action réussie. Le temps avance automatiquement entre certains exercices pour montrer les événements ; les valeurs ne sont pas truquées. Certaines actions sont réservées à la partie libre.

L'entraînement conserve une partie et des fichiers séparés, dans `user://training`. Il ne remplace ni la partie en mémoire ni les sauvegardes du joueur. Les fichiers d'essai sont réinitialisés au prochain lancement du tutoriel. « Terminer », « Quitter l'entraînement » ou Échap restituent la session précédente en pause. Depuis l'aide ou les sauvegardes, un premier Échap ferme cet écran ; un second quitte l'entraînement. Fermer normalement l'application pendant l'entraînement sauvegarde la partie du joueur, si elle existe.

« Aide [F1] » est accessible au menu, en partie et au bilan. F1 fonctionne aussi depuis les paramètres et les sauvegardes. « Situation actuelle » résume le scénario, la région sélectionnée, les raisons d'indisponibilité des évolutions et les effets actifs. Le sélecteur propose également neuf sujets : commandes, régions, évolutions, détection, événements, sauvegardes, Dégel, transports et décision logistique. Faire défiler le texte, ou le focaliser avec Tab et utiliser les flèches. F1, Échap ou « Retour » ramènent à l'écran précédent, en pause.

## Transports

Les véhicules rouges représentent les échanges du jour : avion, bateau ou camion selon le type de route. Leur taille est illustrative, sans correspondance avec un nombre de personnes. Les petits symboles neutres près des hubs signalent une infrastructure aérienne ou maritime, y compris si ses routes sont fermées. Les teintes de terrain et de glace sont illustratives, sans mesure d'altitude.

Chaque liaison a un seul type : terrestre (coefficient ×1), aérien (×1,2) ou maritime (×0,8). Les courbes représentent le réseau ; consulter le type dans les statistiques régionales ou F1 → Transports. Les valeurs sont des paramètres fictifs du jeu. Une route fermée porte toujours des pointillés et une croix ambre, quel que soit son type.

Le détail régional affiche les liaisons ouvertes sur leur total : T pour terrestre, A pour aérien, M pour maritime. Par exemple M 0/2 signifie deux routes maritimes présentes et toutes deux fermées ; A 0/0 signifie aucune route aérienne. Dans F1 → Transports, consulter les destinations, le type, l'ouverture et le coefficient de transport actuel. Ce coefficient n'inclut pas Mobilité ni le bonus saisonnier, qui se multiplient séparément.

Le Standard subit des contrôles aériens du jour 40 au 47 inclus (échanges aériens ×0,6), puis des retards portuaires du 45 au 51 inclus (maritimes ×0,7). Dans Dégel, la congestion des ports réduit les échanges maritimes de moitié du 34 au 39 inclus. Un ralentissement ne rouvre jamais une route fermée. Les autres types de transport restent inchangés par cet événement.

## Spécialisations de transport

Après Diffusion puis Mobilité, vous pouvez choisir une seule spécialisation pour toute la partie. Ce choix est facultatif, irréversible, et ne peut être acheté qu'une fois. Les deux autres choix deviennent incompatibles, même si vous disposez de leurs points.

| Choix | Coût | Avantage sur les échanges | Contrepartie sur la vitesse du remède |
| --- | --- | --- | --- |
| Réseau terrestre | 9 pts | Terrestres ×1,8 | ×1,08, soit +8 % |
| Pont aérien | 10 pts | Aériens ×3 | ×1,18, soit +18 % |
| Logistique maritime | 10 pts | Maritimes ×2,5 | ×1,12, soit +12 % |

Le bonus ne touche que le transport choisi ; il ne rouvre aucune route. L'accélération du remède est permanente après achat et se multiplie avec Discrétion, la difficulté et les événements. Le coût retarde aussi les autres achats : une spécialisation peut être moins intéressante qu'un achat plus précoce de Discrétion.

L'écran Évolution comporte six compétences dans Standard et neuf dans Dégel, réparties par famille. Tab/Maj + Tab parcourt les nœuds de l'onglet ouvert. Lire les contreparties avant Entrée. F1 → Évolutions explique les choix ; F1 → Transports indique le coefficient courant, spécialisation comprise, hors Mobilité et bonus saisonnier.

## Détection et réactions

Une région est détectée lorsque les cas actifs atteignent à la fois 500 personnes et 1,5 % de sa population. Son état apparaît dans les détails. La première détection lance la recherche du remède ; chaque région détectée renforce ensuite sa progression. Chaque région réagit une seule fois par une réduction temporaire de sa croissance locale de 20 % pendant huit jours.

## Événements et routes

Le panneau « Événements actifs » affiche les effets, leur cible et les jours restants. Il permet le défilement si nécessaire. Pendant un choix logistique, ce panneau cède sa place aux trois options ; les effets restent consultables dans F1. Deux événements peuvent fermer la même route : l'expiration du premier ne suffit pas à la rouvrir. Une route fermée bloque les nouveaux cas importés par cette connexion ; les cas déjà présents continuent leur progression locale.

Le standard inclut une tempête, un contrôle des transports, des mesures locales de prudence et une mobilisation accélérant la recherche. Les effets et leur fin sont annoncés dans le journal ; le bilan présente l'historique complet. La grille complète des évolutions reste visible pendant le jeu.

Les points augmentent tous les cinq jours. Chaque évolution ne peut être achetée qu'une fois. Les achats trop chers sont refusés avec un message. Le plein écran se règle dans les paramètres et ce réglage est conservé sur le PC.

## Dégel 2042

| Phase | Début | Changement |
| --- | --- | --- |
| Isolement | Jour 0 | Une seule sortie ouverte depuis Boréale ; croissance froide ×0,8 |
| Ouverture | Jour 12 | Routes Boréale ↔ Centrale et Boréale ↔ Orient disponibles ; froid ×0,95 |
| Instabilité | Jour 28 | Tempêtes et inspection ; froid ×0,75 et autres régions ×0,9 |
| Mobilisation | Jour 55 | Recherche ×1,35 ; froid ×0,9 et autres régions ×0,95 |

Les températures affichées sont fictives et changent par paliers. Le multiplicateur « Climat local » indique l'effet réel sur la région sélectionnée. Les événements actifs restent prioritaires sur l'ouverture saisonnière : Boréale ↔ Centrale est fermée du jour 28 au 38 inclus, et Boréale ↔ Orient du 30 au 35 inclus.

Trois évolutions supplémentaires se trouvent dans la troisième rangée de la grille : Adaptation polaire (9 points, croissance froide ×1,25), Mobilité saisonnière (10 points, échanges saisonniers ×2) et Résilience climatique (12 points, pénalités climatiques divisées par deux). Les deux dernières exigent Adaptation polaire. Elles sont toutes visibles ; Tab permet aussi de les atteindre.

## Difficultés

| Difficulté | Recherche | Seuil de détection | Score |
| --- | --- | --- | --- |
| Facile | ×0,75 | ×1,25 | ×0,8 |
| Normale | ×1 | ×1 | ×1 |
| Difficile | ×1,3 | ×0,75 | ×1,25 |

Un seuil plus bas déclenche la détection et les réactions plus tôt. Le minimum de 500 actifs reste applicable. Le remède, les réactions et le climat se combinent ; les difficultés ne modifient pas directement la croissance de base. Reprendre conserve les choix de la partie en cours ; Recommencer les réutilise, même si les sélections du menu ont changé.

## Sauvegarder et reprendre

Ouvrir « Sauvegardes » depuis le menu, la partie ou le bilan. L'écran met le jeu en pause. Trois emplacements manuels proposent « Enregistrer ici » ; chaque ligne affiche le scénario, la difficulté, le jour et la date locale d'enregistrement. Remplacer un fichier existant demande confirmation. « Charger » demande confirmation si une partie est déjà en mémoire.

La sauvegarde automatique est actualisée tous les dix jours simulés, à la fin de partie, au retour au menu depuis le jeu ou le bilan, et à la fermeture normale de l'application. Une fermeture forcée ou une coupure ne déclenche pas de sauvegarde : les changements depuis le dernier enregistrement peuvent être perdus. Une erreur d'enregistrement est signalée ; si elle survient à la fermeture, le jeu propose d'annuler ou de quitter sans sauvegarder.

Le chargement conserve régions, détections, achats, points, remède, événements, phase, journal, région sélectionnée et vitesse. La partie reprend toujours en pause, au début de la journée affichée ; le temps d'affichage fractionnaire n'est pas conservé. Une partie terminée retrouve son bilan.

Après un remplacement réussi, le fichier `.bak` contient la version précédente. Si le fichier principal manque ou est illisible, un secours valide est chargé avec un avertissement. Il peut être plus ancien. Si les deux fichiers sont invalides, la partie en mémoire est conservée. Les versions de format, données ou moteur incompatibles sont refusées sans écrasement ; aucune migration automatique n'est proposée dans ce prototype.

Les fichiers 0.7 à 0.12 restent locaux, dans `%APPDATA%/Godot/app_userdata/Pandemic Horizon/saves/transports-1/`. Les sauvegardes reconnues sont signalées, chargées en pause et vérifiées avant utilisation. Les parties 0.7/0.8 restent sans objectif ; les parties 0.9 conservent leur suivi de Premiers relais ou l'absence d'objectif dans Dégel. Relais arctiques n'est jamais ajouté rétroactivement. La lecture ne réécrit pas le fichier. Au premier enregistrement 0.12, le fichier ancien devient la copie de secours précédente ; les sauvegardes suivantes font tourner ce secours normalement. Les règles de propagation et le remède restent identiques.

Une partie enregistrée en 0.12 utilise le format 4 et n'est pas compatible avec les anciens exécutables. Les sauvegardes reconnues 0.10 conservent leur objectif et ne reçoivent aucune décision logistique rétroactive. Le premier enregistrement 0.12 conserve le texte ancien en secours ; la lecture seule ne le modifie pas. Les anciennes sauvegardes 0.6 restent dans le dossier `saves/` et nécessitent leur ancien exécutable. Les versions et empreintes inconnues restent refusées, sans écrasement automatique. Les fichiers ne sont pas synchronisés avec GitHub. `dev.ps1 Play` utilise un dossier isolé sous `.tools/user/`. Le rythme et le contenu restent provisoires et doivent être éprouvés avec des joueurs.

## Décision logistique facultative dans Dégel

Depuis la 0.12, une nouvelle partie paie le soutien **3 points**. Une partie 0.11 chargée conserve son tarif **6 points**, indiqué au-dessus des choix intégrés et dans l'aide ; aucun point déjà dépensé n'est remboursé. Les états en attente gardent aussi leur ancien prix. Le format 4 conserve ce profil lors des sauvegardes suivantes. Recommencer crée une nouvelle partie aux règles 0.12. Les autres coefficients et les dates d'expiration restent identiques.

Avant une nouvelle partie Dégel, activer « Décision logistique (J28) ». Au jour 28, le jeu s'arrête en pause et présente trois options :

| Option | Coût | Mer | Vitesse du remède | Durée |
| --- | --- | --- | --- | --- |
| Soutenir les ports | 3 points | ×1,50 | ×1,15 | 12 journées |
| Limiter les échanges | Gratuit | ×0,65 | ×0,85 | 12 journées |
| Maintenir la situation | Gratuit | Aucun ajout | Aucun ajout | Sans effet |

Un seul choix est possible, sans annulation. Les points insuffisants sont expliqués avant et après une tentative. Les effets commencent le lendemain : choix au J28 → effets du J29 au J40 inclus, expiration au J41. Les multiplicateurs se combinent avec les autres effets ; une route fermée reste fermée. Le choix ne change directement ni le score ni le statut des objectifs facultatifs.

Les choix apparaissent sous la carte, en pause, sans masquer les évolutions. On peut réfléchir ou sauvegarder sans décider. F2 revient à la carte et aux choix intégrés. On peut choisir au J28, J29 ou J30 ; au J31, le maintien neutre est automatique et gratuit. Une partie terminée avant décision annule ou clôt le choix sans coût. Les sauvegardes conservent le choix, les points et la date de fin. L'aide F1 propose le sujet « Décision logistique ».

## NACRE et contenu enrichi

Activer Contenu enrichi avant une nouvelle partie ajoute douze évolutions et huit événements : 18 évolutions en Standard, 21 dans Dégel. Le profil classique reste proposé par défaut et le tutoriel conserve ses règles. NACRE est un agent fictif représenté par un emblème de réseau original.

Chaque nœud affiche le nom complet, le coût et un état écrit ; le losange indique un blocage. Les traits relient chaque prérequis à la compétence qu'il débloque. Utiliser Évoluer pour acheter. Tous les choix logistiques restent sous la carte.

Le profil enrichi utilise le format de sauvegarde 5, à reprendre avec la version 0.18 ou suivante compatible. Les parties classiques gardent leur format et leurs règles ; aucun ajout rétroactif aux anciennes parties.

## Confort et sons (0.19)

Dans Paramètres, Réduire les mouvements fige les déplacements des véhicules ; les journées continuent selon la vitesse, sauf en pause. Agrandir le texte de lecture augmente les caractères de l’aide, des actualités et du bilan ; les nœuds de la grille ne changent pas de taille. Le remède utilise une courbe en tirets, les touchés un trait continu.

Les sons sont désactivés par défaut. Activer les sons de retour ajoute des signaux courts pour achat, détection et fin de partie. Régler Volume avec la souris ou les flèches du clavier ; zéro ou désactivation coupe le son. Aucun signal sonore n’est indispensable. Ces préférences restent sur ce PC, indépendantes des sauvegardes de partie.

Pour l’archive Windows, extraire tous les fichiers et lancer PandemicHorizon.exe. VERSION.json identifie le commit et l’empreinte du binaire. Cette version candidate attend les essais physiques, auditifs et sur un second PC décrits dans TESTS-JOUEURS.md.

## Aléas et résilience (0.20)

Au menu, activer Aléas et résilience (+3) pour compléter le catalogue enrichi : 21 compétences en Standard/Réseaux fragiles, 24 dans Dégel. Le profil classique reste disponible en désactivant cette option puis Catalogue enrichi. Le tutoriel conserve ses règles classiques.

Douze incidents sont tirés au lancement parmi huit types : tempête maritime, séisme, panne des communications aériennes, mobilisation scientifique, reprise terrestre, retard de coordination de recherche, fenêtre maritime favorable et reprise régionale. Le premier sac contient chaque type une fois, puis un second sac est entamé ; certains incidents peuvent survenir après la fin de la partie. Dates, durées et certaines cibles varient. Favorable/défavorable se rapporte à la diffusion du joueur. Le calendrier futur n’est pas affiché. Effets, cibles, dates de fin et jours restants se consultent en partie et dans Monde/F3.

Graine règle le tirage ; saisir un nombre puis valider avec Entrée, ou utiliser Autre. Les mêmes choix et la même graine reproduisent la même partie. Recommencer conserve la graine. Changer la graine au menu avant une nouvelle partie pour varier les événements.

Liaisons de secours coûte 10 points et exige Mobilité : les pénalités de transport des aléas sont divisées par deux. Veille scientifique coûte 11 points et exige Discrétion : leurs accélérations du remède sont divisées par deux. Réserves régionales coûte 9 points et exige Relais locaux : leurs pénalités de croissance sont divisées par deux. Ces protections ne modifient ni les événements historiques ni les effets favorables et ne rouvrent aucune route fermée. Sélectionner consulte ; Évoluer confirme l’achat.

Réseaux fragiles impose Centrale et l’option des aléas : incidents environ tous les six jours au lieu de huit, croissance ×0,95 jusqu’au J44, remède ×1,15 dès J45. L’objectif principal reste toucher 90 % avant le remède ; aucun objectif facultatif ni décision portuaire dans ce scénario.

Le profil utilise le format de sauvegarde 6, à reprendre avec 0.20 compatible. Les anciens formats classiques/enrichis 4/5 restent reconnus sans ajout rétroactif d’incidents. Les catastrophes sont des effets de jeu abstraits : aucune nouvelle mortalité ni destruction économique simulée.

## Localiser les incidents (0.22)

Local [F4] parcourt les aléas locaux actifs, avec zoom borné et repère clair. Survoler la région ou le pictogramme révèle l’effet et la fin. Les effets mondiaux restent dans Monde/F3, sans localisation inventée. Aucun tirage futur n’est montré ; les marqueurs expirent avec leurs effets. Les règles et formats 4/5/6 sont conservés.

## Crises réactives (0.22)

L'option du menu active le catalogue enrichi et les aléas. Un foyer actif possédant encore des sains est choisi au déclenchement des aléas régionaux de croissance. À la première panne aérienne, le jeu se met en pause : trois choix intégrés sous la carte [F2]. Détour : 3 points, air ×1,35 ; subir : gratuit, panne conservée ; occasion : 1 point, air ×1,70 et remède ×1,18. Coefficients ajoutés par multiplication pendant six jours dès le lendemain. Aucune route fermée n'est rouverte. Trois journées pour choisir ; ensuite subir est retenu gratuitement.

Dans Réseaux fragiles réactif, Double relais est obligatoire : 6 000 unités depuis Centrale vers Méridien et autant vers Savane avant J60 inclus. Un échec entraîne la défaite. Les unités sont des flux simulés sur routes ouvertes, pas de nouveaux cas. La victoire demande aussi 90 % touchés avant le remède. Les anciennes parties conservent leurs profils.

## Familles et fiche de compétences (0.23)

Les trois symboles de la légende identifient Diffusion (réseau), Discrétion (bouclier) et Résilience (anneau). Les compétences suivent cet ordre, avec les mêmes coûts, prérequis et exclusions. La sélection montre toute son ascendance, le nom complet, l'effet et les coefficients actuels → après achat. Ils sont calculés depuis vos compétences achetées, hors climat et événements temporaires ; une compétence acquise n'est pas comptée deux fois. Les effets cumulés restent décrits dans les événements et les transports. Seul le bouton Évoluer dépense des points.

## Bilan de fin

À la fin, l'écran annonce victoire ou défaite, puis montre le jour, la population touchée (avec le repère 90 %), le remède et le score, la courbe de la partie et ses moments clés. « Rejouer avec les mêmes choix » relance la même configuration ; le journal complet reste dans Monde [F3].

## Écran Évolution

Touche E ou bouton « Évolution » à droite de la carte. La partie se met en pause ; Échap, E ou « Retour à la carte » la rend dans l'état d'avant (en cours ou en pause).

- **Points** : en grand en haut à droite, avec le prochain gain (« +3 au J40 » : 3 points tous les cinq jours).
- **Onglets** : un par famille (Diffusion, Discrétion, Résilience), avec le nombre de compétences acquises et, en dessous, le nombre de compétences achetables maintenant. L'onglet ouvert est souligné.
- **Arbre** : il se lit de gauche à droite. Un trait relie un prérequis à la compétence qu'il débloque ; il est épais quand le prérequis est acquis. Chaque nœud indique nom, coût et état : Disponible, Acquise, Prérequis, Incompatible ou « Manque N pts ». Une compétence achetable maintenant ressort : fond teinté, contour épais, nom en couleur et marque « + » en haut à droite.
- **Fiche** : famille et coût, état détaillé, effet, coefficients avant → après (hors climat et aléas), prérequis un par un et, pour les spécialisations, ce que le choix exclut.
- **Évoluer** : seul ce bouton dépense des points. Sélectionner un nœud ne coûte rien.

Quelques compétences de Résilience exigent une compétence de Diffusion : la fiche le précise.

## Essayer les agents stratégiques (0.25)

Dans Nouvelle partie → Difficulté et options, choisir NACRE, ONDE ou VOILE. Historique conserve les anciennes règles. L’agent sélectionné est nommé sous les options ; les descriptions expliquent sa mécanique. Le catalogue enrichi et les aléas sont activés automatiquement. Les anciennes décisions sont remplacées par les crises de coordination.

NACRE récompense les foyers développés ; ONDE demande de tenir compte du cycle de croissance ; VOILE favorise les régions non détectées. À partir du J20, une décision revient tous les 12 jours : consolider les foyers, forcer les relais ou garder les points. Lire les trois contreparties ; F2 revient au choix en pause. Les effets durent huit jours dès le lendemain. Sans réponse pendant quatre jours, les points sont conservés gratuitement.

Une journée dure 6 secondes à ×1 ; pause et ×2/×4 restent disponibles. Le jeu se met aussi en pause lorsqu’un gain ouvre un premier achat ou qu’une décision arrive. L’ambiance sonore reste facultative dans Paramètres. Le bilan explique la couverture manquante ou la marge face au remède. Ce profil est expérimental : les sessions joueurs restent à réaliser.
