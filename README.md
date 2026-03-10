# synopsx-beta

SynopsX is a lightweight framework for seamless XML corpora publication and exposure — effortless as a breath!

It is free software freely redistributable and modifiable under the terms of the GNU General Public License (GPL) v. 3

## Installation

Prerequisites :
- SynopsX requires [BaseX](http://basex.org) > 10 (you would need Java on your computer)
- using XSLT transformer needs the [Saxon HE](https://www.saxonica.com/products/products.xml) processor (install the .jar file into `basex/lib/`)

- Clone [Synopsx repository](https://github.com/synopsx/synopsx-beta)
- Symlink or put this repository into `basex/webapp/`
- Start [BaseX in HTTP](https://docs.basex.org/12/Web_Application)
- Go to [http://localhost:8080/synopsx]

## Changes

- Suppression des fonctionnalités bloquantes lors de l’installation (création db synopsx, user)
- Mise en avant des processus internes
- Utilisation de références explicites aux fonctions dans les queryParams pour faciliter la navigation dans le code
- Harmonisation de la syntaxe et des déclarations, normalisation des nommages de modules

## Questions

L’introduction des templating et de jsoner dans les models.synopsx est-elle compréhensible ?

## Documentation

Synopsx est un cadre léger pour la publication de sources structurées.

Les fichiers sont organisés


# Simplifier les espaces de nom ?

Afin de simplifier les déclarations, partager les espaces de nom.

Import module ou declare namespace