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
  %rest:GET
  %rest:path("/synopsx/users/create")
  %output:method("html")
  %output:html-version("5.0")
  %perm:allow("admin")
function newUser() { 
  let $queryParams := map { 
    "project" : 'synopsx',
    "model" : 'users',
    "function" : "getUserDetails",
    "mode" : "creation",
    "permission" : "admin"
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
 : This resource function creates an user
 : @param $param the http response
 : @param $referer the referer url
 : @return an http redirection
 : @todo refine the naming of $param
 : @bug  need Mixupdate =true
 :)
 (::)
declare
  %rest:PUT("{$param}")
  %rest:path("/synopsx/users/create")
  %rest:header-param("Referer", "{$referer}", "none")
  %output:method("xml")
  %perm:allow("admin")
  %updating
function createUser($param as document-node(), $referer as xs:string) {
  let $queryParams := map{
    "project" : "synopsx",
    "model" : "users",
    "function" : "putUser",
    "mode" : "create",
    "param" : $param,
    "referer" : $referer
  }
  let $outputParams := map{}
  let $function := xs:QName(synopsx.models.synopsx:getModelFunction($queryParams))
  return synopsx.models.users:putUser($queryParams)
};

(:~
 : This resource function allows an user to set his password after the creation of his account
 : @param $username the username
 : @query-param $token set by synopsx when the user is created (transmitted by admin)
 : @return an XForms to set the password
 :)
declare
  %rest:GET
  %rest:path("/synopsx/users/{$username}/confirm")
  %rest:query-param("token", "{$token}", "no-token")
  %output:method("html")
  %output:html-version("5.0")
function confirmUser($username as xs:string, $token as xs:string) {
  switch (user:info($username)/token = $token)
  case fn:true()
    return (
      let $queryParams := map {
      "project" : 'synopsx',
      "model" : 'users',
      "function" : "getUserDetails",
      "mode" : "confirm",
      "username" : $username,
      "token" : $token
    }
    let $outputParams := map {
      "lang" : "fr",
      "layout" : "layoutForms.xml",
      "pattern": "formUser.xml",
      "xforms-lib" : "xsltforms",
      (: "xforms-prefix" : fn:true(), :)
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
 : This resource function sets the password of a newly created user
 : @param $username the username
 : @query-param $token set by synopsx when the user is created
 : @return 
 :)
declare
  %rest:PUT("{$param}")
  %rest:path("/synopsx/users/{$username}/confirm")
  %rest:header-param("Referer", "{$referer}", "none")
  %rest:query-param("token", "{$token}", "no-token")
  %output:method("xml")
  %updating
function setPwd($param as document-node(), $username as xs:string, $token as xs:string, $referer as xs:string) {
  let $queryParams := map{
    "project" : "synopsx",
    "model" : "users",
    "function" : "putUser",
    "mode" : "confirm",
    "param" : $param,
    "referer" : $referer,
    "username" : $username,
    "token" : $token
  }
  let $outputParams := map{}
  let $function := xs:QName(synopsx.models.synopsx:getModelFunction($queryParams))
  return synopsx.models.users:putUser($queryParams)
};

(:~
 : This resource function updates an user
 : @param $username the username
 : @return 
 :)
declare
  %rest:GET
  %rest:path("/synopsx/users/{$username}/update")
  %output:method("html")
  %output:html-version("5.0")
function user($username) {
  let $user := session:get('id')
  let $permission := if(user:list-details($user)/@permission = 'admin')
    then 'admin'
  else 'user'
  
  let $queryParams := map {
    "project" : 'synopsx',
    "model" : 'users',
    "function" : "getUserDetails",
    "mode" : "update",
    "permission" : $permission,
    "username" : $username
  }
  let $outputParams := map {
    "lang" : "fr",
    "layout" : "layoutForms.xml",
    "pattern": "formUser.xml",
    "xforms-lib" : "xsltforms",
    (: "xforms-prefix" : fn:true(), :)
    "xforms" : fn:true()
  }
  let $function := xs:QName(synopsx.models.synopsx:getModelFunction($queryParams))
  let $data := fn:function-lookup($function, 1)($queryParams)
  (: let $data := synopsx.models.synopsx:getUsersXforms($queryParams) :)
  return synopsx.mappings.templating:wrapper($queryParams, $data, $outputParams)
};

(:~
 : This resource function sets the password of a newly created user
 : @param $username the username
 : @query-param $token set by synopsx when the user is created
 : @return 
 :)
declare
  %rest:PUT("{$param}")
  %rest:path("/synopsx/users/{$username}/update")
  %rest:query-param("oldusername", "{$oldusername}", "no old user name")
  %rest:header-param("Referer", "{$referer}", "none")
  %output:method("xml")
  %updating
function updateUser($param as document-node(), $username as xs:string, $oldusername as xs:string, $referer as xs:string) {
  let $initiator := session:get('id')
  let $queryParams := map{
    "project" : "synopsx",
    "model" : "users",
    "function" : "putUser",
    "mode" : "update",
    "param" : $param,
    "referer" : $referer,
    "username" : $username,
    "oldusername" : $oldusername,
    "initiator" : user:list-details($initiator)/@name
    (:username is potentialy the old user name so we also use a queryparam:)
  }
  let $outputParams := map{}
  let $function := xs:QName(synopsx.models.synopsx:getModelFunction($queryParams))
  return synopsx.models.users:putUser($queryParams)
};

(:~
 : This resource function deletes a user
 : @param $username the username
 : @return 
 :)
declare
  %rest:PUT
  %rest:path("/synopsx/users/{$username}/delete")
  %output:method("xml")
  %perm:allow("admin")
  %updating
function deleteUser($username as xs:string) {
  let $queryParams := map{
    "project" : "synopsx",
    "model" : "users",
    "function" : "putUser",
    "mode" : "delete",
    "username" : $username
  }
  return synopsx.models.users:putUser($queryParams)
};

(:~
 : Permissions: synopsx/users
 : Redirects to the login page when no session is open, except for the
 : account-confirmation flow which is deliberately anonymous (token-gated).
 : @param $perm map with permission data
 :)
declare
    %perm:check('/synopsx/users/{$username}/delete', '{$perm}')
function deleteUserPermission($perm) {
  let $permission := $perm?allow
  let $user := session:get('id')
  
  return (
    if(fn:empty($user))
      then web:redirect('/synopsx/login')
    else if(user:list-details($user)/@permission != $permission)
      then web:redirect('/synopsx/users')
    else ()
  )
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
  %rest:POST
  %rest:path("/synopsx/login/check")
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
          <http:header name="link" value="/synopsx/home"/>
        </http:response>
      </rest:response>,
      <result>
        <message>Vous êtes connecté comme {$name}</message>
        <user><!-- add other infos if needed --></user>
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
        <user><!-- add other infos if needed --></user>
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
 : Redirects to the login page when no session is open, except for the
 : account-confirmation flow which is deliberately anonymous (token-gated).
 : @param $perm map with permission data
 :)
declare
    %perm:check('/synopsx/users', '{$perm}')
function usersPermission($perm) {
  let $path := $perm?path
  let $user := session:get('id')
  let $username := if(fn:not(fn:empty($user)))
    then user:list-details($user)/@name

  return switch()
    case $path = '/synopsx/users/create' return 
      if(fn:empty($user))
        then web:redirect('/synopsx/login')
      else if(user:list-details($user)/@permission != $perm?allow)
        then web:redirect('/synopsx/login')
      else ()
    case fn:contains($path, '/update') return
      if(fn:empty($user))
        then web:redirect('/synopsx/login')
      else if($path[fn:starts-with(., '/synopsx/users/' || $username)])
        then ()
      else if(user:list-details($user)/@permission = 'admin')
        then ()
      else web:redirect('/synopsx/users')
    case fn:contains($path, '/delete') return
      if(fn:empty($user))
        then web:redirect('/synopsx/login')
      else if(user:list-details($user)/@permission != $perm?allow)
        then web:redirect('/synopsx/login')
      else ()
    default return ()
      (: if(fn:contains($path, '/confirm'))
        then ()
      else if(fn:contains($path, '/update') and fn:not(fn:empty($user)))
        then ()
      else if(fn:empty($user))
        then web:redirect('/synopsx/login')
      else if(user:list-details($user)/@permission != $perm?allow)
        then web:redirect('/synopsx/login')
      else () :)
};
