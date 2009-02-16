USING: xml xml.data xml.traversal tools.test accessors kernel
io.encodings.8-bit ;

[ "\u000131" ] [ "resource:basis/xml/tests/latin5.xml" file>xml children>string ] unit-test
[ "\u0000e9" ] [ "resource:basis/xml/tests/latin1.xml" file>xml children>string ] unit-test
[ "\u0000e9" ] [ "resource:basis/xml/tests/spaces.xml" file>xml children>string ] unit-test
[ "\u0000e9" ] [ "resource:basis/xml/tests/utf8.xml" file>xml children>string ] unit-test
[ "\u0000e9" ] [ "resource:basis/xml/tests/utf16.xml" file>xml children>string ] unit-test
[ "\u0000e9" ] [ "resource:basis/xml/tests/utf16be.xml" file>xml children>string ] unit-test
[ "\u0000e9" ] [ "resource:basis/xml/tests/utf16le.xml" file>xml children>string ] unit-test
[ "\u0000e9" ] [ "resource:basis/xml/tests/utf16be-bom.xml" file>xml children>string ] unit-test
[ "\u0000e9" ] [ "resource:basis/xml/tests/utf16le-bom.xml" file>xml children>string ] unit-test
[ "\u0000e9" ] [ "resource:basis/xml/tests/prologless.xml" file>xml children>string ] unit-test
[ "e" ] [ "resource:basis/xml/tests/ascii.xml" file>xml children>string ] unit-test
[ "\u0000e9" "x" ] [ "resource:basis/xml/tests/unitag.xml" file>xml [ name>> main>> ] [ children>string ] bi ] unit-test
