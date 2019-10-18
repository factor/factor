USING: sequences xml kernel arrays xml-utils io test ;
IN: soap-script

: assemble-data ( tag -- 3array )
    { "URL" "snippet" "title" }
    [ find-tag children>string ] map-with ;

: parse-result ( xml -- seq )
    "resultElements" get-tag "item" find-tags
    [ assemble-data ] map ;

[ "http://www.foxnews.com/oreilly/" ] [
    "libs/xml/test/soap.xml" resource-path <file-reader> read-xml
    parse-result first first
] unit-test
