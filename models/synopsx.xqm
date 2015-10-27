xquery version '3.0' ;
module namespace synopsx.models.synopsx = 'synopsx.models.synopsx' ;

(:~
 : This module is for SynopsX models
 :
 : @version 2.0 (Constantia edition)
 : @since 2014-11-10 
 : @author synopsx team
 :
 : This file is part of SynopsX.
 : created by AHN team (http://ahn.ens-lyon.fr)
 :
 : SynopsX is free software: you can redistribute it and/or modify
 : it under the terms of the GNU General Public License as published by
 : the Free Software Foundation, either version 3 of the License, or
 : (at your option) any later version.
 :
 : SynopsX is distributed in the hope that it will be useful,
 : but WITHOUT ANY WARRANTY; without even the implied warranty of
 : MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 : See the GNU General Public License for more details.
 : You should have received a copy of the GNU General Public License along 
 : with SynopsX. If not, see http://www.gnu.org/licenses/
 :
 :)


import module namespace G = "synopsx.globals" at '../globals.xqm';
import module namespace synopsx.mappings.htmlWrapping = "synopsx.mappings.htmlWrapping" at '../mappings/htmlWrapping.xqm';

declare default function namespace "synopsx.models.synopsx";




(:~
 : this function returns a sequence of map for meta and content 
 : !! the result structure has changed to allow sorting early in mapping
 : 
 : @rmq for testing with new htmlWrapping
 :)
declare function getProjectsList($queryParams as map(*)) as map(*) {
  let $projects := db:open('synopsx', 'config.xml')//project
  let $meta := map{
    'title' : 'Liste des projets',
    'count' : fn:string(fn:count($projects)),
    'defaultProject' : getDefaultProject()
    }
  let $content := for $project in $projects return 
    getSynopsxStatus($project)
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
  };

declare function getSynopsxStatus($project) as map(*) {
  let $isDefault := if (fn:exists($project/@default) and $project/@default=fn:true())
                    then "checked"
                    else ""
  return map {'project':fn:string($project/resourceName/text()), 'isDefault':$isDefault}
};

(:~
 : ~:~:~:~:~:~:~:~:~
 : Function library
 : ~:~:~:~:~:~:~:~:~
 :)

(:~
 : this function get the default project
 :
 : @return the default project specified in the config file
 :)
declare function getDefaultProject() as xs:string {
    if(db:exists('synopsx')) then
      if(db:open('synopsx', 'config.xml')//project[@default="true"]/resourceName/text()) then 
         db:open('synopsx', 'config.xml')//project[@default="true"]/resourceName/text()
         else  db:open('synopsx', 'config.xml')//project[1]/resourceName/text()
      else ''
};

(:~
 : this function get the project data base
 :
 : @param $project the project name
 : @return the dbName according to the project in the config file
 :)
declare function getProjectDB($project as xs:string) as xs:string {
  if (db:open('synopsx', 'config.xml')//config/projects/project[resourceName/text() = $project]/dbName)
   then db:open('synopsx', 'config.xml')//config/projects/project[resourceName/text() = $project]/dbName/text()
  else ''
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
        let $prefix := if (fn:contains($template, '_')) then fn:substring-before($template, '_') || '_' else ''
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
declare function getXsltPath($queryParams as map(*), $xsl as xs:string?) as xs:string { 
  let $path :=  $G:WEBAPP || 'static/' || map:get($queryParams, 'project') || '/xsl/' || $xsl
  return 
    if (file:exists($path)) 
    then $path
    else if (file:exists($G:FILES || 'xsl/' || $xsl)) then $G:FILES || 'xsl/' || $xsl
    else $G:FILES || 'xsl/' || 'tei2html.xsl'
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
      else   fn:QName('synopsx.models.synopsx', 'notFound') (: give default or error :)
};

(:~
 : this function build the html content and send it to the wrapper
 :
 : @param $queryParams the query params
 : @param $queryParams the output params
 : @return the html content or an error page
 : @rmq this function requires to declare namespaces in synopsx (not so user friendly)
 :)
declare function htmlDisplay($queryParams as map(*), $outputParams as map(*)) as element(*){
 try {
    let $function := xs:QName(synopsx.models.synopsx:getModelFunction($queryParams))
    let $data := fn:function-lookup($function, 1)($queryParams)
    return synopsx.mappings.htmlWrapping:wrapper($queryParams, $data, $outputParams)
  }catch err:*{   
       synopsx.models.synopsx:error($queryParams, $err:code, $err:additional)
    }
};

(:~
 : this function shows the errors
 :
 : @param $queryParams the query params
 : @param $err:code the error code
 : @param $err:additional the error description, module, line and column numbers, error message
 : @return an html view of the error messages
 :)
declare function error($queryParams as map(*), $err:code as xs:QName, $err:additional as xs:string) as element() {
  let $error := map {
    'title' : 'An error occured :(',
    'error code' : fn:string($err:code),
    'error stack trace' : $err:additional
    }
  let $data := map{
    'meta' : $error,
    'content' : $queryParams
    }
  let $outputParams := map {
    'lang' : 'fr',
    'layout' : 'error404.xhtml',
    'pattern' : 'inc_errorItem.xhtml'
    }
  return synopsx.mappings.htmlWrapping:wrapper($queryParams, $data,  $outputParams)
};

declare function  notFound($queryParams) {
  let $meta := map{
    'title' : 'No function ' || $queryParams('function') || ' in model ' || $queryParams('model')
    }
  let $content := map{'text': <p>Maybe you did not create your project´s files in the workspace directory ? </p>}
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};



(:~
 : this function built document node with dbName and path
 :
 : @param $queryParams the query params
 : @return one or several document-node according to dbName and path
 :)
declare function getDb($queryParams as map(*)) as document-node()* {
  let $dbName := $queryParams('dbName')
  let $path := $queryParams('path')
  return
    if ($path)
    then db:open($dbName, $path)
    else db:open($dbName)
};
