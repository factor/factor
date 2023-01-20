! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
IN: xml.tests
USING: kernel xml tools.test io namespaces make sequences
xml.errors xml.entities.html parser strings xml.data io.files
xml.traversal continuations assocs io.encodings.binary
sequences.deep accessors io.streams.string ;

! This is insufficient
[ [ drop ] each-element ] must-infer

SYMBOL: xml-file
{ } [
    "vocab:xml/tests/test.xml"
    [ file>xml ] with-html-entities xml-file set
] unit-test
{ t } [
    "vocab:xml/tests/test.xml" binary file-contents
    [ bytes>xml ] with-html-entities xml-file get =
] unit-test
{ "1.0" } [ xml-file get prolog>> version>> ] unit-test
{ f } [ xml-file get prolog>> standalone>> ] unit-test
{ "a" } [ xml-file get space>> ] unit-test
{ "http://www.hello.com" } [ xml-file get url>> ] unit-test
{ "that" } [
    xml-file get T{ name f "" "this" "http://d.de" } attr
] unit-test
{ t } [ xml-file get children>> second contained-tag? ] unit-test
[ "<a></b>" string>xml ] [ xml-error? ] must-fail-with
{ T{ comment f "This is where the fun begins!" } } [
    xml-file get before>> [ comment? ] find nip
] unit-test
{ "xsl stylesheet=\"that-one.xsl\"" } [
    xml-file get after>> [ instruction? ] find nip text>>
] unit-test
{ V{ "fa&g" } } [ xml-file get "x" get-id children>> ] unit-test
{ "that" } [ xml-file get "this" attr ] unit-test
{ "abcd" } [
    "<main>a<sub>bc</sub>d<nothing/></main>" string>xml
    [ [ dup string? [ % ] [ drop ] if ] deep-each ] "" make
] unit-test
{ "abcd" } [
    "<main>a<sub>bc</sub>d<nothing/></main>" string>xml
    [ string? ] deep-filter concat
] unit-test
{ "foo" } [
    "<a><b id='c'>foo</b><d id='e'/></a>" string>xml
    "c" get-id children>string
] unit-test
{ "foo" } [
    "<x y='foo'/>" string>xml
    dup dup "y" attr "z" set-attr
    T{ name { space "blah" } { main "z" } } attr
] unit-test
[ "<!-- B+, B, or B--->" string>xml ] must-fail
{ } [ "<?xml version='1.0'?><!-- declarations for <head> & <body> --><foo/>" string>xml drop ] unit-test

: first-thing ( seq -- elt )
    "" swap remove first ;

{ T{ element-decl f "br" "EMPTY" } } [ "<!ELEMENT br EMPTY>" string>dtd directives>> first-thing ] unit-test
{ T{ element-decl f "p" "(#PCDATA|emph)*" } } [ "<!ELEMENT p (#PCDATA|emph)*>" string>dtd directives>> first-thing ] unit-test
{ T{ element-decl f "%name.para;" "%content.para;" } } [ "<!ELEMENT %name.para; %content.para;>" string>dtd directives>> first-thing ] unit-test
{ T{ element-decl f "container" "ANY" } } [ "<!ELEMENT container ANY>" string>dtd directives>> first-thing ] unit-test
{ T{ doctype-decl f "foo" } } [ "<!DOCTYPE foo>" string>xml-chunk first-thing ] unit-test
{ T{ doctype-decl f "foo" } } [ "<!DOCTYPE foo >" string>xml-chunk first-thing ] unit-test
{ T{ doctype-decl f "foo" T{ system-id f "blah.dtd" } } } [ "<!DOCTYPE foo SYSTEM 'blah.dtd'>" string>xml-chunk first-thing ] unit-test
{ T{ doctype-decl f "foo" T{ system-id f "blah.dtd" } } } [ "<!DOCTYPE foo   SYSTEM \"blah.dtd\"   >" string>xml-chunk first-thing ] unit-test
{ 958 } [ [ "&xi;" string>xml-chunk ] with-html-entities first first ] unit-test
{ "x" "<" } [ "<x value='&lt;'/>" string>xml [ name>> main>> ] [ "value" attr ] bi ] unit-test
{ "foo" } [ "<!DOCTYPE foo [<!ENTITY bar 'foo'>]><x>&bar;</x>" string>xml children>string ] unit-test
{ T{ xml-chunk f V{ "hello" } } } [ "hello" string>xml-chunk ] unit-test
{ "1.1" } [ "<?xml version='1.1'?><x/>" string>xml prolog>> version>> ] unit-test
{ "ß" } [ "<x>ß</x>" <string-reader> read-xml children>string ] unit-test

! <pull-xml> tests
! this tests just checks that pull-event doesn't raise an exception
{ } [ "vocab:xml/tests/test.xml" binary [ <pull-xml> pull-event drop ] with-file-reader ] unit-test
