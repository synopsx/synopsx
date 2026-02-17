xquery version "3.1" ;
module namespace synopsx.models.synopsx = "synopsx.models.synopsx" ;

(:~
 : This module provides models for SynopsX
 :
 : @author SynopsX’ team
 : @since 2025-03
 : @version 3.0
 :
 : This file is part of SynopsX, A lightweight framework for
 : XML corpora publication and exposure.
 :
 : GNU General Public License (GPL) v. 3
 :)

declare namespace db = "http://basex.org/modules/db" ;
declare namespace map = "http://www.w3.org/2005/xpath-functions/map" ;

import module namespace G = "synopsx.globals" at "../globals.xqm" ;

declare default function namespace "synopsx.models.synopsx" ;

(:
 : This function
 :)
declare function getHome() {
  let $meta := map{
    "title" : "Test de titre",
    "meta" : "test"
  }
  let $content := map{
    "test" : <p>contenu test</p>
  }
  return map{
    "meta"    : $meta,
    "content" : $content
  }
};