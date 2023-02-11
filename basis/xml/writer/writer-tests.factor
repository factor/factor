! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: xml.data xml.writer tools.test fry xml xml.syntax kernel multiline
xml.writer.private io.streams.string xml.traversal sequences
io.encodings.utf8 io.files io.files.temp accessors io.directories math
math.parser ;
IN: xml.writer.tests

! Add a test for pprint-xml with sensitive-tags

{ "foo" } [ T{ name { main "foo" } } name>string ] unit-test
{ "foo" } [ T{ name { space "" } { main "foo" } } name>string ] unit-test
{ "ns:foo" } [ T{ name { space "ns" } { main "foo" } } name>string ] unit-test

: reprints-as ( to from -- )
    [ ] [ string>xml xml>string ] bi-curry* unit-test ;

: pprint-reprints-as ( to from -- )
    [ ] [ string>xml pprint-xml>string ] bi-curry* unit-test ;

: reprints-same ( string -- ) dup reprints-as ;

"<?xml version=\"1.0\" encoding=\"UTF-8\"?><x/>" reprints-same

"<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE foo [<!ENTITY foo \"bar\">]>
<x>bar</x>"
"<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE foo [<!ENTITY foo 'bar'>]>
<x>&foo;</x>" reprints-as

"<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE foo [
  <!ENTITY foo \"bar\">
  <!ELEMENT br EMPTY>
  <!ATTLIST list type    (bullets|ordered|glossary)  \"ordered\">
  <!NOTATION foo bar>
  <?baz bing bang bong?>
  <!--wtf-->
]>
<x>
  bar
</x>"
"<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE foo [ <!ENTITY foo 'bar'> <!ELEMENT br EMPTY>
<!ATTLIST list
          type    (bullets|ordered|glossary)  \"ordered\">
<!NOTATION 	foo bar> <?baz bing bang bong?>
      		<!--wtf-->
]>
<x>&foo;</x>" pprint-reprints-as

{ t } [ "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\" \"https://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">" dup string>xml-chunk xml>string = ] unit-test
{ "<?xml version=\"1.0\" encoding=\"UTF-8\"?><a b=\"c\"/>" }
    [ "<a b='c'/>" string>xml xml>string ] unit-test
{ "<?xml version=\"1.0\" encoding=\"UTF-8\"?><foo>bar baz</foo>" }
[ "<foo>bar</foo>" string>xml [ " baz" append ] map xml>string ] unit-test
{ "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<foo>\n  bar\n</foo>" }
[ "<foo>         bar            </foo>" string>xml pprint-xml>string ] unit-test
{ "<foo'>" } [ "<foo'>" <unescaped> xml>string ] unit-test
{ "<![CDATA[<&'\"]]>" } [ "<&'\"" <cdata> xml>string ] unit-test

: test-file ( -- path )
    "test.xml" temp-file ;

{ } [
    "<?xml version='1.0' encoding='UTF-16BE'?><x/>" string>xml test-file utf8 [ write-xml ] with-file-writer
] unit-test
{ "x" } [ test-file file>xml body>> name>> main>> ] unit-test
{ } [ test-file delete-file ] unit-test

{ } [
    { 1 2 3 4 } [
        [ number>string ] [ sq number>string ] bi
        [XML <tr><td><-></td><td><-></td></tr> XML]
    ] map [XML <h2>Timings</h2> <table><-></table> XML]
    pprint-xml
] unit-test

{ "<test name=\"bob\"/>" } [
    "test" { { "name" "bob" } } { } <tag> xml>string
] unit-test
