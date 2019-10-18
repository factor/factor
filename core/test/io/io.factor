IN: temporary
USING: arrays io kernel math parser strings test words
namespaces errors ;

[ f ] [
    "resource:/core/test/io/no-trailing-eol.factor" run-file
    "foo" "temporary" lookup
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

[ "" ] [
    "/core/test/io/binary.txt" <resource-reader>
    [ 0.2 read ] with-stream
] unit-test

[ { } ]
[ "/core/test/io/empty-file.txt" <resource-reader> lines ]
unit-test

[ "xyzzy" ] [ [ "xyzzy" write ] string-out ] unit-test

[ "a" ] [ 1 SBUF" cba" stream-read ] unit-test
[ "ab" ] [ 2 SBUF" cba" stream-read ] unit-test
[ "abc" ] [ 3 SBUF" cba" stream-read ] unit-test
[ "abc" ] [ 4 SBUF" cba" stream-read ] unit-test
[ "abc" f ] [
    3 SBUF" cba" [ stream-read ] keep stream-read1
] unit-test

[
    {
        { "It seems " CHAR: J }
        { "obs has lost h" CHAR: i }
        { "s grasp on reality again.\n" f }
    }
] [
    [
        "/core/test/io/separator-test.txt" <resource-reader> [
            "J" read-until 2array ,
            "i" read-until 2array ,
            "X" read-until 2array ,
        ] with-stream
    ] { } make
] unit-test

[
    {
        { "It seems " CHAR: J }
        { "obs has lost h" CHAR: i }
        { "s grasp on reality again.\n" f }
    }
] [
    [
        "It seems Jobs has lost his grasp on reality again.\n"
        <string-reader> [
            "J" read-until 2array ,
            "i" read-until 2array ,
            "X" read-until 2array ,
        ] with-stream
    ] { } make
] unit-test

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

[ "hello" "hi" ] [
    "hello\nhi" <string-reader>
    dup stream-readln
    2 rot stream-read
] unit-test

[ "hello" "hi" ] [
    "hello\r\nhi" <string-reader>
    dup stream-readln
    2 rot stream-read
] unit-test

[ "hello" "hi" ] [
    "hello\rhi" <string-reader>
    dup stream-readln
    2 rot stream-read
] unit-test

[ ] [
    "factor.image" <resource-reader> [
        10 [ 65536 read drop ] times
    ] with-stream
] unit-test

! Test duplex stream close behavior
TUPLE: closing-stream closed? ;

C: closing-stream ;

M: closing-stream stream-close
    dup closing-stream-closed? [
        "Closing twice!" throw
    ] [
        t swap set-closing-stream-closed?
    ] if ;

TUPLE: unclosable-stream ;

M: unclosable-stream stream-close
    "Can't close me!" throw ;

[ ] [
    <closing-stream> <closing-stream> <duplex-stream>
    dup stream-close stream-close
] unit-test

[ t ] [
    <unclosable-stream> <closing-stream> [
        <duplex-stream>
        [ dup stream-close ] catch 2drop
    ] keep closing-stream-closed?
] unit-test

[ t ] [
    <closing-stream> [ <unclosable-stream>
        <duplex-stream>
        [ dup stream-close ] catch 2drop
    ] keep closing-stream-closed?
] unit-test
