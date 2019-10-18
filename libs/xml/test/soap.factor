USING: sequences xml kernel arrays xml-utils io test ;
IN: soap-script

: assemble-data ( tag -- 3array )
    { "URL" "snippet" "title" }
    [ tag-named children>string ] map-with ;

: parse-result ( xml -- seq )
    "resultElements" tag-named* "item" tags-named
    [ assemble-data ] map ;

[ "http://www.foxnews.com/oreilly/" ] [
    "libs/xml/test/soap.xml" resource-path file>xml
    parse-result first first
] unit-test
