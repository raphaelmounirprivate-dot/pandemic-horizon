# Pandemic Horizon

Jeu de stratégie original en français, pour Windows et hors ligne, décrit dans le README et le plan de développement.

## Plateforme et technologie

Application de bureau Windows, Godot 4.7.2 standard et GDScript. Simulation abstraite indépendante de l'interface ; ressources locales. Aucun compte ni serveur.

## Parcours

Choisir un scénario et une difficulté, suivre la propagation entre régions fictives, acheter des évolutions avec prérequis, gérer le temps et comprendre le résultat. Le prototype 0.5 porte sur 24 régions, Standard et Dégel 2042, avec détection, réactions régionales, événements temporaires et phases climatiques. Le tutoriel et le volume final de contenu restent à développer.

Les sauvegardes locales sont accessibles depuis le menu, la partie et le bilan : trois emplacements manuels et un emplacement automatique. Chaque emplacement renseigné affiche le scénario, la difficulté, le jour et la date. La sauvegarde automatique intervient tous les dix jours, en fin de partie, au retour au menu et à la fermeture. Charger une partie reprend en pause ; une partie terminée ouvre son bilan.

Le remplacement d'un emplacement existant ou le chargement qui remplace une partie en mémoire demande confirmation, avec « Annuler » au focus initial. Les erreurs de lecture ou d'écriture sont affichées en français. Si le fichier principal est absent ou invalide, une copie de secours valide peut être chargée avec un avertissement ; un chargement échoué conserve la partie en mémoire.

## Contraintes

Règles visibles, interface redimensionnable dès 1280 × 720, navigation au clavier, nombres en complément des couleurs. Aucun mécanisme biologique réel. Les chiffres du prototype sont des paramètres de jeu provisoires.

## Public et décisions ouvertes

Public supposé : joueurs de jeux de stratégie sur PC ; niveau d'expérience à confirmer. Direction visuelle sombre cartographique avec turquoise et ambre confirmée par l'utilisateur. Les essais avec des joueurs extérieurs et l'équilibrage restent à organiser.
