xquery version "3.1" ;
module namespace synopsx.mappings.json2html = "synopsx.mappings.json2html" ;

(:~
 : This module provides a JSON to HTML transformation
 :
 : @author SynopsX’ team
 : @since 2025-09
 : @version 3.0
 :
 : This file is part of SynopsX, A lightweight framework for
 : XML corpora publication and exposure.
 :
 : GNU General Public License (GPL) v. 3
 :)
declare namespace db = "http://basex.org/modules/db" ;
declare namespace map = "http://www.w3.org/2005/xpath-functions/map" ;
declare namespace array = "http://www.w3.org/2005/xpath-functions/array" ;
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization" ;

import module namespace G = "synopsx.globals" at "../globals.xqm" ;

declare default function namespace "synopsx.mappings.json2html" ;

(:~
 : This function dispatches the treatment of a JSON value based on its kind
 :)
declare
  %output:indent("no")
function dispatch($node as item()*, $options as map(*)) as item()* {
  for $i in $node return typeswitch($i)
    case empty-sequence() return ()
    case map(*) return object($i, $options)
    case array(*) return list($i, $options)
    case xs:boolean return boolean($i, $options)
    case xs:integer | xs:double | xs:decimal return number($i, $options)
    case xs:string return string($i, $options)
    default return getDefault($i, $options)
};

declare function getDefault($node as item(), $options as map(*)) {
  <span>{ fn:string($node) }</span>
};

(:~
 : This function transforms a JSON object (map) into an HTML definition list
 : @return an html dl with a dt/dd pair for each entry
 :)
declare function object($node as map(*), $options as map(*)) {
  <dl class="json-object">{
    map:for-each($node, function($key, $value) {
      (<dt>{ $key }</dt>, <dd>{ dispatch($value, $options) }</dd>)
    })
  }</dl>
};

(:~
 : This function transforms a JSON array into an HTML unordered list
 : @return an html ul with one li per item
 :)
declare function list($node as array(*), $options as map(*)) {
  <ul class="json-array">{
    array:for-each($node, function($item) {
      <li>{ dispatch($item, $options) }</li>
    })
  }</ul>
};

(:~
 : This function transforms a JSON string into an HTML span
 :)
declare function string($node as xs:string, $options as map(*)) {
  <span class="json-string">{ $node }</span>
};

(:~
 : This function transforms a JSON number into an HTML span
 :)
declare function number($node as xs:anyAtomicType, $options as map(*)) {
  <span class="json-number">{ fn:string($node) }</span>
};

(:~
 : This function transforms a JSON boolean into an HTML span
 :)
declare function boolean($node as xs:boolean, $options as map(*)) {
  <span class="json-boolean">{ if ($node) then "true" else "false" }</span>
};
