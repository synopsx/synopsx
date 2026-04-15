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

Convention de nommage des templates
- utilisation _ comme séparateur pour distinguer les noms de fichier ? On pourrait laisser les utilisateurs libres comme le nom est déclaré littéralement

Nota : `files/` --> `static/`

## Utilisation d’XForms

SynopsX intègre l’utilisation de [XForms](https://www.w3.org/TR/xforms11/).

Par défaut, on propose l’utilisation du client libre et open source [XSLTForms](https://github.com/AlainCouthures/declarative4all) qui est proposé comme sous-module Git dans le répertoire `static/`.

Les instances, models et formulaires XForms sont placés dans le répertoire `template/`. Le nommage des fichiers est libre ce qui permet d’intégrer directement des XForms dans les templates. 

Par commodité, SynopsX utilise la convention de nommage suivante : 
- le nom des instances débute par `.`
- le nom des models débute par `model`
- le nom des formulaires débute par `form`

Dans les RESTXQ la déclaration des instances s’opère dans `queryParams` et les models et les formulaires sont déclarés dans `outputParams`.

On se demande s’il ne serait pas possible de faire directement les déclarations. Modulariser le code des models fait du sens à la condition qu’ils puissent être réutilisables. Avantage de modulariser le code pour alléger le client.

Dans l’hypothèse où l’utilisateur fait des déclarations directes dans les templates, SynopsX n’aurait qu’à faire l’assemblage
- déclaration espace de nom
- appel librairie
- association des templates
- param pour le choix de la syntaxe

outputParams
- xforms-lib : optionnel avec valeur par défaut xsltforms pour l’avenir
- xforms-syntax : optionnel avec valeur par défaut xf | xforms
- xforms: optionnel true() | false()

Il peut y avoir plusieurs instances. Il peut avoir un modèle, deux modèles, etc. et à l’intérieur de chaque modèle plusieurs instances. Il y a deux méthodes pour déclarer les instances, soit directement dans le modèle, soit en les appelant avec des resources externes avec `@src` s’il y en a plusieurs, celles-ci doivent avoir un identifiant.

Lors de la mise à jour d’un contenu avec la bdd, besoin de pouvoir identifier l’instance. Afin de simplifier, il serait sans doute utile que l’on ait le même mécanisme pour servir les instances vierges et les instances devant être mises à jour. Alors servir avec SynopsX

```xml
<model>
  <klkj eee="{ine}"></klkj>
  {instance}
  
  <instance xml:id="inst1" src="{}"/>
  <instance xml:id="instData">
    <data xmlns="">
        <q/>
    </data>
  </instance>
  <instance xml:id="inst2" src="{}"/>
</model>
```

Veut-on systématiquement un point d’accès XML ?

Il serait possible de dire que le modèle est tjrs le même et que la ressource ont vient la chercher par le formulaire. Pourrait avoir une valeur mise à jour par le templating.

En utilisant les mécanismes du templating par défaut. Peut être même pas besoin de déclarer les paramètres dans les queryParams, etc.



