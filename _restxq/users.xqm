xquery version "3.1" ;
module namespace synopsx.restxq.users = "synopsx.restxq.users" ;

(:~
 : This module deals with users
 :
 : @author SynopsX’ team
 : @since 2025-07
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

 declare default function namespace "synopsx.restxq.users" ;

 (:~
  : This resource function is the SynopsX’ home
  : @todo give contents
  :)
 declare
   %rest:path("/synopsx-beta/users")
   %output:method("html")
   %output:html-version("5.0")
 function getUsers() {
   let $queryParams := map {
     "project" : 'synopsx',
     "model" : 'synopsx',
     "function" : "getUsers"
   }
   (:user:list-details():)
   let $outputParams := map {
     "lang" : "fr",
     "layout" : "formListUsers.xml",
     "xquery" : "tei2html"
     }
   let $function := xs:QName(synopsx.models.synopsx:getModelFunction($queryParams))
   (: let $data := fn:function-lookup($function, 1)($queryParams) :)
   let $data := synopsx.models.synopsx:getHome($queryParams)
   return synopsx.mappings.templating:wrapper($queryParams, $data, $outputParams)
 };
