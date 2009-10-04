USING: io.files io.streams.string io io.streams.byte-array
tools.test kernel io.encodings.ascii io.encodings.utf8
namespaces accessors io.encodings io.streams.limited ;
IN: io.streams.encodings.tests

[ { } ]
[ "vocab:io/test/empty-file.txt" ascii file-lines ]
unit-test

: lines-test ( file encoding -- line1 line2 )
    [ readln readln ] with-file-reader ;

[
    "This is a line."
    "This is another line."
] [
    "vocab:io/test/windows-eol.txt"
    ascii lines-test
] unit-test

[
    "This is a line."
    "This is another line."
] [
    "vocab:io/test/mac-os-eol.txt"
    ascii lines-test
] unit-test

[
    "This is a line."
    "This is another line."
] [
    "vocab:io/test/unix-eol.txt"
    ascii lines-test
] unit-test

[
    "1234"
] [
     "Hello world\r\n1234" <string-reader>
     dup stream-readln drop
     4 swap stream-read
] unit-test

[
    "1234"
] [
     "Hello world\r\n1234" <string-reader>
     dup stream-readln drop
     4 swap stream-read-partial
] unit-test

[
    CHAR: 1
] [
     "Hello world\r\n1234" <string-reader>
     dup stream-readln drop
     stream-read1
] unit-test

[ utf8 ascii ] [
    "foo" utf8 [
        input-stream get code>>
        ascii decode-input
        input-stream get code>>
    ] with-byte-reader
] unit-test

[ utf8 ascii ] [
    utf8 [
        output-stream get code>>
        ascii encode-output
        output-stream get code>>
    ] with-byte-writer drop
] unit-test
