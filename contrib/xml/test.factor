! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
IN: temporary
REQUIRES: contrib/xml/example ;
USING: kernel xml test io namespaces hashtables sequences
    errors parser xml-arith strings ;

! This is insufficient
SYMBOL: xml-file
[ ] [ "contrib/xml/test.xml" resource-path <file-reader>
    contents string>xml xml-file set ] unit-test
[ "1.0" ] [ xml-file get xml-doc-prolog prolog-version ] unit-test
[ f ] [ xml-file get xml-doc-prolog prolog-standalone ] unit-test
[ "a" ] [ xml-file get name-space ] unit-test
[ "http://www.hello.com" ] [ xml-file get name-url ] unit-test
[ T{ xml-string f { "that" } } ]
    [ T{ name f "" "this" "http://d.de" } xml-file get
    tag-props hash ] unit-test
[ t ] [ xml-file get tag-children second contained-tag? ] unit-test
[ t ] [ [ "<a></b>" string>xml ] catch xml-parse-error? ] unit-test
[ "<?xml version=\"1.0\" encoding=\"iso-8859-1\" standalone=\"no\"?><a b=\"c\"/>" ]
    [ "<a b='c'/>" xml-reprint ] unit-test
[ 32 ] [
    "<math><times><add><number>1</number><number>3</number></add><neg><number>-8</number></neg></times></math>"
    calc-arith
] unit-test
[ "abcd" ] [
    "<main>a<sub>bc</sub>d<nothing/></main>" string>xml
    [ [ dup string? [ % ] [ drop ] if ] xml-each ] "" make
] unit-test
