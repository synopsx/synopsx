xquery version "3.1" ;
module namespace synopsx.mappings.xqdoc2html = "synopsx.mappings.xqdoc2html" ;

(:~
 : This module provides a xqdoc to oai transformation
 :
 : @author SynopsX’ team
 : @since 2025-03
 : @version 3.0
 :
 : This file is part of SynopsX, A lightweight framework for
 : XML corpora publication and exposure.
 :
 : GNU General Public License (GPL) v. 3
 :
 : @status this file is a first draft
 :)
declare namespace xqdoc = "http://www.xqdoc.org/1.0" ;

declare namespace db = "http://basex.org/modules/db" ;
declare namespace map = "http://www.w3.org/2005/xpath-functions/map" ;
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization" ;

import module namespace G = "synopsx.globals" at "../globals.xqm" ;

declare default function namespace "synopsx.mappings.xqdoc2html" ;

(:~
 : This function dispatches the treatment of the XML document
 :)
declare
  %output:indent("no")
function dispatch($node as node()*, $options as map(*)) as item()* {
  for $i in $node return typeswitch($i)
    case text() return $node[fn:normalize-space(.)!='']
    case element(xqdoc:module) return getModule($node, $options)
    case element(xqdoc:function) return getFunction($node, $options)
    case element(xqdoc:argument) return getArgument($node, $options)
    case element(xqdoc:annotation) return getAnnotation($node, $options)
    case element(xqdoc:literal) return getLiteral($node, $options)
    case element(xqdoc:return) return getReturn($node, $options)
    case element(xqdoc:description) return getDescription($node, $options)
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
 : This function transform p elements
 : @return an html p
 :)
declare function p($node as element(xqdoc:p)+, $options as map(*)) {
  <p>{ passthru($node, $options) }</p>
};

(:~
 : This function transform module element
 : @return an map
 :)
declare function getModule($node as node(), $options as map(*)){
  map{
    "openapi": $node/xqdoc:version/text(),
    "info":
      map{
        "title": "Titre de l’api",
        "summary": "summary todo",
        "description": "description todo",
        "contact": map{
          "name": "API Support",
          "url": "https://www todo",
          "email": "email todo"
        },
        "licence": map{
          "name": "GNU GPL v3",
          "url": "url todo"
        },
        "version": "1.0.1"
      },
  "paths": dispatch($node/xqdoc:function, $options)
  }
};

(:~
 : This function
 :)
declare function getFunction($node, $options){

};

(:~
 : This function
 :)
declare function getArgument($node, $options){''};

(:~
 : This function
 :)
declare function getAnnotation($node, $options){''};

(:~
 : This function
 :)
declare function getLiteral($node, $options){''};

(:~
 : This function
 :)
declare function getReturn($node, $options){''};

(:~
 : This function
 :)
declare function getDescription($node, $options){''};