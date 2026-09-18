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


declare default function namespace "synopsx.restxq.exemples" ;

(:~
 : resource function for corpus list
 :
 : @return a json representation of the corpus resource
 :)
declare 
  %rest:path('/corpus')
  %rest:produces('application/json')
  %output:media-type('application/json')
  %output:method('json')
  %output:json("indent=no, escape=yes")
function corpusJson() {
  let $queryParams := map {
    'project' : 'synopsx',
    'model' : '',
    'function' : 'getCorpusList'
    }
  let $function := synopsx.models.synopsx:getModelFunction($queryParams)
  let $data := map{
    'meta' : map{},
    'content' : map{ 'corpus' : <p>Corpus</p>,"name" : "Corpus Name","number" : 1,"keywords" : ("keyword1, keyword2") }
  }
  
  let $outputParams := map {
    'xquery' : 'tei2html'
    }

  return synopsx.mappings.synopsx2json:render($queryParams, $outputParams, $data)
};