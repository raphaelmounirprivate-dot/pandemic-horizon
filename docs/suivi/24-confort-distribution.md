# Point 24 — Confort et candidat Windows 0.19

Date : 17 octobre 2026. Base : `c995547`. Lot F, partie technique.

## Réalisation

Paramètres locaux : réduction des mouvements, lecture agrandie dans l'aide/actualités/bilan, sons facultatifs et volume. Les véhicules s'immobilisent sans interrompre les journées. Les courbes distinguent trait et tirets en plus de la couleur. Trois signaux synthétiques originaux accompagnent achat, détection et issue ; désactivés par défaut. Les retours visuels restent disponibles sans son. Les préférences se conservent ensemble, y compris les clés inconnues ; aucun effet sur les règles, le hasard ou les sauvegardes des parties.

## Vérification

3 141 contrôles passants, dont 44 ciblés sur les préférences, commandes clavier synthétiques, reprise, volume nul et comparaison exacte des mondes avec/sans confort. Douze captures natives exactes aux trois tailles ; revue indépendante `ship`. Tests de ressources et parcours dans l'exécutable exporté, puis lancement graphique sans erreur. Empreinte SHA-256 de l'exécutable : `A2B62B2A3EB71E1C5B0E0DDC5475B2D15DEF9B1FCF759E4ECFEC0F358407AA03`.

Les validations GitHub des étapes 0.14 à 0.18 ont réussi. La validation GitHub du commit de ce lot sera contrôlée après push.

## Distribution et sauvegarde

`scripts/package-windows.ps1`, exécuté après commit propre, revérifie l'exécutable puis crée une archive Windows x64 dans `build/releases/`. Elle contient exécutable, guide, notes, formulaire joueurs, licences et VERSION.json avec commit et empreinte. L'exécutable contenu dans le ZIP est vérifié par SHA-256 ; une empreinte du ZIP est produite à côté. Le nom inclut le commit, les archives existantes sont conservées. Le code est poussé sur main ; aucune release binaire GitHub automatique.

Bundle Git et sources ZIP vérifiés séparément avec `scripts/checkpoint.ps1`, comme aux étapes précédentes. Les anciens exports restent disponibles ; le guide actif de cette version est `build/windows-0.19.0/GUIDE-JOUEUR.md`.

## Limites et suite

FIN-01 et FIN-02 implémentés et vérifiés automatiquement ; FIN-03 est partiellement accompli. Les essais physiques souris/clavier, écoute, plein écran/échelles Windows, second PC et compréhension/équilibrage avec des joueurs restent **non réalisés**. CNT-04 reste aussi partiellement ouvert pour cette raison. Le protocole [TESTS-JOUEURS.md](../TESTS-JOUEURS.md) permet de les consigner. La 0.19 est une version candidate : ne pas la rebaptiser 1.0 validée tant que ces essais n'ont pas abouti.
