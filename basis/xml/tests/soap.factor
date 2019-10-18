USING: sequences xml kernel arrays xml.traversal io.files tools.test ;
IN: xml.tests

: assemble-data ( tag -- 3array )
    { "URL" "snippet" "title" }
    [ tag-named children>string ] with map ;

: parse-result ( xml -- seq )
    "resultElements" deep-tag-named "item" tags-named
    [ assemble-data ] map ;

[ "http://www.foxnews.com/oreilly/" ] [
    "vocab:xml/tests/soap.xml" file>xml
    parse-result first first
] unit-test
