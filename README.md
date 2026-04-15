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

---

brancher tes routes SynopsX pour lever des erreurs propres avec web:error
ajouter un template HTML d’erreur plus propre dans le style du projet


Gestion des erreurs

- les erreurs Jetty/BaseX HTTP globales demandent une configuration dans le web.xml du webapp BaseX, qui n’est pas dans ce dépôt
- en développement, garder l’option RESTXQERRORS active
en production, désactive-la pour éviter d’exposer les traces complètes au client

```xml
<error-page>
  <error-code>400</error-code>
  <location>/synopsx-beta/error/http/400</location>
</error-page>

<error-page>
  <error-code>404</error-code>
  <location>/synopsx-beta/error/http/404</location>
</error-page>

<error-page>
  <error-code>500</error-code>
  <location>/synopsx-beta/error/http/500</location>
</error-page>

<error-page>
  <exception-type>java.lang.Throwable</exception-type>
  <location>/synopsx-beta/error/http/500</location>
</error-page>
```

---

# 7 avril 2026

XForms

Que mettre dans les queryParams ?

- models : peut avoir des valeurs multiples
- trigger n’a pas sa place

Par défaut, modifiait la première instance.

Charger une instance avec trois informations : le modèle à laquelle elle appartient, l’identifiant de l’instance que doit modifier, et son chemin.

Injecter les jsfunction, instance et espaces de nom



