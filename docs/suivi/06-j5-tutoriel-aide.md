# Point 06 — Tutoriel et aide, prototype 0.6

Date : 16 octobre 2026. Suite du [point 05](05-j5-sauvegardes.md). Fonctionnalités DEV-13 implémentées ; les essais de compréhension avec des joueurs restent à organiser.

## Livré

- Tutoriel facultatif, accessible au menu et rejouable. Six actions avec les contrôles du jeu : passer une journée, sélectionner Centrale, acheter Diffusion, consulter Boréale détectée, attendre la fin des deux fermetures d'une route, enregistrer puis charger un essai.
- Monde Standard d'entraînement séparé, avec points gagnés normalement, véritables prérequis, détection et événements. Arrêts pédagogiques aux jours 1, 26 et 32 ; avancées annoncées aux jours 10 et 23 entre les exercices. « Continuer » se débloque après réussite.
- Focus clavier sur l'action attendue, puis Continuer ou Terminer. Les achats interdits par le guidage portent « Hors exercice » ; les acquisitions et prérequis réels restent lisibles.
- Fichiers d'essai sous `user://training`, réinitialisés au démarrage du tutoriel. Aucun automatique d'entraînement. Le monde, le stockage, la sélection, la vitesse et les choix de la session précédente sont restitués en pause après sortie anticipée ou fin du tutoriel.
- Aide F1 depuis menu, partie, bilan, paramètres et sauvegardes ; retour au même écran en pause. Huit sujets, dont un contexte calculé à partir du scénario, de la région, des achats possibles et des événements actuels. L'aide respecte les restrictions pédagogiques du tutoriel.
- Export versionné `build/windows-0.6.0/PandemicHorizon.exe`, avec guide actualisé et licences. Les règles de simulation, le contenu JSON et le format de sauvegarde 1 restent ceux de la version précédente.

## Fichiers principaux

`scripts/ui/tutorial.gd` gère les étapes et réussites. `scripts/ui/help.gd` contient les huit sujets et le contexte. `scripts/ui/main.gd` intègre les écrans, le focus et l'isolation de la session. `tests/test_onboarding.gd` vérifie le parcours et la restitution. Le moteur ne dépend pas de ces écrans.

## Vérifications exécutées

- Import et export Godot 4.7.2 réussis. **1 201 contrôles, zéro échec**, dont 66 contrôles ciblés sur le tutoriel et l'aide.
- Six exercices terminés par événements clavier injectés dans le viewport, y compris Entrée, Tab et la confirmation réelle de chargement. Parcours à la souris ciblant les régions, Diffusion et l'enregistrement. Ce sont des entrées synthétiques Godot, pas des gestes physiques Windows.
- Aide en pause sans évolution du monde ni du RNG ; contexte du scénario et de la région vérifié. Retour vers jeu, menu et sauvegardes. Sortie du tutoriel depuis jeu, aide ou sauvegardes ; monde et fichier de sauvegarde d'origine inchangés après les six exercices.
- Conditions d'achat, points réels, détection et arrêts exacts aux jours 1/26/32 contrôlés. La route reste fermée au jour 26 après la tempête, puis rouvre au jour 32 après l'inspection.
- Quarante captures réelles à 1280 × 720 et 1920 × 1080. Revue indépendante : trois correctifs demandés et validés — états pédagogiques, focus, PRODUCT.md — disposition finale **ship** sur ces correctifs. DESIGN.md et son sidecar sont préservés. Le grand format reste une mise à l'échelle de la composition logique.
- Exécutable copié seul dans un chemin contenant espaces et accents : `RUNTIME_SMOKE_OK`, six exercices complets, sauvegarde/chargement d'essai, retour à la partie initiale, aide, standard, Dégel et démarrage graphique réussis.
- SHA256 : `665388C208BC84D35355AE8B4400A4EF86E1FF9CD6C59076C7F7B27D2429C917`.
- `git diff --check` réussi. Le compte rendu de livraison confirme le commit et GitHub Actions ; aucune release binaire GitHub n'est publiée par ce workflow.

## Limites et prochaine action

Le tutoriel couvre le Standard et explique Dégel dans l'aide ; il ne constitue pas un entraînement stratégique complet à toutes les difficultés. Il n'est jamais imposé et son achèvement n'est pas enregistré comme profil joueur. Les tests techniques ne prouvent pas encore la compréhension, le plaisir ou l'équilibrage auprès de débutants.

**Prochain lot proposé : différencier les transports terrestres, aériens et maritimes**, puis enrichir les choix d'évolution et mesurer leurs effets. Organiser en parallèle un essai physique sur un autre PC Windows et un parcours avec des joueurs. La durée cible, les ressources finales et l'archive de release 1.0 restent à finaliser.
