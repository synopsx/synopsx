xquery version '3.0' ;
module namespace synopsx.models.tei = 'synopsx.models.tei' ;

(:~
 : This module is for TEI models
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

import module namespace synopsx.models.synopsx = 'synopsx.models.synopsx' at '../models/synopsx.xqm' ;

declare namespace tei = 'http://www.tei-c.org/ns/1.0' ;

declare default function namespace "synopsx.models.tei";




(:~
 : this function returns a sequence of map for meta and content 
 : !! the result structure has changed to allow sorting early in mapping
 : 
 : @rmq for testing with new htmlWrapping
 :)
declare function queryCorpus($queryParams as map(*)) as map(*) {
  let $texts := getCorpusItems($queryParams)
   let $missingIds := fn:count($texts[fn:not(@xml:id)])
   
   let $meta := map{
    'title' : fn:count($texts) || ' corpus TEI' ,
      'msg' :  if ($missingIds = 0 ) then '' else 'WARNING : ' || $missingIds || ' teiCorpus elements require(s) the @xml:id attribute (generating errors in the SynopsX webapp !)'
    }
  let $content := for $text in $texts return getCorpusMap($text)
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};


declare function getCorpusItems($queryParams){

  let $sequence := synopsx.models.synopsx:getDb($queryParams)//tei:teiCorpus
  (: TODO : analyse query params : is an id specified ?  is a sorting order specified ? ... :)
  return 
      if ($queryParams('id'))  then $sequence[@xml:id = $queryParams('id')] else $sequence
};






declare function getCorpusMap($item as item()) as map(*) {
 map{
      'description':getProjectDesc($item),
      'title' : getTitles($item),
      'msg' : checkEncoding($item)
      }
  };
  
(:~
 : this function returns a sequence of map for meta and content 
 : !! the result structure has changed to allow sorting early in mapping
 : 
 : @rmq for testing with new htmlWrapping
 :)
(:~
 : this function returns a sequence of map for meta and content 
 : !! the result structure has changed to allow sorting early in mapping
 : 
 : @rmq for testing with new htmlWrapping
 :)
declare function queryTEI($queryParams as map(*)) as map(*) {
  let $texts := getTEIItems($queryParams)
  let $missingIds := fn:count($texts[fn:not(@xml:id)])
   let $meta := map{
    'title' : fn:count($texts) || ' TEI texts' ,
    'msg' :  if ($missingIds = 0 ) then '' else 'WARNING : ' || $missingIds || ' TEI elements require(s) the @xml:id attribute (generating errors in the SynopsX webapp !)'
    }
  let $content := for $text in $texts return getTEIMap($text)
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};


declare function getTEIItems($queryParams){

  let $sequence := synopsx.models.synopsx:getDb($queryParams)//tei:TEI
  (: TODO : analyse query params : is an id specified ?  is a sorting order specified ? ... :)
  return 
      if ($queryParams('id'))  then $sequence[@xml:id = $queryParams('id')] else $sequence
};






declare function getTEIMap($item as item()) as map(*) {
 map{
      'description':getProjectDesc($item),
      'title' : getTitles($item),
      'date' : getDate($item/tei:teiHeader),
      'author' : getAuthors($item/tei:teiHeader),
      'text' : $item/tei:text,
      'id' : fn:string($item/@xml:id) ,
      'msg' : checkEncoding($item)
      }
  };
  

(:~
 : this function creates a map of two maps : one for metadata, one for content data
 :)
declare function queryBibl($queryParams) {
  let $texts := db:open(map:get($queryParams, 'dbName'))//tei:bibl
  let $meta := map{
    'title' : 'Bibliographie'
    }
  let $content := for $item in $texts return getBibl($item)
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};

(:~
 : this function creates a map of two maps : one for metadata, one for content data
 :)
declare function queryResp($queryParams) {
  let $texts := db:open(map:get($queryParams, 'dbName'))//tei:respStmt
  let $meta := map{
    'title' : 'Responsables de l édition'
    }
  let $content := for $item in $texts return getResp($item)
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};



(:~
 : this function creates a map for a corpus item with teiHeader 
 :
 : @param $item a corpus item
 : @return a map with content for each item
 : @rmq subdivised with let to construct complex queries (EC2014-11-10)
 :)
declare function getHeader($item as element()) {
   map {
    'title' : getTitles($item/tei:teiHeader),
    'date' : getDate($item/tei:teiHeader),
    'author' : getAuthors($item/tei:teiHeader),
    'description' : getProjectDesc($item/tei:teiHeader),
    'id': fn:data($item/@xml:id)
  }
};



(:~
 : this function creates a map for a corpus item with teiHeader 
 :
 : @param $item a corpus item
 : @return a map with content for each item
 : @rmq subdivised with let to construct complex queries (EC2014-11-10)
 :)
declare function getBibl($item as element()) {
  map {
    'title' : getBiblTitles($item),
    'date' : getBiblDate($item),
    'author' : getBiblAuthors($item),
    'tei' : $item
  }
};

(:~
 : this function creates a map for a corpus item with teiHeader 
 :
 : @param $item a corpus item
 : @return a map with content for each item
 : @rmq subdivised with let to construct complex queries (EC2014-11-10)
 :)
declare function getResp($item as element()) {
  map {
    'name' : getName($item),
    'resp' : $item//tei:resp
  }
};

(:~
 : ~:~:~:~:~:~:~:~:~
 : tei builders
 : ~:~:~:~:~:~:~:~:~
 :)

(:~
 : this function get titles
 : @param $content texts to process
 : @param $lang iso langcode starts
 : @return a string of comma separated titles
 :)
declare function getTitles($content as element()*){
  fn:string-join(
    for $title in $content/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/text()
    return fn:string-join($title), ' ')
};

(:~
 : this function get titles
 : @param $content texts to process
 : @param $lang iso langcode starts
 : @return a string of comma separated titles
 :)
declare function getBiblTitles($content as element()*){
  fn:string-join(
    for $title in $content//tei:title
    return fn:normalize-space($title),
    ', ')
};

(:~
 : this function get abstract
 : @param $content texts to process
 : @return a tei abstract
 :)
declare function getProjectDesc($content as element()*){
   fn:string-join(
    for $abstract in $content//tei:projectDesc
    return fn:normalize-space($abstract),
    ' ')
};

(:~
 : this function get authors
 : @param $content texts to process
 : @return a distinct-values comma separated list
 :)
declare function getAuthors($content as element()*){
  fn:string-join(
    fn:distinct-values(
      for $name in $content//tei:titleStmt//tei:author//text()
        return fn:string-join($name, ' - ')
      ), 
    ', ')
};

(:~
 : this function get authors
 : @param $content texts to process
 : @return a distinct-values comma separated list
 :)
declare function getBiblAuthors($content as element()*){
  fn:string-join(
    fn:distinct-values(
      for $name in $content//tei:name//text()
        return fn:string-join($name, ' - ')
      ), 
    ', ')
};

(:~
 : this function get the licence url
 : @param $content texts to process
 : @return the @target url of licence
 :
 : @rmq if a sequence get the first one
 : @todo make it better !
 :)
declare function getCopyright($content){
  ($content//tei:licence/@target)[1]
};

(:~
 : this function get date
 : @param $content texts to process
 : @param $dateFormat a normalized date format code
 : @return a date string in the specified format
 : @todo formats
 :)
declare function getDate($content as element()*){
  fn:normalize-space(
    $content//tei:publicationStmt/tei:date
  )
};

(:~
 : this function get date
 : @param $content texts to process
 : @param $dateFormat a normalized date format code
 : @return a date string in the specified format
 : @todo formats
 :)
declare function getBiblDate($content as element()*){
  fn:normalize-space(
    $content//tei:imprint/tei:date
  )
};



(:~
 : this function get keywords
 : @param $content texts to process
 : @param $lang iso langcode starts
 : @return a comma separated list of values
 :)
declare function getKeywords($content as element()*){
  fn:string-join(
    for $terms in fn:distinct-values($content//tei:keywords/tei:term) 
    return fn:normalize-space($terms), 
    ', ')
};

(:~
 : this function serialize persName
 : @param $named named content to process
 : @return concatenate forename and surname
 :)
declare function getName($named as element()*){
  fn:normalize-space(
    for $person in $named/tei:persName 
    return ($person/tei:forename || ' ' || $person/tei:surname)
    )
};


(:~
 : this function get abstract
 : @param $content texts to process
 : @return a tei abstract
 :)
declare function getFront($content as element()*){
  map {
    'tei' :   $content//tei:front
  }

};

(:~
 : this function get abstract
 : @param $content texts to process
 : @return a tei abstract
 :)
declare function getBody($content as element()*){
 map {
    'tei' :   $content//tei:body
  }
};


(:~
 : this function get abstract
 : @param $content texts to process
 : @return a tei abstract
 :)
declare function getBack($content as element()*){
 map {
    'tei' :   $content//tei:back
  }
};

declare function checkEncoding($item as element()*){
  let $checkId := if($item/@xml:id) then () else 'missing  TEI xml:id attribute'
  (: Add other checkings here if needed then concatane them in return :)
  return $checkId
};
