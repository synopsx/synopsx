xquery version '3.0' ;
module namespace synopsx.oai = 'synopsx.oai' ;

(:~
 : This module is the RESTXQ for OAI-PMH for SynopsX
 :
 : @version 2.0 (Constantia edition)
 : @since 2014-10
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

import module namespace request = 'http://exquery.org/ns/request' ;

declare namespace xsi = 'http://www.w3.org/2001/XMLSchema-instance' ;
declare namespace xslt= 'http://basex.org/modules/xslt' ;

declare default function namespace 'synopsx.oai' ;
declare default element namespace 'http://www.openarchives.org/OAI/2.0/' ;

declare variable $synopsx.oai:tei2dc := '../files/xsl/tei2dc.xsl' ;

declare %restxq:path('{$project}/oai')
  %output:method('xml')
  %rest:query-param('verb', '{$verb}', '')
  %rest:query-param('identifier', '{$identifier}')
  %rest:query-param('metadataPrefix', '{$metadataPrefix}')
  %rest:query-param('from', '{$from}')
  %rest:query-param('until', '{$until}')
  %rest:query-param('set', '{$set}')
  %rest:query-param('resumptionToken', '{$resumptionToken}')
  %output:omit-xml-declaration('no')
function index($project, $verb, $identifier, $metadataPrefix, $from, $until, $set, $resumptionToken) {
  <OAI-PMH>
    <responseDate>{fn:current-dateTime()}</responseDate>
    <request>{request:uri()}?{request:query()}</request>
    {
      switch ($verb) 
      case 'GetRecord' 
        return synopsx.oai:GetRecord($project, $identifier, $metadataPrefix)
      case 'Identify'
        return synopsx.oai:Identify($project)
      case 'ListIdentifiers'
        return synopsx.oai:ListIdentifiers($project, $from, $until, $metadataPrefix, $set, $resumptionToken)
      case 'ListMetadataFormats'
        return synopsx.oai:ListMetadataFormats($project, $identifier)
      case 'ListRecords'
        return synopsx.oai:ListRecords($project, $from, $until, $metadataPrefix, $set, $resumptionToken)
      case 'ListSets'
        return synopsx.oai:ListSets($project, $resumptionToken)
      case ''
        return <error code='badVerb'>No verb specified</error>
      default
        return <error code='badVerb'>No such verb {$verb}</error>
      }
    </OAI-PMH>
};

declare function synopsx.oai:GetRecord($project, $identifier, $metadataPrefix){
    <GetRecord>
    </GetRecord>
};

declare function synopsx.oai:Identify($project){
  <Identify>
    <repositoryName>{$project}</repositoryName>
    <baseURL>{request:uri()}</baseURL>
    <protocolVersion>2.0</protocolVersion>
    <adminEmail>ahn-equipe@ens-lyon.fr</adminEmail>
    <earliestDatestamp></earliestDatestamp>
    <deletedRecord></deletedRecord>
    <granularity></granularity>
  </Identify>
};

declare function synopsx.oai:ListIdentifiers($project, $from, $until, $metadataPrefix, $set, $resumptionToken){
  <ListIdentifiers>
  </ListIdentifiers>
};

declare function synopsx.oai:ListMetadataFormats($project, $identifier){
  <ListMetadataFormats>
    <metadataFormat>
    <metadataPrefix>oai_dc</metadataPrefix>
    <schema>http://www.openarchives.org/OAI/2.0/oai_dc.xsd</schema>
    <metadataNamespace>http://www.openarchives.org/OAI/2.0/oai_dc/</metadataNamespace>
    </metadataFormat>
  </ListMetadataFormats>
};

declare function synopsx.oai:ListRecords($project, $from, $until, $metadataPrefix, $set, $resumptionToken){
  <ListRecords>
  </ListRecords>
};

declare function synopsx.oai:ListSets($project, $resumptionToken){
  <ListSets>
    {
      for $set in db:open($project)//*:teiCorpus 
      return 
      <set>
        <setSpec>
          {fn:string-join($set/ancestor-or-self::*:teiCorpus/@xml:id,':')}
        </setSpec>
        <setName>
          {$set/*:teiHeader/*:fileDesc/*:titleStmt/*:title/text()}
        </setName>
        <setDescription>
          { if ($set/*:teiHeader) then
              xslt:transform($set/*:teiHeader, $synopsx.oai:tei2dc)
              else ''
          }
        </setDescription>
      </set>
    }
  </ListSets>
};