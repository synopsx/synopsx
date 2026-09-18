# synopsx

SynopsX is a lightweight framework for seamless XML corpora publication and exposure — effortless as a breath! It is a free software freely redistributable and modifiable under the terms of the GNU General Public License (GPL) v. 3.0

## Installation

Prerequisites :
- SynopsX requires [BaseX](http://basex.org) > 10 (you would need Java on your computer)
- using XSLT transformer needs the [Saxon HE](https://www.saxonica.com/products/products.xml) processor (install the .jar file into `basex/lib/`)

- Clone [Synopsx repository](https://github.com/synopsx/synopsx)
- Symlink or put this repository into `basex/webapp/`
- Start [BaseX in HTTP](https://docs.basex.org/12/Web_Application)
- Go to [http://localhost:8080/synopsx]

Pour utiliser la gestions des utilisateurs de SynopsX, vous devez avoir créé votre compte admin sur BaseX. cf. https://docs.basex.org/main/Commands#alter_password Le comportement de BaseX pour la création du compte admin varie selon les versions (cf. https://docs.basex.org/main/Database_Server#startup, https://docs.basex.org/main/Web_Application#startup)

Par exemple, en invite de commande BaseX : 
```
ALTER PASSWORD admin (password)
```

## Changes

- Suppression des fonctionnalités bloquantes lors de l’installation (création db synopsx, user)
- Mise en avant des processus internes
- Utilisation de références explicites aux fonctions dans les queryParams pour faciliter la navigation dans le code
- Harmonisation de la syntaxe et des déclarations, normalisation des nommages de modules

## Documentation

See the [Project’s Wiki](https://github.com/synopsx/synopsx/wiki)

## Licence

[LICENCE](LICENCE) : GNU General Public License (GPL) v. 3