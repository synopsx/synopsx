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

import module namespace G = "synopsx.globals" at "../globals.xqm" ;

declare default function namespace "synopsx.models.users" ;

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
  let $meta := map{
    "title" : "Liste des utilisateurs",
    "users" : <users xmlns="">{ user:list-details()}</users>
  }
  let $content := map{
    "title" : "Liste des utilisateurs",
    "users" : <users xmlns="">{ user:list-details()}</users>
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
  let $userDetails := if($username and user:exists($username)) then user:list-details($username)
  let $userInstance := if($username and user:exists($username)) then
    <user xmlns="" name="{$userDetails/@name}" permission="{$userDetails/@permission}">
        <password/>
        {$userDetails/database}
        {$userDetails/*:info}
    </user>
    else <user xmlns="" name="" permission="none"><password/><info/></user>

  let $meta := map{
    "title" : "Compte utilisateur",
    "user" : $userInstance,
    "databases" : <databases xmlns="">{ db:list-details() }</databases>,
    "mode" : <mode xmlns="">{ $mode }</mode>
  }
  let $content := map{
    "title" : "Compte utilisateur",
    "user" : $userInstance,
    "databases" : <databases xmlns="">{ db:list-details() }</databases>,
    "mode" : <mode xmlns="">{ $mode }</mode>
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
  let $globalPermission := fn:normalize-space($queryParams?param/*:user/@permission)
  let $patterns := $queryParams?param//*:database

  let $patternPermissions := for $perm in $patterns//@permission
    return fn:normalize-space($perm)
  let $patternNames :=  for $pattern in $patterns/@pattern
    return fn:normalize-space($pattern)
  let $permissions := ($patternPermissions, $globalPermission)
  let $name := fn:normalize-space($queryParams?param/*:user/@name)
  let $pwd := fn:normalize-space($queryParams?param/*:user/*:password)
  let $token := random:uuid()
  let $info  := if(fn:normalize-space($pwd) = '') 
    then
      <info>{
          <token date="{fn:current-dateTime()}">{$token}</token>,
          $queryParams?param/*:user/*:info/*
      }</info>
    else $queryParams?param/*:user/*:info
  return let $meta := map{
  }
  let $content := map{
    "message" : <p>message</p>
  }
 
  return ( 
    user:create($name, $pwd, $permissions, $patternNames, $info)
    ) 
};

