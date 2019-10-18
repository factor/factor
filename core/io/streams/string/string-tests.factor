USING: io.streams.string io kernel arrays namespaces tools.test ;
IN: temporary

[ "line 1" CHAR: l ]
[
    "line 1\nline 2\nline 3" <string-reader>
    dup stream-readln swap stream-read1
]
unit-test

[ f ]
[ "" <string-reader> stream-readln ]
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
        "It seems Jobs has lost his grasp on reality again.\n"
        <string-reader> [
            "J" read-until 2array ,
            "i" read-until 2array ,
            "X" read-until 2array ,
        ] with-stream
    ] { } make
] unit-test

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
