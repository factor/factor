IN: temporary
USING: io kernel math parser strings test ;

[ 4 ] [
    "resource:/core/test/io/no-trailing-eol.factor" run-file
] unit-test

: <resource-reader> ( resource -- stream )
    resource-path <file-reader> ;

: lines-test ( stream -- line1 line2 )
    [ readln readln ] with-stream ;

[
    "This is a line."
    "This is another line."
] [
    "/core/test/io/windows-eol.txt" <resource-reader> lines-test
] unit-test

[
    "This is a line."
    "This is another line."
] [
    "/core/test/io/mac-os-eol.txt" <resource-reader> lines-test
] unit-test

[
    "This is a line."
    "This is another line."
] [
    "/core/test/io/unix-eol.txt" <resource-reader> lines-test
] unit-test

[
    "This is a line.\rThis is another line.\r"
] [
    "/core/test/io/mac-os-eol.txt" <resource-reader>
    [ 500 read ] with-stream
] unit-test

[
    255
] [
    "/core/test/io/binary.txt" <resource-reader>
    [ read1 ] with-stream >fixnum
] unit-test

! Make sure we use correct to_c_string form when writing
[ ] [ "\0" write ] unit-test

[ "" ] [ 0 read ] unit-test

! [ ] [ "123" write 9000 CHAR: x <string> write flush ] unit-test

[ "line 1" CHAR: l ]
[
    "line 1\nline 2\nline 3" <string-reader>
    dup stream-readln swap stream-read1
]
unit-test

[ f ]
[ "" <string-reader> stream-readln ]
unit-test

[ ] [ 10000 f set-timeout ] unit-test

[ "" ] [
    "/core/test/io/binary.txt" <resource-reader>
    [ 0.2 read ] with-stream
] unit-test

[ { } ]
[ "/core/test/io/empty-file.txt" <resource-reader> lines ]
unit-test

[ "xyzzy" ] [ [ "xyzzy" write ] string-out ] unit-test

[ { "" } ] [ "" string-lines ] unit-test
[ { "" "" } ] [ "\n" string-lines ] unit-test
[ { "" "" } ] [ "\r" string-lines ] unit-test
[ { "" "" } ] [ "\r\n" string-lines ] unit-test
[ { "hello" } ] [ "hello" string-lines ] unit-test
[ { "hello" "" } ] [ "hello\n" string-lines ] unit-test
[ { "hello" "" } ] [ "hello\r" string-lines ] unit-test
[ { "hello" "" } ] [ "hello\r\n" string-lines ] unit-test
[ { "hello" "hi" } ] [ "hello\nhi" string-lines ] unit-test
[ { "hello" "hi" } ] [ "hello\rhi" string-lines ] unit-test
[ { "hello" "hi" } ] [ "hello\r\nhi" string-lines ] unit-test
