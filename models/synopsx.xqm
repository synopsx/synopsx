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
declare namespace inspect = "http://basex.org/modules/inspect" ;
declare namespace map = "http://www.w3.org/2005/xpath-functions/map" ;

import module namespace G = "synopsx.globals" at "../globals.xqm" ;

declare default function namespace "synopsx.models.synopsx" ;

(:~
 : this function checks if the function exists in the given module
 :
 : @param module uri and function name
 : @return a function QName
 :
 : @rmq the modules namespaces should be imported in the restxq
 : @todo give a default function or an error
 :)(:
declare function getModelFunction($queryParams as map(*)) as xs:QName {
  let $uri := $queryParams?project || '.models.' || $queryParams?model
  let $context := inspect:context()
  let $function := $context/function[@name = $queryParams?function]
  return
    if ($function/@uri = $uri) then fn:QName($uri, $queryParams?function)
    else if ($function/@uri = 'synopsx.models.' || $queryParams?model)
      then fn:QName('synopsx.models.' || $queryParams?model, $queryParams?function)
      else   fn:QName('synopsx.models.synopsx', 'notFound') :)(: give default or error :)(:
};:)

(:~
 : this function checks if the function exists in the given module
 :
 : @param module uri and function name
 : @return a function QName
 :
 : @rmq the modules namespaces should be imported in the restxq
 : @todo give a default function or an error
 :)
declare function getModelFunction($queryParams as map(*)) as xs:QName {
  let $projectName :=  map:get($queryParams, 'project')
  let $modelName := map:get($queryParams, 'model')
  let $functionName := map:get($queryParams, 'function')
  let $uri := $projectName || '.models.' || $modelName
  let $context := inspect:context()
  let $function := $context//function[@name = $functionName]
  return if ($function/@uri = $uri)
    then fn:QName($uri, $functionName)
    else if ($function/@uri = 'synopsx.models.' || $modelName)
      then fn:QName('synopsx.models.' || $modelName, $functionName)
      else   fn:QName('synopsx.models.synopsx', 'notFound') (: give default or error :)
};

(:~
 : this function built the layout path based on the project hierarchy
 :
 : @param $queryParams the query params
 : @param $template the template name.extension
 : @return a path
 :)
declare function getLayoutPath($queryParams as map(*), $template as xs:string?) as xs:string {
  let $path := $G:WORKSPACE || map:get($queryParams, 'project') || '/templates/' || $template
  return
    if (file:exists($path))
    then $path
    else if (file:exists($G:TEMPLATES || $template)) then $G:TEMPLATES || $template
    else
        (: Test if we are looking for a main layout or a 'inc_*' layout:)
        let $prefix := if (fn:contains($template, '_')) then fn:substring-before($template, '_') || '_' else 'inc_'
         (: Test if we are looking for a inc_*List layout or a inc_*Item layout:)
        let $suffix := if (fn:contains($template, 'List')) then 'List' else 'Item'
        return $G:TEMPLATES || $prefix || 'default' || $suffix || '.xhtml'
};

(:~
 : this function built the layout path based on the project hierarchy
 :
 : @param $queryParams the query params
 : @param $template the template name.extension
 : @return a path
 :)
declare function getMappingsFunction($queryParams as map(*), $outputParams) as xs:QName {
   let $uri := $queryParams?project || '.models.' || $queryParams?model
    let $context := inspect:context()
    let $function := $context/function[@name = $outputParams?xquery]
    return
      if ($function/@uri = $uri) then fn:QName($uri, $outputParams?xquery)
      else if ($function/@uri = 'synopsx.models.' || $outputParams?xquery)
        then fn:QName('synopsx.models.' || $queryParams?model, $outputParams?xquery)
        else   fn:QName('synopsx.models.synopsx', 'notFound') (: give default or error :)
  };

(:~
 : this function built the layout path based on the project hierarchy
 :
 : @param $queryParams the query params
 : @param $template the template name.extension
 : @return a path
 :)
declare function synopsx.models.synopsx:getXsltPath($queryParams as map(*), $outputParams) as xs:QName {
   "todo"
  };

(:
 : This function
 :)
declare function getHome($queryParams) {
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