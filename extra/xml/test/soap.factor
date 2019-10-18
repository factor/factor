USING: sequences xml kernel arrays xml.utilities io.files tools.test ;

: assemble-data ( tag -- 3array )
    { "URL" "snippet" "title" }
    [ tag-named children>string ] curry* map ;

: parse-result ( xml -- seq )
    "resultElements" tag-named* "item" tags-named
    [ assemble-data ] map ;

[ "http://www.foxnews.com/oreilly/" ] [
    "extra/xml/test/soap.xml" resource-path file>xml
    parse-result first first
] unit-test
