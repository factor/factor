USING: io.streams.lines io.files io.streams.string io
tools.test kernel ;
IN: temporary

: <resource-reader> ( resource -- stream )
    resource-path <file-reader> ;
    
[ { } ]
[ "/core/io/test/empty-file.txt" <resource-reader> lines ]
unit-test

: lines-test ( stream -- line1 line2 )
    [ readln readln ] with-stream ;

[
    "This is a line."
    "This is another line."
] [
    "/core/io/test/windows-eol.txt" <resource-reader> lines-test
] unit-test

[
    "This is a line."
    "This is another line."
] [
    "/core/io/test/mac-os-eol.txt" <resource-reader> lines-test
] unit-test

[
    "This is a line."
    "This is another line."
] [
    "/core/io/test/unix-eol.txt" <resource-reader> lines-test
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
