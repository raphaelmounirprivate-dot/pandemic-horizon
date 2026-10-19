# Antivirus et exécutable non signé

Statut au 19 octobre 2026 : faux positif constaté avec AVG sur le PC de développement ; **aucun signalement à l'éditeur n'est encore consigné**, aucun essai sur le PC d'un testeur.

## Constat

- AVG a mis en quarantaine l'exécutable de contrôle (`IDP.HELU.PSD11`) et `scripts/package-windows.ps1` (`IDP.Generic`), voir le [point 28](suivi/28-familles-validation.md).
- Les détections `IDP.*` sont heuristiques : elles visent souvent un exécutable non signé qui lance PowerShell, ce que fait le smoke test de livraison.
- La signature de code est désactivée : `codesign/enable=false` dans `export_presets.cfg`.

## Règle

Ne jamais désactiver une protection ni ajouter d'exclusion pour faire passer un contrôle ou une session, ni le demander à un testeur. Consigner la détection et laisser la personne concernée décider.

## Signaler le faux positif (à faire par l'auteur)

AVG et Avast partagent le même moteur et le même formulaire de signalement de faux positif, sur leurs sites officiels.

1. Prendre l'archive livrée `build/releases/PandemicHorizon-<version>-Windows-x64-<commit>.zip` et son fichier `.sha256`.
2. Envoyer l'archive (ou l'exécutable seul si le formulaire l'exige) avec : nom exact de la détection, SHA-256, version d'AVG, et une description courte (« jeu Godot 4.7.2 hors ligne, auteur identifié, sources privées disponibles sur demande »).
3. Consigner ici la date, le fichier, l'empreinte et la référence du ticket. Après la réponse de l'éditeur, refaire le contrôle avec la protection **active** avant de déclarer le blocage résolu.

| Date | Fichier | SHA-256 | Détection | Référence / réponse |
| --- | --- | --- | --- | --- |
| — | — | — | — | Non signalé |

## Signature de code (plus tard)

Signer l'exécutable réduirait les alertes heuristiques et l'écran SmartScreen, sans les supprimer. Il faut un certificat payant (par exemple Azure Trusted Signing) ; les offres gratuites pour l'open source exigent en général un dépôt public. Activer `codesign/enable` est un changement de chaîne de livraison : à traiter comme un lot à part, avec vérification de `BUILD.json` et du paquet.
