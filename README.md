# Synopsx


SynopsX is a light framework to publish full XML corpus with BaseX XML native database.

## Installation

### Prerequisites
SynopsX requires Java version 8

* Download the last JDK from this Oracle Page (not the JRE!): http://www.objis.com/formation-java/tutoriel-java-installation-jdk.html. Before downloading choose the appropriate version (system + processor: i.e. Mac OSX x64)
* Go to you Downloads directory and double-click on the installation file: i.e.: jdk-8u60-macosx-x64.dmg or jdk-8u60-macosx-x64.exe
* Complete installation
* Open a terminal to check the Java JDK version with the following command: java -version

### Automatic installation

For Mac OS and Linux, you may use the [install.sh](https://raw.githubusercontent.com/synopsx/synopsx/master/install.sh) script

### Manual installation

#### BaseX installation:

* Go to http://basex.org/
* Click on "Download BaseX 8.3"

#### Add Saxon processor HE to BaseX:
* Download from (choose the zipped directory, on top of the page): http://sourceforge.net/projects/saxon/files/
* Unzip downloaded file
* Put content on the following directory: basex/lib


#### SynopsX installation

* Go to: https://github.com/synopsx/synopsx
* Download the zipped synopsX directory
* Unzip synopsx-master.zip
* Rename synopsx-master to synopsx
* Place synopsx directory in basex/webapp
