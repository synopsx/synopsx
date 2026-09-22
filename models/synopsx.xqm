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
declare namespace file = "http://expath.org/ns/file" ;
declare namespace inspect = "http://basex.org/modules/inspect" ;
declare namespace fn = "http://www.w3.org/2005/xpath-functions" ;
declare namespace map = "http://www.w3.org/2005/xpath-functions/map" ;
declare namespace xf = "http://www.w3.org/2002/xforms" ;

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
 :)
declare function getModelFunction($queryParams as map(*)) as xs:QName {
  let $uri := $queryParams?project || '.models.' || $queryParams?model
  let $context := inspect:context()
  let $function := $context/function[@name = $queryParams?function]
  return
    if ($function/@uri = $uri) then fn:QName($uri, $queryParams?function)
    else if ($function/@uri = 'synopsx.models.' || $queryParams?model)
      then fn:QName('synopsx.models.' || $queryParams?model, $queryParams?function)
      else   fn:QName('synopsx.models.synopsx', 'notFound') (: give default or error :)
};

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
      else   fn:QName('synopsx.models.synopsx', 'notFound') 
      (: give default or error :)
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
 : this function built the mapping path based on the project hierarchy
 :
 : @param $queryParams the query params
 : @param $template the template name.extension
 : @return the public dispatch function (arity 2) of the selected mapping module
 :
 : The project module is preferred when it exists.  Otherwise, the mapping
 : bundled with SynopsX is loaded.  This requires BaseX 12 or newer.
 :)
declare function getMappingsFunction($queryParams as map(*), $outputParams as map(*)) {
  let $projectNamespace := $queryParams?project || '.mappings.' || $outputParams?xquery
  let $defaultNamespace := 'synopsx.mappings.' || $outputParams?xquery
  let $projectLocation := $G:WORKSPACE || $queryParams?project || '/mappings/' || $outputParams?xquery || '.xqm'
  let $defaultLocation := $G:HOME || 'mappings/' || $outputParams?xquery || '.xqm'
  let $namespace := if (file:exists($projectLocation)) then $projectNamespace else $defaultNamespace
  let $location := if (file:exists($projectLocation)) then $projectLocation else $defaultLocation
  let $functions := fn:load-xquery-module($namespace, map { 'location-hints': $location })?functions
  let $overloads := $functions(fn:QName($namespace, 'dispatch'))
  return
    if (fn:empty($overloads)) then fn:error(xs:QName('local:NOFUNC'),
      'Fonction dispatch introuvable dans le module : ' || $namespace)
    else
      let $dispatch := $overloads(2)
      return
        if (fn:exists($dispatch)) then $dispatch
        else fn:error(xs:QName('local:NOFUNC'),
          'Fonction dispatch/2 introuvable dans le module : ' || $namespace)
};

(:declare function getMappingsFunction($queryParams as map(*), $outputParams as map(*)) as xs:QName {
  let $projectNamespace := $queryParams?project || '.mappings.' || $outputParams?xquery
  let $defaultNamespace := 'synopsx.mappings.' || $outputParams?xquery
  let $uris := inspect:context()
    /function[fn:tokenize(@name, ':')[fn:last()] = 'dispatch'][fn:count(argument) = 2]/@uri
  return
    if ($uris = $projectNamespace) then fn:QName($projectNamespace, 'dispatch')
    else if ($uris = $defaultNamespace) then fn:QName($defaultNamespace, 'dispatch')
    else fn:error(xs:QName('local:NOFUNC'),
      'QName de la fonction introuvable : ' || $defaultNamespace || ':dispatch')
};
;)

(:~
 : this function built the layout path based on the project hierarchy
 :
 : @param $queryParams the query params
 : @param $template the template name.extension
 : @return a path
 :
 : @todo 
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
    "message" : <p>message</p>
  }
  return map{
    "meta"    : $meta,
    "content" : $content
  }
};

(:~
 : This function builds the data for an XQuery error page.
 :)
declare function getXQueryError($queryParams as map(*)) as map(*) {
  let $description := map:get($queryParams, 'description')
  return map {
    "meta" : map {
      "title" : "Erreur BaseX"
    },
    "content" : map {
      "heading" : "Erreur interne",
      "message" :
        if ($description)
        then $description
        else "Une erreur XQuery est survenue.",
      "details" : details((
        detail("Code", map:get($queryParams, 'code')),
        detail("Message", $description),
        detail("Module", map:get($queryParams, 'module')),
        detail("Ligne", map:get($queryParams, 'line-number')),
        detail("Colonne", map:get($queryParams, 'column-number')),
        detail("Valeur", map:get($queryParams, 'value'))
      ))
    }
  }
};

(:~
 : This function builds the data for an HTTP error page.
 :)
declare function getHttpError($queryParams as map(*)) as map(*) {
  let $status := map:get($queryParams, 'status')
  let $message := map:get($queryParams, 'message')
  return map {
    "meta" : map {
      "title" : "Erreur HTTP " || $status
    },
    "content" : map {
      "heading" : "Erreur HTTP " || $status,
      "message" :
        if ($message)
        then $message
        else "Une erreur HTTP est survenue.",
      "details" : details((
        detail("URL", map:get($queryParams, 'request-uri')),
        detail("Statut", $status),
        detail("Exception", map:get($queryParams, 'exception'))
      ))
    }
  }
};

declare function detail($label as xs:string, $value as xs:string?) as element()* {
  if ($value and fn:normalize-space($value) != '') then (
    <dt>{ $label }</dt>,
    <dd>{ $value }</dd>
  ) else ()
};

declare function details($items as element()*) as element(div) {
  <div>{ if ($items) then <dl>{ $items }</dl> else () }</div>
};
