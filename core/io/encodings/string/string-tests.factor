USING: io.encodings.utf8 io.encodings.utf16 io.encodings.string tools.test ;
IN: io.encodings.string.tests

[ "hello" ] [ "hello" utf8 decode-string ] unit-test
[ "he" ] [ "\0h\0e" utf16be decode-string ] unit-test
