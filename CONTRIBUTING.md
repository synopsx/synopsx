# Bienvenue sur le guide de contribution à SynopsX

Bienvenue sur cette page dédiée aux contributions. Nous sommes enchantés que vous envisagiez de contribuer à ce projet !

SynopsX est un projet libre publié sous licence GNU GPL et toutes les contributions seront indiquées dans la page de documentation.


## Nouveaux contributeurs

### Types de contributions acceptées et attendues

- corrections techniques
- correction des bugs
- corrections typos et orthographiques
- améliorations de la documentation
- nouvelles fonctionnalités après discussion sur la page [github.com/orgs/synopsx/discussions](https://github.com/orgs/synopsx/discussions)

Contenus non accepté actuellement

- améliorations trop nichées ou liées à des préférences personnelles
- changement à la structure générale du logiciel et au flux de travail

### Pour commencer

Commencez par prendre connaissance de la documentation du projet sur [github.com/synopsx/synopsx/wiki](https://github.com/synopsx/synopsx/wiki)


## Participer aux discussions ou soulever un problème

Merci d’utiliser les [Discussions](https://github.com/orgs/synopsx/discussions) pour discuter de nouvelles fonctionnalités, poser des questions ou obtenir de l’aide.

Les [Issues](https://github.com/synopsx/synopsx/issues) sont réservées au signalement des bugs et à l’organisation du travail.

### Création de discussions

Les discussions sont organisées en catégories, n’hésitez pas à les utiliser.

### Création des issues

Les issues sont rattachées à un projet. Merci de renseigner la catégorie et l’urgence.

## Contribuer au code ou à la documentation

### Faire des changements

Réaliser vos changement localement ou dans un codespace.

- forker le projet
- installer le logiciel et la version appropriée de BaseX
- Créer une branche de travail et commencez vos changements

### Changements qui ne devraient pas être commités

Dépendances tierces : nous n’acceptons pas de dépendances tierces dans les Pull request. 

Outils d’automatisation : l’équipe se charge de la maintenance et des outils d’automatisation. Nous demandons aux contributeurs de ne pas y apporter de changements lors de leur contribution.

Merci de bien veiller à ne pas introduire de fichiers systèmes dans vos commits.

### Commiter vos changements

La présentation de votre commit suit idéalement les directives suivantes.

Nous utilisons [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)

Utiliser un préfixe pour indiquer la nature du commit
- `feat:` pour la création d’une nouvelle fonctionnalité
- `feat(auth):` pour la création d’une nouvelle fonctionnalité concernant l’authentification
- `fix:` pour la correction d’un bug
- `docs:` pour la documentation
- `style:` pour le formatage du code 
- `test:` pour l’ajout de tests unitaires
- `refactor:` pour une refactorisation

Entre parenthèses après le préfixe il est possible de désigner la fonctionnalité concernée.

Exemples :
- `feat: Add user authentification feature``
- `fix: Solve serialisation issue (#33)`

N’hésitez pas à fournir des précisions et décrire dans un message de note le travail réalisé. Il est utile de mentionner le numéro de l’issue dans les fix.

### Faire un pull request

## Style de rédaction (documentation)

- clareté et simplicité
- langage inclusif
- langage technique accessible
- terminologie claire
- utilisation de la voix active

## Formatage du code XQuery

On invite les contributeurs à respecter la présentation générale du code existant. Les développements doivent en particulier utiliser l’architecture générale de l’application, l’organisation des fichiers (`_restxq/`, `models/`, `mappings/`) ainsi que les règles de nommage des espaces de nom pour les modules et les fonctions. Les fonctions utilisent une documentation avec [xqDoc](https://xqdoc.org).

### Règles générales

- Indentation de 2 espaces, jamais de tabulation.
- Chaînes entre guillemets doubles : `"layout.xml"`, pas `'layout.xml'`.
- Pas de code de débogage dans les commits (code commenté, `prof:dump`, valeurs de test comme `"vide"`).

### Structure d’un module

Dans l’ordre : version, namespace du module, en-tête xqDoc, déclarations de namespaces, imports, namespace de fonctions par défaut.

```xquery
xquery version "3.1" ;
module namespace synopsx.models.synopsx = "synopsx.models.synopsx" ;

(:~
 : This module provides models for SynopsX
 :
 : @author SynopsX’ team
 : @since 2025-03
 : @version 3.0
 :
 : This file is part of SynopsX, A lightweight framework for
 : XML corpora publication and exposure.
 :
 : GNU General Public License (GPL) v. 3
 :)

declare namespace file = "http://expath.org/ns/file" ;

import module namespace G = "synopsx.globals" at "../globals.xqm" ;

declare default function namespace "synopsx.models.synopsx" ;
```

- Le namespace reprend le chemin du fichier : `synopsx.{dossier}.{module}`.
- Les namespaces des modules BaseX et EXPath sont déclarés explicitement.
- Chaque déclaration se termine par ` ;`, avec une espace avant le point-virgule.

### Nommage

- Fonctions et variables en camelCase : `getLayoutPath`, `$queryParams`.
- Variables globales en majuscules, avec des tirets : `$G:TEMPLATING-REGEX`.
- Codes d’erreur en majuscules : `local:NOTEMPLATE`.

### Préfixes

Les fonctions du module s’appellent sans préfixe, grâce au namespace par défaut. Les fonctions standard gardent `fn:`.

```xquery
return fn:string-join($candidates, " or ")
```

### Mise en page

- Un `let` par ligne. `return` est aligné sur les `let`.
- Les paramètres et le résultat des fonctions sont typés.

```xquery
declare function getXsltPath($queryParams as map(*), $xsl as xs:string?) as xs:string {
  let $projectPath := $G:WEBAPP || "static/" || $queryParams?project || "/xsl/"
  let $defaultPath := $G:FILES || "xsl/"
  return …
};
```

### Maps

Écrire `map {`, avec une espace, et une entrée par ligne, avec une espace de chaque côté du `:`.

```xquery
let $outputParams := map {
  "layout" : "layout.xml",
  "xquery" : "tei2html"
}
```

### Fonctions RESTXQ

`declare` seul sur sa ligne, une annotation par ligne indentée, puis `function` en début de ligne.

```xquery
declare
  %rest:path("/synopsx/home")
  %output:method("html")
function home() {
  …
};
```

### Documentation (xqDoc)

Les fonctions utilisent une documentation avec [xqDoc](https://xqdoc.org).Chaque fonction est précédée d’un commentaire `(:~ … :)`, en anglais.

Des étiquettes supplémentaires `@rmq`, `@bug` et `@todo` sont utilisées pour les commentaires.

```xquery
(:~
 : this function builds the layout path based on the project hierarchy
 :
 : @param $queryParams the query params
 : @param $template the template name.extension
 : @return a path
 : @rmq a remark on implementation choices
 : @todo work left to do
 :)
```

## Documentation

Tous les changements notables sont documentés dans le fichier [`CHANGELOG.md`](CHANGELOG.md). Son formatage est basé sur [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), et ce projet adhère à [Semantic Versioning](https://semver.org/spec/v2.0.0.html).




## Top 10 des contributeurs

<a href="https://github.com/synopsx/synopsx/graphs/contributors">
  <img src="https://contrib.rocks/image?max=10&repo=synopsx/synopsx" />
</a>

Voir la [liste de tous les contributeurs](https://github.com/synopsx/synopsx/graphs/contributors)

## Licence

SynopsX est un logiciel libre publié selon les termes de la licence [GNU General Public Licence (GPL), Version 3](LICENCE).