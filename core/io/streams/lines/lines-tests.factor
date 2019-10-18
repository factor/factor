USING: io.streams.lines io.files io.streams.string io
tools.test ;
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
