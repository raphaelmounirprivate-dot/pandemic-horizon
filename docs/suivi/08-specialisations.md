# Point 08 — Spécialisations, prototype 0.8

Date : 16 octobre 2026. Suite du [point 07](07-transports.md).

## Livré

Trois spécialisations facultatives exigent Mobilité et s'excluent deux à deux. Une seule peut être acquise, sans annulation :

| Spécialisation | Coût | Échanges du type | Vitesse du remède |
| --- | --- | --- | --- |
| Réseau terrestre | 9 pts | Terrestres ×1,8 | ×1,08 |
| Pont aérien | 10 pts | Aériens ×3 | ×1,18 |
| Logistique maritime | 10 pts | Maritimes ×2,5 | ×1,12 |

Le bonus ne touche pas les autres transports et ne rouvre aucune route. Le coût retarde les autres achats ; le multiplicateur de recherche reste actif après achat et se combine avec Discrétion et les événements. Standard propose six évolutions et Dégel neuf, pour au plus quatre/sept achats à cause des exclusions.

Les exclusions JSON sont validées : références connues, uniques, réciproques, sans auto-exclusion ni exclusion d'un prérequis direct ou indirect. Le moteur contrôle prérequis, coût et incompatibilité avant achat ; le chargement refuse deux spécialisations même avec des points suffisants.

Le panneau expose les effets et contreparties avant achat. Un groupe contient bouton, effet et état ; le focus clavier et l'achat révèlent le groupe entier après stabilisation de la mise en page. Un clic maintenu ne déplace pas sa cible. F1 explique l'exclusivité et les coefficients ; les autres choix portent le nom de la spécialisation incompatible.

## Compatibilité 0.7

Le dossier `user://saves/transports-1` et le format 1 sont conservés. Trois empreintes connues de la version 0.7 sont reconnues : distribution locale, LF et CRLF. Les anciens achats sont seuls autorisés dans un fichier identifié 0.7. La lecture reconstruit et valide un nouveau monde, signale la reprise en pause et ne réécrit pas le fichier.

La première écriture 0.8 garde l'original en `.bak` ; les suivantes font tourner ce secours normalement. L'empreinte courante normalise les fins de ligne. Les nouvelles spécialisations sont disponibles selon les prérequis et points de la partie reprise ; sans nouvel achat, l'ordre des calculs 0.7 reste identique. Les formats, empreintes ou moteurs inconnus restent refusés. Une partie réenregistrée en 0.8 ne se charge pas avec l'ancien exécutable. Les parties 0.6 restent séparées.

`tests/fixtures/` conserve quatre états générés avant modification avec le commit `3d89d6b`, graine 2042, Standard/Dégel normaux : jour 56 puis jour 76 après vingt pas sans achat. Ces références ne doivent pas être régénérées avec une nouvelle version pour masquer une régression.

## Vérifications

- Suite complète : **1 462 contrôles, zéro échec**, dont 174 contrôles ciblés sur les spécialisations, la compatibilité et la visibilité.
- Depuis 10 000 actifs, avec Mobilité et la spécialisation : 54 imports terrestres, 108 aériens, 60 maritimes. Accélération réelle du remède, autres modes inchangés, prix, refus et exclusion dans les deux sens vérifiés.
- Achats avec économie légale, sauvegarde, vingt journées suivantes identiques. Reprise des deux scénarios 0.7 comparée aux véritables états futurs de référence ; lecture sans écriture et premier secours identique au fichier ancien contrôlés.
- Parcours Tab/Maj+Tab sur les neuf groupes de Dégel à 1280 × 720 et 1920 × 1080, avant et après achat. Clic maintenu : cible immobile, achat au relâchement, description révélée ensuite. Ces événements sont synthétiques Godot.
- Cinquante-deux captures réelles aux deux tailles. Revue indépendante : trois correctifs validés — groupe entier visible, tests de visibilité, documentation — disposition **ship** sur ces correctifs. PRODUCT.md/DESIGN.md actualisés ; seule la description du panneau dans le sidecar ignoré est ajustée, sans modifier tokens ou schéma.
- Import/export et exécutable autonome vérifiés depuis un chemin avec espaces et accents : Standard, Dégel, acquisitions exclusives, persistance, six exercices et aide. Les références 0.7 sont vérifiées par les tests sources ; elles ne sont pas incluses dans le binaire.
- SHA-256 de `build/windows-0.8.0/PandemicHorizon.exe` : `1CF6366367225300DBD319E157B1B84F42BF1537DA42EFDBC519E01CA122C9EA`.
- Le compte rendu de livraison confirme le commit poussé et GitHub Actions. Les binaires et captures restent hors de Git.

## Exploration d'équilibrage 0.8

Commande : `dev.ps1 Balance`, graines 7/42/2042, trois difficultés, tous les départs autorisés. Le script conserve les anciennes politiques et ajoute trois ordres Diffusion → Mobilité → spécialisation → Discrétion. Tous les achats utilisent les points normalement gagnés. Le CSV est généré dans `build/qa/balance.csv`.

| Scénario | Difficulté | Parties | Victoires | Défaites | Jours |
| --- | --- | --- | --- | --- | --- |
| Standard | Facile | 504 | 489 | 15 | 71–158 |
| Standard | Normale | 504 | 438 | 66 | 71–132 |
| Standard | Difficile | 504 | 381 | 123 | 72–119 |
| Dégel | Facile | 24 | 24 | 0 | 78–120 |
| Dégel | Normale | 24 | 21 | 3 | 78–111 |
| Dégel | Difficile | 24 | 21 | 3 | 78–97 |

Total : **1 584 parties, 1 374 victoires, 210 défaites**, 152 083 pas. Chaque départ/difficulté conserve au moins une victoire parmi ces politiques. En Standard difficile, les nouvelles politiques donnent terrestre 69/72, aérien 49/72, maritime 47/72 ; l'ancienne politique Mobilité puis Discrétion donne 72/72. Ces résultats mêlent effet de spécialisation, coût et retard de Discrétion : ils ne mesurent pas uniquement la pénalité de recherche et ne représentent pas des joueurs humains. Les temps par pas ont été mesurés pendant d'autres vérifications et ne servent pas de référence de performance isolée.

## Prochaine action

Comparer les ordres d'achat et les points de départ avant de modifier les coefficients. Vérifier la lisibilité et le rythme avec des joueurs, puis préparer des objectifs ou événements qui demandent d'adapter la stratégie en cours de partie. La durée cible de 15 à 30 minutes, les ressources finales et la release 1.0 restent à réaliser ; les parties actuelles sont plus courtes. Préserver les références 0.7 lors des prochains changements de règles.
