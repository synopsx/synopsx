xquery version "3.1" ;
module namespace synopsx.mappings.tei2html = "synopsx.mappings.tei2html" ;

(:~
 : This module provides a TEI to HTML transformation
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
declare namespace tei = "http://www.tei-c.org/ns/1.0" ;

declare namespace db = "http://basex.org/modules/db" ;
declare namespace map = "http://www.w3.org/2005/xpath-functions/map" ;
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization" ;

import module namespace G = "synopsx.globals" at "../globals.xqm" ;

declare default function namespace "synopsx.mappings.tei2html" ;

(:~
 : This function dispatches the treatment of the XML document
 :)
declare
  %output:indent("no")
function dispatch($node as node()*, $options as map(*)) as item()* {
  for $i in $node return typeswitch($i)
    case text() return $node[fn:normalize-space(.)!='']
    case element(tei:p) return p($node, $options)
    case element(tei:div) return div($node, $options)
    case element(tei:body) return passthru($node, $options)
    case element(tei:back) return passthru($node, $options)
    case element(tei:front) return passthru($node, $options)
    case element(tei:text) return passthru($node, $options)
    case element(tei:teiHeader) return ""
    case element(tei:TEI) return passthru($node, $options)
    case element() return getDefault($node, $options)
    default return passthru($node, $options)
};

(:~
 : This function pass through child nodes (eq. xsl:apply-templates)
 :)
declare
  %output:indent("no")
function passthru($nodes as node(), $options as map(*)) as item()* {
  for $node in $nodes/node()
  return dispatch($node, $options)
};

declare function getDefault($node as element()+, $options as map(*)) {
  <span class="{fn:name($node)}">{passthru($node, $options)}</span>
};

(:~
 : This function transform div elements
 : @return an html div with an id
 :)
declare function div($node as element(tei:div)+, $options as map(*)) {
  <div>{
    if ($node/@xml:id) then attribute id { $node/@xml:id } else (),
    passthru($node, $options)
  }</div>
};

(:~
 : This function transform p elements
 : @return an html p
 :)
declare function p($node as element(tei:p)+, $options as map(*)) {
  <p>{ passthru($node, $options) }</p>
};