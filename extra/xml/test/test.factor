! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
IN: temporary
USING: kernel xml tools.test io namespaces sequences xml.errors xml.entities
    parser strings xml.data io.files xml.writer xml.utilities state-parser 
    continuations assocs ;

! This is insufficient
SYMBOL: xml-file
[ ] [ "extra/xml/test/test.xml" resource-path
    [ file>xml ] with-html-entities xml-file set ] unit-test
[ "1.0" ] [ xml-file get xml-prolog prolog-version ] unit-test
[ f ] [ xml-file get xml-prolog prolog-standalone ] unit-test
[ "a" ] [ xml-file get name-space ] unit-test
[ "http://www.hello.com" ] [ xml-file get name-url ] unit-test
[ "that" ] [
    xml-file get T{ name f "" "this" "http://d.de" } swap at
] unit-test
[ t ] [ xml-file get tag-children second contained-tag? ] unit-test
[ t ] [ [ "<a></b>" string>xml ] catch xml-parse-error? ] unit-test
[ T{ comment f "This is where the fun begins!" } ] [
    xml-file get xml-before [ comment? ] find nip
] unit-test
[ "xsl stylesheet=\"that-one.xsl\"" ] [
    xml-file get xml-after [ instruction? ] find nip instruction-text
] unit-test
[ V{ "fa&g" } ] [ xml-file get "x" get-id tag-children ] unit-test
[ "that" ] [ xml-file get "this" swap at ] unit-test
[ "<?xml version=\"1.0\" encoding=\"iso-8859-1\"?><a b=\"c\"/>" ]
    [ "<a b='c'/>" string>xml xml>string ] unit-test
[ "abcd" ] [
    "<main>a<sub>bc</sub>d<nothing/></main>" string>xml
    [ [ dup string? [ % ] [ drop ] if ] xml-each ] "" make
] unit-test
[ "abcd" ] [
    "<main>a<sub>bc</sub>d<nothing/></main>" string>xml
    [ string? ] xml-subset concat
] unit-test
[ "foo" ] [
    "<a><b id='c'>foo</b><d id='e'/></a>" string>xml
    "c" get-id children>string
] unit-test
[ "foo" ] [ "<x y='foo'/>" string>xml "y" <name-tag> over
at swap "z" <name-tag> >r tuck r> swap set-at T{ name f "blah" "z" f } swap at ] unit-test
