xquery version "3.1" ;
module namespace synopsx.models.synopsx = "synopsx.models.users" ;

(:~
 : This module provides models for users management in SynopsX
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
declare namespace update = "http://basex.org/modules/update" ;
declare namespace user = "http://basex.org/modules/user" ;
declare namespace session = "http://basex.org/modules/session" ;
declare namespace sessions = "http://basex.org/modules/sessions" ;
declare namespace synopsx-error = "synopsx.models.users.error" ;

declare default function namespace "synopsx.models.users" ;

(:~
 : this function tells whether the current caller is logged in
 : @return true() if a session user id is set
 :)
declare function isLoggedIn() as xs:boolean {
  fn:exists(session:get('id'))
};

(:
 : This function lists basex’s users
 :
 : @param $queryParams the query params
 : @return a meta with users details
 :
 : @rmq this function uses xforms
 : @todo content
 :)
declare function getUsers($queryParams as map(*)) {
  let $connectedUsers := for $sid in sessions:ids()
    let $name := sessions:get($sid, 'id')
    where fn:exists($name)
    return $name
  let $usersList := <users xmlns="">{
      for $u in user:list-details()
      return element user {
        $u/@*,
        attribute connected { if ($u/@name = $connectedUsers) then '🟢' else '⚪' },
        $u/node()
      }
    }</users>
  let $meta := map{
    "title" : "Liste des utilisateurs",
    "users" : $usersList
  }
  let $content := map{
    "title" : "Liste des utilisateurs",
    "users" : $usersList
  }

  return map{
    "meta"    : $meta,
    "content" : $content
  }
};

(:
 : This function returns basex’s user details
 :
 : @param $queryParams the query params
 : @return a meta with informations about a user
 :
 : @rmq this function uses xforms
 : @todo content
 :)
declare function getUserDetails($queryParams as map(*)){
  let $mode := $queryParams("mode")
  let $username := $queryParams("username")
  let $token := $queryParams("token")
  let $userDetails := if($username and user:exists($username)) then user:list-details($username)
  let $userInstance := if($username and user:exists($username)) then
    <user xmlns="" name="{$userDetails/@name}" permission="{$userDetails/@permission}">
        <password/>
        {
          if ($userDetails/database) then $userDetails/database
          else <database pattern="" permission="" xmlns="" />
        }
        {$userDetails/*:info}
    </user>
    else <user xmlns="" name="" permission="none"><password/><database pattern="" permission="" xmlns="" /><info/></user>

  let $meta := map{
    "title" : "Compte utilisateur",
    "user" : $userInstance,
    "databases" : <databases xmlns="">{ db:list-details() }</databases>,
    "mode" : <mode xmlns="">{ $mode }</mode>,
    "token" : <token xmlns="">{ $token }</token>
  }
  let $content := map{
    "title" : "Compte utilisateur",
    "user" : $userInstance,
    "databases" : <databases xmlns="">{ db:list-details() }</databases>,
    "mode" : <mode xmlns="">{ $mode }</mode>,
    "token" : <token xmlns="">{ $token }</token>
  }

  return map{
    "meta"    : $meta,
    "content" : $content
  }
};

(:~
 : this function creates a new user
 :
 : @param $queryParams the query params
 : @return an http response with the informations about the user
 :)
declare 
  %updating 
function putUser($queryParams as map(*))  {
  switch ($queryParams?mode)
    case 'create' return createUser($queryParams) 
    case 'confirm' return confirmUser($queryParams)
    case 'update' return updateUser($queryParams)
    case 'delete' return user:drop($queryParams?username)
    (: TODO: route through the multi-language error catalog (G:message) once it lands :)
    default return fn:error(
      xs:QName('synopsx-error:invalid-mode'),
      'Unknown user mode "' || $queryParams?mode || '". Valid modes: create, confirm, update, delete.',
      $queryParams?mode
    )
};

declare 
  %updating
function createUser($queryParams as map(*)) {
  let $name := fn:normalize-space($queryParams?param/*:user/@name)
  let $pwd := fn:normalize-space($queryParams?param/*:user/*:password)
  let $token := random:uuid()

  let $globalPermission := fn:normalize-space($queryParams?param/*:user/@permission)
  let $patterns := $queryParams?param//*:database[fn:normalize-space(@pattern) != '' and fn:normalize-space(@permission) != '']
  let $patternPermissions := for $perm in $patterns/@permission
    return fn:normalize-space($perm)
  let $patternNames :=  for $pattern in $patterns/@pattern
    return fn:normalize-space($pattern)
  let $permissions := ($patternPermissions, $globalPermission)

  let $info := if (fn:normalize-space($pwd) = '')
    then
      <info>{
          <token date="{fn:current-dateTime()}">{$token}</token>,
          $queryParams?param/*:user/*:info/*
      }</info>
    else $queryParams?param/*:user/*:info
  
  let $confirmLink := if (fn:normalize-space($pwd) = '')
    then '/synopsx/users/' || $name || '/confirm?token=' || $token
    else ''
  
  return (
    user:create($name, $pwd, $permissions, $patternNames, $info),
    update:output((
      <rest:response>
        <http:response status="200" message="OK">
          <http:header name="Content-Language" value="fr"/>
          <http:header name="Content-Type" value="application/xml; charset=utf-8"/>
          <http:header name="Content-Token" value="{$token}"/>
          <http:header name="confirmation-link" value="{$confirmLink}"/>
        </http:response>
      </rest:response>,
      <result>
        <message>Nouvel utilisateur {$name} créé.</message>
        <user>
          <name>{$name}</name>
          <token>{$token}</token>
          <!-- add other infos if needed -->
        </user>
      </result>
    ))
  )
};

declare 
  %updating
function confirmUser($queryParams as map(*)) {
  let $name := fn:normalize-space($queryParams?username)
  let $token := fn:normalize-space($queryParams?token)
  let $userDetails := user:list-details($name)
  let $storedToken := $userDetails/*:info/*:token
  let $pwd := fn:normalize-space($queryParams?param/*:user/*:password)
  
  return 
    if ($storedToken and fn:string($storedToken) = $token) then (
      let $info :=
        copy $i := user:list-details($queryParams?username)/*:info
        modify delete node $i/*:token
        return $i

      return(
        user:password($name, $pwd),
        user:update-info($info, $queryParams?username),
        update:output((
          <rest:response>
            <http:response status="200" message="OK">
              <http:header name="Content-Language" value="fr"/>
              <http:header name="Content-Type" value="application/xml; charset=utf-8"/>
            </http:response>
          </rest:response>,
          <result>
            <message>Le mot de passe a été mis à jour pour l’utilisateur {$name}.</message>
            <user>
              <name>{$name}</name>
            </user>
          </result>
        ))
      )
    )
    else update:output((
      <rest:response>
        <http:response status="400" message="Bad Request">
          <http:header name="Content-Language" value="fr"/>
          <http:header name="Content-Type" value="application/xml; charset=utf-8"/>
        </http:response>
      </rest:response>,
      <result>
        <message>Échec, token invalide.</message>
      </result>
    ))
    (: TODO: route through the multi-language error catalog (G:message) once it lands :)
    (: else fn:error(
      xs:QName('synopsx-error:invalid-token'),
      'Invalid or expired confirmation token for user "' || $queryParams?username || '".',
      $queryParams?username
    ) :)
};

declare 
  %updating
function updateUser($queryParams as map(*)) {
  let $name := fn:normalize-space($queryParams?param/*:user/@name)
  let $oldusername := fn:normalize-space($queryParams?oldusername)
  let $userDetails := user:list-details($oldusername)

  let $globalPermission := fn:normalize-space($queryParams?param/*:user/@permission)
  let $patterns := $queryParams?param//*:database[fn:normalize-space(@pattern) != '' and fn:normalize-space(@permission) != '']
  let $patternPermissions := for $perm in $patterns/@permission
    return fn:normalize-space($perm)
  let $patternNames :=  for $pattern in $patterns/@pattern
    return fn:normalize-space($pattern)
  let $permissions := ($patternPermissions, $globalPermission)

  let $pwd := fn:normalize-space($queryParams?param/*:user/*:password)
  return (
    if ($pwd != '') then user:password($name, $pwd),
    if ($name != $oldusername) then user:alter($oldusername, $name),
    (: if ($queryParams?param/*:user/*:info) then user:update-info($queryParams?param/*:user/*:info, $name), :)
    user:grant($oldusername, $permissions, $patternNames),
    update:output((
      <rest:response>
        <http:response status="200" message="OK">
          <http:header name="Content-Language" value="fr"/>
          <http:header name="Content-Type" value="application/xml; charset=utf-8"/>
        </http:response>
      </rest:response>,
      <result>
        <message>Le mot de passe a été mis à jour pour l’utilisateur {$name}.</message>
        <user>
          <name>{$name}</name>
        </user>
      </result>
    ))
  )
};