xquery version "3.1" ;
module namespace synopsx.restxq.files = "synopsx.restxq.files" ;

(:~
 : This module provides a resolver for static files
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

declare namespace file = "http://expath.org/ns/file" ;
declare namespace fetch = "http://basex.org/modules/fetch" ;
declare namespace rest = "http://exquery.org/ns/restxq" ;
declare namespace web = "http://basex.org/modules/web" ;

import module namespace G = "synopsx.globals" at "../globals.xqm" ;

declare default function namespace "synopsx.restxq.files" ;

(:~
 : This resource function redirects to the static files
 : @param $file file or unknown path
 : @return rest response and binary file
 :)
declare
  %rest:path("/synopsx/static/{$file=.+}")
function file($file as xs:string) as item()+ {
  let $path := $G:FILES || $file
  return (
    web:response-header(map { 'media-type': web:content-type($path) }),
    file:read-binary($path)
  )
};

(:~
 : This function returns a mime-type for a specified file
 : @param  $name  file name
 : @return a mime type for the specified file
 :)
declare function mime-type(
  $name  as xs:string
) as xs:string {
  fetch:content-type($name)
};