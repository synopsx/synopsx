xquery version "3.1" ;
module namespace synopsx.restxq.synopsx = "synopsx.restxq.exemples" ;

(:~
 : This module provides the SynopsX’ REST entries
 :
 : @author Synopsx’ team
 : @since 2025-03
 : @version 3.0
 :
 : This file is part of SynopsX, A lightweight framework for
 : XML corpora publication and exposure.
 :
 : GNU General Public License (GPL) v. 3
 :)

declare namespace rest = "http://exquery.org/ns/restxq" ;
declare namespace file = "http://expath.org/ns/file" ;
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization" ;
declare namespace db = "http://basex.org/modules/db" ;
declare namespace web = "http://basex.org/modules/web" ;
declare namespace update = "http://basex.org/modules/update" ;
declare namespace perm = "http://basex.org/modules/perm" ;
declare namespace user = "http://basex.org/modules/user" ;
declare namespace session = "http://basex.org/modules/session" ;
declare namespace http = "http://expath.org/ns/http-client" ;
declare namespace map = "http://www.w3.org/2005/xpath-functions/map" ;


import module namespace G = "synopsx.globals" at "../globals.xqm" ;
import module namespace synopsx.models.synopsx = "synopsx.models.synopsx" at "../models/synopsx.xqm" ;
import module namespace synopsx.mappings.templating = "synopsx.mappings.templating" at "../mappings/templating.xqm" ;
import module namespace synopsx.mappings.synopsx2json = "synopsx.mappings.synopsx2json" at "../mappings/synopsx2json.xqm" ;


declare namespace tei = "http://www.tei-c.org/ns/1.0" ;


declare default function namespace "synopsx.restxq.exemples" ;

(:~
 : resource function for corpus list
 :
 : @return a json representation of the corpus resource
 :)
declare
  %rest:path('/corpus.json')
  %rest:produces('application/json')
  %output:media-type('application/json')
  %output:method('json')
  %output:json("indent=no, escape=yes")
function corpusJson() {
  let $queryParams := map {
    "project" : "synopsx",
    "model" : "",
    "function" : ""
    }
  let $data := map{
    'meta' : map{},
    'content' : map{ 'corpus' : <p>Corpus</p>,"name" : "Corpus Name","number" : 1,"keywords" : ("keyword1, keyword2") }
  }

  let $outputParams := map {
    'xquery' : 'tei2html'
    }

  return synopsx.mappings.synopsx2json:jsoner($queryParams, $outputParams, $data)
};

(:~
 : resource function for corpus list
 :
 : @return an html representation of the corpus resource
 :)
declare
  %rest:path('/corpus.html')
  %output:method('html')

function corpusHtml() {
  let $queryParams := map {
    'project' : 'synopsx',
    'model' : '',
    'function' : ''
    }

    let $data := map{
    'meta' : map{'title':"Corpus",'dc:title':'Corpus'},
    'content' : map{ 'corpus' : <p>Corpus</p>,"name" : "Corpus Name","number" : 1,"keywords" : ("keyword1", "keyword2") }
  }
  let $outputParams := map {
    'xquery' : 'tei2html'
  }

  let $data :=synopsx.mappings.synopsx2json:jsoner($queryParams, $outputParams, $data)

  let $outputParams := map {
    'xquery' : 'json2html',
    "lang" : "fr",
    "layout" : "layout.xml",
    "pattern":""
    }



    return synopsx.mappings.templating:wrapper($queryParams, $data, $outputParams)
  


};

 


(:~
 : this is a test function for jsoner
 :
 : @return a json representation
 : @rmq we may need a namespace
 :)
declare
  %rest:path("/jsoner-alt")
  %rest:produces("application/json")
  %output:media-type("application/json")
  %output:method("json")
  %output:json("indent=no, escape=yes")
function getJsonAlt() {
  let $queryParams := map {
    "project" : "synopsx",
    "model" : "",
    "function" : ""
    }
  let $meta := map{
    "corpus" : <tei:p>Corpus</tei:p>, 
    "name" : "Corpus Name", 
    "number" : 1, 
    "keywords" : ("keyword1", "keyword2") (: to test with a real xml sequence :)
    }
  let $content := map{ 
    "corpus" : <tei:p>Corpus</tei:p>, 
    "name" : "Corpus Name", 
    "number" : 1, 
    "keywords" : ("keyword1", "keyword2") (: to test with a real xml sequence :)
    }
  let $data := map{
    "meta"    : $meta,
    "content" : $content
    }
  let $outputParams := map {
    'xquery' : 'tei2html' (: user defined serialisation :)
    }
  return synopsx.mappings.synopsx2json:jsoner($queryParams, $outputParams, $data)
};



declare
  %rest:path('/api.json')
  %rest:produces('application/json')
  %output:media-type('application/json')
  %output:method('json')
  %output:json("indent=no, escape=yes")
function api() {
  let $queryParams := map {
    "project" : "synopsx",
    "model" : "",
    "function" : ""
    }
  
  let $modelName:='users'
  let $projectNamespace := $queryParams?project || '.mappings.' || $modelName
  let $defaultNamespace := 'synopsx.models.' || $modelName
  let $projectLocation := $G:WORKSPACE || $queryParams?project || '/models/' || $modelName|| '.xqm'
  let $defaultLocation := $G:HOME || 'models/' || $modelName || '.xqm'
  let $namespace := if (file:exists($projectLocation)) then $projectNamespace else $defaultNamespace
  let $location := if (file:exists($projectLocation)) then $projectLocation else $defaultLocation
  let $module := fn:load-xquery-module($namespace, map { 'location-hints': $location })
  let $data := map{
    'meta' : map{},
    'content' : $module }

  let $outputParams := map {
    'xquery' : 'json2html'
    }
    
  return synopsx.mappings.synopsx2json:jsoner($queryParams, $outputParams, $data)
};
