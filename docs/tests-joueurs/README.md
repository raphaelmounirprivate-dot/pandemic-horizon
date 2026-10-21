# Sessions exploratoires — candidat 0.24

Statut : à réaliser. Aucun résultat humain n'est consigné pour l'instant.

Prévoir trois sessions de 30 à 45 minutes : découverte, stratégie, puis contrôle clavier et accessibilité. Les profils sont des catégories d'expérience, pas des identités personnelles à collecter. Même exécutable et même version pour comparer les sessions ; graines 2042 puis 777, difficulté normale, puis difficile si le joueur maîtrise les commandes.

1. Lire BUILD.json et VERSION.json, vérifier le SHA-256 avec `Get-FileHash PandemicHorizon.exe`, noter Windows, GPU, résolution et échelle. Ne pas utiliser l'ancien dossier build/windows comme s'il contenait la version courante.
2. Faire naviguer librement, sélectionner une compétence et expliquer la fiche avant d'acheter. Noter le temps, l'hésitation et une éventuelle erreur ; ne pas souffler le bon choix.
3. Activer Crises réactives et comparer les réponses à la panne sur la même graine. Relever le jour, les points, le motif déclaré, la dépense et l'achat reporté.
4. Distinguer couverture globale, Relais arctiques facultatifs et Double relais obligatoire. Vérifier que le joueur comprend la défaite J60.
5. Sauvegarder pendant une crise, fermer et reprendre. Tester clavier seul, mouvements réduits, échelle 125/150 %, plein écran et son. Sur un autre PC : lancer sans Godot installé.
6. Compléter une copie de fiche-session.md par session ; ajouter une ligne au registre seulement après observation réelle.

## Si l'antivirus affiche une alerte

L'exécutable n'est pas signé : un antivirus peut le bloquer ou le mettre en quarantaine (AVG l'a déjà fait sur le PC de développement, détection `IDP.HELU.PSD11`). Ce n'est pas une erreur du joueur.

1. Ne pas désactiver l'antivirus et ne pas ajouter d'exclusion pour la session. Ne pas pousser le testeur à le faire.
2. Noter dans la fiche : antivirus et version, nom exact de la détection, fichier visé, moment (extraction, premier lancement, en cours de partie), action de l'antivirus (blocage, quarantaine, suppression).
3. Comparer le SHA-256 du ZIP avec le fichier `.sha256` publié à côté. S'il diffère, arrêter : le fichier n'est pas celui livré.
4. S'il est identique, le testeur décide seul de restaurer ou non le fichier depuis la quarantaine. S'il refuse, terminer la session sur ce constat : c'est une observation bloquante valable.
5. Transmettre la détection à l'organisateur, qui la signale comme faux positif à l'éditeur (procédure dans `docs/ANTIVIRUS.md` du dépôt).

Une erreur empêchant de finir une action est bloquante ; une erreur d'achat, un objectif mal compris ou un texte essentiel inaccessible est majeure. Les préférences visuelles isolées sont mineures. Corriger les blocages en premier et refaire le même parcours pour vérifier la correction.

Ne pas inventer des durées, scores de satisfaction ou citations. Une case vide signifie non observé. Trois sessions n'établissent pas un équilibre universel.
