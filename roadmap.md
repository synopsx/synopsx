# SynopsX’s Roadmap

Now (Maintenant)

Next (Prochainement)

Later (Plus tard)


## Révision du code et améliorations de base

- [x] mise à jour vers Basex10
- [x] révision de la structure d’ensemble du code
- [x] supression des freins au démarrage
- [x] renommage de `files` en `static`
- [ ] simplifications

## Nouvelles fonctionnalités
- [x] personnalisation du workspace
- [x] ajout d’un module d’erreur
- [x] amélioration des regex dans les templates
- [x] intégration de XForms
- [~] users module (en cours)
- [~] amélioration de la documentation
- [ ] intégration du moteur de recherche
- [ ] intégration des sorties TEI par défaut
- [ ] DTS (peut-être pas, utilisation de DOTS possible)
- [ ] module de statification
- [ ] création automatique d’une documentation de l’API
- [ ] création automatique d’une page OpenAPI
- [ ] module OAIPMH

## Roadmap du module utlisateurs

- [x] implémentation des formulaires xforms
- [x] création des fonctions users
- [x] modularisation du code pour suivre la structure rest/models/templates
- [ ] implémentation des users patterns 
- [ ] sessions ?

## Discussions sur le nommage 
- pb templating
- render, spécifique au template
- faire une sortie json
- renommer sérialisation
- les mapping sont toujours liés à un modèle de données

L’utilisation du terme modèle est utile car les gens qui travaillent avec des données XML voient tout de suite ce qu’on y met.

--> utiliser "serializations" / "renderings" (on parle aussi de "marshallings" pour serialization)

Dans templating.xqm lorsque l’on choisit XQuery fait appel à  tei2html
- ligne 136 rendre la désignation du modèle de données générique

Les paramètres génériques queryParams et outputParams font du sens.

On discute l’opportunité des paramètres de requête. DbName. 

Utiliser 11.9

Todo
- enlever la dépendance du voc dans le templating (tei2html)
- faire fonctionner le templating

Discussion sur le catch des erreurs
Discussion sur l’autodocumentation projets ODD
Discussion sur l’intégration XForms



