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

declare namespace tei = "http://www.tei-c.org/ns/1.0" ;

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
 :
 : @rmq static’s paths are rebuilt by _restxq/files.xqm
 : @rmq in `(result, fn:error(...))[1]`: [1] takes the first item of the sequence, so the error is only evaluated if the preceding sequence is empty. XQuery 4 introduced `otherwise` that could be use to simplify but would introduce a dependancy
 :)
declare function getLayoutPath($queryParams as map(*), $template as xs:string) as xs:string {
  let $projectPath := $G:WORKSPACE || $queryParams?project || '/templates/' 
  let $defaultPath := $G:TEMPLATES
  let $candidates := ($projectPath, $defaultPath) ! (. || $template)
  return (
    $candidates[file:exists(.)],
    fn:error(xs:QName('local:NOTEMPLATE'), 'Template : ' || $template || ' not found in ' || fn:string-join($candidates, ' or '))
  )[1]
};

(:~
 : this function built the layout path based on the project hierarchy
 :
 : @param $queryParams the query params
 : @param $template the template name.extension
 : @return a path
 :
 : @rmq static’s paths are rebuilt by _restxq/files.xqm
 : @rmq in `(result, fn:error(...))[1]`: [1] takes the first item of the sequence, so the error is only evaluated if the preceding sequence is empty. XQuery 4 introduced `otherwise` that could be use to simplify but would introduce a dependancy
 : @todo test if $G:WEBAPP works well with a project
 :)
declare function getXsltPath($queryParams as map(*), $xsl as xs:string?) as xs:string { 
  let $projectPath := $G:WEBAPP || 'static/' ||  $queryParams?project || '/xsl/'
  let $defaultPath :=  $G:FILES || 'xsl/'
  let $candidates := ($projectPath, $defaultPath) ! (. || $xsl)
  return (
    $candidates[file:exists(.)],
    fn:error(xs:QName('local:NOXSLT'), 'XSLT : ' || $xsl || ' not found in ' || fn:string-join($candidates, ' or '))
  )[1]
};

(:~
 : this function built the mapping path based on the project hierarchy
 :
 : @param $queryParams the query params
 : @return the public dispatch function (arity 2) of the selected mapping module
 :
 :)
declare function getMappingsFunction($queryParams as map(*), $outputParams as map(*)) as xs:QName {
  let $projectNamespace := $queryParams?project || '.mappings.' || $outputParams?xquery
  let $defaultNamespace := 'synopsx.mappings.' || $outputParams?xquery
  let $uris := inspect:context()//function[@name = 'dispatch']/@uri
  let $candidates := ($projectNamespace, $defaultNamespace)
  return (
    $candidates[. = $uris] ! fn:QName(., 'dispatch'),
    fn:error(xs:QName('local:NOFUNC'), 'Mapping : dispatch not found in ' || fn:string-join($candidates, ' or '))
  )[1]
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
    "message" : <tei:p>message</tei:p>
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
