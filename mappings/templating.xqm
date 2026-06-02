xquery version "3.1" ;
module namespace synopsx.mappings.templating = "synopsx.mappings.templating" ;

(:~
 : This module provides mappings for SynopsX
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

declare namespace xf = "http://www.w3.org/2002/xforms" ;

import module namespace G = "synopsx.globals" at "../globals.xqm" ;
import module namespace synopsx.models.synopsx = 'synopsx.models.synopsx' at '../models/synopsx.xqm' ;
import module namespace synopsx.mappings.tei2html = 'synopsx.mappings.tei2html' at 'tei2html.xqm' ;

declare default function namespace "synopsx.mappings.templating" ;

declare variable $synopsx.mappings.templating:regex := "\s*\{(.+?)\}\s*";

(:~
 : this function wrap the content in an HTML layout
 :
 : @param $queryParams the query params defined in restxq
 : @param $data the result of the query
 : @param $outputParams the serialization params
 : @return an updated HTML document and instantiate pattern
 :
 : @bug can't update a element more than once
 : @rmq it may be interesting to make $data?content available
 : @rmq xsltforms <? css-conversion no ?> 
 :
 :)
declare function wrapper($queryParams as map(*), $data as map(*), $outputParams as map(*)) as node()* {
  let $wrap := fn:doc(synopsx.models.synopsx:getLayoutPath($queryParams, $outputParams?layout))
  let $pi :=
    if ($outputParams?xforms-prefix)
    then processing-instruction xml-stylesheet {
      fn:concat("href='", $G:XFORMS, "' ", "type='text/xsl'")
    }
  return
    (
      $pi,
      $wrap/* update {
      for $node in .//*[text()[fn:matches(., $synopsx.mappings.templating:regex )]] | .//@*[fn:matches(., $synopsx.mappings.templating:regex )]
      let $key := fn:analyze-string($node, $synopsx.mappings.templating:regex )//fn:group/text()
      return if ($key = 'content')
        then replace node $node with pattern($queryParams, $data, $outputParams)
        else associate($queryParams, $data?meta, $outputParams, $node)
      }
    )
  };

(:~
 : this function iterates the pattern template with contents
 :
 : @param $queryParams the query params defined in restxq
 : @param $data the result of the query to dispacth
 : @param $outputParams the serialization params
 : @return instantiate the pattern with $data
 :
 :)
declare function pattern($queryParams as map(*), $data as map(*), $outputParams as map(*)) as node()* {
  let $pattern := fn:doc(synopsx.models.synopsx:getLayoutPath($queryParams, $outputParams?pattern))
  for $content in $data?content
  return
    $pattern/* update {
      for $node in descendant-or-self::*[text()[fn:matches(., $synopsx.mappings.templating:regex )]] | .//@*[fn:matches(., $synopsx.mappings.templating:regex )]
      return associate($queryParams, $content, $outputParams, $node)
      }
  };

(:~
 : this function dispatch the content with the data
 :
 : @param $queryParams the query params defined in restxq
 : @param $data the result of the query to dispacth (meta or content)
 : @param $outputParams the serialization params
 : @return an updated node with the data
 :
 : @bug doesn't treat mixed content
 : @bug doesn't copy other attribute when updating attribute with a sequence
 :)
declare %updating function associate($queryParams as map(*), $data as map(*), $outputParams as map(*), $node as node()) {
  let $data := $data
  let $keys := fn:analyze-string($node, $synopsx.mappings.templating:regex)//fn:group/text()
  let $values := map:get($data, $keys)
    return typeswitch ($values)
    case empty-sequence() return ()
    case text() return replace value of node $node with $values
    case xs:string return replace value of node $node with $values
    case xs:string+ return
      if ($node instance of attribute()) (: when key is an attribute value :)
      then
        replace node $node/parent::* with
          element {fn:name($node/parent::*)} {
          for $att in $node/parent::*/(@* except $node) return 
            $att,
            attribute {fn:name($node)} {fn:string-join($values, ' ')},
            $node/parent::*/text()
          }
      else
        replace node $node with
        for $value in $values
        return element {fn:name($node)} {
          for $att in $node/@* return $att, $value
      }
    case xs:integer return replace value of node $node with xs:string($values)
    case element()+ return replace node $node with
      for $value in $values
      return element {fn:name($node)} {
        for $att in $node/@* return $att,
        render($queryParams, $outputParams, $value)
      }
    default return replace value of node $node with 'default'
  };

  (:~
   : this function dispatch the rendering based on $outpoutParams
   :
   : @param $value the content to render
   : @param $outputParams the serialization params
   : @return a serialization
   :
   : @todo check the xsl with an xsl 1.0
   :)
  declare function render($queryParams as map(*), $outputParams as map(*), $value as node()* ) as item()* {
    let $options := map{
      'lb' : map:get($outputParams, 'lb')
      }
    let $params := map:get($outputParams, 'params')
    return 
      if ($outputParams?xquery)
        (:then synopsx.mappings.tei2html:dispatch($value, $options):)
        then synopsx.models.synopsx:getMappingsFunction($queryParams, $outputParams)
      else if ($outputParams?xsl)
        then for $node in $value return
            if (fn:empty($params) )
              then xslt:transform($node, synopsx.models.synopsx:getXsltPath($queryParams, $outputParams?xsl))
              else xslt:transform($node, synopsx.models.synopsx:getXsltPath($queryParams, $outputParams?xsl), $params)
      else $value
  };
