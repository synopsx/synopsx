xquery version '3.0' ;
module namespace synopsx.models.ead = 'synopsx.models.ead' ;

(:~
 : This module is for TEI models
 :
 : @version 2.0 (Constantia edition)
 : @date 2014-11-10 
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

import module namespace synopsx.models.synopsx = 'synopsx.models.synopsx' at '../models/synopsx.xqm' ;

declare namespace ead = 'urn:isbn:1-931666-22-9';
declare default function namespace 'synopsx.models.ead'; (: This is the default namespace:)


(:~
 : this function returns a sequence of map for meta and content 
 : !! the result structure has changed to allow sorting early in mapping
 : 
 : @rmq for testing with new htmlWrapping
 :)
declare function queryEad($queryParams as map(*)) as map(*) {
  let $repos := getEadItems($queryParams)
   let $missingIds := fn:count($repos[fn:not(@xml:id)])
   
   let $meta := map{
    'title' : fn:count($repos) || ' EAD repositories dans la base ' || $queryParams('dbName') 
    }
  let $content := for $text in $repos return getEadMap($text)
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};


declare function getEadItems($queryParams){

  let $sequence := synopsx.models.synopsx:getDb($queryParams)//ead:ead
  (: TODO : analyse query params : is an id specified ?  is a sorting order specified ? ... :)
  return 
      if ($queryParams('id'))  then $sequence[@xml:id = $queryParams('id')] else $sequence
};






declare function getEadMap($item as item()) as map(*) {
 map{
      'title' :$item/ead:eadheader//ead:titleproper,
      'quantity' : fn:string(fn:count($item//ead:c))
      }
  };
  
  
  (:~
 : this function returns a sequence of map for meta and content 
 : !! the result structure has changed to allow sorting early in mapping
 : 
 : @rmq for testing with new htmlWrapping
 :)
declare function queryC($queryParams as map(*)) as map(*) {
  let $c := getCItems($queryParams)
  let $missingIds := fn:count($c[fn:not(@xml:id)])
   
   let $meta := map{
    'title' : fn:count($c) || ' ead c items',
    'msg' :  if ($missingIds = 0 ) then '' else 'WARNING : ' || $missingIds || ' c elements require(s) the @xml:id attribute (generating errors in the SynopsX webapp !)'
    }
  let $content := for $item in $c return getCMap($item)
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};



declare function getCItems($queryParams){

  let $sequence := synopsx.models.synopsx:getDb($queryParams)//ead:c
  (: TODO : analyse query params : is an id specified ?  is a sorting order specified ? ... :)
  return 
      if ($queryParams('id'))  then $sequence[@xml:id = $queryParams('id')] else $sequence
};



declare function getCMap($item as item()) as map(*)* {

    let $maps :=
         ( for $title in $item/ead:did/ead:unittitle
         return map:entry('title', fn:string($title/text())),
         for $date in $item/ead:did/ead:unitdate
         return map:entry($date/@label, fn:string($date/@normal)),
         for $id in $item/ead:did/ead:unitid 
         return map:entry('cote' || $id/fn:position(), $id/@repossitorycode || $id/text()  || ' ' ||  $id/@type))
    return map:merge($maps)
  };