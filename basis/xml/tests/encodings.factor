USING: xml xml.data xml.traversal tools.test accessors kernel vocabs ;

"io.encodings.8-bit" require ! for latin encodings

{ "\u000131" } [ "vocab:xml/tests/latin5.xml" file>xml children>string ] unit-test
{ "\u0000e9" } [ "vocab:xml/tests/latin1.xml" file>xml children>string ] unit-test
{ "\u0000e9" } [ "vocab:xml/tests/spaces.xml" file>xml children>string ] unit-test
{ "\u0000e9" } [ "vocab:xml/tests/utf8.xml" file>xml children>string ] unit-test
{ "\u0000e9" } [ "vocab:xml/tests/utf16.xml" file>xml children>string ] unit-test
{ "\u0000e9" } [ "vocab:xml/tests/utf16be.xml" file>xml children>string ] unit-test
{ "\u0000e9" } [ "vocab:xml/tests/utf16le.xml" file>xml children>string ] unit-test
{ "\u0000e9" } [ "vocab:xml/tests/utf16be-bom.xml" file>xml children>string ] unit-test
{ "\u0000e9" } [ "vocab:xml/tests/utf16le-bom.xml" file>xml children>string ] unit-test
{ "\u0000e9" } [ "vocab:xml/tests/prologless.xml" file>xml children>string ] unit-test
{ "e" } [ "vocab:xml/tests/ascii.xml" file>xml children>string ] unit-test
{ "\u0000e9" "x" } [ "vocab:xml/tests/unitag.xml" file>xml [ name>> main>> ] [ children>string ] bi ] unit-test
