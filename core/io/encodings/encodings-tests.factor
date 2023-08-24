USING: accessors io io.encodings io.encodings.ascii
io.encodings.string io.encodings.utf8 io.files
io.streams.byte-array io.streams.string kernel namespaces
tools.test ;
IN: io.encodings.tests

{ { } }
[ "vocab:io/test/empty-file.txt" ascii file-lines ]
unit-test

: lines-test ( file encoding -- line1 line2 )
    [ readln readln ] with-file-reader ;

{
    "This is a line."
    "This is another line."
} [
    "vocab:io/test/windows-eol.txt"
    ascii lines-test
] unit-test

{
    "This is a line."
    "This is another line."
} [
    "vocab:io/test/mac-os-eol.txt"
    ascii lines-test
] unit-test

{
    "This is a line."
    "This is another line."
} [
    "vocab:io/test/unix-eol.txt"
    ascii lines-test
] unit-test

{
    "1234"
} [
    "Hello world\r\n1234" <string-reader>
    dup stream-readln drop
    4 swap stream-read
] unit-test

{
    "1234"
} [
    "Hello world\r\n1234" <string-reader>
    dup stream-readln drop
    4 swap stream-read-partial
] unit-test

{
    CHAR: 1
} [
    "Hello world\r\n1234" <string-reader>
    dup stream-readln drop
    stream-read1
] unit-test

{ utf8 ascii } [
    "foo" utf8 [
        input-stream get code>>
        ascii decode-input
        input-stream get code>>
    ] with-byte-reader
] unit-test

{ utf8 ascii } [
    utf8 [
        output-stream get code>>
        ascii encode-output
        output-stream get code>>
    ] with-byte-writer drop
] unit-test

! Bug 1177.
{
    "! lol"
    "! wat"
    13
} [
    "! lol\r\n! wat\r\n" utf8 encode
    utf8 [
        readln
        "\r\n" read-until
    ] with-byte-reader
] unit-test

{
    "! lol"
    "! wa"
    116
} [
    "! lol\r\n! wat\r\n" utf8 encode
    utf8 [
        readln
        "t" read-until
    ] with-byte-reader
] unit-test

! shouldn't be able to tell on (underlying) stream of a decoder
! because it's confusing when you read1 character and tell is
! greater than 1.
[
    "hello world" utf8 encode
    utf8 [ tell-input ] with-byte-reader
] must-fail
