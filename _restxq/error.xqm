xquery version "3.1" ;
module namespace synopsx.restxq.error = "synopsx.restxq.error" ;

(:~
 : This module deals with errors
 :
 : @author SynopsX’ team
 : @since 2025-07
 : @version 3.0
 :
 : This file is part of SynopsX, A lightweight framework for
 : XML corpora publication and exposure.
 :
 : GNU General Public License (GPL) v. 3
 :)

declare namespace rest = "http://exquery.org/ns/restxq" ;
declare namespace request = "http://exquery.org/ns/request" ;
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization" ;
declare namespace http = "http://expath.org/ns/http-client" ;
declare namespace fn = "http://www.w3.org/2005/xpath-functions" ;
declare namespace map = "http://www.w3.org/2005/xpath-functions/map" ;

import module namespace synopsx.models.synopsx = "synopsx.models.synopsx" at "../models/synopsx.xqm" ;
import module namespace synopsx.mappings.templating = "synopsx.mappings.templating" at "../mappings/templating.xqm" ;

declare default function namespace "synopsx.restxq.error" ;

(:~
 : This resource function catches uncaught XQuery errors raised by RESTXQ.
 :)
declare
	%rest:error("*")
	%rest:error-param("code", "{$code}")
	%rest:error-param("description", "{$description}")
	%rest:error-param("value", "{$value}")
	%rest:error-param("module", "{$module}")
	%rest:error-param("line-number", "{$line-number}")
	%rest:error-param("column-number", "{$column-number}")
	%output:method("html")
	%output:html-version("5.0")
function xquery-error(
	$code as xs:QName?,
	$description as xs:string?,
	$value as item()*,
	$module as xs:string?,
	$line-number as xs:integer?,
	$column-number as xs:integer?
) as item()+ {
	let $queryParams := map {
		"project" : "synopsx",
		"model" : "synopsx",
		"function" : "getXQueryError",
		"code" : fn:string($code),
		"description" : $description,
		"value" :
			if (fn:exists($value))
			then fn:serialize($value, map { "method": "adaptive" })
			else (),
		"module" : $module,
		"line-number" : if (fn:exists($line-number)) then fn:string($line-number) else (),
		"column-number" : if (fn:exists($column-number)) then fn:string($column-number) else ()
	}
	let $function := synopsx.models.synopsx:getModelFunction($queryParams)
	let $data := fn:function-lookup($function, 1)($queryParams)
	let $outputParams := map {
		"lang" : "fr",
		"layout" : "layout.xml",
		"pattern" : "incError.xml"
	}
	return (
		<rest:response>
			<http:response status="500">
				<http:header name="Content-Type" value="text/html; charset=utf-8"/>
			</http:response>
		</rest:response>,
		synopsx.mappings.templating:wrapper($queryParams, $data, $outputParams)
	)
};

(:~
 : This resource function catches servlet-level HTTP errors routed from web.xml.
 :)
declare
	%rest:path("/synopsx-beta/error/http/{$status}")
	%output:method("html")
	%output:html-version("5.0")
function http-error($status as xs:string) as item()+ {
	let $queryParams := map {
		"project" : "synopsx",
		"model" : "synopsx",
		"function" : "getHttpError",
		"status" : $status,
		"request-uri" : string-attribute("javax.servlet.error.request_uri"),
		"message" : string-attribute("javax.servlet.error.message"),
		"exception" : string-attribute("javax.servlet.error.exception")
	}
	let $function := synopsx.models.synopsx:getModelFunction($queryParams)
	let $data := fn:function-lookup($function, 1)($queryParams)
	let $statusCode := if ($status castable as xs:integer) then xs:integer($status) else 500
	let $outputParams := map {
		"lang" : "fr",
		"layout" : "layout.xml",
		"pattern" : "incError.xml"
	}
	return (
		<rest:response>
			<http:response status="{$statusCode}">
				<http:header name="Content-Type" value="text/html; charset=utf-8"/>
			</http:response>
		</rest:response>,
		synopsx.mappings.templating:wrapper($queryParams, $data, $outputParams)
	)
};

declare function string-attribute($name as xs:string) as xs:string? {
	let $value := request:attribute($name)
	return if ($value) then fn:string($value) else ()
};