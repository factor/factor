! Copyright (C) 2006 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!
USING: kernel http-client namespaces io errors sequences rss ;
IN: google-search

: build-soap-request ( key string -- soap )
  #! Return the soap request for a google search
  [
    "<?xml version='1.0' encoding='UTF-8'?>" %
    "<SOAP-ENV:Envelope xmlns:SOAP-ENV='http://schemas.xmlsoap.org/soap/envelope/' xmlns:xsi='http://www.w3.org/1999/XMLSchema-instance' xmlns:xsd='http://www.w3.org/1999/XMLSchema'>" %
    "<SOAP-ENV:Body>" %
    "<ns1:doGoogleSearch xmlns:ns1='urn:GoogleSearch'" %
    "    SOAP-ENV:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>" %
    "  <key xsi:type='xsd:string'>" %
    swap %
    "</key>" %
    "  <q xsi:type='xsd:string'>" %
    %
    "</q>" %
    "  <start xsi:type='xsd:int'>0</start>" %
    "  <maxResults xsi:type='xsd:int'>10</maxResults>" %
    "  <filter xsi:type='xsd:boolean'>true</filter>" %
    "  <restrict xsi:type='xsd:string'></restrict>" %
    "  <safeSearch xsi:type='xsd:boolean'>false</safeSearch>" %
    "  <lr xsi:type='xsd:string'></lr>" %
    "  <ie xsi:type='xsd:string'>latin1</ie>" %
    "  <oe xsi:type='xsd:string'>latin1</oe>" %
    "</ns1:doGoogleSearch>" %
    "  </SOAP-ENV:Body>" %
    "</SOAP-ENV:Envelope> " %
  ] "" make ;

TUPLE: search-item url snippet title ;

: parse-result ( string -- seq )
  "resultElements" swap between-tags "item" swap child-tags [
    [ "URL" swap between-tags ] keep
    [ "snippet" swap between-tags ] keep
    "title" swap between-tags <search-item>
  ] map ;

: google-search ( key string -- result )
  #! Perform a google searching using the Google Web API
  #! key and the search string.
  build-soap-request "text/xml" swap "http://api.google.com/search/beta2" http-post 
  rot 200 = not [ 2drop "Google search failed." throw ] [ nip ] if parse-result ;
