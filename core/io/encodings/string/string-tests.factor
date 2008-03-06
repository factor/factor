USING: strings io.encodings.utf8 io.encodings.utf16
io.encodings.string tools.test ;
IN: io.encodings.string.tests

[ "hello" ] [ "hello" utf8 decode ] unit-test
[ "he" ] [ "\0h\0e" utf16be decode ] unit-test

[ "hello" ] [ "hello" utf8 encode >string ] unit-test
[ "\0h\0e" ] [ "he" utf16be encode >string ] unit-test
