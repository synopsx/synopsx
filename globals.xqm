xquery version "3.1" ;
module namespace G = "synopsx.globals";

(:~
 : This module gives the globals variable for SynopsX
 :
 : @author SynopsX’ team
 : @since 2024-10
 : @version 3.0
 :
 : This file is part of SynopsX, A lightweight framework for seamless
 : XML corpora publication and exposure — effortless as a breath!
 :
 : SynopsX is free software, freely redistributable and modifiable
 : under the terms of the GNU General Public License (GPL) v. 3
 :
 :)

declare namespace file = "http://expath.org/ns/file" ;

declare variable $G:HOME := file:base-dir() ;
declare variable $G:WEBAPP := file:parent($G:HOME) ;

declare variable $G:_RESTXQ := $G:HOME || "_restxq/" ;
declare variable $G:FILES := $G:HOME || "static/" ;
declare variable $G:MODELS :=  $G:HOME || "models/" ;
declare variable $G:TEMPLATES :=  $G:HOME || "templates/" ;
declare variable $G:WORKSPACE := if(file:exists($G:WEBAPP || "workspace/")) 
  then $G:WEBAPP || "workspace/" 
  else $G:HOME || "workspace/";

declare variable $G:XFORMS := "static/xsltforms/xsltforms.xsl" ;

(:~ Status: everything ok. :)
declare variable $G:OK := "1" ;
(:~ Status: something failed. :)
declare variable $G:FAILED := "2" ;
(:~ Status: user unknown. :)
declare variable $G:USER-UNKNOWN := "4" ;
(:~ Status: user exists. :)
declare variable $G:USER-EXISTS := "5" ;

(:~ Status and error messages. To be internationalized:)
declare variable $G:STATUS := map {
  $G:OK          : "OK",
  $G:FAILED      : "Something failed.",
  $G:USER-UNKNOWN: "User is unknown.",
  $G:USER-EXISTS : "User exists."
};
