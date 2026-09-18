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

Utiliser un préfixe pour indiquer la nature du commit
- `feat:` pour la création d’une nouvelle fonctionnalité
- `fix:` pour la correction d’un bug
- `docs:` pour la documentation
- `style:` pour le formatage du code 
- `test:` pour l’ajout de tests unitaires

Exemples

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

## Style d’écriture du code

- Respect de la présentation du code existant
- Modularité restxq, models, mappings et système de nommage pour les espaces de nom et les fonctions
- Utilisation de XQdoc pour la documentation des fonctions

@todo 

## Top 10 des contributeurs

<a href="https://github.com/synopsx/synopsx/graphs/contributors">
  <img src="https://contrib.rocks/image?max=10&repo=synopsx/synopsx" />
</a>

Voir la [liste de tous les contributeurs](https://github.com/synopsx/synopsx/graphs/contributors)

## Licence

SynopsX est un logiciel libre publié selon les termes de la licence [GNU General Public Licence (GPL), Version 3](LICENCE).