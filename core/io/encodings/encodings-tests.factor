USING: io.files io.streams.string io
tools.test kernel io.encodings.ascii ;
IN: io.streams.encodings.tests

[ { } ]
[ "resource:core/io/test/empty-file.txt" ascii <file-reader> lines ]
unit-test

: lines-test ( stream -- line1 line2 )
    [ readln readln ] with-input-stream ;

[
    "This is a line."
    "This is another line."
] [
    "resource:core/io/test/windows-eol.txt"
    ascii <file-reader> lines-test
] unit-test

[
    "This is a line."
    "This is another line."
] [
    "resource:core/io/test/mac-os-eol.txt"
    ascii <file-reader> lines-test
] unit-test

[
    "This is a line."
    "This is another line."
] [
    "resource:core/io/test/unix-eol.txt"
    ascii <file-reader> lines-test
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
