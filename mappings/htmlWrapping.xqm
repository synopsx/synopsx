xquery version '3.0' ;
module namespace synopsx.mappings.htmlWrapping = 'synopsx.mappings.htmlWrapping' ;

(:~
 : This module is an HTML mapping for templating
 :
 : @version 2.0 (Constantia edition)
 : @since 2014-11-10 
 : @author synopsx's team
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

import module namespace G = "synopsx.globals" at '../globals.xqm' ;
import module namespace synopsx.models.synopsx = 'synopsx.models.synopsx' at '../models/synopsx.xqm' ; 

import module namespace synopsx.mappings.tei2html = 'synopsx.mappings.tei2html' at 'tei2html.xqm' ; 

declare namespace html = 'http://www.w3.org/1999/xhtml' ;

declare default function namespace 'synopsx.mappings.htmlWrapping' ;

(:~
 : this function wrap the content in an HTML layout
 :
 : @param $queryParams the query params defined in restxq
 : @param $data the result of the query
 : @param $outputParams the serialization params
 : @return an updated HTML document and instantiate pattern
 
 : @todo treat in the same loop @* and text() ?
 @todo add handling of outputParams (for example {class} attribute or call to an xslt)
 :)


(:~
 : this function wrap the content in an HTML layout
 :
 : @param $queryParams the query params defined in restxq
 : @param $data the result of the query
 : @param $outputParams the serialization params
 : @return an updated HTML document and instantiate pattern
 :
 :)
declare function wrapper($queryParams as map(*), $data as map(*), $outputParams as map(*)) as node()* {
  let $meta := map:get($data, 'meta')
  let $layout := synopsx.models.synopsx:getLayoutPath($queryParams, map:get($outputParams, 'layout'))
  let $wrap := fn:doc($layout)
  let $regex := '\{(.*?)\}'
  return
    $wrap/* update (
      for $text in .//*[@data-url] 
            let $incOutputParams := map:put($outputParams, 'layout', $text/@data-url || '.xhtml')
            let $inc :=  wrapper($queryParams, $data, $incOutputParams)
            return replace node $text with $inc,
      (: keys :)      
      for $text in .//@*
        where fn:matches($text, $regex)
        return replace value of node $text with replace($text, $meta, fn:false()),
      for $text in .//text()
        where fn:matches($text, $regex)
        let $key := fn:replace($text, '\{|\}', '')       
        return if ($key = 'content') 
          then replace node $text with pattern($queryParams, $data, $outputParams)
          else 
           let $value := map:get($meta, $key)
           return if ($value instance of node()* and  fn:not(fn:empty($value))) 
           then replace node $text with render($queryParams, $outputParams, $value)
           else replace node $text with replace($text, $meta, fn:true())      
     (: inc :)
    
      )
};

(:~
 : this function iterates the pattern template with contents
 :
 : @param $queryParams the query params defined in restxq
 : @param $data the result of the query to dispacth
 : @param $outputParams the serialization params
 : @return instantiate the pattern with $data
 :
 : @bug default for sorting
 :)
declare function pattern($queryParams as map(*), $data as map(*), $outputParams as map(*)) as node()* {
 let $sorting := if (map:get($queryParams, 'sorting')) 
    then map:get($queryParams, 'sorting') 
    else ''
  let $order := map:get($queryParams, 'order')
  let $contents := map:get($data, 'content')
  let $pattern := synopsx.models.synopsx:getLayoutPath($queryParams, map:get($outputParams, 'pattern'))
  for $content in $contents
  order by (: @see http://jaketrent.com/post/xquery-dynamic-order/ :)
    if ($order = 'descending') then map:get($content, $sorting) else () ascending,
    if ($order = 'descending') then () else map:get($content, $sorting) descending
  let $regex := '\{(.*?)\}'
  return
    fn:doc($pattern)/* update (
       for $text in .//@*
        where fn:matches($text, $regex)
        return replace value of node $text with replace($text, $content, fn:false()),
      for $text in .//text()
        where fn:matches($text, $regex)
        let $key := fn:replace($text, '\{|\}', '')
        let $value := map:get($content, $key)
        return if ($value instance of node()* and fn:not(fn:empty($value))) 
          then replace node $text with render($queryParams, $outputParams, $value)
          else replace node $text with replace($text, $content, fn:true())
      )
};

(:~
 : this function update the text with input content
 : it does not delete the non matching parts of the string (url etc.)
 :
 : @param $text the text node to process
 : @param $input the content to dispatch
 : @return an updated text
 :
 :)
declare function replace($text as xs:string, $input as map(*), $delete as xs:boolean) as xs:string {
  let $tokens := fn:tokenize($text, '\{|\}')
  let $updated := fn:string-join( 
    for $token in $tokens
    let $value := map:get($input, $token)
    return if (fn:empty($value)) 
      then if ($delete) then () (: delete :) else $token (: leave :)
      else $value
    )
  return $updated
};


(:~
 : this function dispatch the rendering based on $outpoutParams
 :
 : @param $value the content to render
 : @param $outputParams the serialization params
 : @return an html serialization
 :
 : @todo check the xslt with an xslt 1.0
 :)
declare function render($queryParams as map(*), $outputParams as map(*), $value as node()* ) as item()* {
  let $xquery := map:get($outputParams, 'xquery')
  let $xsl :=  map:get($outputParams, 'xsl')
  let $options := map{
    'lb' : map:get($outputParams, 'lb')
    }
  return 
    if ($xquery) 
      then synopsx.mappings.tei2html:entry($value, $options)
    else if ($xsl) 
      then for $node in $value
           return xslt:transform($node, synopsx.models.synopsx:getXsltPath($queryParams, $xsl))/*
      else $value
};


(:~
 : ~:~:~:~:~:~:~:~:~
 : templating reloaded !
 : ~:~:~:~:~:~:~:~:~
 :)
 
(:~
 : this function wrap the content in an HTML layout
 :
 : @param $queryParams the query params defined in restxq
 : @param $data the result of the query
 : @param $outputParams the serialization params
 : @return an updated HTML document and instantiate pattern
 : @bug can't update a element more than once
 :
 :)
declare function wrapperNew($queryParams as map(*), $data as map(*), $outputParams as map(*)) as node()* {
  let $meta := map:get($data, 'meta')
  let $layout := map:get($outputParams, 'layout')
  let $wrap := fn:doc(synopsx.models.synopsx:getLayoutPath($queryParams, $layout))
  let $regex := '\{(.+?)\}'
  return
    $wrap/* update (
      for $node in .//*[fn:matches(text(), $regex)] | .//@*[fn:matches(., $regex)]
      let $key := fn:analyze-string($node, $regex)//fn:group/text()
      return if ($key = 'content') 
        then replace node $node with patternNew($queryParams, $data, $outputParams)
        else associate($queryParams, $meta, $outputParams, $node)
      )
  };

(:~
 : this function iterates the pattern template with contents
 :
 : @param $queryParams the query params defined in restxq
 : @param $data the result of the query to dispacth
 : @param $outputParams the serialization params
 : @return instantiate the pattern with $data
 :
 :)
declare function patternNew($queryParams as map(*), $data as map(*), $outputParams as map(*)) as node()* {
  let $contents := map:get($data, 'content')
  let $pattern := map:get($outputParams, 'pattern')
  let $pattern := fn:doc(synopsx.models.synopsx:getLayoutPath($queryParams, $pattern))
  let $regex := '\{(.+?)\}'
  for $content in $contents
  return
    $pattern/* update (
      for $node in .//*[fn:matches(text(), $regex)] | .//@*[fn:matches(., $regex)]
      return associate($queryParams, $content, $outputParams, $node)
      )
  };

(:~
 : this function dispatch the content with the data
 :
 : @param $queryParams the query params defined in restxq
 : @param $data the result of the query to dispacth (meta or content)
 : @param $outputParams the serialization params
 : @return an updated node with the data
 : @bug doesn't treat mixed content
 : @bug doesn't copy other attribute when updating attribute with a sequence
 :) 
declare %updating function associate($queryParams as map(*), $data as map(*), $outputParams as map(*), $node as node()) {
  let $regex := '\{(.+?)\}'
  let $data := $data
  let $keys := fn:analyze-string($node, $regex)//fn:group/text()
  let $values := map:get($data, $keys)
    return typeswitch ($values)
    case empty-sequence() return ()
    case text() return replace value of node $node with $values
    case xs:string return replace value of node $node with $values
    case xs:string+ return 
      if ($node instance of attribute()) (: when key is an attribute value :)
      then 
        replace node $node/parent::* with 
          element {fn:name($node/parent::*)} {
          for $att in $node/parent::*/(@* except $node) return $att, 
          attribute {fn:name($node)} {fn:string-join($values, ' ')},
          $node/parent::*/text()
          }
    else
      replace node $node with 
      for $value in $values 
      return element {fn:name($node)} { 
        for $att in $node/@* return $att,
        $value
      } 
    case xs:integer return replace value of node $node with xs:string($values)
    case element()+ return replace node $node with 
      for $value in $values 
      return element {fn:name($node)} { 
        for $att in $node/@* return $att, 
        render($queryParams, $outputParams, $value)
      }
    default return replace value of node $node with 'default'
  };
  
  
