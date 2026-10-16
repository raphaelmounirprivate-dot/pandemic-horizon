# Pandemic Horizon

Jeu de stratégie original en français, pour Windows et hors ligne, décrit dans le README et le plan de développement.

## Plateforme et technologie

Application de bureau Windows, Godot 4.7.2 standard et GDScript. Simulation abstraite indépendante de l'interface ; ressources locales. Aucun compte ni serveur.

## Parcours

Choisir un scénario, une difficulté et une région de départ, suivre la propagation entre régions fictives, acheter des évolutions avec prérequis, gérer le temps et comprendre le résultat. Le prototype 0.8 porte sur 24 régions, Standard et Dégel 2042, avec détection, réactions régionales, événements temporaires, phases climatiques et liaisons terrestres, aériennes et maritimes. Le volume final de contenu reste à développer.

Les types de transport modulent les échanges entre régions : terrestre ×1, aérien ×1,2 et maritime ×0,8. La carte distingue les routes ouvertes par un trait plein, des tirets ou des points ; une fermeture conserve les tirets et la croix ambre. Le panneau régional et les infobulles affichent les liaisons ouvertes rapportées au total de chaque type (T, A, M). Le thème « Transports » de l'aide détaille les destinations, leur état et le coefficient de transport courant, hors Mobilité et bonus saisonnier. Les effets temporaires du même type se multiplient avec le profil de transport ; une route fermée bloque les échanges.

Après Mobilité, trois spécialisations facultatives sont proposées ; en acheter une exclut les deux autres pour la partie. Réseau terrestre coûte 9 points et multiplie les échanges terrestres par 1,8 et la vitesse du remède par 1,08 ; Pont aérien coûte 10 points et applique respectivement ×3 aux échanges aériens et ×1,18 au remède ; Logistique maritime coûte 10 points et applique ×2,5 aux échanges maritimes et ×1,12 au remède. Le choix augmente donc aussi la vitesse du remède. Standard propose six évolutions et Dégel 2042 neuf, dont ces trois choix exclusifs. Le panneau indique la spécialisation choisie ou rappelle le choix unique après Mobilité ; chaque évolution conserve son coût, son effet et son état visibles.

Dans Standard, les Contrôles aériens commencent au jour 40 pour huit jours (×0,6) et les Retards portuaires au jour 45 pour sept jours (×0,7). Dans Dégel 2042, la Congestion des ports arctiques commence au jour 34 pour six jours (maritime ×0,5). Ces effets réduisent les échanges du type concerné sans fermer les liaisons.

Un tutoriel guidé facultatif est accessible depuis le menu. Six exercices utilisent la simulation et les commandes réelles : faire passer une journée puis revenir en pause ; sélectionner Centrale et lire ses statistiques ; acheter Diffusion au jour 10 ; sélectionner Boréale détectée au jour 23 ; observer deux fermetures cumulées d'une route, avec l'expiration de la tempête au jour 26 puis la réouverture au jour 32 ; enregistrer puis charger une sauvegarde d'essai. Le parcours avance automatiquement jusqu'aux jours nécessaires entre certains exercices. « Continuer », puis « Terminer », deviennent accessibles après l'action attendue ; le focus vise la commande utile, puis ce bouton après réussite. Les évolutions non concernées sont désactivées et signalées « Hors exercice », avec leur éventuel motif de blocage.

L'entraînement utilise une session distincte et des fichiers séparés dans `user://training`. Les fichiers d'essai sont réinitialisés au démarrage du tutoriel ; les sauvegardes du joueur sont conservées. Terminer ou quitter l'entraînement restaure la session précédente, ses choix et sa vitesse, avec la partie en pause.

L'aide accessible par F1 ou par un bouton propose neuf thèmes : situation actuelle, temps et commandes, régions et objectif, évolutions et prérequis, détection et remède, événements et routes, sauvegardes, Dégel 2042, transports. La situation actuelle reprend le scénario, la difficulté, le jour, la région sélectionnée, les états réels des évolutions et les événements actifs ; elle tient compte des restrictions de l'exercice en cours. Fermer l'aide par F1, Échap ou Retour ramène à l'écran précédent, avec la partie en pause.

Les sauvegardes locales sont accessibles depuis le menu, la partie et le bilan : trois emplacements manuels et un emplacement automatique. Chaque emplacement renseigné affiche le scénario, la difficulté, le jour et la date. La sauvegarde automatique intervient tous les dix jours, en fin de partie, au retour au menu et à la fermeture. Charger une partie reprend en pause ; une partie terminée ouvre son bilan.

La version 0.8 conserve le répertoire `user://saves/transports-1` et reconnaît les empreintes de contenu 0.7 autorisées. Une ancienne partie valide est reconstruite dans un nouveau monde, puis chargée en pause avec un avertissement ; les nouvelles spécialisations deviennent disponibles. La lecture ne réécrit pas le fichier : au premier enregistrement sur le même emplacement, l'original valide est conservé en copie de secours. L'empreinte de contenu 0.8 normalise les fins de ligne LF/CRLF. Les fichiers de la version 0.6 restent conservés à la racine `user://saves`, sans migration ; reprendre ces anciennes parties nécessite l'ancien exécutable.

Le remplacement d'un emplacement existant ou le chargement qui remplace une partie en mémoire demande confirmation, avec « Annuler » au focus initial. Les erreurs de lecture ou d'écriture sont affichées en français. Si le fichier principal est absent ou invalide, une copie de secours valide peut être chargée avec un avertissement ; un chargement échoué conserve la partie en mémoire.

## Contraintes

Règles visibles, interface redimensionnable dès 1280 × 720, navigation au clavier, nombres en complément des couleurs. Aucun mécanisme biologique réel. Les chiffres du prototype sont des paramètres de jeu provisoires.

## Public et décisions ouvertes

Public supposé : joueurs de jeux de stratégie sur PC ; niveau d'expérience à confirmer. Direction visuelle sombre cartographique avec turquoise et ambre confirmée par l'utilisateur. Les essais avec des joueurs extérieurs et l'équilibrage restent à organiser.
