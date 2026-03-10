# SynopsX’s Roadmap

- review
  - mise à jour Basex10
  - simplification
  - intégration du moteur de recherche
  - intégration des sorties TEI par défaut
  - amélioration de la documentation
- documentation
- users module
- errors module
- DTS
- statify
- openapi documentation
- oaipmh module


Discussion sur le nommage 
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
