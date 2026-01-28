xquery version '3.0' ;
module namespace synopsx.models.mixed = 'synopsx.models.mixed';

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

import module namespace G = 'synopsx.globals' at '../globals.xqm'; (: import globals variables :)

declare default function namespace 'synopsx.models.mixed'; (: This is the default namespace:)

declare namespace tei = 'http://www.tei-c.org/ns/1.0'; (: Add namespaces :)


declare function  notFound($queryParams) {
  let $meta := map{
    'title' : 'We did not find what you were looking for...'
    }
  let $content := ()
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};

declare function  getHomeContent($queryParams) {
   let $meta := map{
    'title' : 'This is how SynopsX welcomes you...'
    }
  let $content := ()
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};

declare function  getInstall($queryParams) {
   let $meta := map{
    'title' : 'Let´s install SynopsX...'
    }
  let $content := ()
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};