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
import module namespace synopsx.mappings.jsoner = "synopsx.mappings.jsoner" at "../mappings/jsoner.xqm" ;

import module namespace synopsx.mappings.tei2html = "synopsx.mappings.tei2html" at "../mappings/tei2html.xqm" ;

declare namespace tei = "http://www.tei-c.org/ns/1.0" ;

declare default function namespace "synopsx.restxq.exemples" ;


(:~
 : this is a test function for jsoner
 :
 : @return a json representation
 : @rmq we may need a namespace
 :)
declare
  %rest:path("/synopsx/jsoner")
  %rest:produces("application/json")
  %output:media-type("application/json")
  %output:method("json")
  %output:json("indent=no, escape=yes")
function getJson() {
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
    "corpus" : <tei:persName>Corpus</tei:persName>, 
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
  return synopsx.mappings.jsoner:jsoner($queryParams, $data, $outputParams)
};

(:~
 : this is a test function for jsoner
 :
 : @return a json representation
 : @rmq we may need a namespace
 :)
declare
  %rest:path("/synopsx/test")
  %output:method("html")
  %output:html-version("5.0")
function getTest() {
  let $queryParams := map {
    "project" : "synopsx",
    "model" : "",
    "function" : ""
    }
  let $meta := map{
    "message" : <tei:p>Corpus</tei:p>, 
    "name" : "Corpus Name", 
    "number" : 1, 
    "keywords" : ("keyword1", "keyword2") (: to test with a real xml sequence :)
    }
  let $content := map{ 
    "message" : <tei:p>Corpus</tei:p>, 
    "name" : "Corpus Name", 
    "number" : 1, 
    "keywords" : ("keyword1", "keyword2") (: to test with a real xml sequence :)
    }
  let $data := map{
    "meta"    : $meta,
    "content" : $content
    }
  let $outputParams := map {
    "xquery" : "tei2html", (: user defined serialisation :)
    "layout" : "layout.xml",
    "pattern" : "incArticle.xml"
    }
  return synopsx.mappings.templating:wrapper($queryParams, $data, $outputParams)
};

(:~
 : this is a test function for xslt serialization
 :
 : @return a json representation
 : @rmq we may need a namespace
 :)
declare
  %rest:path("/synopsx/xslt")
  %output:method("html")
  %output:html-version("5.0")
function getXslt() {
  let $queryParams := map {
    "project" : "synopsx",
    "model" : "",
    "function" : ""
    }
  let $meta := map{
    "message" : <tei:p>Corpus</tei:p>
    
    }
  let $content := map{ 
    "message" : <tei:persName>Corpus</tei:persName>
    }
  let $data := map{
    "meta"    : $meta,
    "content" : $content
    }
  let $outputParams := map {
    "xslt" : "default.xsl", (: user defined serialisation :)
    "layout" : "layout.xml",
    "pattern" : "incArticle.xml"
    }
  return synopsx.mappings.templating:wrapper($queryParams, $data, $outputParams)
};