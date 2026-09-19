xquery version '3.1' ;
module namespace synopsx.mappings.synopsx2json = 'synopsx.mappings.synopsx2json' ;

(:~
 : This module provides a mapping from SynopsX model to JSON
 :
 : @author SynopsX’ team
 : @since 2025-06
 : @version 3.0
 :
 : This file is part of SynopsX, A lightweight framework for
 : XML corpora publication and exposure.
 :
 : GNU General Public License (GPL) v. 3
 : 
 : @todo rename as jsoner
 :)
declare namespace db = "http://basex.org/modules/db" ;
declare namespace map = "http://www.w3.org/2005/xpath-functions/map" ;
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization" ;

import module namespace G = "synopsx.globals" at '../globals.xqm' ;
import module namespace synopsx.models.synopsx = 'synopsx.models.synopsx' at '../models/synopsx.xqm' ;

declare namespace html = 'http://www.w3.org/1999/xhtml' ;
declare namespace inspect = "http://basex.org/modules/inspect" ;

declare default function namespace 'synopsx.mappings.synopsx2json' ;

(:~
 : this function wrap the content in an HTML layout
 :
 : @param $queryParams the query params defined in restxq
 : @param $data the result of the query
 : @param $outputParams the serialization params
 : @return an updated HTML document and instantiate pattern
 : @todo treat in the same loop @* and text() ?
 : @todo deal with empty content (actually "vide")
 : @rmq this version use the user defined serialisation from RESTXQ
 :)
declare function jsoner($queryParams as map(*), $outputParams as map(*), $data as map(*)) {
  let $contents := map:get($data, 'content')
  let $meta := map:get($data, 'meta')
  return map{
    'meta' : sequence2ArrayInMap($queryParams, $meta, $outputParams),
    'content' : if (fn:count($contents) > 1) then array{
        for $content in $contents
        return sequence2ArrayInMap($queryParams, $content, $outputParams)
        }
        (:
        else sequence2ArrayInMap($queryParams, $contents, $outputParams)
        :) (: for debug :)
        else if (fn:count($contents) = 0)
          then 'vide' (: for debug :)
          else sequence2ArrayInMap($queryParams, $contents, $outputParams)
    }
};

(:~
 : this function transforms a map into a map with arrays
 :
 : @param $map the map to convert
 : @return a map with array instead of sequences
 : @rmq deals only with right keys
 :)
declare function sequence2ArrayInMap($queryParams, $map as map(*), $outputParams) as map(*) {
  map:merge((
    map:for-each(
      $map,
      function($a, $b) {
        map:entry(
          $a ,
          if (fn:count($b) > 1)
          then array{ dispatch($b, $queryParams, $outputParams) }
          else dispatch($b, $queryParams, $outputParams)
        )
      }
    )
  ))
};

(:~
 : this function dispatch the content to render
 : $param $queryParams the query params
 : $param $outputParams the query params
 :)
declare function dispatch($b as item()*, $queryParams, $outputParams) {
  typeswitch($b)
    case empty-sequence() return ()
    case map(*)+ return $b ! sequence2ArrayInMap($queryParams, ., $outputParams)
    case xs:string return $b
    case xs:string+ return $b
    (: case xs:anyAtomicType return fn:data($b)
    case xs:anyAtomicType+ return $b ! fn:data(.) :)
    case xs:integer return fn:data($b)
    case xs:double return fn:format-number($b, "0.00")
    case array(*) return array:for-each($b, function($i) {
      dispatch($i, $queryParams, $outputParams)
    })
    case attribute() return fn:string($b)
    case text() return fn:string($b)
    default return render($queryParams, $outputParams, $b
    )
  };

(:~
 : this function render the content based on $outpoutParams
 :
 : @param $queryParams the query params
 : @param $outputParams the output params
 : @param $value the content to render
 : @return a json content with the serialization parameters
 :
 : @todo check that the xslt works properly
 : @todo check the xslt with an xslt 1.0
 : @todo deals with errors
 :)
declare function render($queryParams as map(*), $outputParams as map(*), $value as node()* ) as item()* {
  let $options := map{
    'lb' : map:get($outputParams, 'lb')
    }
  let $params := map:get($outputParams, 'params')
  return 
    if ($outputParams?xquery)
    then 
      let $qname := synopsx.models.synopsx:getMappingsFunction($queryParams, $outputParams)
      let $f := inspect:functions()[fn:function-name(.) = $qname][fn:function-arity(.) = 2]
      return $f($value, $options)
    else if ($outputParams?xsl)
      then for $node in $value return
        if (fn:empty($params) )
        then xslt:transform($node, synopsx.models.synopsx:getXsltPath($queryParams, $outputParams?xsl))
        else xslt:transform($node, synopsx.models.synopsx:getXsltPath($queryParams, $outputParams?xsl), $params)
      else $value
};