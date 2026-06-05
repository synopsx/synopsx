xquery version "3.1";


module namespace synopsx.restxq.users = "synopsx.restxq.users";


(:~
 : This module deals with users
 :
 : @author SynopsX’ team
 : @since 2025-07
 : @version 3.0
 :
 : This file is part of SynopsX, A lightweight framework for
 : XML corpora publication and exposure.
 :
 : GNU General Public License (GPL) v. 3
 ::)

declare namespace rest = "http://exquery.org/ns/restxq";
declare namespace file = "http://expath.org/ns/file";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace db = "http://basex.org/modules/db";
declare namespace web = "http://basex.org/modules/web";
declare namespace update = "http://basex.org/modules/update";
declare namespace perm = "http://basex.org/modules/perm";
declare namespace user = "http://basex.org/modules/user";
declare namespace session = "http://basex.org/modules/session";
declare namespace http = "http://expath.org/ns/http-client";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";

import module namespace G = "synopsx.globals" at "../globals.xqm";
import module namespace synopsx.models.synopsx = "synopsx.models.synopsx" at "../models/synopsx.xqm";
import module namespace synopsx.mappings.templating = "synopsx.mappings.templating" at "../mappings/templating.xqm";

declare default function namespace "synopsx.restxq.users";

(:~
 : This resource function is the SynopsX’ home
 : @todo give contents
 ::)

declare
  %rest:path("/synopsx-beta/users")
  %output:method("html")
  %output:html-version("5.0")
function getUsers() {
  let $queryParams := map { 
    "project" : 'synopsx',
    "model" : 'synopsx',
    "function" : "getUsers"
  }
  (: user:list-details() :)
  let $outputParams := map { 
    "lang" : "fr",
    "layout" : "formListUsers.xml",
    "xforms-lib" : "xsltforms",
    "xforms-prefix" : fn:true(),
    "xforms" : fn:true()
  }
  let $function := xs:QName(synopsx.models.synopsx:getModelFunction($queryParams))
  (: let $data := fn:function-lookup($function, 1)($queryParams) :)
  let $data := synopsx.models.synopsx:getUsers($queryParams)
  return synopsx.mappings.templating:wrapper($queryParams, $data, $outputParams)
};

(:~ Login page (visible to everyone). :)
declare
  %rest:path("/synopsx-beta/login")
  %output:method("html")
function login() {
  <html>
    Please log in:
    <form action="/synopsx-beta/login/check" method="post">
      <input name="name"/>
      <input type="password" name="pass"/>
      <input type="submit"/>
    </form>
  </html>
};

(:
 : this function checks if the user is registered
 : @param $name usernema
 : @param $pass user password
 :
 ::)
declare 
  %rest:path("/synopsx-beta/login/check") 
  %rest:form-param("name", "{$name}")
  %rest:form-param("pass", "{$pass}")
function login($name as xs:string, $pass as xs:string) {
  try { 
    user:check($name, $pass),
    session:set('id', $name),
    web:redirect("/synopsx-beta/home")
  } 
  catch user:* {
    web:redirect("/synopsx-beta/home")
  }
};

(:
 : this function logs out current user
 ::)
declare
  %rest:path("/synopsx-beta/logout") 
function logout() {
  session:delete('id'),
  web:redirect("/synopsx-beta/home")
};

(:~
 : This function creates new user in dba.
 : @param $param
 : @param $referer
 : @todo return creation message
 : @todo control for duplicate user.
 : @requires Permission: admin + write
 ::)

(:~
 : This resource function is a test for the xforms integration
 ::)
declare
  %rest:path("/synopsx-beta/users/new")
  %output:method("xml")
  %perm:allow("admin")
function newUser() { 
  let $queryParams := map { 
    "project" : 'synopsx',
    "model" : 'synopsx',
    (:"function" : "getDatabases":)
    "function" : "getUserDetails",
    "status" : "creation"
  }
  let $outputParams := map {
    "lang" : "fr",
    "layout" : "formUser.xml",
    "xforms-lib" : "xsltforms",
    "xforms-prefix" : fn:true(),
    "xforms" : fn:true()
  }
  let $function := xs:QName(synopsx.models.synopsx:getModelFunction($queryParams))
  let $data := fn:function-lookup($function, 1)($queryParams)
  (: let $data := synopsx.models.synopsx:getUsersXforms($queryParams) :)
  return synopsx.mappings.templating:wrapper($queryParams, $data, $outputParams)
};

(:~
 : This resource function is a test for the xforms integration
 ::)
declare
  %rest:path("/synopsx-beta/users/{$name}/modify")
  %output:method("xml")
  %perm:allow("admin")
function user($name) {
  let $queryParams := map {
    "project" : 'synopsx',
    "model" : 'synopsx',
    "function" : "getUserDetails",
    "status" : "update",
    "name" : $name
  }
  let $outputParams := map {
    "lang" : "fr",
    "layout" : "formUser.xml",
    "xforms-lib" : "xsltforms",
    "xforms-prefix" : fn:true(),
    "xforms" : fn:true()
  }
  let $function := xs:QName(synopsx.models.synopsx:getModelFunction($queryParams))
  let $data := fn:function-lookup($function, 1)($queryParams)
  (: let $data := synopsx.models.synopsx:getUsersXforms($queryParams) :)
  return synopsx.mappings.templating:wrapper($queryParams, $data, $outputParams)
};

declare
  %rest:path("/synopsx-beta/users/create")
  %output:method("xml")
  %rest:header-param("Referer", "{$referer}", "none")
  %rest:PUT("{$param}")
  %perm:allow("admin") 
  %updating 
function createUser($param as document-node(), $referer as xs:string) {
  let $user := $param
  let $name := fn:normalize-space($user/*:user/@name)
  let $pwd := fn:normalize-space($user/*:user/*:password)
  let $globalPermission := fn:normalize-space($user/*:user/@permission)
  let $patterns := $user//*:database
  let $patternPermissions := for $perm in $patterns//@permission
    return fn:normalize-space($perm)
  let $patternNames :=  for $pattern in $patterns/@pattern
    return fn:normalize-space($pattern)
  let $permissions := ($patternPermissions, $globalPermission)
  let $info  := $user/*:user/*:info
  return user:create($name, $pwd, $permissions, $patternNames, $info)
};

(:~
 : Permissions: synopsx-beta/users
 : Checks if the current user is granted; if not, redirects to the login page.
 : @param $perm map with permission data
 :)
declare
    %perm:check('/synopsx-beta/users', '{$perm}')
function usersPermission($perm) {
  let $user := session:get('id')
  return
      if((fn:empty($user) or fn:not(user:list-details($user)[@permission = $perm?allow])) and fn:ends-with($perm?path, 'new'))
        then web:redirect('/synopsx-beta/login')
      else if((fn:empty($user) or fn:not(user:list-details($user)[@permission = $perm?allow])) and fn:ends-with($perm?path, 'create'))
        then web:redirect('/synopsx-beta/login')
};
