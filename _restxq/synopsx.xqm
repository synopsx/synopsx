xquery version '3.0' ;
module namespace synopsx.synopsx = 'synopsx.synopsx' ;

(:~
 : This module is the RESTXQ for SynopsX's installation processes
 :
 : @author synopsx team
 : @since 2014-11-10 
 : @version 2.0 (Constantia edition)
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

import module namespace rest = "http://exquery.org/ns/restxq";
import module namespace Session = 'http://basex.org/modules/session';
import module namespace G = 'synopsx.globals' at '../globals.xqm' ;
import module namespace synopsx.models.tei = 'synopsx.models.tei' at '../models/tei.xqm' ;
import module namespace synopsx.models.synopsx = 'synopsx.models.synopsx' at '../models/synopsx.xqm' ;

import module namespace synopsx.mappings.htmlWrapping = 'synopsx.mappings.htmlWrapping' at '../mappings/htmlWrapping.xqm' ;

declare default function namespace 'synopsx.synopsx' ;

declare variable $synopsx.synopsx:project := 'synopsx';
declare variable $synopsx.synopsx:db := synopsx.models.synopsx:getProjectDB($synopsx.synopsx:project) ;
(:~
 : this resource function redirects to the synopsx' home
 :)
declare 
  %rest:path('/synopsx')
function index() {
  web:redirect(if(db:exists("synopsx"))
              then '/synopsx/home' 
              else '/synopsx/install')
};

(:~
 : this resource function is the synopsx' home
 : @todo give contents
 :)
declare 
  %rest:path('/synopsx/install')
  %output:method('html')
  %output:html-version('5.0')
  %updating
function install(){
  db:create("synopsx", ($G:FILES||"xml/synopsx.xml",$G:FILES||"xml/config.xml"), (), map {'chop':fn:false()}),
  db:create("example", ($G:FILES||"xml/teiSample.xml", $G:FILES||"xml/eadSample.xml"), (), map {'chop':fn:false()}),
  update:output(web:redirect("/synopsx/home"))
};

(:~
 : this resource function is the synopsx' home
 : @todo give contents
 :)
declare 
  %rest:path('/synopsx/home')
  %output:method('html')
  %output:html-version('5.0')
function home(){
  let $queryParams := map {
    'project' : $synopsx.synopsx:project,
    'dbName' :  $synopsx.synopsx:db,
    'model' : 'tei' ,
    'function' : 'queryTEI',
    'id':'synopsx'
    }
  let $outputParams := map {
    'lang' : 'fr',
    'layout' : 'synopsx.xhtml',
    'pattern' : 'inc_defaultItem.xhtml',
    'xsl':'tei2html.xsl'
    }  
 return synopsx.models.synopsx:htmlDisplay($queryParams, $outputParams)
};

declare 
  %rest:GET
  %perm:allow("admin")
  %rest:path('/synopsx/config')
  %output:method('html')
  %output:html-version('5.0')
function config() as element() {
  let $queryParams := map {
    'project' : $synopsx.synopsx:project,
    'dbName' :  $synopsx.synopsx:db,
    'model' : 'synopsx' ,
    'function' : 'getProjectsList'
    }
  let $outputParams :=map {
    'lang' : 'fr',
    'layout' : 'config.xhtml',
    'pattern' : 'inc_configItem.xhtml'
    (: specify an xslt mode and other kind of output options :)
    }
 return synopsx.models.synopsx:htmlDisplay($queryParams, $outputParams)

};

declare 
  %rest:POST
  %perm:allow('admin')
  %rest:path('/synopsx/config')
  %output:method('html')
  %rest:query-param("project",  "{$project}")
  %updating
function config($project) {
    db:create-backup('synopsx'),
    delete node db:open('synopsx', 'config.xml')//@default, (: supprimer tout attribut défault préexistant :)
    insert node (attribute { 'default' } { 'true' }) into db:open('synopsx', 'config.xml')//project[resourceName/text()=$project][1],
    update:output(web:redirect("/synopsx/config"))  
};


declare 
  %rest:GET
   %perm:allow('admin')
  %rest:path('/synopsx/create-project')
  %output:method('html')
  %output:html-version('5.0')
function create_project() as element() {
  let $queryParams := map {
    
    }
  let $outputParams :=map {
    'lang' : 'fr',
    'layout' : 'create-project.xhtml'
    }
 return synopsx.models.synopsx:htmlDisplay($queryParams, $outputParams)
};

declare 
  %rest:POST
   %perm:allow('admin')
  %rest:path('/synopsx/create-project')
  %output:method('html')
  %rest:query-param("project",  "{$project}")
  %updating
function create_project($project) {
  if(db:open('synopsx', 'config.xml')//project[resourceName/text()=$project]) then 
  update:output(web:redirect("/synopsx/config/unavailable"))
  else
      (db:create($project, (), (), map { 'chop': fn:true(), 'textindex': fn:true(),'attrindex': fn:true() }),
      insert node 
          <project> 
            <resourceName>{$project}</resourceName>
            <dbName>{$project}</dbName>
          </project>      
      into db:open('synopsx', 'config.xml')//projects,
      update:output(web:redirect("/synopsx/config"))
      )
};


declare 
  %rest:GET
  %perm:allow("admin")
  %rest:path('/synopsx/config/{$checkName}')
  %output:method('html')
  %output:html-version('5.0')
function create-project($checkName) as element() {
  let $queryParams := map {
    'project' : $synopsx.synopsx:project,
    'dbName' :  $synopsx.synopsx:db,
    'model' : 'synopsx' ,
    'function' : 'getProjectsList',
    'checkName' : $checkName
    }
  let $outputParams :=map {
    'lang' : 'fr',
    'layout' : 'config.xhtml',
    'pattern' : 'inc_configItem.xhtml'
    (: specify an xslt mode and other kind of output options :)
    }
 return synopsx.models.synopsx:htmlDisplay($queryParams, $outputParams)

};

(:~ Login page (visible to everyone). :)
declare
  %rest:path("/synopsx/login")
  %output:method("html")
function login() {
    fn:doc($G:HOME || 'templates/login.xhtml')
};

declare
  %rest:path("/synopsx/login-check")
  %rest:query-param("name", "{$name}")
  %rest:query-param("pass", "{$pass}")
  function login($name, $pass) {
  if (fn:empty($name)) then  web:redirect("/synopsx/login")
  else
  try {
    user:check($name, $pass),
    Session:set('id', $name),
    web:redirect("/synopsx")
  } catch user:* {
    web:redirect("/synopsx/login")
  }
};

declare
  %rest:path("/synopsx/logout")
function logout() {
  Session:delete('id'),
  web:redirect("/synopsx")
};

declare %perm:check('/synopsx/install', '{$perm}') function check-install($perm) {
  if (fn:empty(Session:get('id'))) then  web:redirect("/synopsx/login")
  else
  let $user := Session:get('id')
  where fn:not(user:list-details($user)/@permission = $perm?allow)
  return web:redirect("/synopsx/login")
};

declare %perm:check('/synopsx/config', '{$perm}') function check-config($perm) {
   if (fn:empty(Session:get('id'))) then  web:redirect("/synopsx/login")
  else
  let $user := Session:get('id')
  where fn:not(user:list-details($user)/@permission = $perm?allow)
  return web:redirect("/synopsx/login")
};

declare %perm:check('/synopsx/create-project', '{$perm}') function check-create-project($perm) {
  if (fn:empty(Session:get('id'))) then  web:redirect("/synopsx/login")
  else
  let $user := Session:get('id')
  where fn:not(user:list-details($user)/@permission = $perm?allow)
  return web:redirect("/synopsx/login")
};