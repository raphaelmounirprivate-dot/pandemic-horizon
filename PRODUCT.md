# Pandemic Horizon

Jeu de stratégie original en français, pour Windows et hors ligne, décrit dans le README et le plan de développement.

## Plateforme et technologie

Application de bureau Windows, Godot 4.7.2 standard et GDScript. Simulation abstraite indépendante de l'interface ; ressources locales. Aucun compte ni serveur.

## Parcours

Choisir un scénario, une difficulté et une région de départ, suivre la propagation entre régions fictives, acheter des évolutions avec prérequis, gérer le temps et comprendre le résultat. Le prototype 0.6 porte sur 24 régions, Standard et Dégel 2042, avec détection, réactions régionales, événements temporaires et phases climatiques. Le volume final de contenu reste à développer.

Un tutoriel guidé facultatif est accessible depuis le menu. Six exercices utilisent la simulation et les commandes réelles : faire passer une journée puis revenir en pause ; sélectionner Centrale et lire ses statistiques ; acheter Diffusion au jour 10 ; sélectionner Boréale détectée au jour 23 ; observer deux fermetures cumulées d'une route, avec l'expiration de la tempête au jour 26 puis la réouverture au jour 32 ; enregistrer puis charger une sauvegarde d'essai. Le parcours avance automatiquement jusqu'aux jours nécessaires entre certains exercices. « Continuer », puis « Terminer », deviennent accessibles après l'action attendue ; le focus vise la commande utile, puis ce bouton après réussite. Les évolutions non concernées sont désactivées et signalées « Hors exercice », avec leur éventuel motif de blocage.

L'entraînement utilise une session distincte et des fichiers séparés dans `user://training`. Les fichiers d'essai sont réinitialisés au démarrage du tutoriel ; les sauvegardes du joueur sont conservées. Terminer ou quitter l'entraînement restaure la session précédente, ses choix et sa vitesse, avec la partie en pause.

L'aide accessible par F1 ou par un bouton propose huit thèmes : situation actuelle, temps et commandes, régions et objectif, évolutions et prérequis, détection et remède, événements et routes, sauvegardes, Dégel 2042. La situation actuelle reprend le scénario, la difficulté, le jour, la région sélectionnée, les états réels des évolutions et les événements actifs ; elle tient compte des restrictions de l'exercice en cours. Fermer l'aide par F1, Échap ou Retour ramène à l'écran précédent, avec la partie en pause.

Les sauvegardes locales sont accessibles depuis le menu, la partie et le bilan : trois emplacements manuels et un emplacement automatique. Chaque emplacement renseigné affiche le scénario, la difficulté, le jour et la date. La sauvegarde automatique intervient tous les dix jours, en fin de partie, au retour au menu et à la fermeture. Charger une partie reprend en pause ; une partie terminée ouvre son bilan.

Le remplacement d'un emplacement existant ou le chargement qui remplace une partie en mémoire demande confirmation, avec « Annuler » au focus initial. Les erreurs de lecture ou d'écriture sont affichées en français. Si le fichier principal est absent ou invalide, une copie de secours valide peut être chargée avec un avertissement ; un chargement échoué conserve la partie en mémoire.

## Contraintes

Règles visibles, interface redimensionnable dès 1280 × 720, navigation au clavier, nombres en complément des couleurs. Aucun mécanisme biologique réel. Les chiffres du prototype sont des paramètres de jeu provisoires.

## Public et décisions ouvertes

Public supposé : joueurs de jeux de stratégie sur PC ; niveau d'expérience à confirmer. Direction visuelle sombre cartographique avec turquoise et ambre confirmée par l'utilisateur. Les essais avec des joueurs extérieurs et l'équilibrage restent à organiser.
