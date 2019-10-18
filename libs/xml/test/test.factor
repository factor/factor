! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
IN: temporary
USING: kernel xml test io namespaces hashtables sequences xml-errors
    errors parser strings xml-data xml-writer xml-utils ;

! This is insufficient
SYMBOL: xml-file
[ ] [ "libs/xml/test/test.xml" resource-path <file-reader>
    read-xml xml-file set ] unit-test
[ "1.0" ] [ xml-file get xml-doc-prolog prolog-version ] unit-test
[ f ] [ xml-file get xml-doc-prolog prolog-standalone ] unit-test
[ "a" ] [ xml-file get name-space ] unit-test
[ "http://www.hello.com" ] [ xml-file get name-url ] unit-test
[ { "that" } ]
    [ T{ name f "" "this" "http://d.de" } xml-file get
    tag-props hash ] unit-test
[ t ] [ xml-file get tag-children second contained-tag? ] unit-test
[ t ] [ [ "<a></b>" string>xml ] catch xml-parse-error? ] unit-test
[ T{ comment f "This is where the fun begins!" } ] [
    xml-file get xml-doc-before [ comment? ] find nip
] unit-test
[ "entity" ] [ xml-file get [ entity? ] xml-find entity-name ] unit-test
[ "xsl stylesheet=\"that-one.xsl\"" ] [
    xml-file get xml-doc-after [ instruction? ] find nip instruction-text
] unit-test
[ V{ "fa&g" } ] [ xml-file get "x" get-id tag-children ] unit-test
[ { "that" } ] [ xml-file get "this" prop-name-tag ] unit-test
[ "<?xml version=\"1.0\" encoding=\"iso-8859-1\" standalone=\"no\"?><a b=\"c\"/>\n" ]
    [ "<a b='c'/>" string>xml xml>string ] unit-test
[ "abcd" ] [
    "<main>a<sub>bc</sub>d<nothing/></main>" string>xml
    [ [ dup string? [ % ] [ drop ] if ] xml-each ] "" make
] unit-test
[ "foo" ] [
    "<a><b id='c'>&foo;</b><d id='e'/></a>" string>xml
    "c" get-id tag-children [ entity? ] find nip
    entity-name
] unit-test
