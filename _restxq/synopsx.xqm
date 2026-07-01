xquery version "3.1" ;
module namespace synopsx.restxq.synopsx = "synopsx.restxq.synopsx" ;

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

declare default function namespace "synopsx.restxq.synopsx" ;

(:~
 : This resource function redirects to the SynopsX’ home or the configuration page
 :)
declare
  %rest:path("/synopsx-beta")
function index() {
  web:redirect(
    if (db:exists("synopsx"))
      then "/synopsx-beta/home"
      else "/synopsx-beta/install"
    )
};

(:~
 : This resource function is the SynopsX’ home
 : @todo give contents
 :)
declare
  %rest:path("/synopsx-beta/home")
  %output:method("html")
  %output:html-version("5.0")
function home() {
  let $queryParams := map {
    "project" : 'synopsx',
    "model" : 'synopsx',
    "function" : "getHome"
  }
  let $outputParams := map {
    "lang" : "fr",
    "layout" : "layout.xml",
    "pattern" : "incArticle.xml",
    "xquery" : "tei2html"
    }
  let $function := xs:QName(synopsx.models.synopsx:getModelFunction($queryParams))
  let $data := fn:function-lookup($function, 1)($queryParams)
  return synopsx.mappings.templating:wrapper($queryParams, $data, $outputParams)
};

(:~
 : This resource function is the SynopsX’ home
 : @todo give contents
 :)
declare
  %rest:path("/synopsx-beta/test/xslt")
  %output:method("html")
  %output:html-version("5.0")
function test-xslt() {
  let $queryParams := map {
    "project" : 'synopsx',
    "model" : 'synopsx',
    "function" : "getHome"
  }
  let $outputParams := map {
    "lang" : "fr",
    "layout" : "layout.xml",
    "pattern" : "incArticle.xml",
    "xsl" : "default.xsl"
    }
  let $function := xs:QName(synopsx.models.synopsx:getModelFunction($queryParams))
  let $data := fn:function-lookup($function, 1)($queryParams)
  return synopsx.mappings.templating:wrapper($queryParams, $data, $outputParams)
};

(:~
 : This resource function is a test for the xforms integration
 :)
declare
  %rest:path("/synopsx-beta/xforms")
  %output:method("xml")
function test-xforms() {
  let $queryParams := map {
    "project" : 'synopsx',
    "model" : 'synopsx',
    "function" : "getUsers"
  }
  let $outputParams := map {
    "lang" : "fr",
    "layout" : "formListUsersXf.xml",
    (:"pattern": "incInstance.xml",:)
    "xforms-lib" : "xsltforms",
    "xforms-prefix" : fn:true(),
    "xforms" : fn:true()
  }

  let $function := xs:QName(synopsx.models.synopsx:getModelFunction($queryParams))
  let $data := fn:function-lookup($function, 1)($queryParams)
  (:let $data := synopsx.models.synopsx:getUsersXforms($queryParams):)
  return synopsx.mappings.templating:wrapper($queryParams, $data, $outputParams)
};

(:~
 : This resource function is a test for the xforms integration with pseudo-element
 :)
declare
  %rest:path("/synopsx-beta/xforms-pseudo")
  %output:method("html")
  %output:html-version("5.0")
function test-xforms-pseudo() {
  let $queryParams := map {
    "project" : 'synopsx',
    "model" : 'synopsx',
    "function" : "getUsersXFormsPseudo"
  }
  let $outputParams := map {
    "lang" : "fr",
    "layout" : "formListUsers.xml",
    (: "pattern" : "incArticle.xml", :)
    "xforms-lib" : "xsltforms",
    "xforms" : fn:true()
  }
  let $function := xs:QName(synopsx.models.synopsx:getModelFunction($queryParams))
  (: let $data := synopsx.models.synopsx:getUsers($queryParams) :)
  let $data := fn:function-lookup($function, 1)($queryParams)
  return synopsx.mappings.templating:wrapper($queryParams, $data, $outputParams)
};