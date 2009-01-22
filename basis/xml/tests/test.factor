! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
IN: xml.tests
USING: kernel xml tools.test io namespaces make sequences
xml.errors xml.entities.html parser strings xml.data io.files
xml.utilities continuations assocs
sequences.deep accessors io.streams.string ;

! This is insufficient
\ read-xml must-infer
[ [ drop ] sax ] must-infer
\ string>xml must-infer

SYMBOL: xml-file
[ ] [ "resource:basis/xml/tests/test.xml"
    [ file>xml ] with-html-entities xml-file set ] unit-test
[ "1.0" ] [ xml-file get prolog>> version>> ] unit-test
[ f ] [ xml-file get prolog>> standalone>> ] unit-test
[ "a" ] [ xml-file get space>> ] unit-test
[ "http://www.hello.com" ] [ xml-file get url>> ] unit-test
[ "that" ] [
    xml-file get T{ name f "" "this" "http://d.de" } swap at
] unit-test
[ t ] [ xml-file get children>> second contained-tag? ] unit-test
[ "<a></b>" string>xml ] [ xml-parse-error? ] must-fail-with
[ T{ comment f "This is where the fun begins!" } ] [
    xml-file get before>> [ comment? ] find nip
] unit-test
[ "xsl stylesheet=\"that-one.xsl\"" ] [
    xml-file get after>> [ instruction? ] find nip text>>
] unit-test
[ V{ "fa&g" } ] [ xml-file get "x" get-id children>> ] unit-test
[ "that" ] [ xml-file get "this" swap at ] unit-test
[ "abcd" ] [
    "<main>a<sub>bc</sub>d<nothing/></main>" string>xml
    [ [ dup string? [ % ] [ drop ] if ] deep-each ] "" make
] unit-test
[ "abcd" ] [
    "<main>a<sub>bc</sub>d<nothing/></main>" string>xml
    [ string? ] deep-filter concat
] unit-test
[ "foo" ] [
    "<a><b id='c'>foo</b><d id='e'/></a>" string>xml
    "c" get-id children>string
] unit-test
[ "foo" ] [ "<x y='foo'/>" string>xml "y" over
    at swap "z" [ tuck ] dip swap set-at
    T{ name f "blah" "z" f } swap at ] unit-test
[ "foo" ] [ "<boo><![CDATA[foo]]></boo>" string>xml children>string ] unit-test
[ "<!-- B+, B, or B--->" string>xml ] must-fail
[ ] [ "<?xml version='1.0'?><!-- declarations for <head> & <body> --><foo/>" string>xml drop ] unit-test
[ T{ element-decl f "br" "EMPTY" } ] [ "<!ELEMENT br EMPTY>" string>xml-chunk first ] unit-test
[ T{ element-decl f "p" "(#PCDATA|emph)*" } ] [ "<!ELEMENT p (#PCDATA|emph)*>" string>xml-chunk first ] unit-test
[ T{ element-decl f "%name.para;" "%content.para;" } ] [ "<!ELEMENT %name.para; %content.para;>" string>xml-chunk first ] unit-test
[ T{ element-decl f "container" "ANY" } ] [ "<!ELEMENT container ANY>" string>xml-chunk first ] unit-test
[ T{ doctype-decl f "foo" } ] [ "<!DOCTYPE foo>" string>xml-chunk first ] unit-test
[ T{ doctype-decl f "foo" } ] [ "<!DOCTYPE foo >" string>xml-chunk first ] unit-test
[ T{ doctype-decl f "foo" T{ system-id f "blah.dtd" } } ] [ "<!DOCTYPE foo SYSTEM 'blah.dtd'>" string>xml-chunk first ] unit-test
[ T{ doctype-decl f "foo" T{ system-id f "blah.dtd" } } ] [ "<!DOCTYPE foo   SYSTEM \"blah.dtd\"   >" string>xml-chunk first ] unit-test
[ 958 ] [ [ "&xi;" string>xml-chunk ] with-html-entities first first ] unit-test
[ "x" "<" ] [ "<x value='&lt;'/>" string>xml [ name>> main>> ] [ "value" swap at ] bi ] unit-test
