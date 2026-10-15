# Point 05 — Sauvegardes, prototype 0.5

Date : 15 octobre 2026. Suite du [point 04](04-j4-carte24.md). DEV-12 implémenté ; J5 reste à compléter par le tutoriel et l'aide contextuelle.

## Livré

- Trois emplacements manuels et un automatique, accessibles depuis menu, partie et bilan. Scénario, difficulté, jour et date locale affichés avant de charger.
- Automatique tous les dix jours simulés, au résultat, au menu depuis une partie et à la fermeture normale. Une fermeture forcée ne garantit pas les changements postérieurs au dernier enregistrement.
- État complet : régions, détections, points, achats, remède, scénario, difficulté, phase, événements actifs et déclenchés, journal, région sélectionnée et vitesse. Chargement en pause, temps d'affichage fractionnaire remis à zéro ; une partie terminée retrouve son bilan.
- Format JSON 1, données et moteur identifiés. Validation sur un nouveau monde avant remplacement de la partie en mémoire. Version incompatible refusée sans écrasement, pas de migration automatique.
- Graine et état RNG conservés comme chaînes décimales 64 bits. Remède conservé en octets IEEE-754 hexadécimaux : un test a constaté une différence du dernier bit après conversion décimale JSON, même à pleine précision.
- Écriture temporaire, validation de la relecture, conservation de la version précédente en `.bak`, renommage dans le même dossier. Un fichier principal absent ou endommagé utilise le secours valide avec avertissement ; une incompatibilité explicite refuse le chargement sans repli silencieux. Un fichier endommagé ne remplace pas un secours valide.
- Confirmation avant écrasement ou chargement remplaçant une partie en mémoire ; titre français et focus initial sur Annuler. Erreurs de stockage affichées ; fermeture après échec avec choix d'annuler ou de quitter sans enregistrer.
- Export distinct `build/windows-0.5.0/PandemicHorizon.exe`, guide et licences inclus. Les anciennes versions conservent leurs dossiers.

## Fichiers principaux

`scripts/persistence/save_store.gd` gère format, validation et stockage. `scripts/ui/main.gd` gère emplacements, confirmations, reprise et automatique. `tests/test_persistence.gd` couvre les cas de persistance. `tests/capture.gd` inclut les écrans vides, remplis et la confirmation. Les règles de croissance, de climat et de remède ne changent pas dans ce lot.

## Vérifications exécutées

- Import Godot 4.7.2 réussi. **1 134 contrôles, zéro échec**, dont 181 contrôles de sauvegarde ; régressions précédentes conservées.
- Trente états de Standard/Dégel × trois difficultés × cinq points de reprise, dont des fins de partie. Comparaison exacte des états restaurés et de cinquante journées suivantes, y compris pendant les fermetures superposées et les phases climatiques.
- Fichiers altérés, en-tête manquant, taille excessive, compteurs, achats sans prérequis, événements absents/invalides, version inconnue, RNG hors limites et remède non fini rejetés. Écriture impossible signalée. Secours après corruption ou absence du principal ; ancien secours préservé. Un chargement échoué conserve l'objet monde actif.
- Tests du contrôleur, automatique au jour 40 à vitesse ×4 et au menu ; clics injectés dans le viewport pour ouvrir les sauvegardes et la confirmation, navigation Échap, annulation et focus. Ces entrées sont synthétiques, pas des gestes physiques Windows.
- Vingt-deux captures par rendu réel à 1280 × 720 et 1920 × 1080. Revue indépendante finale : **ship**, aucun correctif matériel restant dans ce périmètre. La première capture « vide » en grand format a été corrigée pour nettoyer les fichiers de test entre résolutions. PRODUCT.md actualisé ; DESIGN.md et son sidecar conservés.
- Exécutable autonome copié seul dans un chemin avec espaces et accents : `RUNTIME_SMOKE_OK`, écriture/lecture locale, vingt journées suivantes identiques, standard victoire/défaite, Dégel, difficultés et démarrage graphique réussis.
- SHA256 : `A98D00BB4AFD00D38DAC67C2C147F7244665A15574A6F229FF6A5AF7CE13B241`.
- `git diff --check` réussi. Le compte rendu de livraison confirme le commit poussé et le résultat GitHub Actions ; le workflow ne publie pas de binaire.

## Limites et prochaine action

Sauvegardes locales, sans synchronisation cloud ni migration entre formats ou contenus incompatibles. Le secours représente l'enregistrement précédent, pas une seconde copie identique du dernier état. Le prototype n'assure pas la récupération de données jamais enregistrées après une coupure. Les essais de développement utilisent des dossiers distincts des sauvegardes du joueur.

**Prochain lot : tutoriel court et aide contextuelle**, pour expliquer pause, sélection régionale, prérequis, détection, événements et sauvegardes, sans imposer de lecture longue avant de jouer. Puis vérifier les parcours avec de vrais joueurs et sur un autre PC Windows. Le contenu final, les transports différenciés, les ressources audio/visuelles et la release 1.0 restent à réaliser.
