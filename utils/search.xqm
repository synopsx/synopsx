xquery version '3.0' ;
module namespace search = 'http://ahn.ens-lyon.fr/search' ;

(:~
 : This module is a demo search fo SynopsX
 :
 : @version 0.2 (Constantia edition)
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
 : @todo to implement
 :)


(:
 : launches search for a 
 : @word
:)
declare function search:query ($db as xs:string, $word as xs:string) {
  let $ftindex := db:info($db)//ftindex = 'true'
  let $outputParams := map {
    'mode' : 'all words',
    'fuzzy' : true()
  }
  return if ($ftindex) then ( ft:search($db, $word, $outputParams) ) 
  else ( db:open($db)//*[ft:contains($db, $word, $outputParams)] )
};
