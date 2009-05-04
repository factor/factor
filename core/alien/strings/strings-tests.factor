USING: alien.strings alien.c-types tools.test kernel libc
io.encodings.8-bit io.encodings.utf8 io.encodings.utf16
io.encodings.utf16n io.encodings.ascii alien io.encodings.string ;
IN: alien.strings.tests

[ "\u0000ff" ]
[ "\u0000ff" latin1 string>alien latin1 alien>string ]
unit-test

[ "hello world" ]
[ "hello world" latin1 string>alien latin1 alien>string ]
unit-test

[ "hello\u00abcdworld" ]
[ "hello\u00abcdworld" utf16le string>alien utf16le alien>string ]
unit-test

[ t ] [ f expired? ] unit-test

[ "hello world" ] [
    "hello world" ascii malloc-string
    dup ascii alien>string swap free
] unit-test

[ "hello world" ] [
    "hello world" utf16n malloc-string
    dup utf16n alien>string swap free
] unit-test

[ f ] [ f utf8 alien>string ] unit-test

[ "hello" ] [ "hello" utf16 encode utf16 decode ] unit-test

[ "hello" ] [ "hello" utf16 string>alien utf16 alien>string ] unit-test
