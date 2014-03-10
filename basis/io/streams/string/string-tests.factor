USING: io.streams.string io kernel arrays namespaces make
tools.test ;
IN: io.streams.string.tests

[ "" ] [ "" [ contents ] with-string-reader ] unit-test

[ "line 1" CHAR: l ]
[
    "line 1\nline 2\nline 3" <string-reader>
    dup stream-readln swap stream-read1
]
unit-test

{ { "line 1" "line 2" "line 3" } } [
    "line 1\nline 2\nline 3" <string-reader> stream-lines
] unit-test

{ { "" "foo" "bar" "baz" } } [
    "\rfoo\r\nbar\rbaz\n" <string-reader> stream-lines
] unit-test

[ f ]
[ "" <string-reader> stream-readln ]
unit-test

[ "xyzzy" ] [ [ "xyzzy" write ] with-string-writer ] unit-test

[ "a" ] [ 1 "abc" <string-reader> stream-read ] unit-test
[ "ab" ] [ 2 "abc" <string-reader> stream-read ] unit-test
[ "abc" ] [ 3 "abc" <string-reader> stream-read ] unit-test
[ "abc" ] [ 4 "abc" <string-reader> stream-read ] unit-test
[ "abc" f ] [
    3 "abc" <string-reader> [ stream-read ] keep stream-read1
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
        ] with-input-stream
    ] { } make
] unit-test

{ "" CHAR: \r } [
    "\r\n" <string-reader> [ "\r" read-until ] with-input-stream
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

! Issue #70 github
[ f ] [ "" [ 0 read ] with-string-reader ] unit-test
[ f ] [ "" [ 1 read ] with-string-reader ] unit-test
[ f ] [ "" [ readln ] with-string-reader ] unit-test
[ "\"\"" ] [ "\"\"" [ readln ] with-string-reader ] unit-test
