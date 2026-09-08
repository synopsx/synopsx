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
 : 
 : @todo add a i18 parameter
 :)

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
import module namespace synopsx.models.users = "synopsx.models.users" at "../models/users.xqm";
import module namespace synopsx.mappings.templating = "synopsx.mappings.templating" at "../mappings/templating.xqm";

declare default function namespace "synopsx.restxq.users";

(:~
 : This resource function lists the users
 : @return a list of users
 :)
declare
  %rest:path("/synopsx/users")
  %output:method("html")
  %output:html-version("5.0")
function getUsers() {
  let $queryParams := map { 
    "project" : 'synopsx',
    "model" : 'users',
    "function" : "getUsers"
  }
  let $outputParams := map { 
    "lang" : "fr",
    "layout" : "layoutForms.xml",
    "pattern": "formListUsers.xml",
    "xforms-lib" : "xsltforms",
    "xforms" : fn:true()
  }
  let $function := xs:QName(synopsx.models.synopsx:getModelFunction($queryParams))
  let $data := fn:function-lookup($function, 1)($queryParams)
  return synopsx.mappings.templating:wrapper($queryParams, $data, $outputParams)
};

(:~
 : This resource function is a login page
 : @return a list of users
 :)
declare
  %rest:path("/synopsx/login")
  %output:method("html")
  %output:html-version("5.0")
function login() {
  let $queryParams := map { 
    "project" : 'synopsx',
    "model" : 'users',
    "function" : "getUsers"
  }
  let $outputParams := map { 
    "lang" : "fr",
    "layout" : "layoutForms.xml",
    "pattern": "formUserLogin.xml",
    "xforms-lib" : "xsltforms",
    "xforms" : fn:true()
  }
  let $function := xs:QName(synopsx.models.synopsx:getModelFunction($queryParams))
  let $data := fn:function-lookup($function, 1)($queryParams)
  return synopsx.mappings.templating:wrapper($queryParams, $data, $outputParams)
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
 :)
declare
  %rest:path("/synopsx/users/new")
  %output:method("html")
  %output:html-version("5.0")
  %perm:allow("admin")
function newUser() { 
  let $queryParams := map { 
    "project" : 'synopsx',
    "model" : 'users',
    (:"function" : "getDatabases":)
    "function" : "getUserDetails",
    "mode" : "creation"
  }
  let $outputParams := map {
    "lang" : "fr",
    "layout" : "layoutForms.xml",
    "pattern": "formUser.xml",
    "xforms-lib" : "xsltforms",
    "xforms" : fn:true()
  }
  let $function := xs:QName(synopsx.models.synopsx:getModelFunction($queryParams))
  let $data := fn:function-lookup($function, 1)($queryParams)
  return synopsx.mappings.templating:wrapper($queryParams, $data, $outputParams)
};

(:~
 : This resource function modify an user
 : @param $username the username
 : @return 
 :)
declare
  %rest:path("/synopsx/users/{$username}/modify")
  %output:method("xml")
  %perm:allow("admin")
function user($username) {
  let $queryParams := map {
    "project" : 'synopsx',
    "model" : 'users',
    "function" : "getUserDetails",
    "mode" : "update",
    "username" : $username
  }
  let $outputParams := map {
    "lang" : "fr",
    "layout" : "layoutForms.xml",
    "pattern": "formUser.xml",
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
 : This resource function creates an user
 : @param $referer the url from
 : @param $param the username
 : @return 
 :)
declare
  %rest:path("/synopsx/users/create")
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
  let $token := random:uuid()
  let $info  := if(fn:normalize-space($pwd) ='') then
    <info>{
        <token date="{fn:current-dateTime()}">{$token}</token>,
        $user/*:user/*:info/*
    }</info>
  else
   $user/*:user/*:info
  
  return (
    user:create($name, $pwd, $permissions, $patternNames, $info),
    update:output((
      <rest:response>
        <http:response status="201" message="Created">
          <http:header name="Content-Language" value="fr"/>
          <http:header name="Content-Type" value="text/plain; charset=utf-8"/>
          <http:header name="Content-Location" value="{'/synopsx/users/' || $name}"/>
          {
            if(fn:normalize-space($pwd) ='') then
              <http:header name="Content-token" value="{$token}"/>
          }
        </http:response>
      </rest:response>,
      <result>
        <message>Le nouvel utilisateur a été créé.</message>
        <user>
          <username>{$name}</username>
          <!-- add other infos if needed -->
        </user>
      </result>
    ))
  )
};

(:~
 : This resource function modify an user
 : @param $username the username
 : @return 
 :)
declare
  %rest:path("/synopsx/users/{$username}/confirm")
  %rest:query-param("token", "{$token}", "no-token")
  %output:method("xml")
function confirmUser($username as xs:string, $token as xs:string) {
  switch (user:info($username)/token = $token)
  case fn:true()
    return (
      let $queryParams := map {
      "project" : 'synopsx',
      "model" : 'users',
      "function" : "getUserDetails",
      "mode" : "confirm",
      "username" : $username
    }
    let $outputParams := map {
      "lang" : "fr",
      "layout" : "layoutForms.xml",
      "pattern": "formUser.xml",
      "xforms-lib" : "xsltforms",
      "xforms-prefix" : fn:true(),
      "xforms" : fn:true()
    }
    let $function := xs:QName(synopsx.models.synopsx:getModelFunction($queryParams))
    let $data := fn:function-lookup($function, 1)($queryParams)
    (: let $data := synopsx.models.synopsx:getUsersXforms($queryParams) :)
    return   synopsx.mappings.templating:wrapper($queryParams, $data, $outputParams)
    )
    

    default return web:redirect("/")
  
};


(:~
 : Helpers
 :)

(:
 : this function checks if the user is registered
 : @param $name usernema
 : @param $pass user password
 :
 :)
declare 
  %rest:path("/synopsx/login/check")
  %rest:POST
  %rest:form-param("name", "{$name}")
  %rest:form-param("pass", "{$pass}")
  %updating
function login($name as xs:string, $pass as xs:string) {
  try { 
    user:check($name, $pass),
    session:set('id', $name),
    (: web:redirect("/synopsx/home") :)
    update:output((
      <rest:response>
        <http:response status="200" message="OK">
          <http:header name="Content-Language" value="fr"/>
          <http:header name="Content-Type" value="application/xml; charset=utf-8"/>
          <http:header name="Content-Location" value="/synopsx/home"/>
        </http:response>
      </rest:response>,
      <result>
        <message></message>
        <user>
          Vous êtes connecté comme {$name}
          <!-- add other infos if needed -->
        </user>
      </result>
    ))
  } 
  catch user:* {
    update:output((
      <rest:response>
        <http:response status="401" message="Unauthorized">
          <http:header name="Content-Language" value="fr"/>
          <http:header name="Content-Type" value="text/plain; charset=utf-8"/>
          <http:header name="Content-Location" value="{'/synopsx/login'}"/>
        </http:response>
      </rest:response>,
      <result>
        <message>Vous n’êtes pas connecté</message>
        <user>
          <!-- add other infos if needed -->
        </user>
      </result>
    ))
  }
};

(:
 : This function logs out current user
 :)
declare
  %rest:path("/synopsx/logout") 
function logout() {
  session:delete('id'),
  web:redirect("/synopsx/home")
};

(:~
 : Permissions: synopsx/users
 : Checks if the current user is granted; if not, redirects to the login page.
 : @param $perm map with permission data
 :)
(: declare
    %perm:check('/synopsx/users', '{$perm}')
function usersPermission($perm) {
  let $user := session:get('id')
  return
      if((fn:empty($user) or fn:not(user:list-details($user)[@permission = $perm?allow])) and fn:ends-with($perm?path, 'new'))
        then web:redirect('/synopsx/login')
      else if((fn:empty($user) or fn:not(user:list-details($user)[@permission = $perm?allow])) and fn:ends-with($perm?path, 'create'))
        then web:redirect('/synopsx/login')
}; :)
