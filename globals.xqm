xquery version '3.0' ;
module namespace G = 'synopsx.globals';
(:~
 : This module gives the globals variables for SynopsX
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
 :)
 
declare variable $G:HOME := file:base-dir() ;
declare variable $G:WEBAPP := file:parent($G:HOME) ;

declare variable $G:_RESTXQ := $G:HOME || '_restxq/' ;
declare variable $G:FILES := $G:HOME || 'files/' ;
declare variable $G:MODELS :=  $G:HOME || 'models/' ;
declare variable $G:TEMPLATES :=  $G:HOME || 'templates/' ;
declare variable $G:WORKSPACE :=  $G:HOME || 'workspace/' ;

(:~ Status: everything ok. :)
declare variable $G:OK := '1' ;
(:~ Status: something failed. :)
declare variable $G:FAILED := '2' ;
(:~ Status: user unknown. :)
declare variable $G:USER-UNKNOWN := '4' ;
(:~ Status: user exists. :)
declare variable $G:USER-EXISTS := '5' ;

(:~ Status and error messages. To be internationalized:)
declare variable $G:STATUS := map {
  $G:OK          : 'OK',
  $G:FAILED      : 'Something failed.',
  $G:USER-UNKNOWN: 'User is unknown.',
  $G:USER-EXISTS : 'User exists.'
};
